import { useState } from 'react';
import { useBackend } from '../backend';
import type { Direction } from '../constants';
import { NtosWindow } from '../layouts';
import { type MapData, NanoMap } from './common/NanoMap';

type Data = {
  mapData: MapData;
  location: Location;
  signal: SIGNAL;
};

type Location = {
  x: number;
  y: number;
  z: number;
  dir: Direction;
};

enum SIGNAL {
  LOST = 0,
  LOW = 1,
  GOOD = 2,
}

export function NtosNavigator() {
  const { act, data } = useBackend<Data>();
  const { mapData, location, signal } = data;
  const [currentLevel, setCurrentLevel] = useState<number>(mapData.mainFloor);

  return (
    <NtosWindow width={665} height={450}>
      <NtosWindow.Content>
        <NanoMap
          minimapDisabled
          mapData={data.mapData}
          onLevelChange={setCurrentLevel}
        >
          {location && signal !== SIGNAL.LOST && (
            <NanoMap.Button
              circular
              tracking
              selected
              posX={location.x}
              posY={location.y}
              posZ={location.z}
              direction={location.dir}
              hidden={location.z !== currentLevel}
              tooltip="Вы тут!"
              tooltipPosition="top"
            />
          )}
        </NanoMap>
      </NtosWindow.Content>
    </NtosWindow>
  );
}
