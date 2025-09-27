import { Button, Divider, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { useState } from 'react';
import { RoundInfo, RoundTabInfo } from './types';
import { RoundTab } from './RoundTab';

export function CheckAntagonists() {
  const { act } = useBackend();
  // const [data, setData] = useState<RoundInfo>();
  const { data } = useBackend<RoundInfo>();
  const [ selectedIndex, setSelectedIndex ] = useState<number>(0);
  const tabs = ["Antagonists", "Shuttle", "Round"]
  const roundTabInfo: RoundTabInfo = data;
  return (
    <Window
      height={290}
      title="Round Status"
      width={600}
      theme="ntos_darkmode"
      buttons={
        <Button fluid onClick={() => act('game-mode-panel')} icon="gamepad">
          Game Mode Panel
        </Button>
      }
    >
      <Window.Content>
        {data &&
          <Stack vertical>
            <Tabs mb="0px" fontSize="13px" fill fluid align="center" verticalAlign="middle" textAlign="center">
              {tabs.map((item, index) => (
                <Tabs.Tab width="33%" selected={selectedIndex==index} onClick={() => setSelectedIndex(index)}>
                  {item}
                </Tabs.Tab>
              ))}
            </Tabs>
            {selectedIndex==2 &&
              <RoundTab roundTabInfo={roundTabInfo} />
            }
        </Stack>
        }
      </Window.Content>
    </Window>
  );
}



