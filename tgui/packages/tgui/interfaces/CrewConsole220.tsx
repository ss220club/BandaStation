import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  Section,
  Stack,
  Table,
  Tabs,
  LabeledList,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { type MapData, NanoMap } from './common/NanoMap';
import { SearchBar } from './common/SearchBar';

type CrewSensor = {
  name: string;
  assignment: string | undefined;
  ijob: number;
  life_status: number;
  oxydam: number;
  toxdam: number;
  burndam: number;
  brutedam: number;
  position: Position | undefined;
  health: number;
  can_track: BooleanLike;
  ref: string;
};

type Position = {
  area: string;
  x: number;
  y: number;
  z: number;
};

type CrewConsoleData = {
  sensors: CrewSensor[];
  link_allowed: BooleanLike;
  mapData: MapData;
};

type CrewEntryProps = {
  sensor_data: CrewSensor;
};

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];

const SORT_NAMES = {
  ijob: 'Job',
  name: 'Name',
  area: 'Position',
  health: 'Vitals',
  head: 'Head',
};

const STAT_LIVING = 0;
const STAT_DEAD = 4;

const SORT_OPTIONS = ['health', 'ijob', 'name', 'area', 'head'];

const jobIsHead = (jobId: number) => jobId % 10 === 0;

const jobToColor = (jobId: number) => {
  if (jobId === 0) {
    return COLORS.department.captain;
  }
  if (jobId >= 10 && jobId < 20) {
    return COLORS.department.security;
  }
  if (jobId >= 20 && jobId < 30) {
    return COLORS.department.medbay;
  }
  if (jobId >= 30 && jobId < 40) {
    return COLORS.department.science;
  }
  if (jobId >= 40 && jobId < 50) {
    return COLORS.department.engineering;
  }
  if (jobId >= 50 && jobId < 60) {
    return COLORS.department.cargo;
  }
  if (jobId >= 60 && jobId < 200) {
    return COLORS.department.service;
  }
  if (jobId >= 200 && jobId < 230) {
    return COLORS.department.centcom;
  }
  return COLORS.department.other;
};

const statToIcon = (life_status: number) => {
  switch (life_status) {
    case STAT_LIVING:
      return 'heart';
    case STAT_DEAD:
      return 'skull';
  }
  return 'heartbeat';
};

const healthSort = (a: CrewSensor, b: CrewSensor) => {
  if (a.life_status > b.life_status) return -1;
  if (a.life_status < b.life_status) return 1;
  if (a.health < b.health) return -1;
  if (a.health > b.health) return 1;
  return 0;
};

const areaSort = (a: CrewSensor, b: CrewSensor) => {
  const areaA = a.position?.area ?? '~';
  const areaB = b.position?.area ?? '~';
  if (areaA < areaB) return -1;
  if (areaA > areaB) return 1;
  return 0;
};

const headSort = (a: CrewSensor, b: CrewSensor) => {
  if (a.ijob % 10 === 0 && b.ijob % 10 !== 0) return -1;
  else if (a.ijob % 10 !== 0 && b.ijob % 10 === 0) return 1;
  else return a.ijob - b.ijob;
};

const healthToAttribute = (
  oxy: number,
  tox: number,
  burn: number,
  brute: number,
  attributeList: string[],
) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return attributeList[level];
};

type HealthStatProps = {
  type: string;
  value: number;
};

const HealthStat = (props: HealthStatProps) => {
  const { type, value } = props;
  return (
    <Box inline width={2} color={COLORS.damageType[type]} textAlign="center">
      {value}
    </Box>
  );
};

export const CrewConsole220 = () => {
  const [tab, setTab] = useSharedState('crew-console-tab', 'List');
  const [sortAsc, setSortAsc] = useSharedState('crew-console-sort-asc', true);
  const [searchQuery, setSearchQuery] = useSharedState(
    'crew-console-search',
    '',
  );
  const [sortBy, setSortBy] = useSharedState(
    'crew-console-sort-by',
    SORT_OPTIONS[0],
  );

  const cycleSortBy = () => {
    let idx = SORT_OPTIONS.indexOf(sortBy) + 1;
    if (idx === SORT_OPTIONS.length) idx = 0;
    setSortBy(SORT_OPTIONS[idx]);
  };

  return (
    <Window title="Crew Monitor" width={1000} height={750}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              fill
              title={
                <Stack fill m={-0.75} pt={1} pl={1} pr={1}>
                  <Stack.Item grow>
                    <Tabs m={-1}>
                      <Tabs.Tab
                        icon="list"
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
                      style={{ width: '20rem' }}
                      query={searchQuery}
                      onSearch={setSearchQuery}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={cycleSortBy}>{SORT_NAMES[sortBy]}</Button>
                    <Button onClick={() => setSortAsc(!sortAsc)}>
                      <Icon name={sortAsc ? 'chevron-up' : 'chevron-down'} />
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            />
          </Stack.Item>
          <Stack.Item grow mt={0}>
            {tab === 'List' && (
              <CrewTable
                searchQuery={searchQuery}
                sortBy={sortBy}
                sortAsc={sortAsc}
              />
            )}
            {tab === 'Map' && (
              <CrewMap
                searchQuery={searchQuery}
                sortBy={sortBy}
                sortAsc={sortAsc}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

function CrewTable(props) {
  const { data } = useBackend<CrewConsoleData>();
  const { sortAsc, searchQuery, sortBy } = props;
  const { sensors } = data;

  const nameSearch = createSearch(searchQuery, (crew: CrewSensor) => crew.name);

  const sorted = sensors.filter(nameSearch).sort((a, b) => {
    switch (sortBy) {
      case 'name':
        return sortAsc ? +(a.name > b.name) : +(b.name > a.name);
      case 'ijob':
        return sortAsc ? a.ijob - b.ijob : b.ijob - a.ijob;
      case 'health':
        return sortAsc ? healthSort(a, b) : healthSort(b, a);
      case 'area':
        return sortAsc ? areaSort(a, b) : areaSort(b, a);
      case 'head':
        return sortAsc ? headSort(a, b) : headSort(b, a);
      default:
        return 0;
    }
  });

  return (
    <Section fill scrollable>
      <Table>
        <Table.Row>
          <Table.Cell bold>Name</Table.Cell>
          <Table.Cell bold collapsing />
          <Table.Cell bold collapsing textAlign="center">
            Vitals
          </Table.Cell>
          <Table.Cell bold textAlign="center">
            Position
          </Table.Cell>
          {!!data.link_allowed && (
            <Table.Cell bold collapsing textAlign="center">
              Tracking
            </Table.Cell>
          )}
        </Table.Row>
        {sorted.map((sensor) => (
          <CrewTableEntry sensor_data={sensor} key={sensor.ref} />
        ))}
      </Table>
    </Section>
  );
}

const CrewTableEntry = (props: CrewEntryProps) => {
  const { act, data } = useBackend<CrewConsoleData>();
  const { link_allowed } = data;
  const { sensor_data } = props;
  const {
    name,
    assignment,
    ijob,
    life_status,
    oxydam,
    toxdam,
    burndam,
    brutedam,
    position,
    can_track,
  } = sensor_data;

  return (
    <Table.Row className="candystripe">
      <Table.Cell bold={jobIsHead(ijob)} color={jobToColor(ijob)}>
        {name}
        {assignment !== undefined ? ` (${assignment})` : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Icon
            name={statToIcon(life_status)}
            color={healthToAttribute(
              oxydam,
              toxdam,
              burndam,
              brutedam,
              HEALTH_COLOR_BY_LEVEL,
            )}
            size={1}
          />
        ) : life_status !== STAT_DEAD ? (
          <Icon name="heart" color="#17d568" size={1} />
        ) : (
          <Icon name="skull" color="#801308" size={1} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Box inline>
            <HealthStat type="oxy" value={oxydam} />
            {'|'}
            <HealthStat type="toxin" value={toxdam} />
            {'|'}
            <HealthStat type="burn" value={burndam} />
            {'|'}
            <HealthStat type="brute" value={brutedam} />
          </Box>
        ) : life_status !== STAT_DEAD ? (
          'Живой'
        ) : (
          'Мёртв'
        )}
      </Table.Cell>
      <Table.Cell>
        {position?.area !== '~' && position?.area !== undefined ? (
          position.area
        ) : (
          <Icon name="question" color="#ffffff" size={1} />
        )}
      </Table.Cell>
      {!!link_allowed && (
        <Table.Cell collapsing>
          <Button
            disabled={!can_track}
            onClick={() =>
              act('select_person', {
                name: name,
              })
            }
          >
            Track
          </Button>
        </Table.Cell>
      )}
    </Table.Row>
  );
};

function CrewMap(props) {
  const { act, data } = useBackend<CrewConsoleData>();
  const { mapData, sensors } = data;
  const { searchQuery, sortBy, sortAsc } = props;
  const [selectedLevel, setSelectedLevel] = useState<number>(mapData.mainFloor);

  return (
    <NanoMap
      mapData={mapData}
      uiName="crew-console"
      onLevelChange={setSelectedLevel}
    >
      {sensors.map(
        (sensor) =>
          sensor.position?.area !== '~' &&
          sensor.position?.area !== undefined && (
            <NanoMap.Marker
              key={sensor.ref}
              posX={sensor.position?.x}
              posY={sensor.position?.y}
              color={healthToAttribute(
                sensor.oxydam,
                sensor.toxdam,
                sensor.burndam,
                sensor.brutedam,
                HEALTH_COLOR_BY_LEVEL,
              )}
              tooltip={<CrewMapTooltip sensor_data={sensor} />}
              hidden={sensor.position?.z !== selectedLevel}
              onClick={() =>
                act('select_person', {
                  name: sensor.name,
                })
              }
            />
          ),
      )}
    </NanoMap>
  );
}

const CrewMapTooltip = (props: CrewEntryProps) => {
  const { sensor_data } = props;
  const position = sensor_data.position;

  return (
    <Section m={-1} title={sensor_data.name} fontSize={0.9}>
      <LabeledList>
        <LabeledList.Item label="Состояние">
          {sensor_data.life_status !== STAT_DEAD ? 'Живой' : 'Труп'}
        </LabeledList.Item>
        {!!position && (
          <>
            <LabeledList.Item label="Локация">{position.area}</LabeledList.Item>
            <LabeledList.Item label="Местоположение">
              X: {position.x}, Y: {position.y}, Z: {position.z}
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
};
