import { useState } from 'react';
import {
  Button,
  Icon,
  Dropdown,
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

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];

const STAT_LIVING = 0;
const STAT_DEAD = 4;

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

const healthToAttribute = (sensor: CrewSensor, attributeList: string[]) => {
  const { oxydam, toxdam, burndam, brutedam } = sensor;
  const healthSum = oxydam + toxdam + burndam + brutedam;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return attributeList[level];
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

const healthSort = (a: CrewSensor, b: CrewSensor) => {
  if (a.life_status > b.life_status) return -1;
  if (a.life_status < b.life_status) return 1;
  if (a.health < b.health) return -1;
  if (a.health > b.health) return 1;
  return 0;
};

const sortTypes = {
  Name: (a, b) => (a.name > b.name ? 1 : -1),
  Job: (a, b) => a.ijob - b.ijob,
  Head: (a, b) => headSort(a, b),
  Health: (a, b) => healthSort(a, b),
  Area: (a, b) => areaSort(a, b),
};

const HealthStat = (props) => {
  const { sensor_data } = props;
  const { oxydam, toxdam, burndam, brutedam, life_status } = sensor_data;
  return (
    <Stack fill textAlign="center">
      {oxydam !== undefined ? (
        <>
          <Stack.Item color={COLORS.damageType['oxy']}>{oxydam}</Stack.Item>
          <Stack.Divider />
          <Stack.Item color={COLORS.damageType['toxin']}>{toxdam}</Stack.Item>
          <Stack.Divider />
          <Stack.Item color={COLORS.damageType['burn']}>{burndam}</Stack.Item>
          <Stack.Divider />
          <Stack.Item color={COLORS.damageType['brute']}>{brutedam}</Stack.Item>
        </>
      ) : life_status !== STAT_DEAD ? (
        <Stack.Item grow>Живой</Stack.Item>
      ) : (
        <Stack.Item grow>Мёртв</Stack.Item>
      )}
    </Stack>
  );
};

export const CrewConsole220 = () => {
  return (
    <Window title="Crew Monitor" width={1000} height={750}>
      <Window.Content>
        <CrewContent />
      </Window.Content>
    </Window>
  );
};

export function CrewContent() {
  const { act, data } = useBackend<CrewConsoleData>();
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
          <CrewTable
            sorted_sensors={sorted}
            highlightedSensors={highlightedSensors}
            setHighlightedSensors={setHighlightedSensors}
          />
        );
      case 'Map':
        return (
          <CrewMap
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
                      icon={
                        sortAsc
                          ? 'arrow-down-short-wide'
                          : 'arrow-down-wide-short'
                      }
                      onClick={() => setSortAsc(!sortAsc)}
                    />
                  </Stack.Item>
                </>
              )}
            </Stack>
          }
        />
      </Stack.Item>
      <Stack.Item grow mt={0}>
        {decideTab(tab)}
      </Stack.Item>
    </Stack>
  );
}

function CrewTable(props) {
  const { data } = useBackend<CrewConsoleData>();
  const { sorted_sensors, highlightedSensors, setHighlightedSensors } = props;
  return (
    <Section fill scrollable>
      <Table>
        <Table.Row>
          <Table.Cell bold collapsing>
            <Button
              tooltip="Очистить подсветку на карте"
              icon="square-xmark"
              onClick={() => setHighlightedSensors([])}
            />
          </Table.Cell>
          <Table.Cell bold>Имя</Table.Cell>
          <Table.Cell bold collapsing />
          <Table.Cell bold collapsing textAlign="center">
            Состояние
          </Table.Cell>
          <Table.Cell bold textAlign="center">
            Местоположение
          </Table.Cell>
          {!!data.link_allowed && (
            <Table.Cell bold collapsing textAlign="center">
              Трекинг
            </Table.Cell>
          )}
        </Table.Row>
        {sorted_sensors.map((sensor) => (
          <CrewTableEntry
            key={sensor.ref}
            sensor_data={sensor}
            highlightedSensors={highlightedSensors}
            setHighlightedSensors={setHighlightedSensors}
          />
        ))}
      </Table>
    </Section>
  );
}

const CrewTableEntry = (props) => {
  const { act, data } = useBackend<CrewConsoleData>();
  const { link_allowed } = data;
  const { sensor_data, highlightedSensors, setHighlightedSensors } = props;
  const { name, assignment, ijob, life_status, oxydam, position, can_track } =
    sensor_data;

  return (
    <Table.Row className="candystripe">
      <Table.Cell>
        <Button.Checkbox
          checked={highlightedSensors.includes(name)}
          tooltip="Пометить на карте"
          onClick={() =>
            setHighlightedSensors(
              highlightedSensors.includes(name)
                ? highlightedSensors.filter((n) => n !== name)
                : [...highlightedSensors, name],
            )
          }
        />
      </Table.Cell>
      <Table.Cell bold={jobIsHead(ijob)} color={jobToColor(ijob)}>
        {name}
        {assignment !== undefined ? ` (${assignment})` : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Icon
            name={statToIcon(life_status)}
            color={healthToAttribute(sensor_data, HEALTH_COLOR_BY_LEVEL)}
            size={1}
          />
        ) : life_status !== STAT_DEAD ? (
          <Icon name="heart" color="#17d568" size={1} />
        ) : (
          <Icon name="skull" color="#801308" size={1} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <HealthStat sensor_data={sensor_data} />
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
  const { sorted_sensors, highlightedSensors, searchText, headsOnly } = props;
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
              color={healthToAttribute(sensor, HEALTH_COLOR_BY_LEVEL)}
              icon={sensor.life_status === STAT_DEAD && 'skull'}
              tooltip={<CrewMapTooltip sensor_data={sensor} />}
              hidden={
                sensor.position?.z !== selectedLevel ||
                (headsOnly && sensor.ijob % 10 !== 0)
              }
              selected={
                (searchText && sorted_sensors.includes(sensor)) ||
                highlightedSensors.includes(sensor.name)
              }
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

const CrewMapTooltip = (props) => {
  const { sensor_data } = props;
  const position = sensor_data.position;
  return (
    <Section m={-1} title={sensor_data.name} fontSize={0.9}>
      <LabeledList>
        <LabeledList.Item
          label="Состояние"
          color={sensor_data.life_status === STAT_DEAD ? '#e74c3c' : '#17d568'}
        >
          {sensor_data.life_status === STAT_DEAD ? 'Мёртв' : 'Живой'}
        </LabeledList.Item>
        <LabeledList.Item label="Здоровье">
          <HealthStat sensor_data={sensor_data} />
        </LabeledList.Item>
        <LabeledList.Item label="Локация">{position?.area}</LabeledList.Item>
        <LabeledList.Item label="Местоположение">
          X: {position?.x}, Y: {position?.y}, Z: {position?.z}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
