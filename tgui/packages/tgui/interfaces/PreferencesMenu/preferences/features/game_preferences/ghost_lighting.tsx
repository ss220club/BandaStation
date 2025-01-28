import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const ghost_lighting: FeatureChoiced = {
  name: 'Освещение для призраков',
  component: FeatureDropdownInput,
  category: 'ПРИЗРАК',
  description: 'Влияет на уровень освещения, когда вы призрак.',
};
