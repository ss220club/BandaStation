import {
  FeatureIconnedDropdownInput,
  type FeatureWithIcons,
} from '../dropdowns';

export const preferred_ai_emote_display: FeatureWithIcons<string> = {
  name: 'Изображение на дисплеях ИИ',
  description:
    'Изображение по умолчанию, отображаемое на всех дисплеях ИИ на станции, если вы являетесь ИИ.',
  component: FeatureIconnedDropdownInput,
};
