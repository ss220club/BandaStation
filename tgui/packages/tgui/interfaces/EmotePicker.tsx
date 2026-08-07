import { useBackend } from '../backend';
import { Button, Input, Section, Stack } from 'tgui-core/components';
import { Window } from '../layouts';
import { useState } from 'react';

type Emote = {
  key: string;
  name: string;
  category: string;
};

type Data = {
  slot: number;
  emotes: Emote[];
};

export function EmotePicker(_props: Record<string, never>, context) {
  const { act, data } = useBackend<Data>();

  const [search, setSearch] = useState('');

  const filtered = data.emotes.filter(e =>
    e.name.toLowerCase().includes(search.toLowerCase()) ||
    e.key.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Window
      width={420}
      height={600}>
      <Window.Content scrollable>
        <Stack vertical fill>

          <Stack.Item>
            <Input
              fluid
              placeholder="Поиск..."
              value={search}
              onChange={(value) => setSearch(String(value))}
            />
          </Stack.Item>

          <Stack.Item grow>
            <Section title={`Эмоция для слота ${data.slot}`}>
              {filtered.map(emote => (
                <Button
                  fluid
                  key={emote.key}
                  mb={0.5}
                  onClick={() =>
                    act('select', {
                      key: emote.key,
                    })
                  }>
                  {emote.name}
                </Button>
              ))}
            </Section>
          </Stack.Item>

        </Stack>
      </Window.Content>
    </Window>
  );
};

export default EmotePicker;
