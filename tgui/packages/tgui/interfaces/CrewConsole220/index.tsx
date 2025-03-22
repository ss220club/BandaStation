import { Button, Dropdown, Section, Stack, Tabs } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { SearchBar } from '../common/SearchBar';
import { sortTypes } from './constants';
import { MapView } from './MapView';
import { TableView } from './TableView';
import type { CrewConsoleData, CrewSensor } from './types';

export const CrewConsole220 = () => {
  return (
    <Window title="Crew Monitor" width={1000} height={750}>
      <Window.Content>
        <CrewContent />
      </Window.Content>
    </Window>
  );
};

function CrewContent() {
  const { data } = useBackend<CrewConsoleData>();
  const { sensors } = data;

  const [tab, setTab] = useSharedState('crewConsole-tab', 'List');
  const [searchText, setSearchText] = useSharedState('crewConsole-search', '');
  const [highlightedSensors, setHighlightedSensors] = useSharedState(
    'crewConsole-highlighted2',
    [],
  );
  const [headsOnly, setHeadsOnly] = useSharedState('crewConsole-heads', false);
  const [sortAsc, setSortAsc] = useSharedState('crewConsole-sortAsc', true);
  const [sortBy, setSortBy] = useSharedState(
    'crewConsole-sortBy',
    Object.keys(sortTypes)[0],
  );

  const nameSearch = createSearch(searchText, (crew: CrewSensor) => crew.name);
  let sorted = sensors;
  if (searchText) {
    sorted = sensors.filter(nameSearch);
  }

  sorted.sort(sortTypes[sortBy]);
  if (!sortAsc) {
    sorted = sorted.reverse();
  }

  const decideTab = (tab) => {
    switch (tab) {
      case 'List':
        return (
          <TableView
            sorted_sensors={sorted}
            highlightedSensors={highlightedSensors}
            setHighlightedSensors={setHighlightedSensors}
          />
        );
      case 'Map':
        return (
          <MapView
            sorted_sensors={sorted}
            highlightedSensors={highlightedSensors}
            searchText={searchText}
            headsOnly={headsOnly}
          />
        );
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          fill
          fitted
          title={
            <TitleActions
              tab={tab}
              setTab={setTab}
              searchText={searchText}
              setSearchText={setSearchText}
              headsOnly={headsOnly}
              setHeadsOnly={setHeadsOnly}
              sortBy={sortBy}
              setSortBy={setSortBy}
              sortAsc={sortAsc}
              setSortAsc={setSortAsc}
            />
          }
        />
      </Stack.Item>
      <Stack.Item grow mt={0}>
        {decideTab(tab)}
      </Stack.Item>
    </Stack>
  );
}

function TitleActions(props) {
  const {
    tab,
    setTab,
    searchText,
    setSearchText,
    headsOnly,
    setHeadsOnly,
    sortBy,
    setSortBy,
    sortAsc,
    setSortAsc,
  } = props;

  return (
    <Stack fill m={-0.75} pt={1} pl={1} pr={1}>
      <Stack.Item grow>
        <Tabs m={-1}>
          <Tabs.Tab
            icon="table"
            selected={tab === 'List'}
            onClick={() => setTab('List')}
          >
            List
          </Tabs.Tab>
          <Tabs.Tab
            icon="map"
            selected={tab === 'Map'}
            onClick={() => setTab('Map')}
          >
            Map
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        <SearchBar
          noIcon
          style={{ width: '20rem', height: '2.2rem' }}
          query={searchText}
          onSearch={setSearchText}
        />
      </Stack.Item>
      {tab === 'Map' && (
        <Stack.Item>
          <Button
            icon="wheelchair-move"
            tooltip="Показывать только глав"
            tooltipPosition="bottom-end"
            selected={headsOnly}
            onClick={() => setHeadsOnly(!headsOnly)}
          />
        </Stack.Item>
      )}
      {tab === 'List' && (
        <>
          <Stack.Item>
            <Dropdown
              selected={sortBy}
              options={Object.keys(sortTypes)}
              onSelected={(value) => setSortBy(value)}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon={sortAsc ? 'arrow-down-short-wide' : 'arrow-down-wide-short'}
              onClick={() => setSortAsc(!sortAsc)}
            />
          </Stack.Item>
        </>
      )}
    </Stack>
  );
}
