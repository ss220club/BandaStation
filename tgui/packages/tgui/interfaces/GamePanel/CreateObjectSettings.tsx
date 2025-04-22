import React from 'react';
import {
  Button,
  Dropdown,
  Input,
  NumberInput,
  Slider,
  Stack,
  Table,
} from 'tgui-core/components';
import { useLocalStorage } from '@uidotdev/usehooks';

import { useBackend } from '../../backend';
import {
  directionIcons,
  directionNames,
  spawnLocationIcons,
  spawnLocationOptions,
} from './constants';

interface GamePanelData {
  icon: string;
  iconState: string;
  preferences?: {
    hide_icons: boolean;
    hide_mappings: boolean;
    sort_by: string;
    search_text: string;
    search_by: string;
    where_dropdown_value: string;
    offset_type: string;
    offset: string;
    object_count: number;
    dir: number;
    object_name: string;
  };
  precise_mode: string;
}

interface CreateObjectSettingsProps {
  onCreateObject?: (obj: any) => void;
}

export function CreateObjectSettings(props: CreateObjectSettingsProps) {
  const { onCreateObject } = props;
  const { act, data } = useBackend<GamePanelData>();

  const [amount, setAmount] = useLocalStorage('gamepanel-object_count', 1);
  const [cordsType, setCordsType] = useLocalStorage('gamepanel-offset_type', 0);
  const [spawnLocation, setSpawnLocation] = useLocalStorage(
    'gamepanel-where_dropdown_value',
    'Current location',
  );
  const [direction, setDirection] = useLocalStorage('gamepanel-direction', 0);
  const [objectName, setObjectName] = useLocalStorage(
    'gamepanel-object_name',
    '',
  );
  const [offset, setOffset] = useLocalStorage('gamepanel-offset', '');
  const [preciseMode, setPreciseMode] = useLocalStorage(
    'gamepanel-precise_mode',
    'Off',
  );

  const isTargetMode =
    spawnLocation === 'Targeted location' ||
    spawnLocation === 'Targeted location (droppod)' ||
    spawnLocation === "In targeted mob's hand";

  const isPreciseModeActive = data?.precise_mode === 'Target';

  const disablePreciseMode = () => {
    if (isPreciseModeActive) {
      act('toggle-precise-mode', {
        newPreciseType: 'Off',
      });
    }
  };

  const handleSpawn = () => {
    const currentSettings = {
      object_count: amount,
      offset_type: cordsType ? 'Absolute offset' : 'Relative offset',
      where_dropdown_value: spawnLocation,
      dir: [1, 2, 4, 8][direction],
      offset,
      object_name: objectName,
    };
    act('update-settings', currentSettings);

    if (!isTargetMode) {
      if (onCreateObject) {
        onCreateObject(currentSettings);
      } else {
        act('create-object-action', currentSettings);
      }
    } else {
      if (isPreciseModeActive) {
        act('toggle-precise-mode', { newPreciseType: 'Off' });
      } else {
        act('toggle-precise-mode', { newPreciseType: 'Target' });
      }
    }
  };

  React.useEffect(() => {
    if (!isTargetMode && isPreciseModeActive) {
      disablePreciseMode();
    }
  }, [spawnLocation]);

  return (
    <Stack fill vertical>
      <Stack>
        <Stack.Item grow>
          <Table
            style={{
              paddingLeft: '5px',
            }}
          >
            <Table.Row className="candystripe" lineHeight="25px">
              <Table.Cell pl={1} width="80px">
                Amount:
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  minValue={1}
                  maxValue={100}
                  step={1}
                  value={amount}
                  onChange={(value) => setAmount(value)}
                  width="100%"
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight="25px">
              <Table.Cell pl={1} width="80px">
                Direction:
              </Table.Cell>
              <Table.Cell>
                <Stack>
                  <Stack.Item>
                    <Button
                      icon={directionIcons[[1, 2, 4, 8][direction]]}
                      tooltip={directionNames[[1, 2, 4, 8][direction]]}
                      tooltipPosition="top"
                      fontSize="14"
                      onClick={() => {
                        const values = [1, 2, 4, 8];
                        const currentIndex = values.indexOf(values[direction]);
                        const nextIndex = (currentIndex + 1) % 4;
                        setDirection(nextIndex);
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Slider
                      minValue={0}
                      maxValue={3}
                      step={1}
                      stepPixelSize={25}
                      value={direction}
                      format={(value) => {
                        const values = [1, 2, 4, 8];
                        return values[value].toString();
                      }}
                      onChange={(e, value) => setDirection(value)}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight="25px">
              <Table.Cell pl={1} width="80px">
                Offset:
              </Table.Cell>
              <Table.Cell>
                <Stack>
                  <Stack.Item>
                    <Button
                      icon={cordsType ? 'a' : 'r'}
                      height="19px"
                      fontSize="14"
                      onClick={() => {
                        const newCordsType = cordsType ? 0 : 1;
                        setCordsType(newCordsType);
                        if (isPreciseModeActive) {
                          disablePreciseMode();
                        }
                      }}
                      tooltip={cordsType ? 'Absolute' : 'Relative'}
                      tooltipPosition="top"
                      disabled={isTargetMode}
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Input
                      placeholder="x, y, z"
                      value={offset}
                      onChange={(e, value) => setOffset(value)}
                      width="100%"
                      disabled={isTargetMode}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight="25px">
              <Table.Cell pl={1} width="80px">
                Name:
              </Table.Cell>
              <Table.Cell>
                <Input
                  onChange={(e, value) => setObjectName(value)}
                  value={objectName}
                  width="100%"
                  placeholder="leave empty for initial"
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Stack.Item>
        <Stack.Item grow>
          <Stack vertical fill>
            <Stack.Item grow>
              <Button
                onClick={handleSpawn}
                style={{
                  width: '100%',
                  height: '100%',
                  textAlign: 'center',
                  fontSize: '20px',
                  alignContent: 'center',
                }}
                icon={spawnLocationIcons[spawnLocation]}
                color={isTargetMode && isPreciseModeActive ? 'good' : undefined}
              >
                SPAWN
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item>
                  <Button
                    style={{
                      height: '22px',
                      width: '22px',
                      lineHeight: '22px',
                    }}
                    icon="eye-dropper"
                    onClick={() => {
                      act('toggle-precise-mode', {
                        newPreciseType: 'Mark',
                      });
                    }}
                    disabled={spawnLocation !== 'At a marked object'}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Dropdown
                    options={spawnLocationOptions}
                    onSelected={(value) => {
                      if (data?.precise_mode && data.precise_mode !== 'Off') {
                        act('toggle-precise-mode', {
                          newPreciseType: 'Off',
                        });
                      }
                      setSpawnLocation(value);
                    }}
                    selected={spawnLocation}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack>
  );
}
