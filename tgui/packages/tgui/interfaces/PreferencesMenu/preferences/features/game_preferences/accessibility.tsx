import { CheckboxInput, FeatureToggle } from '../base';

export const darkened_flash: FeatureToggle = {
  name: 'Включить затемненные вспышки',
  category: 'ДОСТУПНОСТЬ',
  description: `
    Если включено, яркие вспышки теперь будут затемнять
    ваш экран.
  `,
  component: CheckboxInput,
};

export const screen_shake_darken: FeatureToggle = {
  name: 'Замена дрожи экрана затемнением',
  category: 'ДОСТУПНОСТЬ',
  description: `
      Если включено, дрожь экрана будет заменена затемнением экрана.
    `,
  component: CheckboxInput,
};

export const remove_double_click: FeatureToggle = {
  name: 'Remove double click',
  category: 'ACCESSIBILITY',
  description: `
      When toggled, actions that require a double click will instead offer
      alternatives, good if you have a not-so-functional mouse.
    `,
  component: CheckboxInput,
};
