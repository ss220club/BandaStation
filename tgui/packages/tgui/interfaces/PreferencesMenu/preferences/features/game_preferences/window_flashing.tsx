import { CheckboxInput, FeatureToggle } from '../base';

export const windowflashing: FeatureToggle = {
  name: 'Включить мигание окна',
  category: 'ИНТЕРФЕЙС',
  description: `
    Важные события в игре заставят иконку игры мигать
    на панели задач.
  `,
  component: CheckboxInput,
};
