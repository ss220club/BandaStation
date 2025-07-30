import { CheckboxInput, type FeatureToggle } from '../base';

export const darkened_flash: FeatureToggle = {
  name: 'Включить затемненные вспышки',
  category: 'Доступность',
  description: `
    Если включено, яркие вспышки теперь будут затемнять
    ваш экран.
  `,
  component: CheckboxInput,
};

export const screen_shake_darken: FeatureToggle = {
  name: 'Замена дрожи экрана затемнением',
  category: 'Доступность',
  description: `
      Если включено, дрожь экрана будет заменена затемнением экрана.
    `,
  component: CheckboxInput,
};

export const remove_double_click: FeatureToggle = {
  name: 'Убрать двойной клик',
  category: 'Доступность',
  description: `
      Если включено, действия, требующие двойного клика, будут предлагать
      альтернативные варианты, что очень удобно, если у вас не очень функциональная мышь.
    `,
  component: CheckboxInput,
};
