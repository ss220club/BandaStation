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
  objList: string[];
  tabName: string;
};

export type SelectedObjectIcon = {
  icon: string;
  icon_state: string;
};
