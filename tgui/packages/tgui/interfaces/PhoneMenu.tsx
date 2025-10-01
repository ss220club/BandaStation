import { useEffect, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  BlockQuote,
  Box,
  Button,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type Data = {
  availability: number;
  last_caller: string | null;
  current_display_name: string;
  current_phone_id: string;
  available_transmitters: string[];
  callers_list?: { dir: 'in' | 'out'; id: string; name: string }[];
  transmitters: {
    phone_category: string;
    phone_color: string;
    phone_id: string;
    phone_icon: string;
    display_name: string;
  }[];
  is_advanced: BooleanLike;
};

export const PhoneMenu = (props) => {
  const { act, data } = useBackend();
  return (
    <Window title="Телефон" width={500} height={400} theme="retro">
      <Window.Content>
        <GeneralPanel />
      </Window.Content>
    </Window>
  );
};

const GeneralPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { availability, last_caller } = data;
  const isAdvanced = !!Number((data as any).is_advanced);
  const callers = Array.isArray(data.callers_list) ? data.callers_list : [];
  const available_transmitters = data.available_transmitters || [];

  const transmitters = (data.transmitters || []).filter((val1) =>
    available_transmitters.includes(val1.phone_id),
  );

  console.log('transmitters:', transmitters);
  transmitters.forEach((t, i) => {
    if (typeof t.phone_category !== 'string') {
      console.warn(`Bad phone_category at index ${i}:`, t.phone_category, t);
    }
  });

  const categories: string[] = [];
  transmitters.forEach((t) => {
    const category =
      typeof t.phone_category === 'string' ? t.phone_category.trim() : null;
    if (category && category.length > 0 && !categories.includes(category)) {
      categories.push(category);
    }
  });
  const showTabs = categories.length > 1;

  const [selectedPhone, setSelectedPhone] = useState<string | null>(null);
  const [currentCategory, setCategory] = useState(categories[0] || '');

  useEffect(() => {
    if (categories.length && !categories.includes(currentCategory)) {
      setCategory(categories[0]);
    }
  }, [categories, currentCategory]);

  // Reset selected phone when category changes so selection doesn't leak across tabs
  useEffect(() => {
    setSelectedPhone(null);
  }, [currentCategory]);

  const dnd_state =
    typeof availability === 'string' ? availability : String(availability);
  const dnd_is_on = dnd_state === 'On' || dnd_state === 'Forced';
  const dnd_locked_bool = dnd_state === 'Forced' || dnd_state === 'Forbidden';
  const dnd_locked = dnd_locked_bool ? 'Yes' : 'No';
  const dnd_icon = dnd_is_on ? 'volume-xmark' : 'volume-high';
  const dnd_tooltip =
    dnd_state === 'Forced'
      ? 'Do Not Disturb is ENABLED (LOCKED)'
      : dnd_state === 'Forbidden'
        ? 'Do Not Disturb is DISABLED (LOCKED)'
        : dnd_is_on
          ? 'Do Not Disturb is ENABLED'
          : 'Do Not Disturb is DISABLED';

  return (
    <Box height="100%">
      <Stack fill vertical>
        <Stack.Item grow>
          {' '}
          {/* Первый горизонтальный */}
          <Stack fill>
            {isAdvanced && (
              <Stack.Item width="30%">
                <Section title="История звонков" fill pb="1.5em">
                  <Box
                    height="calc(100% - 1.5em)"
                    style={{ overflowY: 'auto' }}
                  >
                    {callers.length === 0 && !!last_caller && (
                      <Box>{last_caller}</Box>
                    )}
                    {callers.map((c, idx) => (
                      <BlockQuote
                        key={idx}
                        color={c.dir === 'in' ? 'red' : 'green'}
                        textAlign="left"
                        style={{
                          whiteSpace: 'normal',
                          wordBreak: 'break-word',
                          paddingLeft: '5px',
                        }}
                      >
                        {c.name} ({c.id})
                      </BlockQuote>
                    ))}
                  </Box>
                  <Button.Confirm
                    icon="trash"
                    confirmColor="red"
                    confirmIcon="close"
                    fluid
                    onClick={() => act('clear_history')}
                    mb="1em"
                    height="3em"
                    style={{ alignContent: 'center' }}
                  >
                    Очистить
                  </Button.Confirm>
                </Section>
              </Stack.Item>
            )}
            <Stack.Item grow>
              <Section fill title="Телефонная книга">
                <Stack vertical fill>
                  {showTabs && (
                    <Stack.Item>
                      <Tabs>
                        {categories.map((val) => (
                          <Tabs.Tab
                            selected={val === currentCategory}
                            onClick={() => setCategory(val)}
                            key={val}
                          >
                            {val}
                          </Tabs.Tab>
                        ))}
                      </Tabs>
                    </Stack.Item>
                  )}
                  <Stack.Item grow>
                    <Section fill scrollable>
                      {transmitters
                        .filter((val) => {
                          const cat =
                            typeof val.phone_category === 'string'
                              ? val.phone_category.trim()
                              : '';
                          return !currentCategory || cat === currentCategory;
                        })
                        .map((val) => (
                          <Button
                            key={val.phone_id}
                            icon={val.phone_icon}
                            fluid
                            selected={selectedPhone === val.phone_id}
                            onClick={() => setSelectedPhone(val.phone_id)}
                            style={{ marginBottom: '0.5em', textAlign: 'left' }}
                          >
                            {val.display_name} ({val.phone_id})
                          </Button>
                        ))}
                    </Section>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      textAlign="center"
                      style={{ alignContent: 'center' }}
                      fontSize="1.5em"
                      disabled={!(data as any)?.current_call && !selectedPhone}
                      onClick={() =>
                        (data as any)?.current_call
                          ? act('hangup')
                          : act('call_phone', { phone_id: selectedPhone })
                      }
                    >
                      {(data as any)?.current_call ? `Завершить` : 'Вызов'}
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack fill>
            <Stack.Item width="30%">
              <Section>
                <Button.Checkbox
                  tooltip={dnd_tooltip}
                  disabled={dnd_locked === 'Yes'}
                  checked={dnd_is_on}
                  fluid
                  textAlign="center"
                  onClick={() => act('toggle_dnd')}
                  lineHeight="3em"
                >
                  Не беспокоить
                </Button.Checkbox>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Stack.Item>
                <Section>
                  <Table>
                    <Table.Row className="candystripe">
                      <Table.Cell p={0.4}>Имя устройства</Table.Cell>
                      <Table.Cell>{data.current_display_name}</Table.Cell>
                    </Table.Row>
                    <Table.Row className="candystripe">
                      <Table.Cell p={0.4}>ID устройства</Table.Cell>
                      <Table.Cell>{data.current_phone_id}</Table.Cell>
                    </Table.Row>
                  </Table>
                </Section>
              </Stack.Item>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
