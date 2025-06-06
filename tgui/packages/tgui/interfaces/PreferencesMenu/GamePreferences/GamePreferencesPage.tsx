import { binaryInsertWith, sortBy } from 'common/collections';
import { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Stack } from 'tgui-core/components';

import { features } from '../preferences/features';
import { FeatureValueInput } from '../preferences/features/base';
import { PreferencesMenuData } from '../types';
import { TabbedMenu } from './TabbedMenu';

type PreferenceChild = {
  name: string;
  children: ReactNode;
};

function binaryInsertPreference(
  collection: PreferenceChild[],
  value: PreferenceChild,
) {
  return binaryInsertWith(collection, value, (child) => child.name);
}

function sortByName(array: [string, PreferenceChild[]][]) {
  return sortBy(array, ([name]) => name);
}

export function GamePreferencesPage(props) {
  const { data } = useBackend<PreferencesMenuData>();

  const className = 'PreferencesMenu__GamePreferences';
  const gamePreferences: Record<string, PreferenceChild[]> = {};

  function Preference(props) {
    const { feature, featureId, name, description, value } = props;
    return (
      <Stack key={featureId} className={`${className}Preference`}>
        <Stack.Item grow>
          <Stack vertical g={0}>
            <Stack.Item className={`${className}Preference--name`}>
              {name}
            </Stack.Item>
            {description && (
              <Stack.Item className={`${className}Preference--desc`}>
                {description}
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack className={`${className}Preference--control`}>
          {feature ? (
            <FeatureValueInput
              feature={feature}
              featureId={featureId}
              value={value}
            />
          ) : (
            <Box as="b" color="red">
              ...is not filled out properly!!!
            </Box>
          )}
        </Stack>
      </Stack>
    );
  }

  for (const [featureId, value] of Object.entries(
    data.character_preferences.game_preferences,
  )) {
    const feature = features[featureId];

    let name: ReactNode = feature?.name || featureId;
    let description: ReactNode;

    if (feature?.description) {
      description = feature.description;
    }

    const child = (
      <Preference
        feature={feature}
        featureId={featureId}
        name={name}
        description={description}
        value={value}
      />
    );

    const entry = {
      name: feature?.name || featureId,
      children: child,
    };

    const category = feature?.category || 'ERROR';
    gamePreferences[category] = binaryInsertPreference(
      gamePreferences[category] || [],
      entry,
    );
  }

  const gamePreferenceEntries: [string, ReactNode][] = sortByName(
    Object.entries(gamePreferences),
  ).map(([category, preferences]) => {
    return [category, preferences.map((entry) => entry.children)];
  });

  return (
    <Stack fill vertical>
      <TabbedMenu categories={gamePreferenceEntries} fontSize={1.25} />
    </Stack>
  );
}
