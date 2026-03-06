import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';

type Target = {
  uid: string;
  type: 'door' | 'turret' | 'console';
  name: string;
  heat_cost: number;
  status: string;
};

type CyberdeckData = {
  heat: number;
  max_heat: number;
  overheat_at: number;
  disabled: boolean;
  overheated: boolean;
  targets: Target[];
};

const TYPE_ICON: Record<string, string> = {
  door: 'door-open',
  turret: 'crosshairs',
  console: 'desktop',
};

const TYPE_LABEL: Record<string, string> = {
  door: 'Шлюз',
  turret: 'Турель',
  console: 'Консоль',
};

const DOOR_ACTIONS = [
  { action: 'open', label: 'Открыть', color: 'good' },
  { action: 'close', label: 'Закрыть', color: 'average' },
  { action: 'bolt', label: 'Засов ▼', color: 'bad' },
  { action: 'unbolt', label: 'Засов ▲', color: 'average' },
];

const TURRET_ACTIONS = [
  { action: 'disable', label: 'Отключить', color: 'bad' },
  { action: 'enable', label: 'Включить', color: 'good' },
];

const CONSOLE_ACTIONS = [
  { action: 'access', label: 'Удалённый доступ', color: 'good' },
];

function getActions(type: string) {
  if (type === 'door') return DOOR_ACTIONS;
  if (type === 'turret') return TURRET_ACTIONS;
  return CONSOLE_ACTIONS;
}

export function IpcCyberdeck() {
  const { act, data } = useBackend<CyberdeckData>();
  const { heat, max_heat, overheat_at, disabled, overheated, targets } = data;

  const [filter, setFilter] = useState<string>('all');

  const heatRatio = heat / max_heat;
  const heatColor =
    heatRatio >= 1
      ? 'bad'
      : heatRatio >= overheat_at / max_heat
        ? 'average'
        : 'good';

  const filteredTargets =
    filter === 'all' ? targets : targets.filter((t) => t.type === filter);

  return (
    <Window title="Кибердека" width={480} height={520}>
      <Window.Content>
        <Stack vertical>
          {/* Статус */}
          <Stack.Item>
            <Section title="Статус системы">
              {disabled && (
                <NoticeBox danger>
                  <Icon name="exclamation-triangle" mr={1} />
                  Кибердека отключена (ЭМИ)
                </NoticeBox>
              )}
              {overheated && !disabled && (
                <NoticeBox warning>
                  <Icon name="fire" mr={1} />
                  ПЕРЕГРЕВ — ожоги активны
                </NoticeBox>
              )}
              <Box mt={1}>
                <Box mb={0.5} color="label">
                  Тепловая нагрузка: {heat} / {max_heat}
                </Box>
                <ProgressBar
                  value={heat}
                  minValue={0}
                  maxValue={max_heat}
                  color={heatColor}
                >
                  {heat >= overheat_at ? 'ПЕРЕГРЕВ' : `${Math.round(heatRatio * 100)}%`}
                </ProgressBar>
              </Box>
            </Section>
          </Stack.Item>

          {/* Фильтр */}
          <Stack.Item>
            <Flex gap={1}>
              {['all', 'door', 'turret', 'console'].map((f) => (
                <Flex.Item key={f}>
                  <Button
                    selected={filter === f}
                    onClick={() => setFilter(f)}
                    icon={f === 'all' ? 'list' : TYPE_ICON[f]}
                  >
                    {f === 'all'
                      ? 'Все'
                      : TYPE_LABEL[f] + 's'}
                  </Button>
                </Flex.Item>
              ))}
            </Flex>
          </Stack.Item>

          {/* Список целей */}
          <Stack.Item grow>
            <Section
              title={`Цели в зоне видимости (${filteredTargets.length})`}
              scrollable
              fill
            >
              {filteredTargets.length === 0 ? (
                <Box color="label" italic>
                  Нет доступных целей
                </Box>
              ) : (
                filteredTargets.map((target) => (
                  <Section
                    key={target.uid}
                    title={
                      <Flex align="center" gap={1}>
                        <Icon name={TYPE_ICON[target.type]} />
                        <Box>{target.name}</Box>
                        <Box color="label" fontSize="0.85em">
                          [{TYPE_LABEL[target.type]}]
                        </Box>
                      </Flex>
                    }
                    mb={1}
                  >
                    <Flex align="center" justify="space-between">
                      <Box color="label" fontSize="0.85em">
                        Статус: {target.status} · Нагрузка: +{target.heat_cost}°
                      </Box>
                      <Flex gap={0.5}>
                        {getActions(target.type).map((a) => (
                          <Button
                            key={a.action}
                            color={a.color}
                            disabled={disabled || heat >= max_heat}
                            onClick={() =>
                              act('hack', {
                                uid: target.uid,
                                type: target.type,
                                action: a.action,
                              })
                            }
                          >
                            {a.label}
                          </Button>
                        ))}
                      </Flex>
                    </Flex>
                  </Section>
                ))
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
