import { useState } from 'react';
import {
  Button,
  DmIcon,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { useLocalStorage } from 'usehooks-ts';

import { useBackend } from '../../backend';
import { SearchBar } from '../common/SearchBar';
import { listNames, listTypes } from './constants';
import { CreateObjectSettings } from './CreateObjectSettings';
import { CreateObjectProps } from './types';

interface GamePanelData {
  icon: string;
  iconState: string;
  preferences?: {
    hide_icons: boolean;
    hide_mappings: boolean;
    sort_by: string;
    search_text: string;
    search_by: string;
  };
}

export function CreateObject(props: CreateObjectProps) {
  const { act, data } = useBackend<GamePanelData>();
  const { objList } = props;

  const [tooltipIcon, setTooltipIcon] = useState(false);
  const [selectedObj, setSelectedObj] = useState(-1);

  // Используем localStorage для сохранения настроек между сессиями
  const [searchText, setSearchText] = useLocalStorage(
    'gamepanel-searchText',
    '',
  );
  const [searchBy, setSearchBy] = useLocalStorage('gamepanel-searchBy', false); // false = search by name
  const [sortBy, setSortBy] = useLocalStorage(
    'gamepanel-sortBy',
    listTypes.Objects,
  );
  const [hideMapping, setHideMapping] = useLocalStorage(
    'gamepanel-hideMapping',
    false,
  );
  const [hideIcons, setHideIcons] = useLocalStorage(
    'gamepanel-hideIcons',
    false,
  );

  const currentType =
    Object.entries(listTypes).find(([_, value]) => value === sortBy)?.[0] ||
    'Objects';

  const currentList = objList?.[currentType] || {};

  // Функция для отправки предпочтений на бэкенд при создании объекта
  const sendPreferences = (settings) => {
    // Конвертируем локальные состояния в формат бэкенда
    const prefsToSend = {
      hide_icons: hideIcons,
      hide_mappings: hideMapping,
      sort_by:
        Object.keys(listTypes).find((key) => listTypes[key] === sortBy) ||
        'Objects',
      search_text: searchText,
      search_by: searchBy ? 'type' : 'name',
      ...settings,
    };

    act('create-object-action', prefsToSend);
  };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          <CreateObjectSettings onCreateObject={sendPreferences} />
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section>
          <Stack vertical>
            <Stack>
              <Stack.Item>
                <Button
                  icon={sortBy}
                  onClick={() => {
                    const types = Object.values(listTypes);
                    const currentIndex = types.indexOf(sortBy);
                    const nextIndex = (currentIndex + 1) % types.length;
                    setSortBy(types[nextIndex]);
                  }}
                >
                  {
                    listNames[
                      Object.keys(listTypes).find(
                        (key) => listTypes[key] === sortBy,
                      ) || 'Objects'
                    ]
                  }
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={searchBy ? 'code' : 'font'}
                  onClick={() => {
                    setSearchBy(!searchBy);
                  }}
                >
                  {searchBy ? 'Search by type' : 'Search by name'}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => {
                    setHideMapping(!hideMapping);
                  }}
                  color={hideMapping && 'good'}
                  checked={hideMapping}
                >
                  Hide mapping
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => {
                    setHideIcons(!hideIcons);
                  }}
                  color={hideIcons && 'good'}
                  checked={hideIcons}
                >
                  Icons
                </Button.Checkbox>
              </Stack.Item>
            </Stack>
            <Stack>
              <Stack.Item grow ml="-0.5em">
                <SearchBar
                  noIcon
                  placeholder={'Search here...'}
                  query={searchText}
                  onSearch={(query) => {
                    setSearchText(query);
                  }}
                />
              </Stack.Item>
            </Stack>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section fill scrollable>
          {searchText !== '' && (
            <VirtualList>
              {Object.keys(currentList)
                .filter((obj: string) => {
                  if (hideMapping && Boolean(currentList[obj].mapping)) {
                    return false;
                  }
                  if (searchBy) {
                    return obj.toLowerCase().includes(searchText.toLowerCase());
                  }
                  return currentList[obj].name
                    ?.toLowerCase()
                    .includes(searchText.toLowerCase());
                })
                .map((obj, index) => (
                  <Button
                    key={index}
                    color="transparent"
                    tooltip={
                      (hideIcons || tooltipIcon) && (
                        <DmIcon
                          icon={currentList[obj].icon}
                          icon_state={currentList[obj].icon_state}
                        />
                      )
                    }
                    tooltipPosition="top-start"
                    fluid
                    selected={selectedObj === index}
                    style={{
                      backgroundColor:
                        selectedObj === index
                          ? 'rgba(255, 255, 255, 0.1)'
                          : undefined,
                      color: selectedObj === index ? '#fff' : undefined,
                    }}
                    onDoubleClick={() => {
                      if (selectedObj !== -1) {
                        const selectedObject =
                          Object.keys(currentList)[selectedObj];
                        sendPreferences({ object_list: selectedObject });
                      }
                    }}
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
                    {searchBy ? (
                      obj
                    ) : (
                      <>
                        {currentList[obj].name}
                        <span
                          className="label label-info"
                          style={{
                            marginLeft: '0.5em',
                            color: 'rgba(200, 200, 200, 0.5)',
                            fontSize: '10px',
                          }}
                        >
                          {obj}
                        </span>
                      </>
                    )}
                  </Button>
                ))}
            </VirtualList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
