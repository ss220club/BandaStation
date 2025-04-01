export interface Data {
  [panelName: string]: string[]; // Now an array of PanelData objects
}

export enum GamePanelTabName {
  createObject = 'Object',
  createTurf = 'Turf',
  createMob = 'Mob',
}

export type GamePanelTab = {
  name: GamePanelTabName;
  content: string;
  icon: string;
};

export type CreateObjectProps = {
  data: string[];
  tabName: string;
};
