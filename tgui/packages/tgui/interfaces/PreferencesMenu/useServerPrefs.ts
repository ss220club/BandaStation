import { createContext, useContext } from 'react';

import { ServerData } from './types';

export const ServerPrefs = createContext<ServerData | undefined>({
  jobs: {
    departments: {},
    jobs: {},
  },
  names: {
    types: {},
  },
  quirks: {
    max_positive_quirks: -1,
    quirk_info: {},
    quirk_blacklist: [],
    points_enabled: false,
  },
  random: {
    randomizable: [],
  },
  loadout: {
    loadout_tabs: [],
  },
  species: {},
  // BANDASTATION ADDITION START - TTS
  text_to_speech: {
    providers: [],
    seeds: [],
    phrases: [],
  },
  // BANDASTATION ADDITION END - TTS
});

export function useServerPrefs() {
  return useContext(ServerPrefs);
}
