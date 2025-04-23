import { CheckboxInput, Feature, FeatureToggle } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const tgui_fancy: FeatureToggle = {
  name: 'Включить красивый TGUI',
  category: 'ИНТЕРФЕЙС',
  description: 'Окна TGUI будут выглядишь лучше ценой совместимости.',
  component: CheckboxInput,
};

export const tgui_input: FeatureToggle = {
  name: 'Ввод: включить TGUI',
  category: 'ИНТЕРФЕЙС',
  description: 'Окна ввода будут иметь TGUI.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Ввод: большие кнопки',
  category: 'ИНТЕРФЕЙС',
  description: 'Менее традиционные, но более функциональные кнопки TGUI.',
  component: CheckboxInput,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Ввод: инвентировать ввод/отмена',
  category: 'ИНТЕРФЕЙС',
  description: 'Менее традиционные, но более функциональные кнопки TGUI.',
  component: CheckboxInput,
};

export const tgui_layout: Feature<string> = {
  name: 'Стандартный макет TGUI',
  category: 'ИНТЕРФЕЙС',
  description:
    'Применяет выбранный тип макета на все интерфейсы, где это возможно. Например: Smartfridge.',
  component: FeatureDropdownInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'TGUI только на главном дисплее',
  category: 'ИНТЕРФЕЙС',
  description: 'Блокирует местоположение TGUI на главном дисплее.',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Говорить: светлая тема',
  category: 'ИНТЕРФЕЙС',
  description: 'TGUI поле ввода для разговора будет в светлой теме.',
  component: CheckboxInput,
};
