import { useState } from 'react';
import {
  Button,
  Dropdown,
  Input,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

export function GamePanel(props) {
  const { act, data } = useBackend<GamePanelData>();
  const { subwindowTitle, objList } = data;
  const [selectedTab, setSelectedTab] = useState(-1);
  const [searchText, setSearchText] = useState('');
  const [selectedRadio, setSelectedRadio] = useState(1);
  const [selectedObj, setSelectedObj] = useState(0);
  const [whereDropdownVal, setWhereDropdownVal] = useState(
    'On floor below own mob',
  );
  let newSearchTextValue: string = '/';
  const whereDropdownOptions = [
    'On floor below own mob',
    'On floor below own mob, dropped via supply pod',
    "In own's mob hand",
    'In marked object',
  ];
  function clearSearchText() {
    setSearchText('');
  }
  function clearSelectedObject() {
    setSelectedObj(-1);
    act('selected-object-changed', { newObj: -1 });
  }
  const tabs = [
    {
      content: 'Create Object',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(0);
        clearSearchText();
        act('create-object');
      },
      icon: 'fa-wrench',
    },
    {
      content: 'Quick Create Object',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(1);
        clearSearchText();
        act('quick-create-object');
      },
      icon: 'fa-bolt',
    },
    {
      content: 'Create Turf',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(2);
        clearSearchText();
        act('create-turf');
      },
      icon: 'fa-map',
    },
    {
      content: 'Create Mob',
      handleClick: () => {
        clearSelectedObject();
        setSelectedTab(3);
        clearSearchText();
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
                Game Mode Panel
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
                  onEnter={(e, value) => {
                    value = value === '' ? '/' : value;
                    setSearchText(value);
                  }}
                  onChange={(e, value) => {
                    newSearchTextValue = value;
                  }}
                />
                <Button onClick={() => setSearchText(newSearchTextValue)}>
                  Search
                </Button>
              </Stack.Item>
              <Stack.Item>
                Offset:{' '}
                <Input
                  width="250px"
                  mr={2}
                  placeholder="x,y,z"
                  onChange={(e, value) =>
                    value
                      ? act('offset-changed', { newOffset: value })
                      : undefined
                  }
                />
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
                Number:{' '}
                <Input
                  width="30px"
                  mr={1}
                  value={1}
                  onChange={(e, value) =>
                    act('number-changed', { newNumber: value })
                  }
                />
                Dir:{' '}
                <Input
                  width="30px"
                  mr={1}
                  onChange={(e, value) => act('dir-changed', { newDir: value })}
                />
                Name:{' '}
                <Input
                  width="180px"
                  mr={1}
                  onChange={(e, value) =>
                    act('name-changed', { newName: value })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                Where:
                <Dropdown
                  ml={1}
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
              <Stack.Item>
                <Button onClick={() => act('create-object-action')}>
                  Spawn
                </Button>
              </Stack.Item>
              <Stack.Divider />
              <Stack.Item overflow="auto">
                <Table>
                  {objList
                    .filter((obj) => {
                      return searchText === ''
                        ? false
                        : obj.includes(searchText);
                    })
                    .map((obj, index) => (
                      <Table.Row key={index} height="25px">
                        <Table.Cell height="25px">
                          <Button
                            height="25px"
                            color="transparent"
                            fluid
                            selected={selectedObj === index}
                            onClick={() => {
                              setSelectedObj(index);
                              act('selected-object-changed', {
                                newObj: obj,
                              });
                            }}
                          >
                            {obj}
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ))}
                </Table>
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
};
