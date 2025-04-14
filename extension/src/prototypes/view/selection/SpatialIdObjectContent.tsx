import { Divider, IconButton, List, styled, Tooltip } from "@mui/material";
import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";
import { uniq } from "lodash";
import { FC, useCallback, useEffect, useMemo } from "react";
import ReactJson from "react-json-view";

import useCityGMLFiles from "../../../shared/api/citygml/hooks/useCityGMLFiles";
import useCityGMLSpaceAttributes from "../../../shared/api/citygml/hooks/useCityGMLSpaceAttributes";
import { DEFAULT_PLATEAU_SPEC_VERSION } from "../../../shared/constants";
import { useOptionalAtomValue } from "../../../shared/hooks";
import { SPATIAL_ID_OBJECT } from "../../../shared/spatialId";
import { LoadingAnimationIcon } from "../../../shared/ui-components/LoadingAnimationIcon";
import { parseIdentifier } from "../../cesium-helpers";
import { layerSelectionAtom } from "../../layers";
import { screenSpaceSelectionAtom } from "../../screen-space-selection";
import { isNotNullish } from "../../type-helpers";
import {
  InspectorHeader,
  InspectorItem,
  LayerIcon,
  ParameterList,
  PropertyParameterItem,
  SelectParameterItem,
  TrashIcon,
} from "../../ui-components";
import { SpatialIdIcon } from "../../ui-components/icons/SpatialIdIcon";
import { highlightedSpatialIdLayersAtom, SPATIAL_ID_LAYER } from "../../view-layers";
import { SCREEN_SPACE_SELECTION, SelectionGroup } from "../states/selection";

const featureTypeAtom = atom<string | null>(null);

const JSONWrapper = styled("div")(({ theme }) => ({
  padding: theme.spacing(0, 2, 2, 2),
}));

const LoadingWrapper = styled("div")(({ theme }) => ({
  display: "flex",
  justifyContent: "center",
  padding: theme.spacing(0, 2, 2, 2),
}));

const Tips = styled("div")(({ theme }) => ({
  padding: theme.spacing(0, 2, 2, 2),
  color: theme.palette.text.secondary,
  fontSize: theme.typography.body2.fontSize,
  display: "flex",
  justifyContent: "center",
}));
export interface SpatialIdObjectContentProps {
  values: (SelectionGroup & {
    type: typeof SCREEN_SPACE_SELECTION;
    subtype: typeof SPATIAL_ID_OBJECT;
  })["values"];
}

export const SpatialIdObjectContent: FC<SpatialIdObjectContentProps> = ({ values }) => {
  const setSelection = useSetAtom(screenSpaceSelectionAtom);
  const handleClose = useCallback(() => {
    setSelection([]);
  }, [setSelection]);

  const spatialIdLayers = useAtomValue(highlightedSpatialIdLayersAtom);
  const setLayerSelection = useSetAtom(layerSelectionAtom);
  const handleSelectLayers = useCallback(() => {
    setLayerSelection(spatialIdLayers.map(layer => ({ id: layer.id, type: SPATIAL_ID_LAYER })));
  }, [spatialIdLayers, setLayerSelection]);

  const removeFeatures = useSetAtom(
    useMemo(
      () =>
        atom(null, (get, set, featureIds: readonly string[]) => {
          spatialIdLayers.forEach(spatialIdLayer => {
            const featureAtoms = get(spatialIdLayer.featureAtomsAtom);
            featureIds.forEach(featureId => {
              const featureAtom = featureAtoms.find(
                featureAtom => get(featureAtom).id === featureId,
              );
              if (featureAtom != null) {
                set(spatialIdLayer.featureAtomsAtom, {
                  type: "remove",
                  atom: featureAtom,
                });
              }
            });
          });
        }),
      [spatialIdLayers],
    ),
  );
  const handleRemove = useCallback(() => {
    const featureIds = uniq(values.map(value => parseIdentifier(value).key).filter(isNotNullish));
    removeFeatures(featureIds);
    setSelection([]);
  }, [values, removeFeatures, setSelection]);

  const features = useOptionalAtomValue(spatialIdLayers[0]?.featuresAtom);

  const spaceIdProperties = useMemo(() => {
    const feature = features?.find(feature => parseIdentifier(values[0]).key === feature.id);
    if (!feature) return [];
    return [
      {
        id: "spaceId",
        name: "タイルハッシュ",
        values: [feature.data.id],
      },
    ];
  }, [features, values]);

  const spaceIdZFXYProperties = useMemo(() => {
    const feature = features?.find(feature => parseIdentifier(values[0]).key === feature.id);
    if (!feature) return [];
    const zfxy = feature.data.zfxyStr?.startsWith("/")
      ? feature.data.zfxyStr.slice(1)
      : feature.data.zfxyStr;
    return [
      {
        id: "spaceIdZFXY",
        name: "z/f/x/y",
        values: [zfxy],
      },
    ];
  }, [features, values]);

  const spaceZFXYStrs = useMemo(() => {
    const feature = features?.find(feature => parseIdentifier(values[0]).key === feature.id);
    if (!feature) return [];
    return [feature.data.zfxyStr];
  }, [features, values]);

  const { featureTypes } = useCityGMLFiles({
    spaceZFXYStrs,
  });

  const featureTypeOptions: string[][] | undefined = useMemo(() => {
    return featureTypes?.map(type => [type.value, type.name]);
  }, [featureTypes]);

  const [currentType, setCurrentType] = useAtom(featureTypeAtom);

  useEffect(() => {
    setCurrentType(featureTypes?.[0]?.value ?? null);
  }, [featureTypes, setCurrentType]);

  const types = useMemo(() => [currentType], [currentType]);

  const { attributes, loading } = useCityGMLSpaceAttributes({
    spaceZFXYStrs,
    featureTypes: types,
  });

  return (
    <List disablePadding>
      <InspectorHeader
        title={`${values.length}個の空間ID`}
        iconComponent={SpatialIdIcon}
        actions={
          <>
            <Tooltip title="レイヤーを選択">
              <IconButton aria-label="レイヤーを選択" onClick={handleSelectLayers}>
                <LayerIcon />
              </IconButton>
            </Tooltip>
            <Tooltip title="削除">
              <IconButton aria-label="削除" onClick={handleRemove}>
                <TrashIcon />
              </IconButton>
            </Tooltip>
          </>
        }
        onClose={handleClose}
      />
      <Divider />
      <ParameterList>
        <PropertyParameterItem
          properties={spaceIdProperties}
          featureType="tags"
          version={DEFAULT_PLATEAU_SPEC_VERSION}
        />
        <Divider />
        <PropertyParameterItem
          properties={spaceIdZFXYProperties}
          featureType="tags"
          version={DEFAULT_PLATEAU_SPEC_VERSION}
        />
        {featureTypeOptions && featureTypeOptions.length > 0 && currentType && (
          <>
            <Divider />
            <InspectorItem>
              <SelectParameterItem
                label="地物タイプ"
                atom={featureTypeAtom}
                items={featureTypeOptions as [string, string][]}
                layout="stack"
              />
            </InspectorItem>
            {loading ? (
              <LoadingWrapper>
                <LoadingAnimationIcon size={16} />
              </LoadingWrapper>
            ) : attributes && attributes.length > 0 ? (
              <JSONWrapper>
                <ReactJson
                  src={attributes}
                  displayDataTypes={false}
                  enableClipboard={false}
                  displayObjectSize={false}
                  quotesOnKeys={false}
                  indentWidth={2}
                  collapsed={true}
                  style={{ wordBreak: "break-all", lineHeight: 1.2 }}
                />
              </JSONWrapper>
            ) : attributes === null ? (
              <Tips>データが見つかりません</Tips>
            ) : null}
          </>
        )}
      </ParameterList>
    </List>
  );
};
