import { Feature } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const lobby_style: Feature<string> = {
  name: 'Стиль лобби',
  category: 'ИНТЕРФЕЙС',
  component: FeatureDropdownInput,
};
