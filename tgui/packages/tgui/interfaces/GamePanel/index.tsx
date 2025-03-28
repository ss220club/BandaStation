import { useState } from 'react';
import { Button, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CreateObject } from './CreateObject';

export function GamePanel(props) {
  const { act } = useBackend();
  const [selectedObj, setSelectedObj] = useState(-1);
  const [selectedTab, setSelectedTab] = useState(-1);
  const tabs = [
    {
      content: 'Create Object',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(0);
        act('create-object');
      },
      icon: 'fa-wrench',
    },
    {
      content: 'Quick Create Object',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(1);
        act('quick-create-object');
      },
      icon: 'fa-bolt',
    },
    {
      content: 'Create Turf',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(2);
        act('create-turf');
      },
      icon: 'fa-map',
    },
    {
      content: 'Create Mob',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(3);
        act('create-mob');
      },
      icon: 'fa-person',
    },
  ] as tab[];

  function clearSelectedObject() {
    setSelectedObj(-1);
    act('selected-object-changed', { newObj: -1 });
  }

  return (
    <Window height={500} title="Game Panel" width={700} theme="admin">
      <Window.Content>
        {/* Tabs and main window */}
        <Stack vertical fill>
          {/* Tabs */}
          <Stack vertical={false}>
            <Stack.Item shrink={3} basis="70%">
              <Tabs fluid>
                {tabs.map((tabElement: tab, index: number) => (
                  <Tabs.Tab
                    key={index}
                    onClick={tabElement.handleClick}
                    selected={selectedTab === index}
                    icon={tabElement.icon}
                  >
                    {tabElement.content}
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
            <CreateObject />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

interface tab {
  content: string;
  handleClick: (e: any) => void;
  icon;
}
