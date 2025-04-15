import { createDropdownInput, Feature } from '../base';

export const scaling_method: Feature<string> = {
  name: 'Метод масштабирования',
  category: 'ИНТЕРФЕЙС',
  component: createDropdownInput({
    blur: 'Bilinear',
    distort: 'Nearest Neighbor',
    normal: 'Point Sampling',
  }),
};
