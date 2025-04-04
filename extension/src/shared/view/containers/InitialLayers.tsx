import { useMediaQuery, useTheme } from "@mui/material";
import { useAtom, useAtomValue, useSetAtom } from "jotai";
import { cloneDeep } from "lodash-es";
import { useEffect, type FC, useMemo, useRef, useState } from "react";
import format from "string-template";

import { LayerType, useAddLayer } from "../../../prototypes/layers";
import { isNotNullish } from "../../../prototypes/type-helpers";
import {
  censusDatasetMeshCodes,
  censusDatasets,
} from "../../../prototypes/view/constants/censusDatasets";
import { readyAtom } from "../../../prototypes/view/states/app";
import {
  HEATMAP_LAYER,
  MESH_CODE_LAYER,
  MY_DATA_LAYER,
  PEDESTRIAN_LAYER,
  SKETCH_LAYER,
  SPATIAL_ID_LAYER,
  STORY_LAYER,
} from "../../../prototypes/view-layers";
import { useDatasetsByIds } from "../../graphql";
import { Data, SketchFeature } from "../../reearth/types";
import { getShareId, getSharedStoreValue } from "../../sharedAtoms";
import {
  useInitialPedestrianCoordinates,
  useIsCityProject,
} from "../../states/environmentVariables";
import { settingForCityIdsAtom, settingsAtom } from "../../states/setting";
import {
  SHARED_PROJECT_ID_KEY,
  SharedRootLayer,
  getSharedRootLayersAtom,
} from "../../states/share";
import { templatesAtom } from "../../states/template";
import { StoryCapture } from "../../view-layers";
import {
  RootLayerForLayerAtomParams,
  createRootLayerForDatasetAtom,
  createRootLayerForLayerAtom,
} from "../../view-layers/rootLayer";
import { isAppReadyAtom, isLayerInitializedAtom } from "../state/app";

type InitialHeatmapLayerParams = {
  type: string;
  id: string;
  datasetId: string;
  dataId: string;
  title: string;
  getUrl: (code: string) => string;
  codes: string[];
  parserOptions: {
    codeColumn: number;
    valueColumn: number;
    skipHeader: number;
  };
  hidden?: boolean;
};

type InitialPedestrianLayerParams = {
  type: string;
  id: string;
  hidden?: boolean;
};

type InitialMyDataLayerParams = {
  type: string;
  id: string;
  title: string;
  url?: string;
  format?: string;
  layers?: string[];
  csv?: Data["csv"];
  hidden?: boolean;
};

type InitialSketchLayerParams = {
  type: string;
  id: string;
  title: string;
  features: SketchFeature[];
  hidden?: boolean;
};

type InitialStoryLayerParams = {
  type: string;
  id: string;
  title: string;
  captures: StoryCapture[];
  hidden?: boolean;
};

type InitialLayerParams = (
  | RootLayerForLayerAtomParams<LayerType>
  | InitialHeatmapLayerParams
  | InitialPedestrianLayerParams
  | InitialSketchLayerParams
  | InitialMyDataLayerParams
  | InitialStoryLayerParams
)[];

export const InitialLayers: FC = () => {
  const addLayer = useAddLayer();

  const [initialPedestrianCoordinates] = useInitialPedestrianCoordinates();

  const shareId = getShareId();
  const getSharedRootLayers = useSetAtom(getSharedRootLayersAtom);
  const [sharedRootLayers, setSharedRootLayers] = useState<SharedRootLayer[] | undefined>();
  const [isSharedDataLoaded, setIsSharedDataLoaded] = useState(false);
  const isAppReady = useAtomValue(isAppReadyAtom);
  const [isLayerInitialized, setIsLayerInitialized] = useAtom(isLayerInitializedAtom);

  useEffect(() => {
    const run = async () => {
      if (!isAppReady) return;
      const layers = await getSharedRootLayers();
      setSharedRootLayers(layers);
      setIsSharedDataLoaded(true);
    };
    if (shareId) {
      run();
    } else {
      setIsSharedDataLoaded(true);
    }
  }, [getSharedRootLayers, shareId, isAppReady]);

  const settings = useAtomValue(settingsAtom);
  const settingForCityIds = useAtomValue(settingForCityIdsAtom);
  const templates = useAtomValue(templatesAtom);

  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down("mobile"));

  const defaultLayerParams: RootLayerForLayerAtomParams<LayerType>[] = useMemo(() => {
    if (isMobile) {
      return [];
    } else {
      return [
        {
          type: PEDESTRIAN_LAYER,
          location: {
            longitude: initialPedestrianCoordinates?.lng ?? 139.769,
            latitude: initialPedestrianCoordinates?.lat ?? 35.68,
          },
        },
      ];
    }
  }, [isMobile, initialPedestrianCoordinates]);

  const [isCityProject] = useIsCityProject();

  const defaultBuildings = useMemo(
    () =>
      (isCityProject ? settings.filter(s => settingForCityIds.includes(s.id)) : settings)
        .filter(s => !!s.general?.initialLayer?.isInitialLayer)
        .map(s => ({
          datasetId: s.datasetId,
          dataId: s.dataId,
        })),
    [settings, isCityProject, settingForCityIds],
  );

  const isSharedDataset = useMemo(
    () => shareId && isSharedDataLoaded,
    [shareId, isSharedDataLoaded],
  );

  const datasetIds = useMemo(
    () =>
      isSharedDataset
        ? sharedRootLayers
            ?.filter(
              (l): l is Extract<SharedRootLayer, { type: "dataset" }> => l.type === "dataset",
            )
            .map(({ datasetId }) => datasetId) ?? []
        : [...new Set(defaultBuildings.map(b => b.datasetId))],
    [sharedRootLayers, isSharedDataset, defaultBuildings],
  );

  const query = useDatasetsByIds(datasetIds, {
    skip: !!shareId && !isSharedDataLoaded && !sharedRootLayers?.length,
  });

  const initialDatasets = useMemo(() => query.data?.nodes?.filter(isNotNullish) ?? [], [query]);

  const initialLayers: InitialLayerParams = useMemo(() => {
    if (!sharedRootLayers?.length) return defaultLayerParams;
    return sharedRootLayers
      .map(l => {
        switch (l.type) {
          case "heatmap": {
            const dataset = censusDatasets.find(d => d.id === l.datasetId);
            const data = dataset?.data.find(d => d.id === l.dataId);
            if (!dataset || !data) return;
            return {
              id: l.id,
              type: HEATMAP_LAYER,
              datasetId: l.datasetId,
              dataId: l.dataId,
              title: data.name,
              getUrl: (code: string) => format(dataset.urlTemplate, { code }),
              codes: censusDatasetMeshCodes,
              parserOptions: {
                codeColumn: 0,
                valueColumn: data.column,
                skipHeader: 2,
              },
              hidden: l.hidden,
            };
          }
          case "pedestrian":
            return {
              id: l.id,
              type: PEDESTRIAN_LAYER,
              hidden: l.hidden,
            };
          case "myData":
            return {
              title: l.title ?? "",
              format: l?.format,
              type: MY_DATA_LAYER,
              url: l?.url,
              id: l?.id,
              csv: l?.csv,
              layers: l?.layers,
              hidden: l.hidden,
            };
          case "sketch":
            return {
              id: l.id,
              title: l.title,
              type: SKETCH_LAYER,
              features: l.features,
              hidden: l.hidden,
            };
          case "spatialId":
            return {
              id: l.id,
              title: l.title,
              type: SPATIAL_ID_LAYER,
              features: l.features,
              hidden: l.hidden,
            };
          case "meshCode":
            return {
              id: l.id,
              title: l.title,
              type: MESH_CODE_LAYER,
              meshCodeLevel: l.meshCodeLevel,
              features: l.features,
              hidden: l.hidden,
            };
          case "story":
            return {
              id: l.id,
              title: l.title,
              type: STORY_LAYER,
              captures: l.captures,
              hidden: l.hidden,
            };
        }
      })
      .filter(isNotNullish);
  }, [sharedRootLayers, defaultLayerParams]);

  const setReady = useSetAtom(readyAtom);

  const settingsRef = useRef(settings);
  settingsRef.current = settings;

  const templatesRef = useRef(templates);
  templatesRef.current = templates;
  useEffect(() => {
    if (query.loading || !isSharedDataLoaded || !isAppReady || isLayerInitialized) return;

    const initialize = async () => {
      const sharedProjectIdUnknown =
        (await getSharedStoreValue(SHARED_PROJECT_ID_KEY)) ?? undefined;
      const sharedProjectId =
        typeof sharedProjectIdUnknown === "string" ? sharedProjectIdUnknown : undefined;

      if (!sharedRootLayers?.length) {
        initialLayers?.forEach(l =>
          addLayer(
            createRootLayerForLayerAtom({
              ...l,
              shareId: sharedProjectId,
            } as RootLayerForLayerAtomParams<LayerType>),
            {
              autoSelect: false,
            },
          ),
        );
        cloneDeep(initialDatasets)
          .reverse()
          .forEach(d => {
            addLayer(
              createRootLayerForDatasetAtom({
                dataset: d,
                areaCode: d.wardCode || d.cityCode || d.prefectureCode,
                settings: settingsRef.current.filter(s => s.datasetId === d.id),
                templates: templatesRef.current,
                shareId: sharedProjectId,
                currentDataId: defaultBuildings.find(b => b.datasetId === d.id)?.dataId,
              }),
              { autoSelect: false },
            );
          });
      } else {
        // add layer with shared root layers' reverse order
        sharedRootLayers.reverse().forEach(sharedRootLayer => {
          if (sharedRootLayer.type === "dataset") {
            const d = initialDatasets.find(
              initialDataset => initialDataset.id === sharedRootLayer.datasetId,
            );
            if (d) {
              addLayer(
                createRootLayerForDatasetAtom({
                  dataset: d,
                  areaCode: d.wardCode || d.cityCode || d.prefectureCode,
                  settings: settingsRef.current.filter(s => s.datasetId === d.id),
                  templates: templatesRef.current,
                  shareId: sharedProjectId,
                  currentDataId: sharedProjectId
                    ? sharedRootLayer.dataId
                    : defaultBuildings.find(b => b.datasetId === d.id)?.dataId,
                  currentGroupId: sharedRootLayer.groupId,
                  hidden: sharedRootLayer.hidden,
                }),
                { autoSelect: false },
              );
            }
          } else {
            const l = initialLayers.find(initialLayer => initialLayer.id === sharedRootLayer.id);
            if (l) {
              addLayer(
                createRootLayerForLayerAtom({
                  ...l,
                  shareId: sharedProjectId,
                } as RootLayerForLayerAtomParams<LayerType>),
                {
                  autoSelect: false,
                },
              );
            }
          }
        });
      }

      setReady(true);
    };
    initialize();
    setIsLayerInitialized(true);
  }, [
    addLayer,
    initialDatasets,
    shareId,
    query.loading,
    setReady,
    defaultBuildings,
    initialLayers,
    isSharedDataLoaded,
    isAppReady,
    sharedRootLayers,
    isLayerInitialized,
    setIsLayerInitialized,
  ]);

  return null;
};
