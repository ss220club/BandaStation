import { Box, Button, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  credits_stored: number;
};

export const CreditSiphon = () => {
  const { act, data } = useBackend<Data>();
  const { credits_stored } = data;

  return (
    <Window width={280} height={150} title="Credit Siphon">
      <Window.Content>
        <Section title="Stored credits">
          <Box textAlign="center" fontSize={2} mb={2}>
            {credits_stored} cr <Icon color="gold" name="coins" />
          </Box>
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
