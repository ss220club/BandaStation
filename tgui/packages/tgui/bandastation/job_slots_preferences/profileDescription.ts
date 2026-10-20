import type { PreferencesMenuData } from '../../interfaces/PreferencesMenu/types';

export function getJobProfileDescription(
  data: PreferencesMenuData,
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
