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

export interface CreateObjectData {
  Objects: {
    [key: string]: {
      icon: string;
      icon_state: string;
      name: string;
      mapping: boolean;
    };
  };
  Turfs: {
    [key: string]: {
      icon: string;
      icon_state: string;
      name: string;
      mapping: boolean;
    };
  };
  Mobs: {
    [key: string]: {
      icon: string;
      icon_state: string;
      name: string;
      mapping: boolean;
    };
  };
}

export interface CreateObjectProps {
  objList: CreateObjectData;
}
