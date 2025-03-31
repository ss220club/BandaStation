import { useEffect, useState } from 'react';
import {
  Button,
  Collapsible,
  Dropdown,
  Input,
  Stack,
  Table,
} from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { logger } from '../../logging';
import { Data } from './types';

export function CreateObject(props) {
  const { act } = useBackend();
  const panel = props?.currentPanel;
  const [searchText, setSearchText] = useState('');
  const [selectedRadio, setSelectedRadio] = useState(1);
  const [selectedObj, setSelectedObj] = useState(-1);
  const [data, setData] = useState<Data>();
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
  return (
    <Stack fill vertical>
      <Stack.Item>
        Type:
        <Input
          width="280px"
          ml={1}
          // placeholder={
          //   data[panel]?.subWindowTitle
          //     ? 'Search for ' + data[panel]?.subWindowTitle || ''
          //     : 'Select Tab to search'
          // }
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
      {/* ICON PREVIEW CODE
      <Collapsible>
        <DmIcon icon={icon || ''} icon_state={icon_state || ''} />
      </Collapsible> */}
      <Collapsible mt={1} title="Settings">
        <Stack.Item m={1}>
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
        <Stack.Item m={1}>
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
        <Stack.Item m={1}>
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
      </Collapsible>
      <Stack.Item>
        <Button onClick={() => act('create-object-action')}>Spawn</Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item overflow="auto">
        <Table>
          {data === null ? 'null' : Object.keys(data)}
          {/* {data[panel].objList
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
                      // ICON PREVIEW CODE
                      // act('load-new-icon');
                    }}
                  >
                    {obj}
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))} */}
        </Table>
      </Stack.Item>
    </Stack>
  );
}

// type GamePanelData = {
//   subWindowTitle: string;
//   objList: string[];
//   /* ICON PREVIEW CODE
//   icon: string;
//   icon_state: string; */
// };
