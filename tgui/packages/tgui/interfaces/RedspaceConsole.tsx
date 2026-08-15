import '../styles/interfaces/RedspaceConsole.scss';

import { useState } from 'react';
import {
  Box,
  Button,
  Chart,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { LoadingScreen } from './common/LoadingScreen';
import { NanoMap, type MapData } from './common/NanoMap';

type Position = {
  x: number;
  y: number;
  z: number;
};

type HistorySample = {
  available: BooleanLike;
  value?: number;
  state: string;
  age_seconds: number;
  position?: Position;
};

type AvailableHistorySample = HistorySample & {
  value: number;
};

type Sensor = {
  id: string;
  name: string;
  connected: BooleanLike;
  available: BooleanLike;
  status: 'fresh' | 'stale' | 'unknown' | 'disconnected';
  value?: number;
  state: string;
  state_code: number;
  last_sample_age_seconds: number;
  last_sample_reason: string;
  position?: Position;
  history: HistorySample[];
};

type Data = {
  mapData: MapData;
  sensor_count: number;
  sample_interval_seconds: number;
  stale_after_seconds: number;
  sensors: Sensor[];
};

type ValueBand = 'ebb' | 'calm' | 'disturbance' | 'storm' | 'invasion' | 'unknown';

const VALUE_BANDS: Array<{
  band: Exclude<ValueBand, 'unknown'>;
  range: string;
  color: string;
}> = [
  { band: 'ebb', range: '< 0', color: '#3498db' },
  { band: 'calm', range: '0-3', color: '#2ecc71' },
  {
    band: 'disturbance',
    range: '4-7',
    color: '#f1c40f',
  },
  { band: 'storm', range: '8-10', color: '#e74c3c' },
  { band: 'invasion', range: '10+', color: '#111111' },
];

const STATUS_LABELS: Record<Sensor['status'], string> = {
  fresh: 'свежие данные',
  stale: 'данные устарели',
  unknown: 'нет показания',
  disconnected: 'нет связи',
};

const STATUS_COLORS: Record<Sensor['status'], string> = {
  fresh: 'good',
  stale: 'average',
  unknown: 'label',
  disconnected: 'bad',
};

function formatValue(value?: number) {
  return value === undefined ? '—' : value.toFixed(2);
}

function formatAge(age: number) {
  return age < 0 ? 'нет данных' : `${Math.floor(age)} с назад`;
}

function getValueBand(value?: number): ValueBand {
  if (value === undefined) {
    return 'unknown';
  }
  if (value < 0) {
    return 'ebb';
  }
  if (value <= 3) {
    return 'calm';
  }
  if (value <= 7) {
    return 'disturbance';
  }
  if (value <= 10) {
    return 'storm';
  }
  return 'invasion';
}

function getValueColor(value?: number) {
  const band = getValueBand(value);
  return (
    VALUE_BANDS.find((entry) => entry.band === band)?.color ||
    'var(--color-label)'
  );
}

function getValueTextColor(value?: number) {
  const band = getValueBand(value);
  return band === 'invasion' || band === 'storm' ? '#ffffff' : '#111111';
}

function getValueFillColor(value?: number) {
  const color = getValueColor(value);
  return color.startsWith('#') ? `${color}44` : 'transparent';
}

function getHistorySamples(sensor: Sensor): AvailableHistorySample[] {
  return sensor.history.filter(
    (sample): sample is AvailableHistorySample =>
      Boolean(sample.available) && typeof sample.value === 'number',
  );
}

function getHistoryRange(samples: AvailableHistorySample[]): [number, number] {
  const values = samples.map((sample) => sample.value);
  const min = Math.min(0, ...values);
  const max = Math.max(10, ...values);
  const padding = Math.max(1, (max - min) * 0.1);
  return [min - padding, max + padding];
}

export const RedspaceConsole = () => {
  const { act, data } = useBackend<Data>();
  const [selectedSensorId, setSelectedSensorId] = useState<string>();
  const [selectedLevel, setSelectedLevel] = useState<number>();

  if (!data.mapData || !data.sensors) {
    return (
      <Window width={1200} height={760}>
        <Window.Content>
          <LoadingScreen />
        </Window.Content>
      </Window>
    );
  }

  const selectedSensor =
    data.sensors.find((sensor) => sensor.id === selectedSensorId) ||
    data.sensors[0];

  const selectSensor = (sensorId: string) => {
    setSelectedSensorId(sensorId);
  };

  return (
    <Window width={1200} height={760}>
      <Window.Content fitted>
        <Stack fill vertical className="RedspaceConsole">
          <Stack.Item shrink={0}>
            <ConsoleToolbar
              sensorCount={data.sensor_count}
              sampleInterval={data.sample_interval_seconds}
              staleAfter={data.stale_after_seconds}
            />
          </Stack.Item>

          <Stack.Item grow minHeight={0}>
            <Stack
              fill
              className="RedspaceConsole__workspace"
              style={{ gap: 'var(--space-s)' }}
            >
              <Stack.Item grow basis={0} minWidth={0} minHeight={0}>
                <Section
                  title="Карта датчиков"
                  fill
                  fitted
                  className="RedspaceConsole__mapSection"
                >
                  <NanoMap
                    mapData={data.mapData}
                    minimapPosition="top-right"
                    onLevelChange={setSelectedLevel}
                  >
                    {data.sensors.map((sensor) => {
                      const position = sensor.position;
                      if (!position) {
                        return null;
                      }

                      const isSelected = selectedSensor?.id === sensor.id;
                      return (
                        <NanoMap.Button
                          circular
                          key={`${sensor.id}-${isSelected}`}
                          posX={position.x}
                          posY={position.y}
                          posZ={position.z}
                          backgroundColor={getValueColor(sensor.value)}
                          color={getValueTextColor(sensor.value)}
                          style={{
                            borderColor:
                              getValueBand(sensor.value) === 'invasion'
                                ? '#ffffff'
                                : undefined,
                          }}
                          hidden={
                            position.z !==
                            (selectedLevel ?? data.mapData.mainFloor)
                          }
                          selected={isSelected}
                          highlighted={isSelected}
                          tracking={isSelected}
                          tooltip={<SensorTooltip sensor={sensor} />}
                          onClick={() => selectSensor(sensor.id)}
                        />
                      );
                    })}
                  </NanoMap>
                </Section>
              </Stack.Item>

              <Stack.Item
                basis="44%"
                minWidth="440px"
                maxWidth="520px"
                shrink={1}
                minHeight={0}
              >
                <Stack
                  fill
                  className="RedspaceConsole__sidebar"
                  style={{ gap: 'var(--space-s)' }}
                >
                  <Stack.Item
                    basis="48%"
                    minWidth="240px"
                    shrink={1}
                    minHeight={0}
                  >
                    <SensorList
                      sensors={data.sensors}
                      selectedSensorId={selectedSensor?.id}
                      onSelect={selectSensor}
                      onUnlink={(sensorId) =>
                        act('unlink_sensor', { sensor_id: sensorId })
                      }
                      onForget={(sensorId) =>
                        act('forget_sensor', { sensor_id: sensorId })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0} minWidth={0} minHeight={0}>
                    {selectedSensor ? (
                      <SensorHistory sensor={selectedSensor} />
                    ) : (
                      <Section title="История показаний" fill>
                        <NoticeBox>Выберите датчик в списке.</NoticeBox>
                      </Section>
                    )}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ConsoleToolbar = (props: {
  sensorCount: number;
  sampleInterval: number;
  staleAfter: number;
}) => {
  const { sensorCount, sampleInterval, staleAfter } = props;

  return (
    <Box className="RedspaceConsole__toolbar">
      <Stack align="center" style={{ gap: 'var(--space-m)' }}>
        <Stack.Item shrink={0}>
          <Box bold>Сеть наблюдения</Box>
          <Box color="label" fontSize={0.8}>
            {sensorCount} датчиков · опрос каждые {sampleInterval} с ·
            устаревание через {staleAfter} с
          </Box>
        </Stack.Item>
        <Stack.Item grow />
        <Stack.Item shrink={0}>
          <ValueLegend />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const ValueLegend = () => (
  <Stack
    align="center"
    className="RedspaceConsole__legend"
    style={{ gap: 'var(--space-s)' }}
  >
    {VALUE_BANDS.map((entry) => (
      <Stack.Item key={entry.band}>
        <Stack align="center" style={{ gap: '0.25rem' }}>
          <Box
            className="RedspaceConsole__legendSwatch"
            style={{ backgroundColor: entry.color }}
          />
          <Box color="label" fontSize={0.8}>
            {entry.range}
          </Box>
        </Stack>
      </Stack.Item>
    ))}
  </Stack>
);

type SensorListProps = {
  sensors: Sensor[];
  selectedSensorId?: string;
  onSelect: (sensorId: string) => void;
  onUnlink: (sensorId: string) => void;
  onForget: (sensorId: string) => void;
};

const SensorList = (props: SensorListProps) => {
  const { sensors, selectedSensorId, onSelect, onUnlink, onForget } = props;

  return (
    <Section
      title={`Датчики (${sensors.length})`}
      fill
      scrollable
      fitted
      className="RedspaceConsole__sensorList"
    >
      {!sensors.length && (
        <NoticeBox m={0.5}>Сопряжённых датчиков нет.</NoticeBox>
      )}
      {!!sensors.length && (
        <Table>
          {sensors.map((sensor) => (
            <Table.Row
              key={sensor.id}
              className={`RedspaceConsole__sensorRow${
                selectedSensorId === sensor.id
                  ? ' RedspaceConsole__sensorRow--selected'
                  : ''
              }`}
              onClick={() => onSelect(sensor.id)}
            >
              <Table.Cell style={{ minWidth: 0 }}>
                <Box
                  bold
                  style={{
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {sensor.name}
                </Box>
                <Box
                  color={STATUS_COLORS[sensor.status]}
                  fontSize={0.8}
                  style={{ overflowWrap: 'anywhere' }}
                >
                  {sensor.id} · {STATUS_LABELS[sensor.status]}
                </Box>
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <ValueBadge value={sensor.value} />
              </Table.Cell>
              <Table.Cell collapsing>
                {sensor.connected ? (
                  <Button
                    icon="unlink"
                    tooltip="Разорвать привязку"
                    onClick={(event) => {
                      event.stopPropagation();
                      onUnlink(sensor.id);
                    }}
                  />
                ) : (
                  <Button
                    icon="trash"
                    color="bad"
                    tooltip="Удалить запись"
                    onClick={(event) => {
                      event.stopPropagation();
                      onForget(sensor.id);
                    }}
                  />
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const ValueBadge = (props: { value?: number }) => {
  const { value } = props;
  return (
    <Box
      inline
      className="RedspaceConsole__valueBadge"
      style={{
        backgroundColor: getValueColor(value),
        color: getValueTextColor(value),
        borderColor:
          getValueBand(value) === 'invasion' ? '#ffffff' : undefined,
      }}
    >
      {formatValue(value)}
    </Box>
  );
};

const SensorHistory = (props: { sensor: Sensor }) => {
  const { sensor } = props;
  const samples = getHistorySamples(sensor);
  const historyData = samples.map((sample, index) => [index, sample.value]);
  const rangeY = getHistoryRange(samples);

  return (
    <Section
      title="История показаний"
      fill
      fitted
      className="RedspaceConsole__history"
    >
      <Stack fill vertical>
        <Stack.Item shrink={0}>
          <Box className="RedspaceConsole__historyHeader">
            <Stack align="center">
              <Stack.Item grow minWidth={0}>
                <Box
                  bold
                  style={{
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {sensor.name}
                </Box>
                <Box color="label" fontSize={0.8}>
                  {sensor.id}
                </Box>
              </Stack.Item>
              <Stack.Item shrink={0}>
                <ValueBadge value={sensor.value} />
              </Stack.Item>
            </Stack>
            <LabeledList>
              <LabeledList.Item label="Диапазон">
                {sensor.state}
              </LabeledList.Item>
              <LabeledList.Item label="Последняя выборка">
                {formatAge(sensor.last_sample_age_seconds)}
              </LabeledList.Item>
              <LabeledList.Item label="Координаты">
                {sensor.position
                  ? `${sensor.position.x}, ${sensor.position.y}, ${sensor.position.z}`
                  : 'нет'}
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Stack.Item>

        <Stack.Item shrink={0}>
          {historyData.length > 1 ? (
            <Box className="RedspaceConsole__historyChart">
              <Chart.Line
                fillPositionedParent
                data={historyData}
                rangeX={[0, historyData.length - 1]}
                rangeY={rangeY}
                strokeColor={getValueColor(sensor.value)}
                fillColor={getValueFillColor(sensor.value)}
              />
            </Box>
          ) : (
            <NoticeBox m={0.5}>
              Недостаточно данных для построения истории.
            </NoticeBox>
          )}
        </Stack.Item>

        <Stack.Item grow minHeight={0}>
          <Box
            className="RedspaceConsole__historyTable"
            overflowY="auto"
            p={0.5}
          >
            <Table>
              <Table.Row header>
                <Table.Cell>Возраст</Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  Значение
                </Table.Cell>
                <Table.Cell collapsing>Диапазон</Table.Cell>
              </Table.Row>
              {sensor.history
                .slice()
                .reverse()
                .map((sample, index) => (
                  <Table.Row key={`${sample.age_seconds}-${index}`}>
                    <Table.Cell>{formatAge(sample.age_seconds)}</Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      <ValueBadge value={sample.value} />
                    </Table.Cell>
                    <Table.Cell collapsing>{sample.state}</Table.Cell>
                  </Table.Row>
                ))}
            </Table>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SensorTooltip = (props: { sensor: Sensor }) => {
  const { sensor } = props;
  return (
    <Section m={-1} title={sensor.name} fontSize={0.9}>
      <LabeledList>
        <LabeledList.Item label="Статус" color={STATUS_COLORS[sensor.status]}>
          {STATUS_LABELS[sensor.status]}
        </LabeledList.Item>
        <LabeledList.Item label="Значение">
          <ValueBadge value={sensor.value} />
        </LabeledList.Item>
        <LabeledList.Item label="Диапазон">{sensor.state}</LabeledList.Item>
        <LabeledList.Item label="Возраст">
          {formatAge(sensor.last_sample_age_seconds)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
