// BANDASTATION ADD START - Перенос ИИ: физическая панель слотов и загрузка закона.
import { capitalize } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Floating,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  type LawIntrusionData,
  LawIntrusionNotice,
} from '../bandastation/ai_overhaul/LawIntrusionNotice';
import { Window } from '../layouts';

enum SlotSecurity {
  NONE = 0,
  SCREWED = 1,
  WELDED = 2,
}

type SlotData = {
  name: string;
  security: SlotSecurity;
  ioned: BooleanLike;
  empty: BooleanLike;
};

type Linkable = {
  name: string;
  ref: string;
};

type Data = LawIntrusionData & {
  slots: SlotData[];
  holding_module: BooleanLike;
  holding_screwdriver: BooleanLike;
  holding_welder: BooleanLike;
  holding_multitool: BooleanLike;
  has_core_slot: BooleanLike;
  depowered: BooleanLike;
  parent_rack?: Linkable;
  linkable_silicons?: Linkable[];
  linkable_racks?: Linkable[];
  linked_mobs?: string[];
  linked_rack_module_count?: number;
  refresh_cooldown: number;
};

function getSlotColor(
  slot: SlotData,
  index: number,
  has_core_slot: BooleanLike,
): string {
  const is_core_slot = index === 0 && has_core_slot;
  if (slot.empty) return is_core_slot ? '#5AA6FF' : '#83BFB1';
  if (slot.ioned) return '#DD7973';
  return is_core_slot ? '#4183CD' : '#14BB69';
}

const LawSlotScrew = (props: {
  noscrew: BooleanLike;
  disabled: BooleanLike;
  tooltip?: string;
  handleScrew: () => void;
}) => {
  return (
    <Button
      tooltip={props.tooltip}
      className={props.noscrew ? 'LawRack__Screw Empty' : 'LawRack__Screw'}
      disabled={props.disabled}
      onClick={props.handleScrew}
    />
  );
};

const LawSlot = (props: { slot: SlotData; index: number }) => {
  const { act, data } = useBackend<Data>();

  const { slot, index } = props;
  const {
    holding_module,
    holding_screwdriver,
    holding_welder,
    holding_multitool,
    has_core_slot,
  } = data;

  return (
    <Box
      height="33px"
      backgroundColor={getSlotColor(slot, index, has_core_slot)}
      p={1}
      mb={-0.5}
      className="LawRack__Slot"
    >
      <Flex align="center">
        <Flex.Item mr={1}>
          <LawSlotScrew
            tooltip={
              slot.security === SlotSecurity.SCREWED && !holding_screwdriver
                ? 'Для откручивания модуля нужна отвёртка.'
                : holding_screwdriver && slot.security === SlotSecurity.WELDED
                  ? 'Сначала нужно срезать сварку, затем выкрутить винты.'
                  : undefined
            }
            noscrew={slot.empty || slot.security === SlotSecurity.NONE}
            disabled={
              !holding_screwdriver ||
              slot.empty ||
              slot.security === SlotSecurity.WELDED
            }
            handleScrew={() => act('screw_module', { slot: index + 1 })}
          />
        </Flex.Item>
        <Flex.Item width="85%">
          {(slot.security === SlotSecurity.WELDED || !!holding_welder) && (
            <Button
              textAlign="center"
              verticalAlignContent="middle"
              fluid
              tooltip={
                slot.security === SlotSecurity.WELDED && !holding_welder
                  ? 'Перед извлечением модуля нужно срезать сварку.'
                  : holding_welder &&
                      slot.security === SlotSecurity.NONE &&
                      !slot.empty
                    ? 'Перед сваркой закрепите модуль винтами.'
                    : undefined
              }
              className={
                slot.security === SlotSecurity.WELDED
                  ? 'LawRack__Welded'
                  : undefined
              }
              disabled={
                !holding_welder ||
                slot.empty ||
                slot.security === SlotSecurity.NONE
              }
              onClick={() => act('weld_module', { slot: index + 1 })}
            >
              {slot.security === SlotSecurity.WELDED
                ? 'Приварено'
                : slot.empty
                  ? slot.name || 'Пусто'
                  : 'Приварить модуль'}
            </Button>
          )}
          {slot.security !== SlotSecurity.WELDED && !!holding_multitool && (
            <Button
              height="100%"
              textAlign="center"
              verticalAlignContent="middle"
              fluid
              disabled={!slot.ioned}
              onClick={() => act('multitool_module', { slot: index + 1 })}
            >
              {' '}
              Устранить ионные повреждения{' '}
            </Button>
          )}
          {slot.security !== SlotSecurity.WELDED &&
            !holding_multitool &&
            !holding_welder &&
            (data.holding_hacked_law && slot.empty ? (
              <Button.Confirm
                fluid
                icon="plug"
                disabled={
                  data.law_intrusion_signature == null ||
                  !!data.law_intrusion_pending ||
                  !!(has_core_slot && index === 0)
                }
                confirmContent="Начать загрузку приоритетного закона?"
                key={`${data.hacked_law_ref}:${data.law_signature}:${data.law_intrusion_signature}:${index}`}
                onClick={() =>
                  act('insert_module', {
                    slot: index + 1,
                    module: data.hacked_law_ref,
                    signature: data.law_intrusion_signature,
                    law_signature: data.law_signature,
                  })
                }
              >
                {' '}
                Подключить устройство{' '}
              </Button.Confirm>
            ) : (
              <Button
                height="100%"
                textAlign="center"
                verticalAlignContent="middle"
                fluid
                tooltip={
                  slot.security === SlotSecurity.SCREWED
                    ? 'Перед извлечением модуля нужно выкрутить винты.'
                    : undefined
                }
                disabled={
                  (!holding_module && slot.empty) ||
                  slot.security !== SlotSecurity.NONE
                }
                style={{ textTransform: 'capitalize' }}
                onClick={() =>
                  act(
                    holding_module && slot.empty
                      ? 'insert_module'
                      : 'remove_module',
                    { slot: index + 1 },
                  )
                }
              >
                {slot.name || 'Пусто'}
              </Button>
            ))}
        </Flex.Item>
        <Flex.Item ml={1}>
          <LawSlotScrew
            tooltip={
              slot.security === SlotSecurity.SCREWED && !holding_screwdriver
                ? 'Для откручивания модуля нужна отвёртка.'
                : holding_screwdriver && slot.security === SlotSecurity.WELDED
                  ? 'Сначала нужно срезать сварку, затем выкрутить винты.'
                  : undefined
            }
            noscrew={slot.empty || slot.security === SlotSecurity.NONE}
            disabled={
              !holding_screwdriver ||
              slot.empty ||
              slot.security === SlotSecurity.WELDED
            }
            handleScrew={() => act('screw_module', { slot: index + 1 })}
          />
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const LinkableFloating = (props: {
  show_floating: boolean;
  linkable: Linkable[];
  link_act: (ref: string, name: string) => void;
  hide_floating: () => void;
  button: React.ReactNode;
}) => {
  const { show_floating, linkable, link_act, button, hide_floating } = props;

  if (!show_floating) {
    return button;
  }

  return (
    <Floating
      stopChildPropagation
      placement="top-start"
      content={
        <Stack
          fill
          backgroundColor="black"
          p={1}
          style={{
            borderRadius: '4px',
            boxShadow: '0px 4px 8px 3px rgba(0, 0, 0, 0.7)',
            flexDirection: 'column',
          }}
        >
          {linkable.map((item) => (
            <Stack.Item key={item.ref}>
              <Button
                icon="link"
                style={{ textTransform: 'capitalize' }}
                onClick={() => {
                  link_act(item.ref, item.name);
                  if (linkable.length === 1) hide_floating();
                }}
              >
                <b>{item.name}</b>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      }
    >
      {button}
    </Floating>
  );
};

const UnlinkableFloating = (props: {
  show_floating: boolean;
  unlinkable: string[];
  unlink_act: (index: number, name: string) => void;
  hide_floating: () => void;
  button: React.ReactNode;
  can_unlink: BooleanLike;
  unlink_tooltip?: string;
}) => {
  const {
    button,
    can_unlink,
    hide_floating,
    show_floating,
    unlink_act,
    unlink_tooltip,
    unlinkable,
  } = props;

  if (!show_floating) {
    return button;
  }

  return (
    <Floating
      stopChildPropagation
      placement="top-start"
      content={
        <Stack
          fill
          backgroundColor="black"
          p={1}
          style={{
            borderRadius: '4px',
            boxShadow: '0px 4px 8px 3px rgba(0, 0, 0, 0.7)',
            flexDirection: 'column',
          }}
        >
          {unlinkable.map((name, list_index) => (
            <Stack.Item key={name + list_index}>
              <Button
                icon="link-slash"
                style={{ textTransform: 'capitalize' }}
                disabled={!can_unlink}
                tooltip={unlink_tooltip}
                onClick={() => {
                  unlink_act(list_index, name);
                  if (unlinkable.length === 1) hide_floating();
                }}
              >
                <b>{name}</b>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      }
    >
      {button}
    </Floating>
  );
};

const BroadcasterDisplay = () => {
  const { data, act } = useBackend<Data>();
  const { depowered, parent_rack, linkable_racks } = data;

  const [rackLink, setRackLink] = useState(true);
  return (
    <Stack>
      <Stack.Item width="50%">
        <Stack p={1} className="LawRack__Console" vertical>
          <Stack.Item>
            &gt; <b>Связанная стойка:</b>
          </Stack.Item>
          <Stack.Item>
            {parent_rack ? capitalize(parent_rack.name) : 'Нет данных'}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item width="50%" align="center">
        <Stack vertical fill>
          <Stack.Item>
            <Button
              fluid
              width="100%"
              disabled={depowered || !parent_rack}
              tooltip={
                depowered
                  ? 'Нет питания!'
                  : parent_rack
                    ? undefined
                    : 'Связанной стойки нет!'
              }
              fontFamily="monospace"
              color={depowered || !parent_rack ? 'grey' : 'black'}
              onClick={() => act('unlink_rack')}
            >
              {' '}
              &gt; Отвязать стойку{' '}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <LinkableFloating
              show_floating={rackLink}
              linkable={linkable_racks || []}
              link_act={(ref, name) =>
                act('link_rack', {
                  rack_ref: ref,
                  rack_name: name,
                })
              }
              hide_floating={() => setRackLink(false)}
              button={
                <Button
                  width="100%"
                  disabled={
                    !linkable_racks?.length || depowered || !!parent_rack
                  }
                  tooltip={
                    depowered
                      ? 'Нет питания!'
                      : linkable_racks?.length
                        ? parent_rack
                          ? 'Уже привязано!'
                          : undefined
                        : 'Нет стоек для подключения!'
                  }
                  fontFamily="monospace"
                  color={depowered || parent_rack ? 'grey' : 'black'}
                  onClick={() => setRackLink(!rackLink)}
                >
                  {' '}
                  &gt; Новая привязка{' '}
                </Button>
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const BaseDisplay = () => {
  const { data, act } = useBackend<Data>();
  const { depowered, linkable_silicons, linked_mobs, parent_rack } = data;

  const [siliconLink, setSiliconLink] = useState(true);
  const [siliconUnlink, setSiliconUnlink] = useState(true);

  return (
    <Stack>
      <Stack.Item>
        <Stack p={1} className="LawRack__Console" vertical>
          <Stack.Item>
            &gt; <b>Связанные синтетики:</b>
          </Stack.Item>
          <Stack.Item style={{ wordBreak: 'break-word' }}>
            {linked_mobs?.length ? linked_mobs.join(', ') : 'Нет данных'}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical>
          <UnlinkableFloating
            show_floating={siliconUnlink}
            unlinkable={linked_mobs || []}
            can_unlink={!depowered}
            unlink_tooltip={depowered ? 'Нет питания!' : undefined}
            unlink_act={(index, name) =>
              act('unlink_silicon', {
                silicon_index: index,
                silicon_name: name,
              })
            }
            hide_floating={() => setSiliconUnlink(false)}
            button={
              <Button
                width="100%"
                disabled={!linked_mobs?.length || depowered}
                tooltip={
                  depowered
                    ? 'Нет питания!'
                    : linked_mobs?.length
                      ? undefined
                      : 'Связанных синтетиков нет!'
                }
                color={depowered || !linked_mobs?.length ? 'grey' : 'black'}
                fontFamily="monospace"
                onClick={() => setSiliconUnlink(!siliconUnlink)}
              >
                {' '}
                &gt; Управление связями{' '}
              </Button>
            }
          />
          <Stack.Item>
            <LinkableFloating
              show_floating={siliconLink}
              linkable={linkable_silicons || []}
              link_act={(ref, name) =>
                act('link_silicon', {
                  silicon_ref: ref,
                  silicon_name: name,
                })
              }
              hide_floating={() => setSiliconLink(false)}
              button={
                <Button
                  width="100%"
                  disabled={
                    !linkable_silicons?.length || depowered || !!parent_rack
                  }
                  tooltip={
                    depowered
                      ? 'Нет питания!'
                      : linkable_silicons?.length
                        ? parent_rack
                          ? 'Привязано к другой стойке!'
                          : undefined
                        : 'Нет синтетиков для подключения!'
                  }
                  color={
                    depowered || !linkable_silicons?.length ? 'gray' : 'black'
                  }
                  fontFamily="monospace"
                  onClick={() => setSiliconLink(!siliconLink)}
                >
                  {' '}
                  &gt; Новое подключение{' '}
                </Button>
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
export const LawRack = () => {
  const { data, act } = useBackend<Data>();
  const {
    depowered,
    linkable_racks,
    linked_mobs,
    slots,
    refresh_cooldown,
    linked_rack_module_count,
  } = data;

  return (
    <Window
      title="Стойка модулей"
      width={400}
      height={
        slots.length * 40 +
        200 +
        (data.holding_hacked_law || data.law_intrusion_pending ? 140 : 0)
      }
    >
      <Window.Content scrollable>
        <LawIntrusionNotice {...data} />
        <Section>
          <Stack vertical>
            {slots.map((slot, index) => (
              <Stack.Item key={index}>
                <LawSlot slot={slot} index={index} />
              </Stack.Item>
            ))}
            {linked_rack_module_count !== undefined && (
              <Stack.Item
                className="LawRack__Console"
                mt={1}
                p={0.5}
                textAlign="center"
              >
                <b>{linked_rack_module_count}</b> других модулей загружается
                удалённо.{' '}
              </Stack.Item>
            )}
          </Stack>
        </Section>
        <Section
          title="Управление"
          buttons={
            <Button
              icon="refresh"
              disabled={depowered || refresh_cooldown > 0}
              tooltipPosition="left"
              tooltip={
                depowered
                  ? 'Нет питания!'
                  : refresh_cooldown > 0
                    ? `Повтор через: ${Math.round(refresh_cooldown / 10)}s`
                    : 'Обновить данные модулей и подключений.'
              }
              onClick={() => act('refresh')}
            />
          }
        >
          <Stack vertical>
            <Stack.Item>
              <Stack>
                {linkable_racks && (
                  <Stack.Item grow>
                    <BroadcasterDisplay />
                  </Stack.Item>
                )}
                {linked_mobs && (
                  <Stack.Item grow>
                    <BaseDisplay />
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
// BANDASTATION ADD END - Перенос ИИ
