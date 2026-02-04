import { useState } from 'react';
import { Box, Button, Icon, Modal, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type {
  IPCBrainType,
  IPCChassisBrand,
  IPCCustomization,
  IPCHEFManufacturer,
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
  // HEF производители
  general: '#888888',
  hephaestus: '#ff5722',
  hephaestus_titan: '#d84315',
  interdyne: '#e91e63',
  wardtakahashi: '#ffeb3b',
  wardtakahashi_pro: '#ffd600',
  xion_light: '#ce93d8',
  gromtech: '#8bc34a',
  bishop_mk2: '#66bb6a',
  bishop_nano: '#81c784',
  etamin_industry: '#29b6f6',
  etamin_industry_lumineux: '#4fc3f7',
  shellguard_brand: '#795548',
  zeng_hu_brand: '#00bcd4',
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
type SlotConfig = {
  key: string;
  label: string;
  icon: string;
  color: string;
  type: 'chassis' | 'brain' | 'hef';
};

// Все слоты в одном списке - основные и HEF
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

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverData = useServerPrefs();

  // Какой слот сейчас выбран для редактирования
  const [activeSlot, setActiveSlot] = useState<string | null>('chassis');

  // Получаем данные IPC из middleware (ui_data)
  const customization: IPCCustomization = data.ipc_customization || {
    chassis_brand: 'unbranded',
    brain_type: 'positronic',
    hef_head: 'unbranded',
    hef_chest: 'unbranded',
    hef_l_arm: 'unbranded',
    hef_r_arm: 'unbranded',
    hef_l_leg: 'unbranded',
    hef_r_leg: 'unbranded',
  };

  // Проверяем species напрямую из character_preferences
  const isIPC = data.character_preferences?.misc?.species === 'ipc';

  // Получаем статические данные из serverData (preferences.json)
  const ipcData = serverData?.ipc_customization;
  const chassisBrands: IPCChassisBrand[] = ipcData?.chassis_brands || [];
  const brainTypes: IPCBrainType[] = ipcData?.brain_types || [];
  const hefManufacturers: IPCHEFManufacturer[] =
    ipcData?.hef_manufacturers || [];

  const isHEF = customization.chassis_brand === 'hef';

  // Находим текущие значения
  const currentChassis = chassisBrands.find(
    (b) => b.key === customization.chassis_brand,
  );
  const currentBrain = brainTypes.find(
    (b) => b.key === customization.brain_type,
  );

  // Получить значение слота
  const getSlotValue = (slot: SlotConfig): string => {
    if (slot.type === 'chassis') {
      return currentChassis?.name || 'Unbranded';
    }
    if (slot.type === 'brain') {
      return currentBrain?.name || 'Positronic';
    }
    const manufacturerKey =
      customization[slot.key as keyof IPCCustomization] || 'unbranded';
    const manufacturer = hefManufacturers.find(
      (m) => m.key === manufacturerKey,
    );
    return manufacturer?.name || 'Unbranded';
  };

  // Получить цвет для слота
  const getSlotColor = (slot: SlotConfig): string => {
    if (slot.type === 'chassis') {
      return BRAND_COLORS[customization.chassis_brand] || BRAND_COLORS.unbranded;
    }
    if (slot.type === 'brain') {
      return BRAIN_COLORS[customization.brain_type] || BRAIN_COLORS.positronic;
    }
    const manufacturerKey =
      customization[slot.key as keyof IPCCustomization] || 'unbranded';
    // Normalize key for color lookup
    const normalizedKey = manufacturerKey.toLowerCase().replace(/[\s-]/g, '_');
    return BRAND_COLORS[normalizedKey] || BRAND_COLORS.general || '#888888';
  };

  // Получить цвет для опции
  const getOptionColor = (key: string): string => {
    const normalizedKey = key.toLowerCase().replace(/[\s-]/g, '_');
    return BRAND_COLORS[normalizedKey] || BRAIN_COLORS[normalizedKey] || '#888888';
  };

  // Собираем все видимые слоты
  const visibleSlots = isHEF ? [...MAIN_SLOTS, ...HEF_SLOTS] : MAIN_SLOTS;

  // Рендер слота
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
        {/* Цветовой индикатор бренда */}
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

  // Рендер панели выбора
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

    const slot = [...MAIN_SLOTS, ...HEF_SLOTS].find(
      (s) => s.key === activeSlot,
    );
    if (!slot) return null;

    // Определяем опции для выбора
    let options: { key: string; name: string; description?: string }[] = [];

    if (slot.type === 'chassis') {
      options = chassisBrands.map((b) => ({
        key: b.key,
        name: b.name,
        description: b.description,
      }));
    } else if (slot.type === 'brain') {
      options = brainTypes.map((b) => ({
        key: b.key,
        name: b.name,
        description: b.description,
      }));
    } else {
      options = hefManufacturers.map((m) => ({
        key: m.key,
        name: m.name,
      }));
    }

    // Текущее выбранное значение
    let currentValue = '';
    if (slot.type === 'chassis') {
      currentValue = customization.chassis_brand;
    } else if (slot.type === 'brain') {
      currentValue = customization.brain_type;
    } else {
      currentValue = customization[slot.key as keyof IPCCustomization] || '';
    }

    return (
      <Box style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        {/* Заголовок выбора */}
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
          <Icon
            name={slot.icon}
            style={{ color: slot.color, fontSize: '1.1rem' }}
          />
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

        {/* Список опций */}
        <Box style={{ flex: 1, overflow: 'auto', padding: '0.5rem' }}>
          {options.map((option) => {
            const isSelected = option.key === currentValue;
            const optionIcon =
              slot.type === 'chassis'
                ? BRAND_ICONS[option.key] || 'robot'
                : slot.type === 'brain'
                  ? BRAIN_ICONS[option.key] || 'brain'
                  : 'industry';
            const optionColor = getOptionColor(option.key);

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
                  } else {
                    act('set_hef_part', {
                      part: slot.key,
                      manufacturer: option.key,
                    });
                  }
                }}
              >
                {/* Цветовая полоса бренда */}
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
                  {/* Иконка с цветом бренда */}
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
                    <Icon name={optionIcon} />
                  </Box>

                  {/* Текст */}
                  <Box style={{ flex: 1, minWidth: 0 }}>
                    <Box
                      style={{
                        fontSize: '0.9rem',
                        fontWeight: 600,
                        color: isSelected
                          ? CYBER_COLORS.green
                          : CYBER_COLORS.textPrimary,
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

                  {/* Галочка */}
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

  return (
    <Modal width="750px" height="550px">
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
            {/* Левая панель - ВСЕ слоты */}
            <Box
              style={{
                width: '200px',
                minWidth: '200px',
                background: 'rgba(0,0,0,0.3)',
                borderRight: `1px solid rgba(0,128,255,0.25)`,
                padding: '0.75rem',
                overflowY: 'auto',
              }}
            >
              {/* Основные слоты */}
              {MAIN_SLOTS.map(renderSlot)}

              {/* HEF слоты - только если HEF режим */}
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

                {/* Шасси - вертикальный блок */}
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
                  <Box
                    bold
                    style={{
                      fontSize: '0.85rem',
                      color: BRAND_COLORS[customization.chassis_brand] || CYBER_COLORS.textPrimary,
                      lineHeight: 1.2,
                    }}
                  >
                    {currentChassis?.name || 'Standard'}
                  </Box>
                </Box>

                {/* Ядро - вертикальный блок */}
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
                  <Box
                    bold
                    style={{
                      fontSize: '0.85rem',
                      color: BRAIN_COLORS[customization.brain_type] || CYBER_COLORS.textPrimary,
                      lineHeight: 1.2,
                    }}
                  >
                    {currentBrain?.name || 'Positronic'}
                  </Box>
                </Box>

                {/* HEF статус */}
                <Box
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '0.4rem 0.5rem',
                    background: isHEF
                      ? 'rgba(255,200,0,0.15)'
                      : 'rgba(100,100,100,0.1)',
                    border: `1px solid ${isHEF ? 'rgba(255,200,0,0.5)' : 'rgba(100,100,100,0.3)'}`,
                    borderRadius: '3px',
                  }}
                >
                  <Box
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.3rem',
                    }}
                  >
                    <Icon
                      name="puzzle-piece"
                      style={{ color: isHEF ? CYBER_COLORS.yellow : '#666', fontSize: '0.9rem' }}
                    />
                    <Box
                      style={{
                        fontSize: '0.7rem',
                        color: '#8a8a9a',
                        textTransform: 'uppercase',
                      }}
                    >
                      HEF
                    </Box>
                  </Box>
                  <Box
                    bold
                    style={{
                      fontSize: '0.8rem',
                      color: isHEF ? CYBER_COLORS.yellow : '#666',
                      textTransform: 'uppercase',
                    }}
                  >
                    {isHEF ? 'АКТИВЕН' : 'НЕАКТИВЕН'}
                  </Box>
                </Box>

                {/* HEF инфо */}
                {isHEF && (
                  <Box
                    mt={0.75}
                    style={{
                      textAlign: 'center',
                      fontSize: '0.7rem',
                      color: CYBER_COLORS.yellow,
                      padding: '0.4rem',
                      background: 'rgba(255,200,0,0.05)',
                      borderRadius: '3px',
                    }}
                  >
                    <Icon name="info-circle" /> Модульная система: {HEF_SLOTS.length} частей
                  </Box>
                )}
              </Box>
            </Box>

            {/* Правая панель - выбор */}
            <Box
              style={{
                width: '240px',
                minWidth: '240px',
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
            : 'Выберите шасси "HEF (Frankensteinian)" для модульной настройки'}
        </Box>
      </Box>
    </Modal>
  );
};
