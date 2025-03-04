import { CheckboxInput, FeatureToggle } from '../../base';

export const donor_public: FeatureToggle = {
  name: 'Отображать статус бустера',
  category: 'ЧАТ',
  description:
    'Если включено, в OOC чате будет отображаться значок тира подписки.',
  component: CheckboxInput,
};
