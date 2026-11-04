import '../../styles/bandastation/job_variants.scss';

import { useBackend } from 'tgui/backend';
import { Dropdown } from 'tgui-core/components';
import { JobHudIcon } from './JobHudIcon';
import type { JobPreferencesData } from './types';

export function JobVariantSelector(props: { name: string; children: string }) {
  const { act, data } = useBackend<JobPreferencesData>();
  const job = data.job_variants?.[props.name];
  if (!job) {
    return props.children;
  }
  const selected = job.variants.find((variant) => variant.id === job.selected);
  if (job.variants.length < 2) {
    return (
      <>
        <JobHudIcon icon={job.icon} />
        {selected?.name ?? props.children}
      </>
    );
  }

  return (
    <div className="PreferencesMenu__JobVariant">
      <JobHudIcon icon={job.icon} />
      <Dropdown
        key={job.lock_reason ? 'locked' : 'available'}
        color="transparent"
        disabled={!!job.lock_reason}
        width="100%"
        selected={job.selected ?? undefined}
        displayText={selected?.name ?? props.children}
        options={job.variants.map((variant) => ({
          value: variant.id,
          displayText: variant.name,
        }))}
        onSelected={(variant: string) =>
          act('set_job_variant', {
            job: props.name,
            slot: data.active_slot,
            variant,
          })
        }
      />
    </div>
  );
}
