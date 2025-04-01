export interface Data {
  [panelName: string]: string[]; // Now an array of PanelData objects
}

export interface tab {
  content: string;
  handleClick: (e: any) => void;
  icon;
}
