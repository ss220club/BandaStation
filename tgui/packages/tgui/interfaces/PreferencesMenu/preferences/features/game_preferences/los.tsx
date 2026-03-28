import { type Feature, FeatureSliderInput } from '../base';

export const los_alpha: Feature<number> = {
  name: 'Непрозрачность',
  category: 'Line of sight',
  description: 'Непрозрачность затемнения за пределами поля зрения.',
  component: FeatureSliderInput,
};

export const los_blur: Feature<number> = {
  name: 'Размытие маски',
  category: 'Line of sight',
  description: 'Уровень размытия за пределами поля зрения.',
  component: FeatureSliderInput,
};
