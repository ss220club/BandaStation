import { createDropdownInput, Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Мульти-Z - детализация',
  category: 'ГЕЙМПЛЕЙ',
  description: 'Уровень детализации мульти-Z. Влияет на производительность.',
  component: createDropdownInput({
    [-1]: 'Стандартная',
    2: 'Высокая',
    1: 'Средняя',
    0: 'Низкая',
  }),
};
