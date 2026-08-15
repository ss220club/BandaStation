import { useState } from 'react';
import {
  Box,
  Button,
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

const STATUS_LABELS: Record<Sensor['status'], string> = {
  fresh: 'Свежие данные',
  stale: 'Данные устарели',
  unknown: 'Нет показания',
  disconnected: 'Нет связи',
};

const STATUS_COLORS: Record<Sensor['status'], string> = {
  fresh: 'good',
  stale: 'average',
  unknown: 'average',
  disconnected: 'bad',
};

const STATUS_MAP_COLORS: Record<Sensor['status'], string> = {
  fresh: '#17d568',
  stale: '#e67e22',
  unknown: '#c4cf2d',
  disconnected: '#e74c3c',
};

function formatValue(value?: number) {
  return value === undefined ? '—' : value.toFixed(2);
}

function formatAge(age: number) {
  return age < 0 ? 'нет данных' : `${Math.floor(age)} с назад`;
}

export const RedspaceConsole = () => {
  const { act, data } = useBackend<Data>();
  const [selectedSensorId, setSelectedSensorId] = useState<string>();
  const [selectedLevel, setSelectedLevel] = useState<number>();

  if (!data.mapData || !data.sensors) {
    return (
      <Window width={980} height={720}>
        <Window.Content>
          <LoadingScreen />
        </Window.Content>
      </Window>
    );
  }

  const selectedSensor =
    data.sensors.find((sensor) => sensor.id === selectedSensorId) ||
    data.sensors[0];

  return (
    <Window width={980} height={720}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Сеть наблюдения">
              <LabeledList>
                <LabeledList.Item label="Подключено датчиков">
                  {data.sensor_count}
                </LabeledList.Item>
                <LabeledList.Item label="Период выборки">
                  {data.sample_interval_seconds} с
                </LabeledList.Item>
                <LabeledList.Item label="Устаревание данных">
                  {data.stale_after_seconds} с
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item grow minHeight={0}>
            <Stack fill wrap="wrap">
              <Stack.Item grow basis="60%" minWidth={0}>
                <Section title="Точки измерения" fill>
                  {data.mapData ? (
                    <NanoMap
                      mapData={data.mapData}
                      onLevelChange={setSelectedLevel}
                    >
                      {data.sensors.map((sensor) => {
                        const position = sensor.position;
                        if (!position) {
                          return null;
                        }
                        return (
                          <NanoMap.Button
                            circular
                            key={sensor.id}
                            posX={position.x}
                            posY={position.y}
                            backgroundColor={STATUS_MAP_COLORS[sensor.status]}
                            color={STATUS_MAP_COLORS[sensor.status]}
                            hidden={
                              position.z !==
                              (selectedLevel ?? data.mapData.mainFloor)
                            }
                            selected={selectedSensor?.id === sensor.id}
                            tooltip={
                              <SensorTooltip sensor={sensor} />
                            }
                            onClick={() => setSelectedSensorId(sensor.id)}
                          />
                        );
                      })}
                    </NanoMap>
                  ) : (
                    <NoticeBox>Карта станции недоступна.</NoticeBox>
                  )}
                </Section>
              </Stack.Item>

              <Stack.Item grow basis="40%" minWidth={0}>
                <Stack fill vertical>
                  <Stack.Item grow minHeight={0}>
                    <SensorList
                      sensors={data.sensors}
                      selectedSensorId={selectedSensor?.id}
                      onSelect={setSelectedSensorId}
                      onUnlink={(sensorId) => act('unlink_sensor', { sensor_id: sensorId })}
                      onForget={(sensorId) => act('forget_sensor', { sensor_id: sensorId })}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    {selectedSensor && <SensorHistory sensor={selectedSensor} />}
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
    <Section title="Датчики" fill scrollable>
      {!sensors.length && <NoticeBox>Сопряжённых датчиков нет.</NoticeBox>}
      {!!sensors.length && (
        <Table>
          <Table.Row header>
            <Table.Cell>Датчик</Table.Cell>
            <Table.Cell collapsing>Показание</Table.Cell>
            <Table.Cell collapsing>Статус</Table.Cell>
            <Table.Cell collapsing />
          </Table.Row>
          {sensors.map((sensor) => (
            <Table.Row
              key={sensor.id}
              className={selectedSensorId === sensor.id ? 'selected' : undefined}
              onClick={() => onSelect(sensor.id)}
            >
              <Table.Cell style={{ minWidth: 0 }}>
                <Box color={STATUS_COLORS[sensor.status]} bold>
                  {sensor.name}
                </Box>
                <Box
                  color="label"
                  fontSize="0.8em"
                  style={{ overflowWrap: 'anywhere' }}
                >
                  {sensor.id}
                </Box>
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {formatValue(sensor.value)}
              </Table.Cell>
              <Table.Cell
                color={STATUS_COLORS[sensor.status]}
                style={{ overflowWrap: 'anywhere', whiteSpace: 'normal' }}
              >
                {STATUS_LABELS[sensor.status]}
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

type SensorHistoryProps = {
  sensor: Sensor;
};

const SensorHistory = (props: SensorHistoryProps) => {
  const { sensor } = props;
  return (
    <Section title={`История: ${sensor.name}`}>
      <LabeledList>
        <LabeledList.Item label="Текущее значение">
          {formatValue(sensor.value)}
        </LabeledList.Item>
        <LabeledList.Item label="Диапазон">{sensor.state}</LabeledList.Item>
        <LabeledList.Item label="Последняя выборка">
          {formatAge(sensor.last_sample_age_seconds)}
        </LabeledList.Item>
        <LabeledList.Item label="Координаты">
          {sensor.position
            ? `${sensor.position.x}, ${sensor.position.y}, ${sensor.position.z}`
            : 'нет'}
        </LabeledList.Item>
      </LabeledList>
      <Box color="label" mt={1} mb={0.5}>
        Последние показания
      </Box>
      <Table>
        <Table.Row header>
          <Table.Cell>Возраст</Table.Cell>
          <Table.Cell collapsing>Значение</Table.Cell>
          <Table.Cell collapsing>Диапазон</Table.Cell>
        </Table.Row>
        {sensor.history
          .slice()
          .reverse()
          .map((sample, index) => (
            <Table.Row key={`${sample.age_seconds}-${index}`}>
              <Table.Cell>{formatAge(sample.age_seconds)}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {formatValue(sample.value)}
              </Table.Cell>
              <Table.Cell collapsing>{sample.state}</Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};

const SensorTooltip = (props: { sensor: Sensor }) => {
  const { sensor } = props;
  return (
    <Section title={sensor.name} fontSize={0.9}>
      <LabeledList>
        <LabeledList.Item label="Статус" color={STATUS_COLORS[sensor.status]}>
          {STATUS_LABELS[sensor.status]}
        </LabeledList.Item>
        <LabeledList.Item label="Значение">
          {formatValue(sensor.value)}
        </LabeledList.Item>
        <LabeledList.Item label="Диапазон">{sensor.state}</LabeledList.Item>
        <LabeledList.Item label="Возраст">
          {formatAge(sensor.last_sample_age_seconds)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
