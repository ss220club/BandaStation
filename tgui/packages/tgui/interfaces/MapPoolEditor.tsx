import {
  BlockQuote,
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type MapEntry = {
  map_name: string;
  display_name: string;
  config_count: number;
  remaining_count: number;
};

type Data = {
  maps: MapEntry[];
  last_played: string | null;
  remaining_total: number;
};

export function MapPoolEditor() {
  const { act, data } = useBackend<Data>();
  const { maps, last_played, remaining_total } = data;

  return (
    <Window title="Редактор пула карт" width={480} height={560}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title={`Текущий пул (${remaining_total} шт.)`}
              buttons={
                <Button
                  icon="rotate-left"
                  color="orange"
                  tooltip="Перечитать конфиг и сбросить остаток к начальному составу"
                  onClick={() => act('reset_remaining')}
                >
                  Сбросить
                </Button>
              }
            >
              {last_played && (
                <BlockQuote style={{ lineHeight: '24px' }}>
                  Последняя карта: <b>{last_played}</b>
                </BlockQuote>
              )}
              <Stack vertical>
                {maps.map((entry) => (
                  <Stack
                    key={entry.map_name}
                    className="candystripe"
                    style={{
                      alignContent: 'center',
                      lineHeight: '24px',
                      gap: '10px',
                      padding: '3px 5px 3px 8px',
                    }}
                  >
                    <Stack.Item style={{ fontSize: '20px', display: 'flex', gap: '10px' }}>
                      <Box
                        color={entry.remaining_count === 0 ? 'bad' : 'good'}
                        inline
                      >
                        {entry.remaining_count}
                      </Box>
                      <Box>/</Box>
                      <Box color="label" inline>
                        {entry.config_count}
                      </Box>
                    </Stack.Item>
                    <Stack.Item grow>{entry.display_name}</Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="minus"
                        disabled={entry.remaining_count === 0}
                        onClick={() => act('remove_one', { map_name: entry.map_name })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="plus"
                        onClick={() => act('add_one', { map_name: entry.map_name })}
                      />
                    </Stack.Item>
                  </Stack>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item style={{ marginBottom: '-5px', marginTop: 'auto' }}>
            <NoticeBox info>
              Пул определяет то, за какие карты игроки могут голосовать. Сыгранные карты убираются из
              пула. Когда пул пустеет, он обновляется согласно конфигурации. Одинаковая карта
              не может идти два раза подряд.
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
