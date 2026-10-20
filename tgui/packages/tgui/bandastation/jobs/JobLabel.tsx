import '../../styles/bandastation/job_variants.scss';

import type { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Dropdown } from 'tgui-core/components';
import { JOBS_RU } from '../ru_jobs';
import { JobHudIcon } from './JobHudIcon';
import type { JobPreferencesData } from './types';

/** A row-local label map; the native JSX keeps its translation/fallback expression. */
export function useJobLabel(name: string) {
  return {
    [name]: <JobLabel jobName={name}>{JOBS_RU[name] || name}</JobLabel>,
  };
}

export function JobLabel(props: { jobName: string; children: ReactNode }) {
  const { act, data } = useBackend<JobPreferencesData>();
  const job = data.job_variants?.[props.jobName];
  if (!job || job.variants.length < 2) {
    return (
      <Box>
        <JobHudIcon icon={job?.icon} />
        {job?.title || props.children}
      </Box>
    );
  }

  const selected = job.variants.find((variant) => variant.id === job.selected);
  return (
    <div className="PreferencesMenu__JobVariant">
      <JobHudIcon icon={job.icon} />
      <Dropdown
        key={job.lock_reason ? 'locked' : 'available'}
        color="transparent"
        disabled={!!job.lock_reason}
        width="100%"
        selected={selected?.name}
        options={job.variants.map((variant) => ({
          value: variant.id,
          displayText: variant.name,
        }))}
        onSelected={(variant: string) =>
          act('set_job_variant', {
            job: props.jobName,
            slot: data.active_slot,
            variant,
          })
        }
      />
    </div>
  );
}
