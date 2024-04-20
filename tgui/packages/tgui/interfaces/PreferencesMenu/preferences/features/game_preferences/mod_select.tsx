import { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const mod_select: Feature<string> = {
  name: 'Активация модуля MOD',
  category: 'ГЕЙМПЛЕЙ',
  description: 'Какая клавиша вызовет функционал активного модуля MOD.',
  component: FeatureDropdownInput,
};
