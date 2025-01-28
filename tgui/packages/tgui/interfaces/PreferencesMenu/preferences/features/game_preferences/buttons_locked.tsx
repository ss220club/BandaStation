import { CheckboxInput, FeatureToggle } from '../base';

export const buttons_locked: FeatureToggle = {
  name: 'Заблокировать кнопки действий',
  category: 'ГЕЙМПЛЕЙ',
  description: 'Запрещает перемещать кнопки действий.',
  component: CheckboxInput,
};
