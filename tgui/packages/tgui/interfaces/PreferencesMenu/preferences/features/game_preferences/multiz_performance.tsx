import { createDropdownInput, Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Мульти-Z - детализация',
  category: 'ГЕЙМПЛЕЙ',
  description:
    'Сколько уровней Мульти-Z рендерится, прежде чем они начнут выбраковываться. Уменьшите это значение, чтобы повысить производительность на картах с Мульти-Z.',
  component: createDropdownInput({
    [-1]: 'Стандартная',
    2: 'Высокая',
    1: 'Средняя',
    0: 'Низкая',
  }),
};
