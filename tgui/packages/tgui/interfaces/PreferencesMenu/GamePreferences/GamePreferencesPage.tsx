import { binaryInsertWith, sortBy } from 'common/collections';
import { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Stack } from 'tgui-core/components';

import { features } from '../preferences/features';
import { FeatureValueInput } from '../preferences/features/base';
import { PreferencesMenuData } from '../types';
import { TabbedMenu } from './TabbedMenu';

export type PreferenceChild = {
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
  const className = 'PreferencesMenu__Preference';

  const gamePreferences: Record<string, PreferenceChild[]> = {};
  for (const [featureId, value] of Object.entries(
    data.character_preferences.game_preferences,
  )) {
    const feature = features[featureId];
    const child = (
      <Stack key={featureId} className={className}>
        <Stack.Item grow>
          <Stack vertical g={0}>
            <Stack.Item className={`${className}--name`}>
              {feature.name || featureId}
            </Stack.Item>
            {feature.description && (
              <Stack.Item className={`${className}--desc`}>
                {feature.description}
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack className={`${className}--control`}>
          {feature ? (
            <FeatureValueInput
              feature={feature}
              featureId={featureId}
              value={value}
            />
          ) : (
            <Stack.Item grow bold color="red">
              ...is not filled out properly!!!
            </Stack.Item>
          )}
        </Stack>
      </Stack>
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

  const gamePreferenceEntries: [string, PreferenceChild[]][] = sortByName(
    Object.entries(gamePreferences),
  ).map(([category, preferences]) => {
    return [category, preferences.map((entry) => entry)];
  });

  console.log(gamePreferenceEntries);

  return (
    <Stack fill vertical>
      <TabbedMenu categories={gamePreferenceEntries} fontSize={1.25} />
    </Stack>
  );
}
