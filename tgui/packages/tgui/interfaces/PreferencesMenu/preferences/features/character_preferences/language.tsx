import {
  CheckboxInput,
  type FeatureChoiced,
  type FeatureToggle,
} from '../base';
import {
  FeatureDropdownInput,
  FeatureIconnedDropdownInput,
} from '../dropdowns';

export const language: FeatureChoiced = {
  name: 'Язык',
  component: FeatureIconnedDropdownInput,
};

export const language_speakable: FeatureToggle = {
  name: 'Владение языком',
  description: `Если не включено, вы сможете только понимать этот язык,
    но не говорить на нём.`,
  component: CheckboxInput,
};

export const language_skill: FeatureChoiced = {
  name: 'Уровень владения языком',
  description: 'Процент понимания выбранного языка.',
  component: FeatureDropdownInput,
};

export const csl_strength: FeatureChoiced = {
  name: 'Уровень владения языком',
  description: 'Процент понимания общего языка (Common).',
  component: FeatureDropdownInput,
};
