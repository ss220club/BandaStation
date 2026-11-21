import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Weapon = {
  slot: string;
  name: string;
  button: string;
  ammo?: {
    projectiles: number;
    max_magazine: number;
    projectiles_cache: number;
    projectiles_cache_max: number | null;
    disabledreload: boolean | null;
  };
};

type CockpitData = {
  seat: 'main' | 'weapons' | null;
  integrity: number;
  max_integrity: number;
  charge_percent: number;
  infinite_power: boolean;
  shield_active: boolean;
  shield_charge: number;
  shield_max_charge: number;
  ejecting: boolean;
  separate_blocker: string | null;
  main_pilot: string | null;
  gunner: string | null;
  strafe?: boolean;
  lights?: boolean;
  force?: number;
  shield_ready?: boolean;
  strike_cooldown?: number;
  weapons?: Weapon[];
};

const CRITICAL_SHARE = 0.3;

const share = (value: number, max: number) => (max > 0 ? value / max : 0);

export const GoldenGardrenCockpit = () => {
  const { data } = useBackend<CockpitData>();
  const { seat } = data;
  return (
    <Window
      title={seat === 'weapons' ? 'Место стрелка' : 'Место пилота'}
      width={420}
      height={seat === 'weapons' ? 560 : 470}
      theme="ntos_darkmode"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <MachineSection />
          </Stack.Item>
          <Stack.Item>
            {seat === 'main' && <MainSeatSection />}
            {seat === 'weapons' && <WeaponsSeatSection />}
          </Stack.Item>
          <Stack.Item>
            <EmergencySection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MachineSection = () => {
  const { data } = useBackend<CockpitData>();
  const integrity = share(data.integrity, data.max_integrity);
  const charge = data.charge_percent / 100;
  const shield = share(data.shield_charge, data.shield_max_charge);
  return (
    <Section title="Машина">
      {integrity <= CRITICAL_SHARE && (
        <NoticeBox danger>
          Критические повреждения! Готовьтесь к катапультированию.
        </NoticeBox>
      )}
      <LabeledList>
        <LabeledList.Item label="Корпус">
          <ProgressBar
            value={integrity}
            ranges={{
              good: [0.6, Infinity],
              average: [CRITICAL_SHARE, 0.6],
              bad: [-Infinity, CRITICAL_SHARE],
            }}
          >
            {Math.round(data.integrity)} / {data.max_integrity}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Заряд батареи">
          <ProgressBar
            value={charge}
            ranges={{
              good: [0.5, Infinity],
              average: [0.2, 0.5],
              bad: [-Infinity, 0.2],
            }}
          >
            {data.infinite_power ? '∞' : `${Math.round(data.charge_percent)}%`}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Щит">
          <ProgressBar
            value={shield}
            color={data.shield_active ? 'blue' : 'label'}
          >
            {data.shield_active ? 'Поднят' : 'Опущен'} —{' '}
            {Math.round(data.shield_charge)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Пилот">
          {data.main_pilot || 'свободно'}
        </LabeledList.Item>
        <LabeledList.Item label="Стрелок">
          {data.gunner || 'свободно'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MainSeatSection = () => {
  const { act, data } = useBackend<CockpitData>();
  return (
    <Section title="Ходовая и руки">
      <LabeledList>
        <LabeledList.Item label="Стрейф">
          <Button
            icon="arrows-left-right"
            selected={data.strafe}
            onClick={() => act('toggle_strafe')}
          >
            {data.strafe ? 'Включён' : 'Выключен'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Фары">
          <Button
            icon="lightbulb"
            selected={data.lights}
            onClick={() => act('toggle_lights')}
          >
            {data.lights ? 'Включены' : 'Выключены'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Сила удара">{data.force}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const WeaponsSeatSection = () => {
  const { act, data } = useBackend<CockpitData>();
  const weapons = data.weapons || [];
  return (
    <Section
      title="Оружие и щит"
      buttons={
        <Button
          icon="shield-halved"
          selected={data.shield_active}
          disabled={!data.shield_active && !data.shield_ready}
          onClick={() => act('toggle_shield')}
        >
          {data.shield_active ? 'Опустить щит' : 'Поднять щит'}
        </Button>
      }
    >
      <LabeledList>
        {weapons.map(({ slot, name, button, ammo }) => (
          <LabeledList.Item
            key={slot}
            label={button}
            buttons={
              ammo &&
              !ammo.disabledreload && (
                <Button
                  icon="rotate"
                  disabled={
                    ammo.projectiles >= ammo.max_magazine ||
                    !ammo.projectiles_cache
                  }
                  onClick={() => act('reload', { slot })}
                >
                  Перезарядить
                </Button>
              )
            }
          >
            {name}
            {ammo && (
              <>
                <ProgressBar value={share(ammo.projectiles, ammo.max_magazine)}>
                  {ammo.projectiles} / {ammo.max_magazine}
                </ProgressBar>
                {!!ammo.projectiles_cache_max && (
                  <Box color="label" mt={0.25}>
                    Запас {ammo.projectiles_cache} / {ammo.projectiles_cache_max}
                  </Box>
                )}
              </>
            )}
          </LabeledList.Item>
        ))}
        <LabeledList.Item label="Ракетный удар">
          {data.strike_cooldown ? `${data.strike_cooldown} с` : 'Готов'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const EmergencySection = () => {
  const { act, data } = useBackend<CockpitData>();
  return (
    <Section title="Аварийные системы">
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            icon="people-arrows"
            disabled={!!data.separate_blocker}
            tooltip={data.separate_blocker || undefined}
            onClick={() => act('separate')}
          >
            Разделение
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button.Confirm
            fluid
            color="red"
            icon="parachute-box"
            disabled={data.ejecting}
            confirmContent="Точно катапультироваться?"
            onClick={() => act('emergency_eject')}
          >
            {data.ejecting ? 'Выберите место посадки' : 'Катапультирование'}
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
