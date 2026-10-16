import {
  Box,
  Button,
  Dropdown,
  NoticeBox,
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
  offline: '#45474b',
  not_ready: '#756122',
  ready: '#285c3a',
};

const statusLabels = {
  offline: 'Вышел',
  not_ready: 'Не готов',
  ready: 'Готов',
};

export function RoundstartRoster() {
  const { act, data } = useBackend<Data>();
  const { rows, jobs, editable } = data;

  return (
    <Window width={440} height={720}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <NoticeBox>
              Должность получат только готовые игроки. Для остальных назначение
              отменяется при старте раунда.
            </NoticeBox>
            {!editable && (
              <NoticeBox info>Идёт распределение должностей.</NoticeBox>
            )}
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <Stack vertical>
                <Stack.Item>
                  <Stack bold>
                    <Stack.Item grow>ckey</Stack.Item>
                    <Stack.Item width="16rem">Должность</Stack.Item>
                  </Stack>
                </Stack.Item>
                {rows.map((row) => (
                  <Stack.Item key={row.ckey}>
                    <Box p={1} backgroundColor={statusColors[row.status]}>
                      <Stack align="center">
                        <Stack.Item
                          grow
                          minWidth={0}
                          style={{ overflowWrap: 'anywhere' }}
                        >
                          <Box bold>{row.ckey}</Box>
                          <Box fontSize="0.8em">{statusLabels[row.status]}</Box>
                        </Stack.Item>
                        <Stack.Item width="13rem">
                          <Dropdown
                            fluid
                            disabled={!editable}
                            placeholder="Выберите должность"
                            selected={row.job || undefined}
                            options={jobs.map((job) => ({
                              displayText: JOBS_RU[job] || job,
                              value: job,
                            }))}
                            onSelected={(job) =>
                              act('set_job', { ckey: row.ckey, job })
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
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
          <Stack.Item>
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
