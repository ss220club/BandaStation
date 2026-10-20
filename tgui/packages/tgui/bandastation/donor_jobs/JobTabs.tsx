import { createContext, type ReactNode, useContext, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Tabs } from 'tgui-core/components';

import type { PreferencesMenuData } from '../../interfaces/PreferencesMenu/types';
import { useServerPrefs } from '../../interfaces/PreferencesMenu/useServerPrefs';

const JobTabsContext = createContext({
  hasSubscriptionJobs: false,
  subscriptionJobs: false,
  selectSubscriptionJobs: (_selected: boolean) => {},
});

export function JobTabsProvider(props: { children: ReactNode }) {
  const { data } = useBackend<PreferencesMenuData>();
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
  const { data } = useBackend<PreferencesMenuData>();
  const { subscriptionJobs } = useContext(JobTabsContext);
  return (name: string) =>
    (data.job_variants?.[name]?.required_tier ?? 0) > 0 === subscriptionJobs;
}

export function useSubscriptionJobs() {
  return useContext(JobTabsContext).subscriptionJobs;
}
