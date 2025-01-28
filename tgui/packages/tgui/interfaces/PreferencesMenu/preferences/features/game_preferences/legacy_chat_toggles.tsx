import { CheckboxInput, FeatureToggle } from '../base';

export const chat_bankcard: FeatureToggle = {
  name: 'Оповещать о зарплате',
  category: 'ЧАТ',
  description: 'Оповещать об изменениях вашего банковского аккаунта.',
  component: CheckboxInput,
};

export const chat_dead: FeatureToggle = {
  name: 'Включить чат призраков',
  category: 'АДМИН',
  component: CheckboxInput,
};

export const chat_ghostears: FeatureToggle = {
  name: 'Слышать все сообщения',
  category: 'ПРИЗРАК',
  description: `
    Если включено, вы будете слышать всех мобов.
    Если отключено, вы будете слышать только мобов на экране.
  `,
  component: CheckboxInput,
};

export const chat_ghostlaws: FeatureToggle = {
  name: 'Оповещать о смене законов',
  category: 'ПРИЗРАК',
  description: 'Оповещать, если произошли какие-либо смены законов.',
  component: CheckboxInput,
};

export const chat_ghostpda: FeatureToggle = {
  name: 'Оповещать о новых сообщениях на КПК',
  category: 'ПРИЗРАК',
  description: 'Оповещать, когда какое-либо КПК получает сообщение.',
  component: CheckboxInput,
};

export const chat_ghostradio: FeatureToggle = {
  name: 'Слышать радио',
  category: 'ПРИЗРАК',
  description: 'Если включено, вы будете слышать все радио-сообщения.',
  component: CheckboxInput,
};

export const chat_ghostsight: FeatureToggle = {
  name: 'Слышать все эмоции',
  category: 'ПРИЗРАК',
  description: 'Если включено, вы будете слышать, как все мобы делают эмоции.',
  component: CheckboxInput,
};

export const chat_ghostwhisper: FeatureToggle = {
  name: 'Слышать все шепоты',
  category: 'ПРИЗРАК',
  description: `
    Если включено, вы будете слышать шепоты всех мобов.
    Если выключено, вы будете слышать шепоты только мобов на экране.
  `,
  component: CheckboxInput,
};

export const chat_login_logout: FeatureToggle = {
  name: 'Оповещать о входе/выходе',
  category: 'ПРИЗРАК',
  description: 'Оповещать, когда игроки входят/выходят из сервера.',
  component: CheckboxInput,
};

export const chat_ooc: FeatureToggle = {
  name: 'Включить OOC чат',
  category: 'ЧАТ',
  component: CheckboxInput,
};

export const chat_prayer: FeatureToggle = {
  name: 'Слышать молитвы',
  category: 'АДМИН',
  component: CheckboxInput,
};

export const chat_pullr: FeatureToggle = {
  name: 'Оповещать о Pull-Request',
  category: 'ЧАТ',
  description: 'Оповещать, когда Pull-Request создан, закрыт или вмержен.',
  component: CheckboxInput,
};
