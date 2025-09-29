import { useEffect, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Section, Stack, Table, Tabs } from 'tgui-core/components';

type Data = {
  availability: number;
  last_caller: string | null;
  current_display_name: string;
  current_phone_id: string;
  available_transmitters: string[];
  transmitters: {
    phone_category: string;
    phone_color: string;
    phone_id: string;
    phone_icon: string;
    display_name: string;
  }[];
};

export const PhoneMenu = (props) => {
  const { act, data } = useBackend();
  return (
    <Window title="Telephone" width={500} height={400}>
      <Window.Content>
        <GeneralPanel />
      </Window.Content>
    </Window>
  );
};

const GeneralPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { availability, last_caller } = data;
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

  let dnd_tooltip = 'Do Not Disturb is DISABLED';
  let dnd_locked = 'No';
  let dnd_icon = 'volume-high';
  if (availability === 1) {
    dnd_tooltip = 'Do Not Disturb is ENABLED';
    dnd_icon = 'volume-xmark';
  } else if (availability >= 2) {
    dnd_tooltip = 'Do Not Disturb is ENABLED (LOCKED)';
    dnd_locked = 'Yes';
    dnd_icon = 'volume-xmark';
  } else if (availability < 0) {
    dnd_tooltip = 'Do Not Disturb is DISABLED (LOCKED)';
    dnd_locked = 'Yes';
  }

  return (
    <Box height="100%">
      <Stack fill>
        <Stack.Item width="30%">
          <Stack vertical fill>
            <Stack.Item>
              <Section>
                <Button.Checkbox
                  color="red"
                  tooltip={dnd_tooltip}
                  disabled={dnd_locked === 'Yes'}
                  checked={availability >= 1}
                  fluid
                  textAlign="center"
                  onClick={() => act('toggle_dnd')}
                  lineHeight="3em"
                >
                  Do Not Disturb
                </Button.Checkbox>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section title="Call History" fill>
                <Box height="calc(100% - 1.5em)">
                  {!!last_caller && <Box>{last_caller}</Box>}
                </Box>
                <Button.Confirm
                  icon="trash"
                  color="transparent"
                  confirmColor="red"
                  confirmIcon="close"
                  fluid
                >
                  Clear
                </Button.Confirm>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Stack vertical fill>
            <Stack.Item>
              <Stack.Item>
                <Section>
                  <Table>
                    <Table.Row className="candystripe">
                      <Table.Cell p={0.25}>Display Name</Table.Cell>
                      <Table.Cell>{data.current_display_name}</Table.Cell>
                    </Table.Row>
                    <Table.Row className="candystripe">
                      <Table.Cell p={0.25}>Device ID</Table.Cell>
                      <Table.Cell>{data.current_phone_id}</Table.Cell>
                    </Table.Row>
                  </Table>
                </Section>
              </Stack.Item>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill>
                <Stack vertical fill>
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
                  <Stack.Item grow>
                    <Section fill scrollable>
                      {transmitters
                        .filter((val) => {
                          const cat =
                            typeof val.phone_category === 'string'
                              ? val.phone_category.trim()
                              : '';
                          // If no current category selected, show all; otherwise match exactly
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
                            {val.display_name}
                          </Button>
                        ))}
                    </Section>
                  </Stack.Item>
                  {!!selectedPhone && (
                    <Stack.Item>
                      <Button
                        color="good"
                        fluid
                        textAlign="center"
                        onClick={() =>
                          act('call_phone', { phone_id: selectedPhone })
                        }
                      >
                        Dial
                      </Button>
                    </Stack.Item>
                  )}
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
