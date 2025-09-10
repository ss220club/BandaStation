import { Button, Divider, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { useState } from 'react';

export function CheckAntagonists() {
  const { act } = useBackend();
  // const [data, setData] = useState<RoundInfo>();
  const { data } = useBackend<RoundInfo>();
  const [ selectedIndex, setSelectedIndex ] = useState<number>(0);
  const buttons = ["Round", "Shuttle", "Antagonists"]
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
        {data &&
          <Stack vertical>
            <Stack fill align="center" verticalAlign="middle" textAlign="center">
              {buttons.map((item, index) => (
                <Stack.Item grow >
                  <Button selected={selectedIndex==index} onClick={() => setSelectedIndex(index)} fluid>{item}</Button>
                </Stack.Item>
              ))}
            </Stack>
            <Divider></Divider>
            <Stack vertical fill>
              <Stack.Item>{data.round_duration}</Stack.Item>
              <Stack.Item>{"Test"}</Stack.Item>
              <Stack.Item>{data.is_idle_or_recalled}</Stack.Item>
              <Stack.Item>{data.time_left}</Stack.Item>
              <Stack.Item>{data.is_called}</Stack.Item>
              <Stack.Item>{data.is_delayed}</Stack.Item>
              <Stack.Item>{data.connected_players}</Stack.Item>
              <Stack.Item>{data.lobby_players}</Stack.Item>
            </Stack>
          </Stack>
        }
      </Window.Content>
    </Window>
  );
}


export type RoundInfo = {
  round_duration: string;
  is_idle_or_recalled: boolean;
  time_left: string;
  is_called: boolean;
  is_delayed: boolean;
  connected_players: number;
  lobby_players: number;
  observers: number;
  observers_connected: number;
  living_players: number;
  living_players_connected: number;
  antagonists: number;
  antagonists_dead: number;
  brains: number;
  other_players: number;
  living_skipped: number;
  drones: number;
  security: number;
  security_dead: number;
  antagonists_info: AntagInfo[];
};

export type AntagInfo = {
  ckey: string;
}
