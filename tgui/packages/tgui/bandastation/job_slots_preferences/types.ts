import type { BooleanLike } from 'tgui-core/react';

export type JobSlotsPreferencesData = {
  job_character_profiles?: Record<
    string,
    {
      slot: number | null;
      randomized: BooleanLike;
      error: string | null;
      public_title: string | null;
    }
  >;
  pref_job_slots: Record<string, number>;
};
