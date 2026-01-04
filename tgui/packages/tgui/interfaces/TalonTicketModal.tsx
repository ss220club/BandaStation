import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ButtonData = {
  name: string;
  weight: number;
};

type Data = {
  message: string;
  buttons: ButtonData[];
  title: string;
  remaining_cells: number;
  total_cells: number;
};

export function TalonTicketModal(props) {
  const { act, data } = useBackend<Data>();
  const {
    message = '',
    buttons = [],
    title,
    remaining_cells = 0,
    total_cells = 0
  } = data;

  return (
    <Window title={title} width={400} height={280}>
      <Window.Content>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <Box color="good" textAlign="center">
                Оставшиеся ячейки: {remaining_cells} / {total_cells}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Stack fill vertical>
                {buttons.map((button, index) => (
                  <Stack.Item key={index}>
                    <Button
                      fluid
                      onClick={() => act('choose', { choice: button.name })}
                      textAlign="center"
                      disabled={button.weight > remaining_cells}
                      color={button.weight > remaining_cells ? 'bad' : 'default'}
                    >
                      {button.name} ({button.weight} яч.)
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}
