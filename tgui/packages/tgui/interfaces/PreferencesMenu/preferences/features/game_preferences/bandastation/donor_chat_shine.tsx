import type { Feature } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const donor_chat_effect: Feature<string> = {
  name: 'Блеск ника в чате',
  category: 'Чат',
  description:
    'Выбор эффекта переливания ckey в OOC чате. Требует включённого статуса бустера.',
  component: FeatureDropdownInput,
};
