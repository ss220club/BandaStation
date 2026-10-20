import '../../styles/bandastation/job_variants.scss';

import { useBackend } from 'tgui/backend';
import { Box, Dropdown, Tooltip } from 'tgui-core/components';

import type { PreferencesMenuData } from '../../interfaces/PreferencesMenu/types';
import { JOBS_RU } from '../ru_jobs';
import { JobHudIcon } from './JobHudIcon';

export function JobLabel(props: { jobName: string; description: string }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const job = data.job_variants?.[props.jobName];
  if (!job || job.variants.length < 2) {
    return (
      <Tooltip content={props.description} position="bottom-start">
        <Box>
          <JobHudIcon icon={job?.icon} />
          {job?.title || JOBS_RU[props.jobName] || props.jobName}
        </Box>
      </Tooltip>
    );
  }

  const selected = job.variants.find((variant) => variant.id === job.selected);
  return (
    <Tooltip
      content={`${props.description} Вариант активного персонажа. Для другого назначенного слота настройте вариант в его профиле.`}
      position="bottom-start"
    >
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
    </Tooltip>
  );
}
