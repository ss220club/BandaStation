export interface PanelData {
  subWindowTitle: string;
  objList: string[];
}

export interface Data {
  [panelName: string]: PanelData; // Now an array of PanelData objects
}

export interface tab {
  content: string;
  handleClick: (e: any) => void;
  icon;
}
