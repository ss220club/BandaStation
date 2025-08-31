import { CheckboxInput, type FeatureToggle } from '../../base';

export const donor_chat_shine: FeatureToggle = {
  name: 'Блеск ника в чате',
  category: 'Чат',
  description:
    'Если включено, ваш никнейм в OOC чате будет "блестеть". Требует включённого статуса бустера.',
  component: CheckboxInput,
};
