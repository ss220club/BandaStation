import { CheckboxInput, FeatureToggle } from '../base';

export const widescreenpref: FeatureToggle = {
  name: 'Включить широкоэкранный режим',
  category: 'ИНТЕРФЕЙС',
  component: CheckboxInput,
};

export const fullscreen_mode: FeatureToggle = {
  name: 'Включить полноэкранный режим',
  category: 'ИНТЕРФЕЙС',
  description:
    'Включает полноэкранный режим игры, также можно включить с помощью F11.',
  component: CheckboxInput,
};
