import { CheckboxInput, type Feature, type FeatureToggle, FeatureSliderInput } from '../base';

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

export const min_recoil_multiplier: Feature<number> = {
  name: 'Сила визуального эффекта отдачи',
  category: 'Доступность',
  description: `
      Регулирует интенсивность эффекта визуальной отдачи на вашей камере.
      Значение 0 полностью отключает визуальную отдачу, однако механическая отдача при этом не изменится.
    `,
  component: FeatureSliderInput,
};

export const stair_indicator: FeatureToggle = {
  name: 'Включить индикатор лестницы',
  category: 'Доступность',
  description: `
      При включении этой функции на лестницах будет отображаться визуальный индикатор, указывающий, в каком
      направлении следует идти, чтобы перейти на другие этажи.
    `,
  component: CheckboxInput,
};

export const twelve_hour: FeatureToggle = {
  name: '12-часовой формат времени',
  category: 'Доступность',
  description: `
      Если включить эту опцию, многие упоминания реального времени будут заменены на обозначения AM/PM.
    `,
  component: CheckboxInput,
};
