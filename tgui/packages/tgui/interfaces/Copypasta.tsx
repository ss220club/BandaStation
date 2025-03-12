import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export function Copypasta(props) {
  const { act } = useBackend();
  return (
    <Window height={240} title="Game Panel" width={280} theme="admin">
      <Window.Content>
        <Stack
          height="100%"
          vertical
          align="center"
          verticalAlign="center"
          textAlign="center"
          direction="column"
          justify="space-around"
          fillPositionedParent
        >
          <Button
            fluid
            content="(Game Mode Panel)"
            onClick={() => act('game-mode-panel')}
          />
          <Button
            fluid
            content={'Create Object'}
            onClick={() => act('create-object')}
          />
          <Button
            fluid
            content="Quick Create Object"
            onClick={() => act('quick-create-object')}
          />
          <Button
            fluid
            content="Create Turf"
            onClick={() => act('create-turf')}
          />
          <Button
            fluid
            content="Create Mob"
            onClick={() => act('create-mob')}
          />
        </Stack>
      </Window.Content>
    </Window>
  );
}
