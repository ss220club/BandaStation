import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

export function CheckAntagonists() {
  const { act } = useBackend();
  // const [data, setData] = useState<CreateObjectData | undefined>();

  return (
    <Window
      height={500}
      title="Round Status"
      width={500}
      theme="admin"
      buttons={
        <Button fluid onClick={() => act('game-mode-panel')} icon="gamepad">
          Game Mode Panel
        </Button>
      }
    >
      <Window.Content>
        <Stack vertical fill>
          {/* <Stack.Item grow>{data && "xdd"}</Stack.Item> */}
          <Stack.Item grow>{"xdd"}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
