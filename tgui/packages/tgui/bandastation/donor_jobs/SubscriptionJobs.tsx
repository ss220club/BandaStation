import '../../styles/bandastation/donor_jobs.scss';

import type { ComponentType, CSSProperties } from 'react';
import { useBackend } from 'tgui/backend';
import { Color } from 'tgui-core/color';
import { Box, Icon, Section } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import type { Job } from '../../interfaces/PreferencesMenu/types';
import { useServerPrefs } from '../../interfaces/PreferencesMenu/useServerPrefs';
import type { JobPreferencesData } from '../jobs/types';
import { useSubscriptionJobs } from './JobTabs';

/** Tier view uses native rows; ordinary department rendering stays in its native interface. */
export function SubscriptionJobs(props: {
  jobRow: ComponentType<{ name: string; job: Job; className?: string }>;
}) {
  const subscriptionJobs = useSubscriptionJobs();
  const { data } = useBackend<JobPreferencesData>();
  const serverPrefs = useServerPrefs();
  if (subscriptionJobs && serverPrefs) {
    const { jobs, jobs_sorted, departments } = serverPrefs.jobs;
    const donorJobs = data.job_variants ?? {};
    const names = jobs_sorted.filter(
      (name) => (donorJobs[name]?.required_tier ?? 0) > 0,
    );
    const tiers = [
      ...new Set(names.map((name) => donorJobs[name].required_tier)),
    ].sort((a, b) => a - b);
    const JobRow = props.jobRow;

    function renderTier(tier: number) {
      const tierJobs = names.filter(
        (name) => donorJobs[name].required_tier === tier,
      );
      const locked = tierJobs.every((name) => !!donorJobs[name].lock_reason);
      return (
        <Section
          key={tier}
          className={classes([
            'PreferencesMenu__JobTier',
            locked && 'PreferencesMenu__JobTier--locked',
          ])}
          title={`Тир ${tier}`}
          buttons={
            <Box color={locked ? 'label' : 'good'}>
              <Icon name={locked ? 'lock' : 'check'} />{' '}
              {locked ? 'Недоступен' : 'Доступен'}
            </Box>
          }
        >
          <div className="PreferencesMenu__JobTierJobs">
            {tierJobs.map((name) => {
              const job = jobs[name];
              const department = departments[job.department];
              return (
                <Box
                  key={name}
                  minWidth={0}
                  style={
                    {
                      '--department-color': Color.fromHex(department.color)
                        .darken(10)
                        .toString(),
                    } as CSSProperties
                  }
                >
                  <JobRow
                    name={name}
                    job={job}
                    className={classes([
                      'PreferencesMenu__Department',
                      `PreferencesMenu__Department--${job.department.replace(' ', '')}`,
                      name === department.head && 'head',
                    ])}
                  />
                </Box>
              );
            })}
          </div>
        </Section>
      );
    }

    return (
      <div className="PreferencesMenu__JobTiers">{tiers.map(renderTier)}</div>
    );
  }
  return null;
}
