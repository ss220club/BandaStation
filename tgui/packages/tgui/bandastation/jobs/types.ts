import type { PreferencesMenuData } from '../../interfaces/PreferencesMenu/types';
import type { JobSlotsPreferencesData } from '../job_slots_preferences/types';

export type JobPreferencesData = PreferencesMenuData &
  JobVariantsData &
  JobSlotsPreferencesData;

export type JobVariantsData = {
  job_variants?: Record<
    string,
    {
      title: string | null;
      selected: string | null;
      icon: string;
      variants: { id: string; name: string }[];
      required_tier: number;
      lock_reason: string | null;
    }
  >;
};
