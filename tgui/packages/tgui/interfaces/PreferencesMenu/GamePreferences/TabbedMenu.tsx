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
      <Stack.Item className="PreferencesMenu__Section">
        <Section fill fitted title={selectedCategory} />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill g={0}>
          <Stack.Item basis={13} className="PreferencesMenu__Section Sidebar">
            <Section fill fontSize={1.2}>
              <Stack fill vertical>
                <Stack.Item grow>
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
                </Stack.Item>
                <Stack.Item>{buttons}</Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow className="PreferencesMenu__Content">
            <Section fill scrollable>
              <Stack vertical>{categoryContent}</Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}
