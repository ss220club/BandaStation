import { useState } from 'react';
import { Box, Button, Dropdown, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  credits_stored: number;
  tc_price: number;
  tc_purchase_limit: number;
  tc_purchased: number;
  player_count: number;
  traitor_count: number;
  active: boolean;
  attached: boolean;
  nearby_players: { name: string; ref: string }[];
};

export const CreditSiphon = () => {
  const { act, data } = useBackend<Data>();
  const {
    credits_stored,
    tc_price,
    tc_purchase_limit,
    tc_purchased,
    player_count,
    traitor_count,
    active,
    attached,
    nearby_players = [],
  } = data;
  const [target, setTarget] = useState('');
  const targetOptions = nearby_players.map((player) => ({
    displayText: player.name,
    value: player.ref,
  }));

  return (
    <Window width={280} height={390} title="Credit Siphon">
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
        <Section title="Credit exchange">
          <Box textAlign="center" mb={1}>
            {tc_price} cr / TC <Icon color="gold" name="coins" />
          </Box>
          <Box textAlign="center" mb={1}>
            {tc_purchased} / {tc_purchase_limit} TC purchased
          </Box>
          <Box textAlign="center" mb={1}>
            {player_count} online, {traitor_count} traitors
          </Box>
          <Button
            fluid
            icon="gem"
            disabled={
              credits_stored < tc_price || tc_purchased >= tc_purchase_limit
            }
            onClick={() => act('buy_tc')}
          >
            Buy 1 TC
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
