import { IconButton, useMediaQuery, useTheme } from "@mui/material";
import { useAtom, useAtomValue, useSetAtom } from "jotai";
import { useCallback, type FC } from "react";

import ARModal from "../../../shared/view/ui-container/ARModal";
import ShareModal from "../../../shared/view/ui-container/ShareModal";
import { AppBar, AppIconButton, ARIcon, PaperPlaneTilt, Space } from "../../ui-components";
import { hideAppOverlayAtom, showARModalAtom, showShareModalAtom } from "../states/app";

import { CameraButtons } from "./CameraButtons";
import { DateControlButton } from "./DateControlButton";
import { EnvironmentSelect } from "./EnvironmentSelect";
import { LocationBreadcrumbs } from "./LocationBreadcrumbs";
import { MainMenuButton } from "./MainMenuButton";
import { SettingsButton } from "./SettingsButton";
import { StoryButton } from "./StoryButton";
import { ToolButtons } from "./ToolButtons";

type Props = {
  arURL?: string;
};

export const AppHeader: FC<Props> = ({ arURL }) => {
  const hidden = useAtomValue(hideAppOverlayAtom);
  const [showShareModal, setShowShareModal] = useAtom(showShareModalAtom);
  const setShowARModel = useSetAtom(showARModalAtom);
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down("mobile"));

  const handleARButtonClick = useCallback(() => {
    setShowARModel(true);
  }, [setShowARModel]);

  if (hidden) {
    return null;
  }

  return (
    <AppBar>
      <MainMenuButton />
      {!isMobile && (
        <>
          <Space size={2} />
          <ToolButtons />
        </>
      )}
      <Space flexible={isMobile} />
      <SettingsButton />
      <DateControlButton />
      <EnvironmentSelect />
      <StoryButton />
      <AppIconButton title="シェア" onClick={() => setShowShareModal(true)}>
        <PaperPlaneTilt />
      </AppIconButton>
      {isMobile && (
        <IconButton onClick={handleARButtonClick}>
          <ARIcon />
        </IconButton>
      )}
      <ARModal arURL={arURL} />
      {showShareModal && (
        <ShareModal showShareModal={showShareModal} setShowShareModal={setShowShareModal} />
      )}
      {!isMobile && (
        <>
          <Space flexible />
          <LocationBreadcrumbs />
          <Space flexible />
        </>
      )}
      {!isMobile && <CameraButtons />}
    </AppBar>
  );
};
