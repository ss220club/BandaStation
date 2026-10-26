import { useBackend } from 'tgui/backend';

import type { PreferencesMenuData } from '../../interfaces/PreferencesMenu/types';

const cacheSlots = new WeakMap<object, number>();

// Keep native callbacks, but never reuse a callback captured for another profile.
export function prepareJobPriorityCache(
  cache: Record<string, unknown>,
): number {
  const { data } = useBackend<PreferencesMenuData>();
  if (cacheSlots.get(cache) !== data.active_slot) {
    for (const job of Object.keys(cache)) {
      delete cache[job];
    }
    cacheSlots.set(cache, data.active_slot);
  }
  return data.active_slot;
}
