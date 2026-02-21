import { type Feature, FeatureColorInput, FeatureSliderInput } from '../base';

export const fov_alpha: Feature<number> = {
  name: 'Непрозрачность',
  category: 'FOV',
  description: 'Непрозрачность затемнения за пределами поля зрения.',
  component: FeatureSliderInput,
};

export const fov_color: Feature<string> = {
  name: 'Цвет затемнения',
  category: 'FOV',
  description: 'Цвет затемнения за пределами поля зрения.',
  component: FeatureColorInput,
};
