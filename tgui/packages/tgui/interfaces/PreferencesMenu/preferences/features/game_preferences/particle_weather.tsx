import { CheckboxInput, type FeatureToggle } from '../base';

export const particle_weather: FeatureToggle = {
  name: 'Включить эффекты погоды (частицы) (несовместимо с AMD GPU)',
  category: 'Геймплей',
  description:
    'Включить красивую погоду с эффектами частиц. Несовместимо с графическими процессорами AMD и вызывает на них сильные лаги из-за ошибки в BYOND.',
  component: CheckboxInput,
};
