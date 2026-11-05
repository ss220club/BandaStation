import type { sendAct } from '../../events/act';

/** Bind job actions to this render without changing native callers or other UIs. */
export function jobActionContext(
  state: {
    config?: { interface?: { name?: string } };
    data: Record<string, any>;
  },
  act: typeof sendAct,
): { act?: typeof sendAct } {
  const interfaceName = state.config?.interface?.name;
  const preferences = interfaceName === 'PreferencesMenu';
  if (!preferences && interfaceName !== 'JobSelection') {
    return {};
  }
  const editSlot = preferences ? state.data.active_slot : state.data.edit_slot;
  if (!Number.isInteger(editSlot)) {
    return {};
  }

  return {
    act(action, payload = {}) {
      const profileAction = preferences && action === 'set_job_to_profile';
      const jobAction = preferences
        ? profileAction || action === 'set_job_preference'
        : action === 'select_job';
      if (!jobAction) {
        return act(action, payload);
      }
      return act(
        profileAction && typeof payload.slot === 'number'
          ? 'set_job_slot'
          : action,
        { ...payload, edit_slot: payload.edit_slot ?? editSlot },
      );
    },
  };
}
