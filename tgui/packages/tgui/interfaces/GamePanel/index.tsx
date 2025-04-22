import { useEffect, useState } from 'react';
import { Stack } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { CreateObject } from './CreateObject';
import { CreateObjectData } from './types';

export function GamePanel() {
  const [data, setData] = useState<CreateObjectData | undefined>();

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
    <Window height={500} title="Spawn Panel" width={500} theme="admin">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            {data && <CreateObject objList={data} />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
