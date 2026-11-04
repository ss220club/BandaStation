import { createContext, type ReactNode, useContext } from 'react';
import { useBackend } from 'tgui/backend';
import { Stack, Tooltip } from 'tgui-core/components';

import type { JobPreferencesData } from '../jobs/types';

const JobRestrictionContext = createContext(false);

export function JobRowControls(props: { name: string; children: ReactNode }) {
  const { data } = useBackend<JobPreferencesData>();
  const job = data.job_variants?.[props.name];
  const reason =
    job?.lock_reason || data.job_character_profiles?.[props.name]?.error;

  return (
    <JobRestrictionContext.Provider value={!!reason}>
      {reason && (
        <Tooltip content={reason}>
          <Stack.Item className="restricted">
            {job?.lock_reason
              ? `Тир ${job.required_tier}`
              : 'Профиль недоступен'}
          </Stack.Item>
        </Tooltip>
      )}
      {props.children}
    </JobRestrictionContext.Provider>
  );
}

export function useJobPriorityButtonProps(modifier?: string) {
  const restricted = useContext(JobRestrictionContext);
  return { disabled: restricted && modifier !== 'off' };
}
