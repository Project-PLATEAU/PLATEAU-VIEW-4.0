import { Divider, IconButton, List, Tooltip } from "@mui/material";
import { atom, useAtomValue, useSetAtom, type SetStateAction } from "jotai";
import { merge, uniq } from "lodash";
import { useCallback, useMemo, type FC } from "react";

import { matchIdentifier, parseIdentifier } from "../../cesium-helpers";
import { layerSelectionAtom } from "../../layers";
import { screenSpaceSelectionAtom } from "../../screen-space-selection";
import { SKETCH_OBJECT } from "../../sketch";
import { isNotNullish } from "../../type-helpers";
import {
  InspectorHeader,
  InspectorItem,
  LayerIcon,
  NumberParameterItem,
  ParameterList,
  SketchIcon,
  TrashIcon,
} from "../../ui-components";
import { SKETCH_LAYER, highlightedSketchLayersAtom } from "../../view-layers";
import { type SCREEN_SPACE_SELECTION, type SelectionGroup } from "../states/selection";

export interface SketchObjectContentProps {
  values: (SelectionGroup & {
    type: typeof SCREEN_SPACE_SELECTION;
    subtype: typeof SKETCH_OBJECT;
  })["values"];
}

export const SketchObjectContent: FC<SketchObjectContentProps> = ({ values }) => {
  const setSelection = useSetAtom(screenSpaceSelectionAtom);
  const handleClose = useCallback(() => {
    setSelection([]);
  }, [setSelection]);

  const sketchLayers = useAtomValue(highlightedSketchLayersAtom);
  const setLayerSelection = useSetAtom(layerSelectionAtom);
  const handleSelectLayers = useCallback(() => {
    setLayerSelection(sketchLayers.map(layer => ({ id: layer.id, type: SKETCH_LAYER })));
  }, [sketchLayers, setLayerSelection]);

  const removeFeatures = useSetAtom(
    useMemo(
      () =>
        atom(null, (get, set, featureIds: readonly string[]) => {
          sketchLayers.forEach(sketchLayer => {
            const featureAtoms = get(sketchLayer.featureAtomsAtom);
            featureIds.forEach(featureId => {
              const featureAtom = featureAtoms.find(
                featureAtom => get(featureAtom).properties.id === featureId,
              );
              if (featureAtom != null) {
                set(sketchLayer.featureAtomsAtom, {
                  type: "remove",
                  atom: featureAtom,
                });
              }
            });
          });
        }),
      [sketchLayers],
    ),
  );
  const handleRemove = useCallback(() => {
    const featureIds = uniq(values.map(value => parseIdentifier(value).key).filter(isNotNullish));
    removeFeatures(featureIds);
    setSelection([]);
  }, [values, removeFeatures, setSelection]);

  const extrudedHeightAtoms = useAtomValue(
    useMemo(
      () =>
        atom(get => {
          return sketchLayers
            .flatMap(sketchLayer => {
              const featureAtoms = get(sketchLayer.featureAtomsAtom);
              return values.map(value => {
                const featureAtom = featureAtoms.find(featureAtom =>
                  matchIdentifier(value, {
                    type: "Sketch",
                    subtype: SKETCH_OBJECT,
                    key: get(featureAtom).properties.id,
                  }),
                );
                return featureAtom != null
                  ? atom(
                      get => get(featureAtom).properties.extrudedHeight ?? 0,
                      (get, set, value: SetStateAction<number>) => {
                        const feature = get(featureAtom);
                        const prevValue = feature.properties.extrudedHeight ?? 0;
                        const nextValue = typeof value === "function" ? value(prevValue) : value;
                        set(
                          featureAtom,
                          merge(feature, {
                            properties: {
                              extrudedHeight: nextValue,
                            },
                          }),
                        );
                      },
                    )
                  : undefined;
              });
            })
            .filter(isNotNullish);
        }),
      [values, sketchLayers],
    ),
  );

  return (
    <List disablePadding>
      <InspectorHeader
        title={`${values.length}個の作図`}
        iconComponent={SketchIcon}
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
      <InspectorItem>
        <ParameterList>
          <NumberParameterItem label="高さ" atom={extrudedHeightAtoms} unit="m" />
        </ParameterList>
      </InspectorItem>
    </List>
  );
};
