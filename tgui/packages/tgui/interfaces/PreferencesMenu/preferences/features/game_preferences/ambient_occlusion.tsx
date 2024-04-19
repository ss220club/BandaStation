import { CheckboxInput, FeatureToggle } from '../base';

export const ambientocclusion: FeatureToggle = {
  name: 'Включить Ambient Occlusion',
  category: 'ГЕЙМПЛЕЙ',
  description: 'Глобальное затенение, добавляющее легие тени вокруг объектов.',
  component: CheckboxInput,
};
