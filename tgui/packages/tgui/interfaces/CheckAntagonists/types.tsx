export type RoundInfo = {
  round_duration: string;
  is_idle_or_recalled: boolean;
  time_left: string;
  is_called: boolean;
  is_delayed: boolean;
  connected_players: number;
  lobby_players: number;
  observers: number;
  observers_connected: number;
  living_players: number;
  living_players_connected: number;
  antagonists: number;
  antagonists_dead: number;
  brains: number;
  other_players: number;
  living_skipped: number;
  drones: number;
  security: number;
  security_dead: number;
  antagonists_info: AntagInfo[];
};

export type RoundTabInfo = {
  round_duration: string;
  is_idle_or_recalled: boolean;
  time_left: string;
  is_called: boolean;
  is_delayed: boolean;
  connected_players: number;
  lobby_players: number;
  observers: number;
  observers_connected: number;
  living_players: number;
  living_players_connected: number;
  antagonists: number;
  antagonists_dead: number;
  brains: number;
  other_players: number;
  living_skipped: number;
  drones: number;
  security: number;
  security_dead: number;
};

export type AntagInfo = {
  ckey: string;
}

export interface RoundTabInfoProps {
  roundTabInfo: RoundTabInfo;
}
