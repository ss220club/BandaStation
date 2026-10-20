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

export type JobCharacterDisplayData = {
  public_title: string;
  character_profile: string;
  job_icon?: string;
};

export type LatejoinCharacterData = {
  edit_slot: number;
};

export type JobSlotCount = number | '∞';

export type LatejoinJobMetadata = {
  command: BooleanLike;
  description: string;
};

export type LatejoinJobAvailability = {
  availability: number;
  unavailable_reason?: string | null;
  open_slots: JobSlotCount;
  used_slots: number;
  prioritized: BooleanLike;
  jobIcon: string;
} & JobCharacterDisplayData;

export type LatejoinJob = LatejoinJobMetadata & LatejoinJobAvailability;

export type LatejoinDepartmentMetadata = {
  color: string;
  jobs: Record<string, LatejoinJobMetadata>;
};

export type LatejoinDepartmentAvailability = {
  jobs: Record<string, LatejoinJobAvailability>;
  open_slots: JobSlotCount;
};

export type LatejoinDepartment = {
  color: string;
  jobs: Record<string, LatejoinJob>;
  open_slots: JobSlotCount;
};
