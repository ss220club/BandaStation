import {
  FeatureIconnedDropdownInput,
  type FeatureWithIcons,
} from '../dropdowns';

export const preferred_ai_emote_display: FeatureWithIcons<string> = {
  name: 'Изображение на дисплеях ИИ',
  description:
    'Если вы играете за ИИ - это изображение будет отображаться по умолчанию на всех дисплеях ИИ на станции.',
  component: FeatureIconnedDropdownInput,
};
