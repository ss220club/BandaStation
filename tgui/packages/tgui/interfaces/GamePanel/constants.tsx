import { GamePanelTab, GamePanelTabName } from './types';

export const GamePanelTabs = [
  {
    name: GamePanelTabName.createObject,
    content: 'Create Object',
    icon: 'wrench',
  },
  {
    name: GamePanelTabName.createTurf,
    content: 'Create Turf',
    icon: 'map',
  },
  {
    name: GamePanelTabName.createMob,
    content: 'Create Mob',
    icon: 'person',
  },
] as GamePanelTab[];

export const spawnLocationOptions = [
  'On floor below own mob',
  'On floor below own mob, dropped via supply pod',
  "In own's mob hand",
  'In marked object',
];
