import {
  Divider,
  FilterOptionsState,
  styled,
  Tab,
  tabClasses,
  Tabs,
  useMediaQuery,
  useTheme,
} from "@mui/material";
import { useAtomValue } from "jotai";
import {
  useCallback,
  useContext,
  useDeferredValue,
  useMemo,
  useRef,
  useState,
  type FC,
  type MouseEvent,
  type ReactNode,
  MutableRefObject,
} from "react";

import { getCesiumCanvas } from "../../../shared/reearth/utils";
import { useCityName } from "../../../shared/states/environmentVariables";
import { ViewClickAwayListener } from "../../../shared/ui-components/common/ViewClickAwayListener";
import { useWindowEvent } from "../../react-helpers";
import { platformAtom } from "../../shared-states";
import {
  AppOverlayLayoutContext,
  FloatingPanel,
  Scrollable,
  SearchAutocomplete,
  SearchAutocompleteProps,
  SearchOption,
  Shortcut,
  testShortcut,
} from "../../ui-components";
import { useSearchOptions } from "../hooks/useSearchOptions";

import { CityDatasetsList } from "./CityDatasetsList";
import { DatasetAreaList } from "./DatasetAreaList";
import { DatasetTypeList } from "./DatasetTypeList";
import { SearchList } from "./SearchList";

type TabOption = "search" | "city" | "area" | "type";

const StyledScrollable = styled(Scrollable)(({ theme }) => {
  const canvas = getCesiumCanvas();
  const searchHeaderHeight = "70px";
  return {
    maxHeight: `calc(${canvas?.clientHeight}px - ${theme.spacing(
      6,
    )} - 1px - ${searchHeaderHeight})`,
  };
});

const StyledTabs = styled(Tabs)(({ theme }) => ({
  position: "sticky",
  top: 0,
  minHeight: theme.spacing(5),
  width: "100%",
  backgroundColor: theme.palette.background.default,
  zIndex: 1,
  [`& .${tabClasses.root}`]: {
    minHeight: theme.spacing(5),
  },
}));

function filterOptions(
  options: SearchOption[],
  state: FilterOptionsState<SearchOption>,
): SearchOption[] {
  const tokens = state.inputValue.split(/\s+/).filter(value => value.length > 0);
  return tokens.length > 0
    ? options.filter(option => tokens.some(token => state.getOptionLabel(option).includes(token)))
    : options;
}

export interface SearchAutocompletePanelProps {
  children?: ReactNode;
  isResizing?: MutableRefObject<boolean>;
}

export const SearchAutocompletePanel: FC<SearchAutocompletePanelProps> = ({
  children,
  isResizing,
}) => {
  const [cityName] = useCityName();

  const textFieldRef = useRef<HTMLInputElement>(null);
  const [focused, setFocused] = useState(false);
  const handleFocus = useCallback(() => {
    setFocused(true);
  }, []);
  const handleBlur = useCallback(() => {
    setFocused(false);
  }, []);

  const [inputValue, setInputValue] = useState("");
  const handleInputChange: NonNullable<SearchAutocompleteProps["onInputChange"]> = useCallback(
    (_event, value, _reason) => {
      setInputValue(value);
    },
    [],
  );

  const deferredInputValue = useDeferredValue(inputValue);

  // TODO(ReEarth): Support search options
  const searchOptions = useSearchOptions({
    inputValue: deferredInputValue,
    skip: !focused,
  });
  const options = useMemo(
    () => [...searchOptions.datasets, ...searchOptions.buildings, ...searchOptions.areas],
    [searchOptions.datasets, searchOptions.buildings, searchOptions.areas],
  );

  const selectOption = searchOptions.select;
  const handleOptionSelect = useCallback(
    (_event: MouseEvent, option: SearchOption) => {
      selectOption(option);
    },
    [selectOption],
  );

  const [filters, setFilters] = useState<string[]>();
  const handleFiltersChange = useCallback((_event: MouseEvent, filters: string[]) => {
    setFilters(filters);
  }, []);

  const handleChange: NonNullable<SearchAutocompleteProps["onChange"]> = useCallback(
    (_event, values, reason, _details) => {
      if (reason === "removeOption") {
        setFilters([]);
        return;
      }
      const [value] = values.filter(
        (value: SearchOption | string): value is SearchOption =>
          typeof value !== "string" && value.type !== "filter",
      );
      if (value == null) {
        return;
      }
      selectOption(value);
      textFieldRef.current?.blur();
      setFocused(false);
    },
    [selectOption],
  );

  useWindowEvent("keydown", event => {
    // TODO: Manage shortcut globally
    if (textFieldRef.current == null) {
      return;
    }
    if (
      testShortcut(event, platform, {
        code: "KeyK",
        commandKey: true,
      })
    ) {
      event.preventDefault();
      if (document.activeElement !== textFieldRef.current) {
        textFieldRef.current.select();
      } else {
        textFieldRef.current.blur();
        setFocused(false);
      }
    }
  });

  const handleClickAway = useCallback(() => {
    if (isResizing?.current) return;
    setTimeout(() => {
      setFocused(false);
    }, 0);
  }, [isResizing]);

  const [tab, setTab] = useState<TabOption>("search");
  const deferredTab = useDeferredValue(tab);
  const handleTabChange = useCallback((_event: unknown, value: TabOption) => setTab(value), []);

  const { maxMainHeightAtom } = useContext(AppOverlayLayoutContext);
  const maxMainHeight = useAtomValue(maxMainHeightAtom);

  const platform = useAtomValue(platformAtom);

  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down("mobile"));
  return (
    <ViewClickAwayListener onClickAway={handleClickAway}>
      <FloatingPanel>
        <SearchAutocomplete
          inputRef={textFieldRef}
          placeholder="データセット、建築物、住所を検索"
          options={options}
          filterOptions={filterOptions}
          filters={filters}
          maxHeight={maxMainHeight}
          onFocus={handleFocus}
          onDeepBlur={handleBlur}
          onChange={handleChange}
          onInputChange={handleInputChange}
          endAdornment={
            <Shortcut variant="outlined" platform={platform} shortcutKey="K" commandKey />
          }
          isResizing={isResizing}>
          <Divider />
          {!focused ? (
            children
          ) : (
            <StyledScrollable>
              <StyledTabs
                value={deferredTab}
                variant={isMobile ? "fullWidth" : "standard"}
                onChange={handleTabChange}>
                <Tab value="search" label="検索" />
                {cityName && <Tab value="city" label={cityName} />}
                <Tab value="area" label="都道府県" />
                <Tab value="type" label="カテゴリー" />
              </StyledTabs>
              {tab === "search" && (
                <SearchList
                  datasets={searchOptions.datasets}
                  buildings={searchOptions.buildings}
                  areas={searchOptions.areas}
                  onOptionSelect={handleOptionSelect}
                  onFiltersChange={handleFiltersChange}
                />
              )}
              {tab === "city" && <CityDatasetsList />}
              {tab === "area" && <DatasetAreaList />}
              {tab === "type" && <DatasetTypeList />}
            </StyledScrollable>
          )}
        </SearchAutocomplete>
      </FloatingPanel>
    </ViewClickAwayListener>
  );
};
