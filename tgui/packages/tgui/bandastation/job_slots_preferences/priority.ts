import { useCallback } from 'react';
import { useBackend } from 'tgui/backend';

import type { JobPriority } from '../../interfaces/PreferencesMenu/types';

export function useJobPriorityAction(jobName: string, editSlot: number) {
  const { act } = useBackend();
  return useCallback(
    (level: JobPriority | null) => () =>
      act('set_job_preference', {
        job: jobName,
        level,
        edit_slot: editSlot,
      }),
    [act, jobName, editSlot],
  );
}
