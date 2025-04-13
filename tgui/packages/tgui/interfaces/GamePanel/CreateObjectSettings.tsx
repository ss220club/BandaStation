import { useState } from 'react';
import {
  Button,
  Collapsible,
  Dropdown,
  Input,
  Stack,
} from 'tgui-core/components';
import { LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { spawnLocationOptions } from './constants';

export function CreateObjectSettings(props) {
  const { act } = useBackend();
  const [cordsType, setCordsType] = useState(1);
  const [spawnLocation, setSpawnLocation] = useState('On floor below own mob');

  return (
    <Stack fill vertical>
      <Collapsible mt={1} title="Settings">
        <LabeledList>
          <LabeledList.Item label="Offset">
            <Input
              width="30%"
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
          </LabeledList.Item>
          <LabeledList.Item label="Spec">
            Number:
            <Input
              width="10%"
              m={1}
              value={1}
              onChange={(e, value) =>
                act('number-changed', { newNumber: value })
              }
            />
            Dir:
            <Input
              width="10%"
              m={1}
              onChange={(e, value) => act('dir-changed', { newDir: value })}
            />
            Name:
            <Input
              width="40%"
              m={1}
              onChange={(e, value) => act('name-changed', { newName: value })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Where">
            <Dropdown
              width="100%"
              options={spawnLocationOptions}
              onSelected={(value) => {
                setSpawnLocation(value);
                act('where-dropdown-changed', {
                  newWhere: value,
                });
              }}
              selected={spawnLocation}
            />
          </LabeledList.Item>
        </LabeledList>
      </Collapsible>
    </Stack>
  );
}
