import { useState } from 'react';
import { Box, Button, Icon, Input, Modal, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type {
  IPCBrainType,
  IPCChassisBrand,
  IPCCustomization,
  IPCGeneration,
  IPCHEFManufacturer,
  IPCModule,
  PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

type IPCCustomizationProps = {
  handleClose: () => void;
};

// Маппинг брендов на иконки
const BRAND_ICONS: Record<string, string> = {
  unbranded: 'robot',
  morpheus: 'brain',
  etamin: 'temperature-low',
  bishop: 'plus-square',
  hesphiastos: 'shield-alt',
  ward_takahashi: 'running',
  xion: 'microchip',
  zeng_hu: 'flask',
  shellguard: 'shield-alt',
  cybersun: 'sun',
  hef: 'puzzle-piece',
};

// Цвета брендов для визуальной идентификации
const BRAND_COLORS: Record<string, string> = {
  unbranded: '#888888',
  morpheus: '#00d4ff',
  etamin: '#4fc3f7',
  bishop: '#4caf50',
  hesphiastos: '#ff5722',
  ward_takahashi: '#ffeb3b',
  xion: '#9c27b0',
  zeng_hu: '#00bcd4',
  shellguard: '#795548',
  cybersun: '#ff9800',
  hef: '#ffc107',
  general: '#888888',
};

const BRAIN_ICONS: Record<string, string> = {
  positronic: 'brain',
  mmi: 'head-side-virus',
  borg: 'server',
};

const BRAIN_COLORS: Record<string, string> = {
  positronic: '#00d4ff',
  mmi: '#ff5722',
  borg: '#9c27b0',
};

// Иконки для поколений
const GENERATION_ICONS: Record<string, string> = {
  gen1_modular: 'puzzle-piece',
  gen2_standard: 'robot',
  gen3_humanity: 'heart',
  gen4_cyberdeck: 'network-wired',
};

// Цвета для поколений
const GENERATION_COLORS: Record<string, string> = {
  gen1_modular: '#ffeb3b',
  gen2_standard: '#00d4ff',
  gen3_humanity: '#ff4081',
  gen4_cyberdeck: '#39ff14',
};

// Иконки для модулей (Gen I)
const MODULE_ICONS: Record<string, string> = {
  medical: 'plus-square',
  engineering: 'wrench',
  security: 'shield-alt',
  research: 'flask',
};

const MODULE_COLORS: Record<string, string> = {
  medical: '#4caf50',
  engineering: '#ff9800',
  security: '#f44336',
  research: '#9c27b0',
};

// Цвета в стиле Cyberpunk 2077
const CYBER_COLORS = {
  cyan: '#00f0ff',
  blue: '#0080ff',
  purple: '#9d4edd',
  yellow: '#ffc800',
  red: '#ff3333',
  green: '#39ff14',
  magenta: '#ff2a6d',
  textPrimary: '#e0e0e0',
  textSecondary: '#8a8a9a',
  bgDark: '#0a0a12',
  bgPanel: 'rgba(10, 10, 18, 0.95)',
};

// Конфигурация слотов
type SlotType = 'chassis' | 'brain' | 'hef' | 'generation' | 'gen1module';

type SlotConfig = {
  key: string;
  label: string;
  icon: string;
  color: string;
  type: SlotType;
};

const MAIN_SLOTS: SlotConfig[] = [
  {
    key: 'chassis',
    label: 'ШАССИ',
    icon: 'robot',
    color: CYBER_COLORS.blue,
    type: 'chassis',
  },
  {
    key: 'brain',
    label: 'ЯДРО',
    icon: 'brain',
    color: CYBER_COLORS.purple,
    type: 'brain',
  },
  {
    key: 'generation',
    label: 'ПОКОЛЕНИЕ',
    icon: 'microchip',
    color: CYBER_COLORS.cyan,
    type: 'generation',
  },
];

const HEF_SLOTS: SlotConfig[] = [
  {
    key: 'hef_head',
    label: 'ГОЛОВА',
    icon: 'head-side-virus',
    color: CYBER_COLORS.magenta,
    type: 'hef',
  },
  {
    key: 'hef_chest',
    label: 'ГРУДЬ',
    icon: 'heart',
    color: CYBER_COLORS.red,
    type: 'hef',
  },
  {
    key: 'hef_l_arm',
    label: 'ЛЕВАЯ РУКА',
    icon: 'hand-paper',
    color: CYBER_COLORS.yellow,
    type: 'hef',
  },
  {
    key: 'hef_r_arm',
    label: 'ПРАВАЯ РУКА',
    icon: 'hand-paper',
    color: CYBER_COLORS.yellow,
    type: 'hef',
  },
  {
    key: 'hef_l_leg',
    label: 'ЛЕВАЯ НОГА',
    icon: 'shoe-prints',
    color: CYBER_COLORS.green,
    type: 'hef',
  },
  {
    key: 'hef_r_leg',
    label: 'ПРАВАЯ НОГА',
    icon: 'shoe-prints',
    color: CYBER_COLORS.green,
    type: 'hef',
  },
];

// Слот выбора модуля для Gen I — добавляется в список слева когда gen = gen1_modular
const GEN1_MODULE_SLOT: SlotConfig = {
  key: 'gen1module',
  label: 'МОДУЛЬ',
  icon: 'puzzle-piece',
  color: CYBER_COLORS.yellow,
  type: 'gen1module',
};

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverData = useServerPrefs();

  const [activeSlot, setActiveSlot] = useState<string | null>('chassis');

  const customization: IPCCustomization = data.ipc_customization || {
    chassis_brand: 'unbranded',
    brain_type: 'positronic',
    hef_head: 'unbranded',
    hef_chest: 'unbranded',
    hef_l_arm: 'unbranded',
    hef_r_arm: 'unbranded',
    hef_l_leg: 'unbranded',
    hef_r_leg: 'unbranded',
    generation: 'gen2_standard',
    gen1_module: 'security',
  };

  const isIPC = data.character_preferences?.misc?.species === 'ipc';

  const ipcData = serverData?.ipc_customization;
  const chassisBrands: IPCChassisBrand[] = ipcData?.chassis_brands || [];
  const brainTypes: IPCBrainType[] = ipcData?.brain_types || [];
  const hefManufacturers: IPCHEFManufacturer[] = ipcData?.hef_manufacturers || [];
  const generations: IPCGeneration[] = ipcData?.generations || [];
  const gen1Modules: IPCModule[] = ipcData?.gen1_modules || [];

  const isHEF = customization.chassis_brand === 'hef';
  const isGen1 = customization.generation === 'gen1_modular';

  const currentChassis = chassisBrands.find((b) => b.key === customization.chassis_brand);
  const currentBrain = brainTypes.find((b) => b.key === customization.brain_type);
  const currentGeneration = generations.find((g) => g.key === customization.generation);
  const currentModule = gen1Modules.find((m) => m.key === customization.gen1_module);

  const getSlotValue = (slot: SlotConfig): string => {
    if (slot.type === 'chassis') return currentChassis?.name || 'Unbranded';
    if (slot.type === 'brain') return currentBrain?.name || 'Positronic';
    if (slot.type === 'generation') return currentGeneration?.name || 'Gen II: Standard';
    if (slot.type === 'gen1module') return currentModule?.name || 'Security';
    const manufacturerKey = customization[slot.key as keyof IPCCustomization] || 'unbranded';
    const manufacturer = hefManufacturers.find((m) => m.key === manufacturerKey);
    return manufacturer?.name || 'Unbranded';
  };

  const getSlotColor = (slot: SlotConfig): string => {
    if (slot.type === 'chassis')
      return BRAND_COLORS[customization.chassis_brand] || BRAND_COLORS.unbranded;
    if (slot.type === 'brain')
      return BRAIN_COLORS[customization.brain_type] || BRAIN_COLORS.positronic;
    if (slot.type === 'generation')
      return GENERATION_COLORS[customization.generation] || CYBER_COLORS.cyan;
    if (slot.type === 'gen1module')
      return MODULE_COLORS[customization.gen1_module] || CYBER_COLORS.yellow;
    const manufacturerKey = customization[slot.key as keyof IPCCustomization] || 'unbranded';
    return BRAND_COLORS[manufacturerKey.toLowerCase().replace(/[\s-]/g, '_')] || '#888888';
  };

  // Собираем видимые слоты
  const visibleSlots: SlotConfig[] = [
    ...MAIN_SLOTS,
    ...(isGen1 ? [GEN1_MODULE_SLOT] : []),
    ...(isHEF ? HEF_SLOTS : []),
  ];

  const renderSlot = (slot: SlotConfig) => {
    const isActive = activeSlot === slot.key;
    const value = getSlotValue(slot);
    const brandColor = getSlotColor(slot);

    return (
      <Box
        key={slot.key}
        style={{
          background: isActive
            ? `linear-gradient(135deg, rgba(0,240,255,0.2) 0%, ${CYBER_COLORS.bgPanel} 100%)`
            : `linear-gradient(135deg, rgba(26,26,36,0.8) 0%, ${CYBER_COLORS.bgPanel} 100%)`,
          border: isActive
            ? `2px solid ${CYBER_COLORS.cyan}`
            : `1px solid rgba(0,128,255,0.3)`,
          borderRadius: '4px',
          padding: '0.6rem 0.75rem',
          marginBottom: '0.5rem',
          cursor: 'pointer',
          transition: 'all 0.2s ease',
          boxShadow: isActive ? `0 0 15px rgba(0,240,255,0.4)` : 'none',
          position: 'relative',
          overflow: 'hidden',
        }}
        onClick={() => setActiveSlot(slot.key)}
      >
        <Box
          style={{
            position: 'absolute',
            left: 0,
            top: 0,
            bottom: 0,
            width: '4px',
            background: brandColor,
            boxShadow: `0 0 8px ${brandColor}`,
          }}
        />
        <Box style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginLeft: '0.5rem' }}>
          <Box
            style={{
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: `rgba(0,0,0,0.4)`,
              border: `2px solid ${brandColor}`,
              borderRadius: '4px',
              color: brandColor,
              fontSize: '1rem',
              boxShadow: isActive ? `0 0 8px ${brandColor}` : 'none',
            }}
          >
            <Icon name={slot.icon} />
          </Box>
          <Box style={{ flex: 1, minWidth: 0 }}>
            <Box
              style={{
                fontSize: '0.65rem',
                color: CYBER_COLORS.textSecondary,
                textTransform: 'uppercase',
                letterSpacing: '0.5px',
                marginBottom: '0.1rem',
              }}
            >
              {slot.label}
            </Box>
            <Box
              style={{
                fontSize: '0.8rem',
                color: isActive ? CYBER_COLORS.cyan : CYBER_COLORS.textPrimary,
                fontWeight: 600,
                lineHeight: 1.2,
                wordBreak: 'break-word',
              }}
            >
              {value}
            </Box>
          </Box>
          <Icon
            name={isActive ? 'chevron-right' : 'angle-right'}
            style={{
              color: isActive ? CYBER_COLORS.cyan : CYBER_COLORS.textSecondary,
              fontSize: '0.9rem',
            }}
          />
        </Box>
      </Box>
    );
  };

  const renderSelectionPanel = () => {
    if (!activeSlot) {
      return (
        <Box
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            height: '100%',
            color: CYBER_COLORS.textSecondary,
            textAlign: 'center',
            padding: '1.5rem',
          }}
        >
          <Icon name="hand-pointer" size={3} />
          <Box mt={1.5} style={{ fontSize: '1rem' }}>
            Выберите слот слева
          </Box>
        </Box>
      );
    }

    const slot = visibleSlots.find((s) => s.key === activeSlot);
    if (!slot) return null;

    type Option = { key: string; name: string; description?: string; icon?: string; color?: string };
    let options: Option[] = [];

    if (slot.type === 'chassis') {
      options = chassisBrands.map((b) => ({
        key: b.key,
        name: b.name,
        description: b.description,
        icon: BRAND_ICONS[b.key] || 'robot',
        color: BRAND_COLORS[b.key] || '#888',
      }));
    } else if (slot.type === 'brain') {
      options = brainTypes.map((b) => ({
        key: b.key,
        name: b.name,
        description: b.description,
        icon: BRAIN_ICONS[b.key] || 'brain',
        color: BRAIN_COLORS[b.key] || '#888',
      }));
    } else if (slot.type === 'generation') {
      options = generations.map((g) => ({
        key: g.key,
        name: g.name,
        description: g.description,
        icon: GENERATION_ICONS[g.key] || 'microchip',
        color: GENERATION_COLORS[g.key] || CYBER_COLORS.cyan,
      }));
    } else if (slot.type === 'gen1module') {
      options = gen1Modules.map((m) => ({
        key: m.key,
        name: m.name,
        description: m.description,
        icon: MODULE_ICONS[m.key] || 'cog',
        color: MODULE_COLORS[m.key] || '#888',
      }));
    } else {
      options = hefManufacturers.map((m) => ({
        key: m.key,
        name: m.name,
        icon: 'industry',
        color: BRAND_COLORS[m.key] || '#888',
      }));
    }

    let currentValue = '';
    if (slot.type === 'chassis') currentValue = customization.chassis_brand;
    else if (slot.type === 'brain') currentValue = customization.brain_type;
    else if (slot.type === 'generation') currentValue = customization.generation;
    else if (slot.type === 'gen1module') currentValue = customization.gen1_module;
    else currentValue = customization[slot.key as keyof IPCCustomization] || '';

    return (
      <Box style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        <Box
          style={{
            padding: '0.75rem 1rem',
            background: `linear-gradient(90deg, rgba(0,240,255,0.15), transparent)`,
            borderBottom: `2px solid ${slot.color}`,
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
          }}
        >
          <Icon name={slot.icon} style={{ color: slot.color, fontSize: '1.1rem' }} />
          <Box
            style={{
              fontSize: '1rem',
              fontWeight: 700,
              textTransform: 'uppercase',
              letterSpacing: '1px',
              color: slot.color,
            }}
          >
            {slot.label}
          </Box>
        </Box>

        <Box style={{ flex: 1, overflow: 'auto', padding: '0.5rem' }}>
          {options.map((option) => {
            const isSelected = option.key === currentValue;
            const optionColor = option.color || '#888';

            return (
              <Box
                key={option.key}
                style={{
                  background: isSelected
                    ? `linear-gradient(135deg, rgba(57,255,20,0.15) 0%, ${CYBER_COLORS.bgPanel} 100%)`
                    : 'rgba(0,0,0,0.3)',
                  border: isSelected
                    ? `2px solid ${CYBER_COLORS.green}`
                    : '1px solid rgba(0,240,255,0.2)',
                  borderRadius: '4px',
                  padding: '0.65rem 0.75rem',
                  marginBottom: '0.5rem',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
                  position: 'relative',
                  overflow: 'hidden',
                }}
                onClick={() => {
                  if (slot.type === 'chassis') {
                    act('set_chassis_brand', { brand: option.key });
                  } else if (slot.type === 'brain') {
                    act('set_brain_type', { brain_type: option.key });
                  } else if (slot.type === 'generation') {
                    act('set_generation', { generation: option.key });
                  } else if (slot.type === 'gen1module') {
                    act('set_gen1_module', { module: option.key });
                  } else {
                    act('set_hef_part', { part: slot.key, manufacturer: option.key });
                  }
                }}
              >
                <Box
                  style={{
                    position: 'absolute',
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: '4px',
                    background: optionColor,
                    boxShadow: isSelected ? `0 0 8px ${optionColor}` : 'none',
                  }}
                />
                <Box
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.6rem',
                    marginLeft: '0.5rem',
                  }}
                >
                  <Box
                    style={{
                      width: '36px',
                      height: '36px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      background: `rgba(0,0,0,0.3)`,
                      border: `2px solid ${optionColor}`,
                      borderRadius: '4px',
                      color: optionColor,
                      fontSize: '1rem',
                    }}
                  >
                    <Icon name={option.icon || 'cog'} />
                  </Box>

                  <Box style={{ flex: 1, minWidth: 0 }}>
                    <Box
                      style={{
                        fontSize: '0.9rem',
                        fontWeight: 600,
                        color: isSelected ? CYBER_COLORS.green : CYBER_COLORS.textPrimary,
                      }}
                    >
                      {option.name}
                    </Box>
                    {option.description && (
                      <Box
                        style={{
                          fontSize: '0.75rem',
                          color: CYBER_COLORS.textSecondary,
                          marginTop: '0.2rem',
                          lineHeight: 1.3,
                        }}
                      >
                        {option.description}
                      </Box>
                    )}
                  </Box>

                  {isSelected && (
                    <Icon
                      name="check"
                      style={{
                        color: CYBER_COLORS.green,
                        fontSize: '1.1rem',
                        textShadow: `0 0 8px ${CYBER_COLORS.green}`,
                      }}
                    />
                  )}
                </Box>
              </Box>
            );
          })}
        </Box>
      </Box>
    );
  };

  const genColor = GENERATION_COLORS[customization.generation] || CYBER_COLORS.cyan;

  return (
    <Modal width="800px" height="570px">
      <Box
        style={{
          background: `linear-gradient(135deg, ${CYBER_COLORS.bgDark} 0%, #12121a 100%)`,
          border: `2px solid ${CYBER_COLORS.blue}`,
          borderRadius: '4px',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          color: 'white',
        }}
      >
        {/* Заголовок */}
        <Box
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '0.6rem 1rem',
            background: `linear-gradient(90deg, rgba(0,128,255,0.25), transparent 50%, rgba(157,78,221,0.25))`,
            borderBottom: `2px solid rgba(0,128,255,0.4)`,
          }}
        >
          <Box
            bold
            style={{
              fontSize: '1.15rem',
              color: CYBER_COLORS.blue,
              textTransform: 'uppercase',
              letterSpacing: '2px',
              textShadow: `0 0 10px rgba(0,128,255,0.6)`,
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
            }}
          >
            <Icon name="robot" /> КОНФИГУРАЦИЯ КПБ
            {isHEF && (
              <Box
                as="span"
                ml={0.5}
                style={{
                  fontSize: '0.7rem',
                  background: 'rgba(255,200,0,0.25)',
                  border: '1px solid rgba(255,200,0,0.6)',
                  padding: '0.2rem 0.5rem',
                  borderRadius: '3px',
                  color: CYBER_COLORS.yellow,
                  textShadow: 'none',
                }}
              >
                HEF MODE
              </Box>
            )}
          </Box>
          <Button icon="times" color="red" onClick={props.handleClose}>
            Закрыть
          </Button>
        </Box>

        {/* Основной контент */}
        {!isIPC ? (
          <Box
            style={{
              flex: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Stack vertical align="center">
              <Icon name="exclamation-triangle" size={4} color="red" />
              <Box mt={1.5} bold fontSize={1.4}>
                ДОСТУП ЗАПРЕЩЁН
              </Box>
              <Box mt={0.5} color="label" fontSize={1}>
                Только для КПБ (IPC)
              </Box>
            </Stack>
          </Box>
        ) : (
          <Box style={{ display: 'flex', flex: 1, overflow: 'hidden' }}>
            {/* Левая панель - слоты */}
            <Box
              style={{
                width: '215px',
                minWidth: '215px',
                background: 'rgba(0,0,0,0.3)',
                borderRight: `1px solid rgba(0,128,255,0.25)`,
                padding: '0.75rem',
                overflowY: 'auto',
              }}
            >
              {MAIN_SLOTS.map(renderSlot)}

              {/* Слот модуля — только для Gen I */}
              {isGen1 && renderSlot(GEN1_MODULE_SLOT)}

              {/* HEF слоты */}
              {isHEF && (
                <>
                  <Box
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      padding: '0.5rem 0',
                      margin: '0.25rem 0',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '0.7rem',
                        textTransform: 'uppercase',
                        letterSpacing: '1px',
                        color: CYBER_COLORS.yellow,
                        whiteSpace: 'nowrap',
                      }}
                    >
                      HEF Части
                    </Box>
                    <Box
                      style={{
                        flex: 1,
                        height: '1px',
                        background: `linear-gradient(90deg, rgba(255,200,0,0.4), transparent)`,
                        marginLeft: '0.5rem',
                      }}
                    />
                  </Box>
                  {HEF_SLOTS.map(renderSlot)}
                </>
              )}
            </Box>

            {/* Центр - Статус КПБ */}
            <Box
              style={{
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                padding: '1rem',
                background: `radial-gradient(ellipse at 50% 50%, rgba(0,128,255,0.06) 0%, transparent 70%)`,
                position: 'relative',
              }}
            >
              {/* Сетка */}
              <Box
                style={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  backgroundImage: `
                    linear-gradient(rgba(0,128,255,0.03) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(0,128,255,0.03) 1px, transparent 1px)
                  `,
                  backgroundSize: '25px 25px',
                  pointerEvents: 'none',
                }}
              />

              {/* Центральный дисплей статуса */}
              <Box
                style={{
                  position: 'relative',
                  zIndex: 1,
                  width: '100%',
                  maxWidth: '240px',
                  padding: '1rem',
                  background:
                    'linear-gradient(180deg, rgba(0,128,255,0.15) 0%, rgba(0,0,0,0.4) 100%)',
                  border: `2px solid ${CYBER_COLORS.blue}`,
                  borderRadius: '6px',
                  boxShadow: `0 0 20px rgba(0,128,255,0.2), inset 0 0 30px rgba(0,128,255,0.05)`,
                }}
              >
                {/* Иконка робота */}
                <Box
                  style={{
                    textAlign: 'center',
                    marginBottom: '0.75rem',
                    paddingBottom: '0.5rem',
                    borderBottom: `1px solid rgba(0,128,255,0.3)`,
                  }}
                >
                  <Icon
                    name="robot"
                    style={{
                      fontSize: '2rem',
                      color: BRAND_COLORS[customization.chassis_brand] || CYBER_COLORS.blue,
                      display: 'block',
                      marginBottom: '0.25rem',
                      filter: `drop-shadow(0 0 10px ${BRAND_COLORS[customization.chassis_brand] || CYBER_COLORS.blue})`,
                    }}
                  />
                  <Box
                    bold
                    style={{
                      fontSize: '0.7rem',
                      textTransform: 'uppercase',
                      letterSpacing: '1px',
                      color: CYBER_COLORS.cyan,
                    }}
                  >
                    КОНФИГУРАЦИЯ
                  </Box>
                </Box>

                {/* Шасси */}
                <Box
                  style={{
                    padding: '0.5rem',
                    background: 'rgba(0,0,0,0.3)',
                    borderRadius: '4px',
                    marginBottom: '0.5rem',
                    borderLeft: `3px solid ${BRAND_COLORS[customization.chassis_brand] || '#888'}`,
                  }}
                >
                  <Box
                    style={{
                      fontSize: '0.6rem',
                      color: '#8a8a9a',
                      textTransform: 'uppercase',
                      letterSpacing: '1px',
                      marginBottom: '0.2rem',
                    }}
                  >
                    <Icon name="microchip" style={{ marginRight: '0.3rem' }} />
                    Шасси
                  </Box>
                  <Box bold style={{ fontSize: '0.85rem', color: BRAND_COLORS[customization.chassis_brand] || CYBER_COLORS.textPrimary, lineHeight: 1.2 }}>
                    {currentChassis?.name || 'Standard'}
                  </Box>
                </Box>

                {/* Ядро */}
                <Box
                  style={{
                    padding: '0.5rem',
                    background: 'rgba(0,0,0,0.3)',
                    borderRadius: '4px',
                    marginBottom: '0.5rem',
                    borderLeft: `3px solid ${BRAIN_COLORS[customization.brain_type] || '#888'}`,
                  }}
                >
                  <Box
                    style={{
                      fontSize: '0.6rem',
                      color: '#8a8a9a',
                      textTransform: 'uppercase',
                      letterSpacing: '1px',
                      marginBottom: '0.2rem',
                    }}
                  >
                    <Icon name="brain" style={{ marginRight: '0.3rem' }} />
                    Ядро
                  </Box>
                  <Box bold style={{ fontSize: '0.85rem', color: BRAIN_COLORS[customization.brain_type] || CYBER_COLORS.textPrimary, lineHeight: 1.2 }}>
                    {currentBrain?.name || 'Positronic'}
                  </Box>
                </Box>

                {/* Поколение */}
                <Box
                  style={{
                    padding: '0.5rem',
                    background: 'rgba(0,0,0,0.3)',
                    borderRadius: '4px',
                    marginBottom: '0.5rem',
                    borderLeft: `3px solid ${genColor}`,
                  }}
                >
                  <Box
                    style={{
                      fontSize: '0.6rem',
                      color: '#8a8a9a',
                      textTransform: 'uppercase',
                      letterSpacing: '1px',
                      marginBottom: '0.2rem',
                    }}
                  >
                    <Icon name="microchip" style={{ marginRight: '0.3rem' }} />
                    Поколение
                  </Box>
                  <Box bold style={{ fontSize: '0.85rem', color: genColor, lineHeight: 1.2 }}>
                    {currentGeneration?.name || 'Gen II: Standard'}
                  </Box>
                </Box>

                {/* Модуль Gen I */}
                {isGen1 && (
                  <Box
                    style={{
                      padding: '0.5rem',
                      background: 'rgba(255,200,0,0.06)',
                      borderRadius: '4px',
                      marginBottom: '0.5rem',
                      borderLeft: `3px solid ${MODULE_COLORS[customization.gen1_module] || CYBER_COLORS.yellow}`,
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '0.6rem',
                        color: '#8a8a9a',
                        textTransform: 'uppercase',
                        letterSpacing: '1px',
                        marginBottom: '0.2rem',
                      }}
                    >
                      <Icon name="puzzle-piece" style={{ marginRight: '0.3rem' }} />
                      Профессиональный модуль
                    </Box>
                    <Box bold style={{ fontSize: '0.85rem', color: MODULE_COLORS[customization.gen1_module] || CYBER_COLORS.yellow, lineHeight: 1.2 }}>
                      {currentModule?.name || 'Security'}
                    </Box>
                  </Box>
                )}

                {/* HEF статус */}
                <Box
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '0.4rem 0.5rem',
                    background: isHEF ? 'rgba(255,200,0,0.15)' : 'rgba(100,100,100,0.1)',
                    border: `1px solid ${isHEF ? 'rgba(255,200,0,0.5)' : 'rgba(100,100,100,0.3)'}`,
                    borderRadius: '3px',
                  }}
                >
                  <Box style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                    <Icon
                      name="puzzle-piece"
                      style={{ color: isHEF ? CYBER_COLORS.yellow : '#666', fontSize: '0.9rem' }}
                    />
                    <Box style={{ fontSize: '0.7rem', color: '#8a8a9a', textTransform: 'uppercase' }}>
                      HEF
                    </Box>
                  </Box>
                  <Box bold style={{ fontSize: '0.8rem', color: isHEF ? CYBER_COLORS.yellow : '#666', textTransform: 'uppercase' }}>
                    {isHEF ? 'АКТИВЕН' : 'НЕАКТИВЕН'}
                  </Box>
                </Box>
              </Box>

              {/* Пароль ОС */}
              <Box
                mt={1}
                style={{
                  position: 'relative',
                  zIndex: 1,
                  width: '100%',
                  maxWidth: '240px',
                  padding: '0.75rem 1rem',
                  background:
                    'linear-gradient(180deg, rgba(0,240,255,0.08) 0%, rgba(0,0,0,0.4) 100%)',
                  border: `1px solid ${CYBER_COLORS.cyan}40`,
                  borderRadius: '6px',
                }}
              >
                <Box
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.3rem',
                    marginBottom: '0.4rem',
                  }}
                >
                  <Icon name="lock" style={{ color: CYBER_COLORS.cyan, fontSize: '0.8rem' }} />
                  <Box
                    style={{
                      fontSize: '0.6rem',
                      color: '#8a8a9a',
                      textTransform: 'uppercase',
                      letterSpacing: '1px',
                    }}
                  >
                    Пароль ОС
                  </Box>
                </Box>
                <Input
                  fluid
                  placeholder="Пароль (опционально)..."
                  value={customization.os_password || ''}
                  onChange={(val: string) => {
                    act('set_os_password', { password: val });
                  }}
                />
                <Box
                  style={{
                    fontSize: '0.6rem',
                    color: CYBER_COLORS.textSecondary,
                    marginTop: '0.3rem',
                  }}
                >
                  {customization.os_password
                    ? 'Пароль установлен — автовход при спавне'
                    : 'Пусто — пароль вводится в игре'}
                </Box>
              </Box>
            </Box>

            {/* Правая панель - выбор */}
            <Box
              style={{
                width: '255px',
                minWidth: '255px',
                background: 'rgba(0,0,0,0.25)',
                borderLeft: `1px solid rgba(0,128,255,0.25)`,
                display: 'flex',
                flexDirection: 'column',
                overflow: 'hidden',
              }}
            >
              {renderSelectionPanel()}
            </Box>
          </Box>
        )}

        {/* Подвал */}
        <Box
          style={{
            padding: '0.5rem 1rem',
            background: 'rgba(0,0,0,0.4)',
            borderTop: `1px solid rgba(0,128,255,0.25)`,
            fontSize: '0.8rem',
            color: CYBER_COLORS.textSecondary,
            textAlign: 'center',
          }}
        >
          {isHEF
            ? 'HEF режим: выберите производителя для каждой части тела'
            : isGen1
              ? 'Gen I: выберите профессиональный модуль — без него эффективность -40%'
              : 'Выберите шасси "HEF" для модульной настройки или поколение для особых механик'}
        </Box>
      </Box>
    </Modal>
  );
};
