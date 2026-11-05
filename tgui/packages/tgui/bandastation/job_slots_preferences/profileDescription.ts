import type { JobSlotsPreferencesData } from './types';

type ProfileData = {
  character_profiles: (string | null)[];
  job_preferences: { job: string; assigned_profile_slot: number | null }[];
} & Pick<
  JobSlotsPreferencesData,
  'job_character_profiles'
>;

export function getJobProfileDescription(
  data: ProfileData,
  jobName: string,
): string {
  const entryProfile = data.job_character_profiles?.[jobName];
  const entryName = entryProfile?.slot
    ? data.character_profiles[entryProfile.slot - 1]
    : null;
  const profileTitle = entryProfile?.public_title;
  return entryProfile?.error
    ? entryProfile.error
    : entryName
      ? `В начале раунда: ${entryProfile?.slot}. ${entryName}${entryProfile?.randomized ? ', случайная внешность' : ''}${profileTitle ? `, ${profileTitle}` : ''}`
      : 'Профиль для входа недоступен';
}

export function jobProfileTooltipProps(
  data: ProfileData,
  jobName: string,
  currentSlotName: string | null | undefined,
) {
  const assignedSlot = data.job_preferences.find(
    (entry) => entry.job === jobName,
  )?.assigned_profile_slot;
  return assignedSlot != null && data.job_character_profiles?.[jobName]
    ? {
        content: `${currentSlotName ?? 'Активный персонаж'}. ${getJobProfileDescription(data, jobName)}`,
      }
    : {};
}
