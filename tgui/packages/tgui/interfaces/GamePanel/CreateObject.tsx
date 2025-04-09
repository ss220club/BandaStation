import { useState } from 'react';
import {
  Button,
  Collapsible,
  DmIcon,
  Dropdown,
  Input,
  Stack,
  VirtualList,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { spawnLocationOptions } from './constants';
import { CreateObjectProps } from './types';

export function CreateObject(props: CreateObjectProps) {
  const { act } = useBackend();
  const [searchText, setSearchText] = useState('');
  const [cordsType, setCordsType] = useState(1);
  const [tooltipIcon, setTooltipIcon] = useState(false);
  const [selectedObj, setSelectedObj] = useState(-1);
  const [spawnLocation, setSpawnLocation] = useState('On floor below own mob');
  const { objList, tabName } = props;

  let newSearchTextValue: string = '/';

  return (
    <Stack fill vertical>
      <Stack.Item>
        Type:
        <Input
          width="280px"
          ml={1}
          placeholder={'Search for ' + tabName}
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
            selected={cordsType === 0}
            mr={1}
            icon="a"
            onClick={() => {
              setCordsType(0);
              act('set-absolute-cords');
            }}
          />
          <Button.Checkbox
            circular
            selected={cordsType === 1}
            icon="r"
            onClick={() => {
              setCordsType(1);
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
            options={spawnLocationOptions}
            onSelected={(value) => {
              setSpawnLocation(value);
              act('where-dropdown-changed', {
                newWhere: value,
              });
            }}
            selected={spawnLocation}
          />
        </Stack.Item>
      </Collapsible>
      <Stack.Item>
        <Button onClick={() => act('create-object-action')}>Spawn</Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item grow overflow="auto">
        <VirtualList>
          {Object.keys(objList)
            .filter((obj: string) => {
              return searchText === '' ? false : obj.includes(searchText);
            })
            .map((obj, index) => (
              <Button
                key={index}
                color="transparent"
                tooltip={
                  tooltipIcon && (
                    <DmIcon
                      icon={objList[obj].icon}
                      icon_state={objList[obj].icon_state}
                    />
                  )
                }
                tooltipPosition="top-start"
                fluid
                selected={selectedObj === index}
                onDoubleClick={(e) => act('create-object-action')}
                onMouseDown={(e) => {
                  if (e.button === 0 && e.shiftKey) {
                    setTooltipIcon(true);
                  }
                }}
                onMouseUp={(e) => {
                  if (e.button === 0) {
                    setTooltipIcon(false);
                  }
                }}
                onClick={() => {
                  setSelectedObj(index);
                  act('selected-object-changed', {
                    newObj: obj,
                  });
                }}
              >
                {obj}
              </Button>
            ))}
        </VirtualList>
      </Stack.Item>
    </Stack>
  );
}
