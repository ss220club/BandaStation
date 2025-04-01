import { useEffect, useState } from 'react';
import { Button, Stack, Tabs } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { CreateObject } from './CreateObject';
import { Data, GamePanelTab, GamePanelTabName } from './types';

const GamePanelTabs = [
  {
    name: GamePanelTabName.createObject,
    content: 'Create Object',
    icon: 'fa-wrench',
  },
  {
    name: GamePanelTabName.createTurf,
    content: 'Create Turf',
    icon: 'fa-map',
  },
  {
    name: GamePanelTabName.createMob,
    content: 'Create Mob',
    icon: 'fa-person',
  },
] as GamePanelTab[];

export function GamePanel(props) {
  const { act } = useBackend();
  const [selectedTab, setSelectedTab] = useState<
    GamePanelTabName | undefined
  >();
  const [data, setData] = useState<Data | undefined>();

  useEffect(() => {
    fetchRetry(resolveAsset('gamepanel.json'))
      .then((response) => response.json())
      .then((data) => {
        setData(data);
      })
      .catch((error) => {
        logger.log('Failed to fetch gamepanel.json', error);
      });
  }, []);

  const selectedTabData = data && selectedTab && data[selectedTab];

  return (
    <Window
      height={selectedTab ? 500 : 80}
      title="Game Panel"
      width={500}
      theme="admin"
    >
      <Window.Content>
        {/* Tabs and main window */}
        <Stack vertical fill>
          {/* Tabs */}
          <Stack vertical={false}>
            <Stack.Item shrink={3} basis="70%">
              <Tabs fluid>
                {GamePanelTabs.map((tab) => (
                  <Tabs.Tab
                    key={tab.name}
                    onClick={() => setSelectedTab(tab.name)}
                    selected={selectedTab === tab.name}
                    icon={tab.icon}
                  >
                    {tab.content}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item grow>
              <Button
                height="100%"
                align="center"
                verticalAlignContent="middle"
                fluid
                onClick={() => act('game-mode-panel')}
                icon="fa-gamepad"
              >
                Game Mode Panel
              </Button>
            </Stack.Item>
          </Stack>
          <Stack.Divider />
          {/* Main window */}
          <Stack.Item grow basis="85%">
            {selectedTabData && (
              <CreateObject
                objList={selectedTabData}
                tabName={selectedTab || ''}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
