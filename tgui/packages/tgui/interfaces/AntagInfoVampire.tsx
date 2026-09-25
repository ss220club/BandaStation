import '../styles/interfaces/AntagInfoVampire.scss';

import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Icon,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

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
  total_blood: number;
  specialization_blood_required: number;
  can_select_subclass: boolean;
  objectives: Objective[];
  subclasses: Specialization[];
  selected_subclass?: string;
};

const IntroductionSection = ({
  objectives,
  specialization_blood_required,
}: Pick<Data, 'objectives' | 'specialization_blood_required'>) => (
  <Section title="Вы Вампир!" fill scrollable fontSize="14px">
    <Stack vertical>
      <Stack.Item textAlign="center" italic>
        Пейте кровь живых, чтобы усиливать свои вампирские способности.
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item fontSize="12px" lineHeight={1.6}>
        <Box bold mb={0.5} color="#e05b65">
          Выберите свой путь
        </Box>
        Достигнув <b>{specialization_blood_required} единиц крови</b>, откройте
        раздел «Специализации» и выберите специализацию. Изучите способности
        каждого пути: они определяют, как будет развиваться ваша сила.
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item lineHeight={1.6}>
        <ObjectivePrintout objectives={objectives} />
      </Stack.Item>
    </Stack>
  </Section>
);

export const AntagInfoVampire = () => {
  const { data } = useBackend<Data>();
  const { objectives, total_blood, specialization_blood_required } = data;
  const [currentTab, setCurrentTab] = useState(0);

  const tabs = [
    {
      label: 'Информация',
      icon: 'info',
      content: (
        <IntroductionSection
          objectives={objectives}
          specialization_blood_required={specialization_blood_required}
        />
      ),
    },
    {
      label: 'Специализации',
      icon: 'book',
      content: <SpecializationInfo />,
    },
  ];

  return (
    <Window title="Вампир" width={750} height={635} theme="Vampire">
      <Window.Content>
        <Stack vertical fill g="0.75rem">
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
          <Stack.Item>
            <Box className="Vampire__blood-total">
              <Icon name="tint" mr={1} />
              Всего выпито крови: <b>{total_blood}</b>
              <Box color="label" fontSize="12px" mt={0.5}>
                Накопленная кровь открывает новые способности.
              </Box>
            </Box>
          </Stack.Item>
          <Stack.Item grow minHeight={0}>
            {tabs[currentTab].content}
          </Stack.Item>
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
    <Stack fill>
      <Stack.Item width="125px" shrink={0}>
        <Tabs fluid vertical>
          {subclasses.map((subclass, index) => (
            <Tabs.Tab
              key={subclass.id}
              icon={subclass.id === selected_subclass ? 'check' : 'info'}
              selected={currentTab === index}
              onClick={() => setCurrentTab(index)}
            >
              {subclass.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow minWidth={0}>
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
  const { data } = useBackend<Data>();
  const { canSelect, onSelect, selected, specialization } = props;
  const { total_blood, specialization_blood_required } = data;
  const selectionTooltip = selected
    ? 'Это ваша специализация.'
    : data.selected_subclass
      ? 'Вы уже выбрали другую специализацию.'
      : !canSelect && total_blood < specialization_blood_required
        ? `Для выбора специализации нужно выпить ещё ${specialization_blood_required - total_blood} крови (всего ${specialization_blood_required}).`
        : canSelect
          ? 'Выбрать этот путь развития.'
          : 'Выбор специализации недоступен.';

  return (
    <Section
      fill
      scrollable
      title={
        <Box textAlign="center" fontSize="24px" color="#e05b65" my={0.5}>
          {specialization.name}
        </Box>
      }
    >
      <Stack vertical>
        <Stack.Item textAlign="center">
          <Box lineHeight={1.6}>{specialization.description}</Box>
          <Box my={1}>
            <Button
              icon={selected ? 'check' : canSelect ? 'plus' : 'lock'}
              color={selected ? 'good' : 'red'}
              disabled={!canSelect || selected}
              tooltip={selectionTooltip}
              onClick={onSelect}
            >
              {selected
                ? 'Ваша специализация'
                : canSelect
                  ? 'Выбрать специализацию'
                  : 'Недоступно'}
            </Button>
          </Box>
        </Stack.Item>
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
    <Stack.Item>
      <Box bold fontSize="14px" mb={1}>
        {title}
      </Box>
      <Stack vertical>
        {powers.map((power, index) => (
          <PowerDescription key={`${power.name}-${index}`} power={power} />
        ))}
      </Stack>
    </Stack.Item>
  );
}

function PowerDescription({ power }: { power: Power }) {
  const { data } = useBackend<Data>();
  const { blood_required, description, name } = power;
  const thresholdReached =
    blood_required !== undefined && data.total_blood >= blood_required;

  return (
    <Stack.Item>
      {(name || blood_required !== undefined) && (
        <Box mb={0.5}>
          <b>{name || 'Пассивная способность'}</b>
          {blood_required !== undefined && (
            <Tooltip
              content={
                thresholdReached
                  ? 'Порог крови достигнут. Способность относится к этому пути.'
                  : `Для открытия на этом пути нужно выпить ещё ${blood_required - data.total_blood} крови.`
              }
            >
              <Box
                as="span"
                ml={1}
                className={`Vampire__blood-requirement Vampire__blood-requirement--${thresholdReached ? 'reached' : 'locked'}`}
              >
                <Icon name={thresholdReached ? 'check' : 'lock'} mr={0.5} />
                {blood_required} крови
              </Box>
            </Tooltip>
          )}
        </Box>
      )}
      <BlockQuote>
        <Box lineHeight={1.5}>{description}</Box>
      </BlockQuote>
    </Stack.Item>
  );
}
