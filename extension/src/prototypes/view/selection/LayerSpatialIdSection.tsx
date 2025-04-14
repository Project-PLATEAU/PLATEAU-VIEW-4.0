import { Divider, styled } from "@mui/material";
import { atom, useAtom, useAtomValue } from "jotai";
import { FC, useEffect, useMemo } from "react";
import ReactJson from "react-json-view";

import useCityGMLFiles from "../../../shared/api/citygml/hooks/useCityGMLFiles";
import useCityGMLSpaceAttributes from "../../../shared/api/citygml/hooks/useCityGMLSpaceAttributes";
import { DEFAULT_PLATEAU_SPEC_VERSION } from "../../../shared/constants";
import { LoadingAnimationIcon } from "../../../shared/ui-components/LoadingAnimationIcon";
import { LayerModel } from "../../layers";
import {
  InspectorItem,
  ParameterList,
  PropertyParameterItem,
  SelectParameterItem,
} from "../../ui-components";
import { SPATIAL_ID_LAYER } from "../../view-layers";

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

export interface LayerSpatialIdSectionProps {
  layers: readonly LayerModel[];
}

export const LayerSpatialIdSection: FC<LayerSpatialIdSectionProps> = ({ layers }) => {
  const spatialIdLayers = useMemo(
    () =>
      layers.filter(
        (layer): layer is LayerModel<typeof SPATIAL_ID_LAYER> => layer.type === SPATIAL_ID_LAYER,
      ),
    [layers],
  );

  const features = useAtomValue(
    useMemo(
      () => atom(get => spatialIdLayers.flatMap(layer => get(layer.featuresAtom))),
      [spatialIdLayers],
    ),
  );

  const spaceZFXYStrs = useMemo(() => features.map(feature => feature.data.zfxyStr), [features]);

  const { featureTypes } = useCityGMLFiles({
    spaceZFXYStrs,
  });

  const featureTypeOptions: string[][] | undefined = useMemo(() => {
    return featureTypes?.map(type => [type.value, type.name]);
  }, [featureTypes]);

  const [currentType, setCurrentType] = useAtom(featureTypeAtom);

  const types = useMemo(() => [currentType], [currentType]);

  const { attributes, loading } = useCityGMLSpaceAttributes({
    spaceZFXYStrs,
    featureTypes: types,
  });

  useEffect(() => {
    setCurrentType(featureTypes?.[0]?.value ?? null);
  }, [featureTypes, setCurrentType]);

  const spaceIdProperties = useMemo(() => {
    if (!features || features.length === 0) return [];
    return [
      {
        id: "spaceId",
        name: "タイルハッシュ",
        values: features.map(feature => feature.data.id),
      },
    ];
  }, [features]);

  const spaceIdZFXYProperties = useMemo(() => {
    if (!features || features.length === 0) return [];
    return [
      {
        id: "spaceIdZoomZFXY",
        name: "z/f/x/y",
        values: features.map(feature =>
          feature.data.zfxyStr?.startsWith("/")
            ? feature.data.zfxyStr.slice(1)
            : feature.data.zfxyStr,
        ),
      },
    ];
  }, [features]);

  if (spatialIdLayers.length === 0) {
    return null;
  }
  return (
    <ParameterList>
      <Divider />
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
  );
};
