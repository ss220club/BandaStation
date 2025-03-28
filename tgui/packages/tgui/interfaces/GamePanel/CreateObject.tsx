import { useState } from 'react';
import { Button, Dropdown, Input, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';

export function CreateObject(props) {
  const { act, data } = useBackend<GamePanelData>();
  const { subWindowTitle, objList } = data;
  const [searchText, setSearchText] = useState('');
  const [selectedRadio, setSelectedRadio] = useState(1);
  const [selectedObj, setSelectedObj] = useState(-1);
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

  return (
    <Stack fill vertical>
      <Stack.Item>
        Type:
        <Input
          width="280px"
          ml={1}
          placeholder={
            subWindowTitle
              ? 'Search for ' + subWindowTitle
              : 'Select Tab to search'
          }
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
            value ? act('offset-changed', { newOffset: value }) : undefined
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
          onChange={(e, value) => act('number-changed', { newNumber: value })}
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
          onChange={(e, value) => act('name-changed', { newName: value })}
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
        <Button onClick={() => act('create-object-action')}>Spawn</Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item overflow="auto">
        <Table>
          {objList
            .filter((obj) => {
              return searchText === '' ? false : obj.includes(searchText);
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
  );
}

type GamePanelData = {
  subWindowTitle: string;
  objList: string[];
};
