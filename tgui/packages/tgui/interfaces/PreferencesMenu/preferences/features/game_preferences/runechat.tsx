import {
  CheckboxInput,
  FeatureNumberInput,
  FeatureNumeric,
  FeatureToggle,
} from '../base';

export const chat_on_map: FeatureToggle = {
  name: 'Рунчат: включить',
  category: 'РУНЧАТ',
  description: 'Тест сообщений будет появляться над головами.',
  component: CheckboxInput,
};

export const see_chat_non_mob: FeatureToggle = {
  name: 'Рунчат: включить для объектов',
  category: 'РУНЧАТ',
  description: 'Текст сообщений будет появляться над объектами.',
  component: CheckboxInput,
};

export const see_rc_emotes: FeatureToggle = {
  name: 'Рунчат: включить для эмоций',
  category: 'РУНЧАТ',
  description: 'Текст эмоций будет повляться над головами.',
  component: CheckboxInput,
};

export const max_chat_length: FeatureNumeric = {
  name: 'Рунчат: максимальная длина',
  category: 'РУНЧАТ',
  description: 'Максимальная длина, показываемая рунчатом.',
  component: FeatureNumberInput,
};
