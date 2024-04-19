import { CheckboxInput, FeatureToggle } from '../base';

export const typingIndicator: FeatureToggle = {
  name: 'Включить индикатор печатания',
  category: 'ГЕЙМПЛЕЙ',
  description: 'Показывать индикатор печатания, когда вы пишите сообщение.',
  component: CheckboxInput,
};
