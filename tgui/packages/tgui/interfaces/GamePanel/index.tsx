import { useEffect, useState } from 'react';
import { Button, Stack, Tabs } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { CreateObject } from './CreateObject';
import { Data, tab } from './types';

export function GamePanel(props) {
  const { act } = useBackend();
  const [selectedTab, setSelectedTab] = useState(-1);
  const [compact, setCompact] = useState(1);
  const [data, setData] = useState<Data>(null);
  const [selectedTabName, setSelectedTabName] = useState();
  // const [searchTextValue, setSearchTextValue] = useState('');
  const [isLoading, setIsLoading] = useState<Boolean>(false);
  const tabs = [
    {
      content: 'Create Object',
      handleClick: () => {
        loadTab('Object', 0);
      },
      icon: 'fa-wrench',
    },
    {
      content: 'Create Turf',
      handleClick: () => {
        loadTab('Turf', 1);
      },
      icon: 'fa-map',
    },
    {
      content: 'Create Mob',
      handleClick: () => {
        loadTab('Mob', 2);
      },
      icon: 'fa-person',
    },
  ] as tab[];

  function loadTab(tabName, tabIndex) {
    setSelectedTabName(tabName);
    setSelectedTab(tabIndex);
    // setSearchTextValue('');
    setCompact(0);
    setIsLoading(true);
    setTimeout(() => setIsLoading(false), 0);
  }

  useEffect(
    () =>
      fetchRetry(resolveAsset('gamepanel.json'))
        .then((response) => response.json())
        .then((data) => {
          setData(data);
        })
        .catch((error) => {
          logger.log('Failed to fetch gamepanel.json', error);
        }),
    [],
  );
  function isReadyToRender(): boolean {
    return !compact && data && data[selectedTabName] && !isLoading;
  }
  return (
    <Window
      height={compact ? 80 : 500}
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
            {isReadyToRender() && (
              <CreateObject
                // searchTextValue={searchTextValue}
                data={data}
                currentPanel={selectedTabName}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
