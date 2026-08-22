import { useState } from 'react';
import { Box, Button, Dropdown, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  credits_stored: number;
  active: boolean;
  attached: boolean;
  nearby_players: { name: string; ref: string }[];
};

export const CreditSiphon = () => {
  const { act, data } = useBackend<Data>();
  const { credits_stored, active, attached, nearby_players = [] } = data;
  const [target, setTarget] = useState('');
  const targetOptions = nearby_players.map((player) => ({
    displayText: player.name,
    value: player.ref,
  }));

  return (
    <Window width={280} height={250} title="Credit Siphon">
      <Window.Content>
        <Section title="Stored credits">
          <Box textAlign="center" fontSize={2} mb={2}>
            {credits_stored} cr <Icon color="gold" name="coins" />
          </Box>
          <Button
            fluid
            icon={active ? 'power-off' : 'play'}
            color={active ? 'red' : 'green'}
            onClick={() => act('toggle')}
          >
            {active ? 'Disable siphon' : 'Enable siphon'}
          </Button>
          <Button
            fluid
            icon="user-secret"
            disabled={attached || !target}
            onClick={() => act('attach', { target })}
          >
            {attached ? 'Attached to a player' : 'Attach to nearby player'}
          </Button>
          <Dropdown
            fluid
            disabled={attached || !targetOptions.length}
            options={targetOptions}
            selected={target}
            displayText={
              targetOptions.find((option) => option.value === target)
                ?.displayText
            }
            placeholder="Select nearby player"
            onSelected={setTarget}
          />
          <Button
            fluid
            icon="money-bill-wave"
            disabled={credits_stored <= 0}
            onClick={() => act('withdraw')}
          >
            Withdraw
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
