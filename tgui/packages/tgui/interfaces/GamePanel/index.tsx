import { useState } from 'react';
import { Button, Dropdown, Input, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

export function GamePanel(props) {
  const { act, data } = useBackend<GamePanelData>();
  const { subwindowTitle, objList, whereDropdownValue } = data;
  const [selectedTab, setSelectedTab] = useState(0);
  const [selectedRadio, setSelectedRadio] = useState(1);
  const [whereDropdownVal, setWhereDropdownVal] = useState(
    'On floor below own mob',
  );
  const whereDropdownOptions = [
    'On floor below own mob',
    'On floor below own mob, dropped via supply pod',
    "In own's mob hand",
    'In marked object',
  ];
  const tabs = [
    {
      content: 'Create Object',
      handleClick: () => {
        setSelectedTab(0);
        act('create-object');
      },
      icon: 'fa-wrench',
    },
    {
      content: 'Quick Create Object',
      handleClick: () => {
        setSelectedTab(1);
        act('quick-create-object');
      },
      icon: 'fa-bolt',
    },
    {
      content: 'Create Turf',
      handleClick: () => {
        setSelectedTab(2);
        act('create-turf');
      },
      icon: 'fa-map',
    },
    {
      content: 'Create Mob',
      handleClick: () => {
        setSelectedTab(3);
        act('create-mob');
      },
      icon: 'fa-person',
    },
  ] as tab[];

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
                (Game Mode Panel)
              </Button>
            </Stack.Item>
          </Stack>
          <Stack.Divider />
          {/* Main window */}
          <Stack.Item grow basis="85%">
            {/* <CreateMobPanel mobs /> */}
            <Stack fill vertical>
              <Stack.Item>
                Type:
                <Input
                  width="280px"
                  ml={1}
                  placeholder={'Search for ' + subwindowTitle?.split(' ')[1]}
                />
                <Button onClick={() => act('update-search')}>Search</Button>
              </Stack.Item>
              <Stack.Item>
                Offset: <Input width="250px" mr={2} placeholder="x,y,z" />
                <Button.Checkbox
                  circular
                  selected={selectedRadio === 0}
                  mr={1}
                  icon="fa-a"
                  onClick={() => {
                    setSelectedRadio(0);
                    act('set-absolute-cords');
                  }}
                />
                <Button.Checkbox
                  circular
                  selected={selectedRadio === 1}
                  icon="fa-r"
                  onClick={() => {
                    setSelectedRadio(1);
                    act('set-relative-cords');
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                Number: <Input width="30px" mr={1} value={1} />
                Dir: <Input width="30px" mr={1} />
                Name: <Input width="180px" mr={1} />
              </Stack.Item>
              <Stack.Item>
                <Dropdown
                  width="320px"
                  options={whereDropdownOptions}
                  onSelected={(value) => {
                    setWhereDropdownVal(value);
                    act('where-dropdown-changed', {
                      newWhere: value,
                    });
                  }}
                  selected={whereDropdownVal}
                />
              </Stack.Item>
            </Stack>
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

export type GamePanelData = {
  subwindowTitle: string;
  objList: string[];
  whereDropdownValue: string;
};
