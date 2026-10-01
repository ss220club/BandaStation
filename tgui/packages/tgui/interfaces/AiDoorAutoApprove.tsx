import { useState } from 'react';
import { Box, Button, NoticeBox, Section, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Entry = { key: string; name: string };

type Data = {
  enabled: boolean;
  names: Entry[];
};

export function AiDoorAutoApprove() {
  const { act, data } = useBackend<Data>();
  const { enabled, names = [] } = data;

  const [newName, setNewName] = useState('');

  return (
    <Window title="Автоодобрение шлюзов" width={480} height={420}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Состояние">
              <Stack>
                <Stack.Item grow>
                  <Button.Checkbox
                    checked={enabled}
                    fluid
                    onClick={() => act('toggle')}
                    lineHeight="2em"
                  >
                    {enabled ? 'Включено' : 'Выключено'}
                  </Button.Checkbox>
                </Stack.Item>
                <Stack.Item>
                  <Button.Confirm
                    color="bad"
                    confirmContent="ОЧИСТИТЬ?"
                    onClick={() => act('clear')}
                    lineHeight="2em"
                  >
                    Очистить
                  </Button.Confirm>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Добавить имя">
              <Stack fill>
                <Stack.Item grow>
                  <TextArea
                    fluid
                    height="2.2em"
                    value={newName}
                    placeholder="Имя персонажа"
                    onChange={(value) => setNewName(value)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('add', { name: newName });
                      setNewName('');
                    }}
                    lineHeight="2em"
                  >
                    Добавить
                  </Button>
                </Stack.Item>
              </Stack>
              <Box mt={1} color="label">
                Сверка идёт по видимому для вас имени.
              </Box>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section fill scrollable title="Список имён">
              {names.length === 0 ? (
                <NoticeBox info mb={0}>
                  Список пуст.
                </NoticeBox>
              ) : (
                <Stack fill vertical>
                  {names.map((entry) => (
                    <Stack.Item key={entry.key}>
                      <Stack>
                        <Stack.Item grow>
                          <Box>{entry.name}</Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            color="bad"
                            onClick={() => act('remove', { key: entry.key })}
                          >
                            Удалить
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  ))}
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
