import { useState } from 'react';
import { Box, Button, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Power = {
  name?: string;
  description: string;
  blood_required?: number;
};

type Specialization = {
  id: string;
  name: string;
  description: string;
  powers: Power[];
  full_powers: Power[];
};

type Data = {
  can_select_subclass: boolean;
  objectives: Objective[];
  subclasses: Specialization[];
  selected_subclass?: string;
};

const IntroductionSection = ({ objectives }: { objectives: Objective[] }) => (
  <Section title="Вы Вампир!" fill scrollable>
    <Stack vertical>
      <Stack.Item>
        Пейте кровь живых, чтобы усиливать свои вампирские способности. Достигнув
        150 единиц крови, выберите специализацию в разделе «Специализации».
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <ObjectivePrintout objectives={objectives} />
      </Stack.Item>
    </Stack>
  </Section>
);

export const AntagInfoVampire = () => {
  const { data } = useBackend<Data>();
  const { objectives } = data;
  const [currentTab, setCurrentTab] = useState(0);

  const tabs = [
    {
      label: 'Информация',
      icon: 'info',
      content: <IntroductionSection objectives={objectives} />,
    },
    {
      label: 'Специализации',
      icon: 'book',
      content: <SpecializationInfo />,
    },
  ];

  return (
    <Window title="Вампир" width={750} height={635} theme="nologo">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              {tabs.map((tab, index) => (
                <Tabs.Tab
                  key={tab.label}
                  icon={tab.icon}
                  selected={currentTab === index}
                  onClick={() => setCurrentTab(index)}
                >
                  {tab.label}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{tabs[currentTab].content}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SpecializationInfo = () => {
  const { act, data } = useBackend<Data>();
  const { can_select_subclass, selected_subclass, subclasses } = data;
  const selectedIndex = subclasses.findIndex(
    (subclass) => subclass.id === selected_subclass,
  );
  const [currentTab, setCurrentTab] = useState(
    selectedIndex === -1 ? 0 : selectedIndex,
  );
  const specialization = subclasses[currentTab];

  if (!specialization) {
    return null;
  }

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs fluid>
          {subclasses.map((subclass, index) => (
            <Tabs.Tab
              key={subclass.id}
              icon="info"
              selected={currentTab === index}
              onClick={() => setCurrentTab(index)}
            >
              {subclass.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <SpecializationContent
          canSelect={can_select_subclass && !selected_subclass}
          onSelect={() => act(specialization.id)}
          selected={selected_subclass === specialization.id}
          specialization={specialization}
        />
      </Stack.Item>
    </Stack>
  );
};

type SpecializationContentProps = {
  canSelect: boolean;
  onSelect: () => void;
  selected: boolean;
  specialization: Specialization;
};

function SpecializationContent(props: SpecializationContentProps) {
  const { canSelect, onSelect, selected, specialization } = props;

  return (
    <Section
      fill
      scrollable
      textAlign="center"
      title={specialization.name}
      buttons={
        <Button
          disabled={!canSelect || selected}
          onClick={onSelect}
        >
          {selected ? 'Выбрано' : canSelect ? 'Выбрать' : 'Недоступно'}
        </Button>
      }
    >
      <Stack vertical>
        <Stack.Item>{specialization.description}</Stack.Item>
        <Stack.Divider />
        <PowerGroup title="Способности пути" powers={specialization.powers} />
        <Stack.Divider />
        <PowerGroup title="Полная сила" powers={specialization.full_powers} />
      </Stack>
    </Section>
  );
}

function PowerGroup({ powers, title }: { powers: Power[]; title: string }) {
  return (
    <Stack.Item textAlign="left">
      <Stack vertical>
        <Stack.Item bold>{title}:</Stack.Item>
        {powers.map((power, index) => (
          <PowerDescription key={`${power.name}-${index}`} power={power} />
        ))}
      </Stack>
    </Stack.Item>
  );
}

function PowerDescription({ power }: { power: Power }) {
  const { blood_required, description, name } = power;

  return (
    <Stack.Item>
      &bull; {name && <Box bold inline mr={0.5}>{name}</Box>}
      <Box inline>{description}</Box>
      {blood_required !== undefined && (
        <Box color="label" inline ml={0.5}>
          ({blood_required} крови)
        </Box>
      )}
    </Stack.Item>
  );
}
