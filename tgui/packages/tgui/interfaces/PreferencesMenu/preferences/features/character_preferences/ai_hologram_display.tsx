import {
  FeatureIconnedDropdownInput,
  type FeatureWithIcons,
} from '../dropdowns';

export const preferred_ai_hologram_display: FeatureWithIcons<string> = {
  name: 'Образ голограммы ИИ',
  description:
    'Голографический образ, который вы примете при использовании голопада.',
  component: FeatureIconnedDropdownInput,
};
