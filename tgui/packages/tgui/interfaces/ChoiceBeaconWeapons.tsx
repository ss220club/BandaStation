import { useState } from 'react';
import {
  Box,
  Button,
  ImageButton,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Mode = {
  ammo_name?: string;
  energy_cost_percent?: number;
  shots_per_charge?: number;
  weak_against_armour?: boolean;
  hits_to_neutralize?: number;
  hits_to_exhaust?: number;
};

type Weapon = {
  name: string;
  desc: string;
  image: string;
  weapon_type: 'ballistic' | 'energy' | 'other';
  magazine_size?: number;
  modes: Mode[];
};

type Data = {
  weapons: Weapon[];
};

const WEAPON_TYPE_LABELS = {
  ballistic: 'Баллистика',
  energy: 'Лазерное',
  other: 'Прочее',
};

export const ChoiceBeaconWeapons = () => {
  const { act, data } = useBackend<Data>();
  const { weapons = [] } = data;
  const [selectedName, setSelectedName] = useState<string | null>(null);
  const selected = weapons.find((weapon) => weapon.name === selectedName);

  return (
    <Window width={640} height={440} title="Выбор оружия">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item basis="38%">
                <Section fill scrollable title="Оружие">
                  {weapons.map((weapon) => (
                    <ImageButton
                      key={weapon.name}
                      base64={weapon.image}
                      selected={weapon.name === selectedName}
                      tooltip={capitalizeAll(weapon.name)}
                      tooltipPosition="bottom"
                      onClick={() => setSelectedName(weapon.name)}
                    >
                      {capitalizeAll(weapon.name)}
                    </ImageButton>
                  ))}
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  fill
                  scrollable
                  title={selected ? capitalizeAll(selected.name) : 'Характеристики'}
                >
                  {selected ? (
                    <WeaponInfo weapon={selected} />
                  ) : (
                    <NoticeBox info>
                      Выберите оружие, чтобы увидеть его характеристики.
                    </NoticeBox>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              icon="truck"
              color="good"
              textAlign="center"
              disabled={!selected}
              onClick={() => selected && act('deliver', { choice: selected.name })}
            >
              Доставить
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const WeaponInfo = (props: { weapon: Weapon }) => {
  const { weapon } = props;
  const isEnergy = weapon.weapon_type === 'energy';
  const { modes = [] } = weapon;

  return (
    <Stack vertical>
      <Stack.Item>
        <Box italic color="label">
          {weapon.desc}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Тип">
            {WEAPON_TYPE_LABELS[weapon.weapon_type]}
          </LabeledList.Item>
          <LabeledList.Item label="Патронов в магазине">
            {isEnergy ? '—' : (weapon.magazine_size ?? '—')}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      {modes.map((mode, index) => (
        <Stack.Item key={index}>
          <ModeInfo
            mode={mode}
            title={index === 0 ? 'Основной режим' : 'Дополнительный режим'}
            showTitle={modes.length > 1}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const ModeInfo = (props: { mode: Mode; title: string; showTitle: boolean }) => {
  const { mode, title, showTitle } = props;

  return (
    <Box>
      {showTitle && (
        <Box bold color="label" mb={0.5}>
          {title}
        </Box>
      )}
      <LabeledList>
        <LabeledList.Item label="Боеприпас">
          {mode.ammo_name ? capitalizeAll(mode.ammo_name) : '—'}
        </LabeledList.Item>
        <LabeledList.Item label="Заряд за выстрел">
          {mode.energy_cost_percent !== undefined
            ? `${mode.energy_cost_percent}% батареи (${mode.shots_per_charge} выстр.)`
            : '—'}
        </LabeledList.Item>
        <LabeledList.Item label="Бронепробитие">
          {mode.weak_against_armour === undefined
            ? '—'
            : mode.weak_against_armour
              ? 'Слабое'
              : 'Присутствует'}
        </LabeledList.Item>
        {mode.hits_to_neutralize !== undefined && (
          <LabeledList.Item label="Выстрелов до нейтрализации">
            {mode.hits_to_neutralize}
          </LabeledList.Item>
        )}
        {mode.hits_to_exhaust !== undefined && (
          <LabeledList.Item label="Выстрелов до падения от истощения">
            {mode.hits_to_exhaust}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Box>
  );
};
