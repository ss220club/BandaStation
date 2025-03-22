import { Button, Icon, Section, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  HEALTH_COLOR_BY_LEVEL,
  healthToAttribute,
  jobIsHead,
  jobToColor,
  STAT_DEAD,
  statToIcon,
} from './constants';
import { HealthStat } from './HealthStat';
import type { CrewConsoleData } from './types';

export function TableView(props) {
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

function CrewTableEntry(props) {
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
}
