import {
  Box,
  Button,
  Dropdown,
  Icon,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { JOBS_RU } from '../bandastation/ru_jobs';
import { Window } from '../layouts';

type Assignment = {
  ckey: string;
  job: string | null;
  status: 'offline' | 'not_ready' | 'ready';
};

type Data = {
  rows: Assignment[];
  jobs: string[];
  editable: BooleanLike;
};

const statusColors = {
  offline: 'label',
  not_ready: 'average',
  ready: 'good',
};

const statusLabels = {
  offline: 'Вышел',
  not_ready: 'Не готов',
  ready: 'Готов',
};

export function RoundstartRoster() {
  const { act, data } = useBackend<Data>();
  const { rows, jobs, editable } = data;
  const readyCount = rows.filter((row) => row.status === 'ready').length;

  return (
    <Window width={460} height={500} theme="admin">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Участники"
              buttons={
                <Box color={readyCount > 0 ? 'good' : 'label'}>
                  Готовы {readyCount}/{rows.length}
                </Box>
              }
            >
              {!editable && <Box mb={1}>Идёт распределение должностей.</Box>}
              <Table>
                <Table.Row header color="label">
                  <Table.Cell width="8rem">ckey</Table.Cell>
                  <Table.Cell width="7rem">Статус</Table.Cell>
                  <Table.Cell>Должность</Table.Cell>
                  <Table.Cell collapsing />
                </Table.Row>
                {rows.map((row) => (
                  <Table.Row key={row.ckey}>
                    <Table.Cell
                      width="8rem"
                      style={{ overflowWrap: 'anywhere' }}
                    >
                      <Box bold>{row.ckey}</Box>
                    </Table.Cell>
                    <Table.Cell width="7rem" color={statusColors[row.status]}>
                      <Icon name="circle" mr={0.5} size={0.7} />
                      {statusLabels[row.status]}
                    </Table.Cell>
                    <Table.Cell>
                      <Dropdown
                        fluid
                        disabled={!editable}
                        placeholder="Выберите должность"
                        selected={row.job || undefined}
                        displayText={
                          row.job ? JOBS_RU[row.job] || row.job : undefined
                        }
                        options={jobs.map((job) => ({
                          displayText: JOBS_RU[job] || job,
                          value: job,
                        }))}
                        onSelected={(job) =>
                          act('set_job', { ckey: row.ckey, job })
                        }
                      />
                    </Table.Cell>
                    <Table.Cell collapsing>
                      <Button
                        color="bad"
                        icon="trash-alt"
                        tooltip="Удалить назначение"
                        tooltipPosition="left"
                        disabled={!editable}
                        onClick={() => act('remove', { ckey: row.ckey })}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
          <Stack.Item textAlign="center">
            <Button icon="plus" disabled={!editable} onClick={() => act('add')}>
              Добавить участника
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
