import { atom, useAtom } from 'jotai';
import type { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Button } from 'tgui-core/components';
import { sharedAtom, store } from '../../events/store';

import { useServerPrefs } from '../../interfaces/PreferencesMenu/useServerPrefs';
import type { JobPreferencesData } from '../jobs/types';

// Window-local state uses the native store and resets with it; no replacement layout/provider.
const subscriptionTab = atom(
  (get) => !!get(sharedAtom)['bandastation.jobs.subscription'],
  (get, set, selected: boolean) =>
    set(sharedAtom, {
      ...get(sharedAtom),
      'bandastation.jobs.subscription': selected,
    }),
);

function useJobTabs() {
  const { data } = useBackend<JobPreferencesData>();
  const serverPrefs = useServerPrefs();
  const [selected, selectSubscriptionJobs] = useAtom(subscriptionTab, {
    store,
  });
  const hasSubscriptionJobs = !!serverPrefs?.jobs.jobs_sorted.some(
    (name) => (data.job_variants?.[name]?.required_tier ?? 0) > 0,
  );
  return {
    hasSubscriptionJobs,
    subscriptionJobs: hasSubscriptionJobs && selected,
    selectSubscriptionJobs,
  };
}

export function JobTabButtons() {
  const { hasSubscriptionJobs, subscriptionJobs, selectSubscriptionJobs } =
    useJobTabs();
  if (!hasSubscriptionJobs) {
    return null;
  }

  return (
    <>
      <Button
        opacity={subscriptionJobs ? 0.55 : 1}
        onClick={() => selectSubscriptionJobs(false)}
      >
        Обычные
      </Button>
      <Button
        icon="star"
        opacity={subscriptionJobs ? 1 : 0.55}
        onClick={() => selectSubscriptionJobs(true)}
      >
        Подписка
      </Button>
    </>
  );
}

/** Extend the native header on the jobs page; keep its character selector intact. */
export function getJobHeaderButtons(
  isJobsPage: boolean,
  characterSelection: ReactNode,
) {
  return isJobsPage
    ? {
        buttons: (
          <>
            <JobTabButtons />
            {characterSelection}
          </>
        ),
      }
    : {};
}

export function useJobTabFilter() {
  const { data } = useBackend<JobPreferencesData>();
  const { subscriptionJobs } = useJobTabs();
  return (jobs: (readonly [string, unknown])[]) => {
    if (subscriptionJobs) {
      return false;
    }
    for (let index = jobs.length - 1; index >= 0; index--) {
      if ((data.job_variants?.[jobs[index][0]]?.required_tier ?? 0) > 0) {
        jobs.splice(index, 1);
      }
    }
    return jobs.length > 0;
  };
}

export function useSubscriptionJobs() {
  return useJobTabs().subscriptionJobs;
}
