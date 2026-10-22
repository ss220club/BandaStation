import '../../styles/bandastation/job_variants.scss';

import { Stack } from 'tgui-core/components';
import { JOBS_RU } from '../ru_jobs';
import { JobHudIcon } from './JobHudIcon';

type JobDisplay = {
  description: string;
  unavailable_reason?: string | null;
  public_title?: string;
  character_profile?: string;
  job_icon?: string;
};

/** Display-only inputs: native availability/HoP markup and canonical action closures stay intact. */
export function extendLatejoinDisplay<
  T extends { jobName: string; job: JobDisplay },
>(props: T): T {
  const { job } = props;
  const title = job.public_title;
  const details = [
    title && title !== (JOBS_RU[props.jobName] || props.jobName) && title,
    job.character_profile,
  ]
    .filter(Boolean)
    .join(' — ');
  return {
    ...props,
    job: details
      ? {
          ...job,
          description: `${job.description} — ${details}`,
          unavailable_reason: job.unavailable_reason
            ? `${job.unavailable_reason} — ${details}`
            : job.unavailable_reason,
        }
      : job,
  };
}

export function LatejoinJobIcon(props: { job: JobDisplay }) {
  return props.job.job_icon ? (
    <Stack.Item className="LatejoinJobIcon">
      <JobHudIcon icon={props.job.job_icon} />
    </Stack.Item>
  ) : null;
}
