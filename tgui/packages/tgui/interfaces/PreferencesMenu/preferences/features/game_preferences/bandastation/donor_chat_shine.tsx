import type { Feature } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const donor_chat_shine: Feature<string> = {
  name: 'Блеск ника в чате',
  category: 'Чат',
  description:
    'Если включено, ваш никнейм в OOC чате будет "блестеть". Требует включённого статуса бустера.',
  component: FeatureDropdownInput,
};
