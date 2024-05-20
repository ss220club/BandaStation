import { CheckboxInput, FeatureToggle } from '../base';

export const broadcast_login_logout: FeatureToggle = {
  name: 'Оповещать остальных о входе/выходе',
  category: 'ГЕЙМПЛЕЙ',
  description: `
    Оповещать в чате призраков остальных, когда вы входите или выходите из сервера.
  `,
  component: CheckboxInput,
};
