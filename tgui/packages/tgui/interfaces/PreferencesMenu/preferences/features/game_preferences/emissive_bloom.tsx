import { type Feature, FeatureSliderInput } from '../base';

export const emissive_bloom: Feature<number> = {
  name: 'Интенсивность эффекта свечения',
  category: 'Геймплей',
  description: `Регулирует силу свечения излучающих свет объектов, таких как экраны компьютеров. Это оказывает незначительное влияние на производительность.`,
  component: FeatureSliderInput,
};
