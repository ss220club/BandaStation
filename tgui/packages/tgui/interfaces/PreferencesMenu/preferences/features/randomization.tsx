import { useBackend } from 'tgui/backend';

import { RandomizationButton } from '../../components/RandomizationButton';
import { PreferencesMenuData, RandomSetting } from '../../types';
import { CheckboxInput, Feature, FeatureToggle } from './base';

export const random_hardcore: FeatureToggle = {
  name: 'Тотальный рандом',
  component: CheckboxInput,
};

export const random_body: Feature<RandomSetting> = {
  name: 'Случайное тело',
  component: (props) => {
    return (
      <RandomizationButton
        setValue={(value) => props.handleSetValue(value)}
        value={props.value}
      />
    );
  },
};

export const random_name: Feature<RandomSetting> = {
  name: 'Случайное имя',
  component: (props) => {
    return (
      <RandomizationButton
        setValue={(value) => props.handleSetValue(value)}
        value={props.value}
      />
    );
  },
};

export const random_species: Feature<RandomSetting> = {
  name: 'Случайный вид',
  component: (props) => {
    const { act, data } = useBackend<PreferencesMenuData>();
    const species = data.character_preferences.randomization['species'];

    return (
      <RandomizationButton
        setValue={(newValue) =>
          act('set_random_preference', {
            preference: 'species',
            value: newValue,
          })
        }
        value={species || RandomSetting.Disabled}
      />
    );
  },
};
