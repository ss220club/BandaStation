export interface Data {
  [panelName: string]: CreateObjectData[];
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
  objList: CreateObjectData[];
  tabName: string;
};
export type CreateObjectData = {
  [objectPath: string]: CreateObjectIcon;
};

export type CreateObjectIcon = {
  icon: string;
  iconState: string;
};
