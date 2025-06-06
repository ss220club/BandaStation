import { ReactNode, useState } from 'react';
import { Section, Stack, Tabs } from 'tgui-core/components';

type PreferencesTabsProps = {
  buttons?: ReactNode;
  categories: [string, ReactNode][];
  fontSize?: number;
};

export function TabbedMenu(props: PreferencesTabsProps) {
  const { buttons, categories, fontSize } = props;

  const [selectedCategory, setSelectedCategory] = useState(categories[0][0]);
  const categoryContent = categories.find(
    ([category]) => category === selectedCategory,
  )?.[1];

  return (
    <Stack fill vertical g={0} fontSize={fontSize}>
      <Stack.Item>
        <Section fill fitted title={selectedCategory} buttons={buttons} />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill g={0}>
          <Stack.Item>
            <Section fill mr={'-2px'}>
              <Tabs vertical>
                {categories.map(([category]) => (
                  <Tabs.Tab
                    key={category}
                    selected={category === selectedCategory}
                    onClick={() => setSelectedCategory(category)}
                  >
                    {category}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>
            <Section fill scrollable>
              <Stack fill vertical className="PreferencesMenu__GamePreferences">
                {categoryContent}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}
