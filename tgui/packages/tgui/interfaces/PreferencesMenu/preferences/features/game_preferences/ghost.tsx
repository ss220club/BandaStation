import { binaryInsertWith } from 'common/collections';
import { classes } from 'common/react';
import { multiline } from 'common/string';
import { ReactNode } from 'react';

import { useBackend } from '../../../../../backend';
import { Box, Dropdown, Flex } from '../../../../../components';
import { PreferencesMenuData } from '../../../data';
import {
  CheckboxInput,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureDropdownInput,
  FeatureToggle,
  FeatureValueProps,
} from '../base';

export const ghost_accs: FeatureChoiced = {
  name: 'Призрак - аксессуары',
  category: 'ПРИЗРАК',
  description: 'Влияет на то, какие изменения будет иметь ваш призрак.',
  component: FeatureDropdownInput,
};

const insertGhostForm = binaryInsertWith<{
  displayText: ReactNode;
  value: string;
}>(({ value }) => value);

const GhostFormInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  const { data } = useBackend<PreferencesMenuData>();

  const serverData = props.serverData;
  if (!serverData) {
    return <> </>;
  }

  const displayNames = serverData.display_names;
  if (!displayNames) {
    return <Box color="red">No display names for ghost_form!</Box>;
  }

  const displayTexts = {};
  let options: {
    displayText: ReactNode;
    value: string;
  }[] = [];

  for (const [name, displayName] of Object.entries(displayNames)) {
    const displayText = (
      <Flex key={name}>
        <Flex.Item>
          <Box
            className={classes([`preferences32x32`, serverData.icons![name]])}
          />
        </Flex.Item>

        <Flex.Item grow={1}>{displayName}</Flex.Item>
      </Flex>
    );

    displayTexts[name] = displayText;

    const optionEntry = {
      displayText,
      value: name,
    };

    // Put the default ghost on top
    if (name === 'ghost') {
      options.unshift(optionEntry);
    } else {
      options = insertGhostForm(options, optionEntry);
    }
  }

  return (
    <Dropdown
      disabled={!data.content_unlocked}
      selected={props.value}
      displayText={displayTexts[props.value]}
      onSelected={props.handleSetValue}
      width="100%"
      options={options}
    />
  );
};

export const ghost_form: FeatureChoiced = {
  name: 'Призрак - форма',
  category: 'ПРИЗРАК',
  description: 'Внешний вид вашего призрака. Нужна подписка BYOND.',
  component: GhostFormInput,
};

export const ghost_hud: FeatureToggle = {
  name: 'Призрак - HUD',
  category: 'ПРИЗРАК',
  description: 'Переключает наличие кнопок на HUD призрака.',
  component: CheckboxInput,
};

export const ghost_orbit: FeatureChoiced = {
  name: 'Призрак - орбитирование',
  category: 'ПРИЗРАК',
  description: multiline`
    Форма, по которой ваш призрак будет орбитировать.
    Необходима подписка BYOND.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    const { data } = useBackend<PreferencesMenuData>();

    return (
      <FeatureDropdownInput {...props} disabled={!data.content_unlocked} />
    );
  },
};

export const ghost_others: FeatureChoiced = {
  name: 'Призрак - окружающие',
  category: 'ПРИЗРАК',
  description: multiline`
    Должны ли призраки других показываться с их настройками, только с их
    стандартным спрайтом, или только показывать их стандартным белым призраком?
  `,
  component: FeatureDropdownInput,
};

export const inquisitive_ghost: FeatureToggle = {
  name: 'Призрак - осмотр',
  category: 'ПРИЗРАК',
  description: 'Нажатие по чему-то будет вызывать осмотр.',
  component: CheckboxInput,
};

export const ghost_roles: FeatureToggle = {
  name: 'Получать гост-роли',
  category: 'ПРИЗРАК',
  description: multiline`
    Если вы отключите это, вы не будете получать оповещения о гост-ролях, вообще!
    Каждое оповещение БУДЕТ заглушено для вас, когда вы являетесь призраком.
    Полезная опция для тех, кто не хочет играть на гост-ролях или не любит их
    оповещения, используйте на свой страх и риск.
`,
  component: CheckboxInput,
};
