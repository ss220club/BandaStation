import { useState } from 'react';
import { Button, DmIcon, Stack, VirtualList } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SearchBar } from '../common/SearchBar';
import { CreateObjectSettings } from './CreateObjectSettings';
import { CreateObjectProps } from './types';

export function CreateObject(props: CreateObjectProps) {
  const { act } = useBackend();
  const [searchText, setSearchText] = useState('');
  const [tooltipIcon, setTooltipIcon] = useState(false);
  const [selectedObj, setSelectedObj] = useState(-1);
  const { objList, tabName } = props;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <SearchBar
          noIcon
          placeholder={'Search for ' + tabName}
          query=""
          onSearch={(query) => {
            setSearchText(query);
          }}
        />
      </Stack.Item>
      <Stack.Item>
        <CreateObjectSettings />
      </Stack.Item>
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
