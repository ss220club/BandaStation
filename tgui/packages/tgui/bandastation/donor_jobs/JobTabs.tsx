import { createContext, type ReactNode, useContext, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Tabs } from 'tgui-core/components';

import { useServerPrefs } from '../../interfaces/PreferencesMenu/useServerPrefs';
import type { JobPreferencesData } from '../jobs/types';

const JobTabsContext = createContext({
  hasSubscriptionJobs: false,
  subscriptionJobs: false,
  selectSubscriptionJobs: (_selected: boolean) => {},
});

export function JobTabsProvider(props: { children: ReactNode }) {
  const { data } = useBackend<JobPreferencesData>();
  const serverPrefs = useServerPrefs();
  const [selected, selectSubscriptionJobs] = useState(false);
  const hasSubscriptionJobs = !!serverPrefs?.jobs.jobs_sorted.some(
    (name) => (data.job_variants?.[name]?.required_tier ?? 0) > 0,
  );

  return (
    <JobTabsContext.Provider
      value={{
        hasSubscriptionJobs,
        subscriptionJobs: hasSubscriptionJobs && selected,
        selectSubscriptionJobs,
      }}
    >
      {props.children}
    </JobTabsContext.Provider>
  );
}

export function JobTabButtons() {
  const { hasSubscriptionJobs, subscriptionJobs, selectSubscriptionJobs } =
    useContext(JobTabsContext);
  if (!hasSubscriptionJobs) {
    return null;
  }

  return (
    <Tabs className="PreferencesMenu__JobTabs">
      <Tabs.Tab
        selected={!subscriptionJobs}
        onClick={() => selectSubscriptionJobs(false)}
      >
        Обычные
      </Tabs.Tab>
      <Tabs.Tab
        icon="star"
        selected={subscriptionJobs}
        onClick={() => selectSubscriptionJobs(true)}
      >
        Подписка
      </Tabs.Tab>
    </Tabs>
  );
}

export function useJobTabFilter() {
  const { data } = useBackend<JobPreferencesData>();
  const { subscriptionJobs } = useContext(JobTabsContext);
  return (jobs: (readonly [string, unknown])[]) => {
    for (let index = jobs.length - 1; index >= 0; index--) {
      const [name] = jobs[index];
      if (
        (data.job_variants?.[name]?.required_tier ?? 0) > 0 !==
        subscriptionJobs
      ) {
        jobs.splice(index, 1);
      }
    }
    return jobs.length > 0;
  };
}

export function useSubscriptionJobs() {
  return useContext(JobTabsContext).subscriptionJobs;
}
