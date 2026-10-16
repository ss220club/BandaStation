import {
  Box,
  Button,
  Dropdown,
  Icon,
  Section,
  Stack,
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
  offline: '#a0a6ad',
  not_ready: '#e5b94b',
  ready: '#65c77a',
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
    <Window width={460} height={500}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item p={1}>
            <Box color="label" mb={1}>
              Должности получат только готовые игроки.
            </Box>
            <Box color={readyCount > 0 ? statusColors.ready : 'label'}>
              Готовы {readyCount}/{rows.length}
            </Box>
            {!editable && <Box mt={1}>Идёт распределение должностей.</Box>}
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable backgroundColor="#1b1b1b">
              <Stack vertical>
                <Stack.Item px={1} color="label">
                  <Stack align="center">
                    <Stack.Item width="8rem" minWidth={0}>
                      ckey
                    </Stack.Item>
                    <Stack.Item grow>Статус</Stack.Item>
                    <Stack.Item width="12rem">Должность</Stack.Item>
                    <Stack.Item width="2rem" />
                  </Stack>
                </Stack.Item>
                {rows.length === 0 && (
                  <Stack.Item p={1} color="label">
                    Добавьте участников кнопкой ниже.
                  </Stack.Item>
                )}
                {rows.map((row) => (
                  <Stack.Item key={row.ckey}>
                    <Box
                      p={1}
                      backgroundColor="#242424"
                      style={{
                        border: '1px solid #414141',
                        borderRadius: '4px',
                      }}
                    >
                      <Stack align="center">
                        <Stack.Item
                          width="8rem"
                          minWidth={0}
                          style={{ overflowWrap: 'anywhere' }}
                        >
                          <Box bold>{row.ckey}</Box>
                        </Stack.Item>
                        <Stack.Item grow color={statusColors[row.status]}>
                          <Icon name="circle" mr={0.5} size={0.7} />
                          {statusLabels[row.status]}
                        </Stack.Item>
                        <Stack.Item width="12rem">
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
                        </Stack.Item>
                        <Stack.Item width="2rem">
                          <Button
                            icon="trash"
                            color="transparent"
                            tooltip="Удалить назначение"
                            disabled={!editable}
                            onClick={() => act('remove', { ckey: row.ckey })}
                          />
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item mx={1} mb={1}>
            <Button
              fluid
              icon="plus"
              textAlign="center"
              disabled={!editable}
              onClick={() => act('add')}
            >
              Добавить участника
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
