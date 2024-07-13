import { CheckboxInput, CheckboxInputInverse, FeatureToggle } from '../base';

export const admin_ignore_cult_ghost: FeatureToggle = {
  name: 'Не появляться за призрака культа',
  category: 'АДМИН',
  description: `
    Если включено, и если вы призрак, не дает Spirit Realm превращать вас
    в призрака культа.
  `,
  component: CheckboxInput,
};

export const announce_login: FeatureToggle = {
  name: 'Оповещать о входе',
  category: 'АДМИН',
  description: 'Администрация будет оповещена о вашем входе.',
  component: CheckboxInput,
};

export const combohud_lighting: FeatureToggle = {
  name: 'Включить Combo-HUD с полным светом',
  category: 'АДМИН',
  component: CheckboxInput,
};

export const deadmin_always: FeatureToggle = {
  name: 'Авто deadmin',
  category: 'АДМИН',
  description: 'Автоматический deadmin при заходе в раунд.',
  component: CheckboxInput,
};

export const deadmin_antagonist: FeatureToggle = {
  name: 'Авто deadmin - при антагонизме',
  category: 'АДМИН',
  description: 'Автоматический deadmin, если вы антагонист.',
  component: CheckboxInput,
};

export const deadmin_position_head: FeatureToggle = {
  name: 'Авто deadmin - глава отдела',
  category: 'АДМИН',
  description:
    'Автоматический deadmin, если вы становитесь главой какого-либо отдела',
  component: CheckboxInput,
};

export const deadmin_position_security: FeatureToggle = {
  name: 'Авто deadmin - СБ',
  category: 'АДМИН',
  description:
    'Автоматический deadmin, если вы становитесь членом службы безопасности.',
  component: CheckboxInput,
};

export const deadmin_position_silicon: FeatureToggle = {
  name: 'Авто deadmin - синтетик',
  category: 'АДМИН',
  description: 'Автоматический deadmin, если вы синтетик.',
  component: CheckboxInput,
};

export const disable_arrivalrattle: FeatureToggle = {
  name: 'Оповещать о прибытии экипажа',
  category: 'ПРИЗРАК',
  description: 'Оповещать, когда вы призрак, о прибытии нового члена экипажа.',
  component: CheckboxInputInverse,
};

export const disable_deathrattle: FeatureToggle = {
  name: 'Оповещать о смертях',
  category: 'ПРИЗРАК',
  description:
    'Оповещать, когда вы призрак, когда умирают другие игроки от чего-либо.',
  component: CheckboxInputInverse,
};

export const member_public: FeatureToggle = {
  name: 'Показывать подписку BYOND',
  category: 'ЧАТ',
  description:
    'При включении, показывает логотип BYOND рядом с вашим именем в OOC чате.',
  component: CheckboxInput,
};

export const sound_adminhelp: FeatureToggle = {
  name: 'Включить звуки админхелпов',
  category: 'АДМИН',
  component: CheckboxInput,
};

export const sound_prayers: FeatureToggle = {
  name: 'Включить звуки молитв',
  category: 'АДМИН',
  component: CheckboxInput,
};

export const split_admin_tabs: FeatureToggle = {
  name: 'Разделять админские вкладки',
  category: 'АДМИН',
  description: "Разделяет вкладки на панели 'Admin'",
  component: CheckboxInput,
};
