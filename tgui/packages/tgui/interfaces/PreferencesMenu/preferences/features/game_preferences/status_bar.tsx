import { CheckboxInput, type FeatureToggle } from '../base';

export const status_bar: FeatureToggle = {
  name: 'Влючить статус-бар',
  category: 'Интерфейс',
  description: `
      При включении этой функции в левом нижнем углу экрана будет
      указано название объекта, над которым находится курсор мыши.
    `,
  component: CheckboxInput,
};
