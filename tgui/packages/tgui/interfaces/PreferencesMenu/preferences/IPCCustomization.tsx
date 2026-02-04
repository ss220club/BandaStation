import { useState } from 'react';
import { Box, Button, Icon, Modal, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { CharacterPreview } from '../../common/CharacterPreview';
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

const BRAIN_ICONS: Record<string, string> = {
  positronic: 'brain',
  mmi: 'head-side-virus',
  borg: 'server',
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

// Конфигурация слотов для Ripperdoc layout
type SlotConfig = {
  key: string;
  label: string;
  icon: string;
  color: string;
  side: 'left' | 'right';
  type: 'chassis' | 'brain' | 'hef';
};

// Части тела для HEF режима - расположение в стиле Ripperdoc
const SLOT_CONFIGS: SlotConfig[] = [
  // Левая сторона
  {
    key: 'chassis',
    label: 'Шасси',
    icon: 'robot',
    color: CYBER_COLORS.blue,
    side: 'left',
    type: 'chassis',
  },
  {
    key: 'brain',
    label: 'Ядро',
    icon: 'brain',
    color: CYBER_COLORS.purple,
    side: 'left',
    type: 'brain',
  },
  {
    key: 'hef_l_arm',
    label: 'Л. Рука',
    icon: 'hand-paper',
    color: CYBER_COLORS.yellow,
    side: 'left',
    type: 'hef',
  },
  {
    key: 'hef_l_leg',
    label: 'Л. Нога',
    icon: 'shoe-prints',
    color: CYBER_COLORS.green,
    side: 'left',
    type: 'hef',
  },
  // Правая сторона
  {
    key: 'hef_head',
    label: 'Голова',
    icon: 'head-side-virus',
    color: CYBER_COLORS.magenta,
    side: 'right',
    type: 'hef',
  },
  {
    key: 'hef_chest',
    label: 'Торс',
    icon: 'heart',
    color: CYBER_COLORS.red,
    side: 'right',
    type: 'hef',
  },
  {
    key: 'hef_r_arm',
    label: 'П. Рука',
    icon: 'hand-paper',
    color: CYBER_COLORS.yellow,
    side: 'right',
    type: 'hef',
  },
  {
    key: 'hef_r_leg',
    label: 'П. Нога',
    icon: 'shoe-prints',
    color: CYBER_COLORS.green,
    side: 'right',
    type: 'hef',
  },
];

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverData = useServerPrefs();

  // Какой слот сейчас выбран для редактирования
  const [activeSlot, setActiveSlot] = useState<string | null>(null);

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

  // Проверяем species напрямую из character_preferences (как в MainPage.tsx)
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
    // HEF part
    const manufacturerKey =
      customization[slot.key as keyof IPCCustomization] || 'unbranded';
    const manufacturer = hefManufacturers.find(
      (m) => m.key === manufacturerKey,
    );
    return manufacturer?.name || 'Unbranded';
  };

  // Проверить, должен ли слот быть видимым
  const isSlotVisible = (slot: SlotConfig): boolean => {
    if (slot.type === 'chassis' || slot.type === 'brain') {
      return true; // Всегда показываем шасси и мозг
    }
    return isHEF; // HEF части только если включен HEF режим
  };

  // Фильтруем слоты по стороне
  const leftSlots = SLOT_CONFIGS.filter(
    (s) => s.side === 'left' && isSlotVisible(s),
  );
  const rightSlots = SLOT_CONFIGS.filter(
    (s) => s.side === 'right' && isSlotVisible(s),
  );

  // Рендер слота
  const renderSlot = (slot: SlotConfig) => {
    const isActive = activeSlot === slot.key;
    const value = getSlotValue(slot);

    return (
      <Box
        key={slot.key}
        style={{
          background: isActive
            ? `linear-gradient(135deg, rgba(0,240,255,0.15) 0%, ${CYBER_COLORS.bgPanel} 100%)`
            : `linear-gradient(135deg, rgba(26,26,36,0.8) 0%, ${CYBER_COLORS.bgPanel} 100%)`,
          border: isActive
            ? `2px solid ${CYBER_COLORS.cyan}`
            : `1px solid rgba(${slot.color === CYBER_COLORS.blue ? '0,128,255' : '0,240,255'},0.3)`,
          borderRadius: '3px',
          padding: '0.5rem',
          marginBottom: '0.5rem',
          cursor: 'pointer',
          transition: 'all 0.2s ease',
          boxShadow: isActive ? `0 0 15px rgba(0,240,255,0.3)` : 'none',
        }}
        onClick={() => setActiveSlot(isActive ? null : slot.key)}
      >
        <Box
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
          }}
        >
          <Box
            style={{
              width: '28px',
              height: '28px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: `rgba(${slot.color === CYBER_COLORS.blue ? '0,128,255' : slot.color === CYBER_COLORS.purple ? '157,78,221' : slot.color === CYBER_COLORS.yellow ? '255,200,0' : slot.color === CYBER_COLORS.green ? '57,255,20' : slot.color === CYBER_COLORS.magenta ? '255,42,109' : '255,51,51'},0.2)`,
              border: `1px solid ${slot.color}`,
              borderRadius: '2px',
              color: slot.color,
              fontSize: '0.85rem',
            }}
          >
            <Icon name={slot.icon} />
          </Box>
          <Box style={{ flex: 1 }}>
            <Box
              style={{
                fontSize: '0.65rem',
                color: CYBER_COLORS.textSecondary,
                textTransform: 'uppercase',
                letterSpacing: '1px',
              }}
            >
              {slot.label}
            </Box>
            <Box
              style={{
                fontSize: '0.75rem',
                color: CYBER_COLORS.textPrimary,
                fontWeight: 600,
              }}
            >
              {value}
            </Box>
          </Box>
          <Icon
            name={isActive ? 'chevron-up' : 'chevron-right'}
            style={{ color: CYBER_COLORS.textSecondary, fontSize: '0.7rem' }}
          />
        </Box>
      </Box>
    );
  };

  // Рендер панели выбора для активного слота
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
            padding: '1rem',
          }}
        >
          <Icon name="mouse-pointer" size={2} />
          <Box mt={1} style={{ fontSize: '0.8rem' }}>
            Выберите слот слева или справа
          </Box>
          <Box
            mt={0.5}
            style={{ fontSize: '0.7rem', color: CYBER_COLORS.textSecondary }}
          >
            для изменения компонента
          </Box>
        </Box>
      );
    }

    const slot = SLOT_CONFIGS.find((s) => s.key === activeSlot);
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

    // Получаем текущее выбранное значение
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
        <Box
          style={{
            padding: '0.5rem 0.75rem',
            background: `linear-gradient(90deg, rgba(0,240,255,0.1), transparent)`,
            borderBottom: `1px solid rgba(0,240,255,0.2)`,
            fontSize: '0.75rem',
            fontWeight: 700,
            textTransform: 'uppercase',
            letterSpacing: '1px',
            color: slot.color,
          }}
        >
          <Icon name={slot.icon} /> {slot.label}
        </Box>
        <Box style={{ flex: 1, overflow: 'auto', padding: '0.5rem' }}>
          {options.map((option) => {
            const isSelected = option.key === currentValue;
            return (
              <Box
                key={option.key}
                style={{
                  background: isSelected
                    ? `linear-gradient(135deg, rgba(57,255,20,0.1) 0%, ${CYBER_COLORS.bgPanel} 100%)`
                    : 'rgba(0,0,0,0.3)',
                  border: isSelected
                    ? `1px solid ${CYBER_COLORS.green}`
                    : '1px solid rgba(0,240,255,0.2)',
                  borderRadius: '2px',
                  padding: '0.5rem',
                  marginBottom: '0.4rem',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
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
                <Box
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                  }}
                >
                  <Box
                    style={{
                      width: '24px',
                      height: '24px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      background: isSelected
                        ? `rgba(57,255,20,0.2)`
                        : `rgba(0,128,255,0.2)`,
                      border: `1px solid ${isSelected ? CYBER_COLORS.green : 'rgba(0,128,255,0.4)'}`,
                      borderRadius: '2px',
                      color: isSelected ? CYBER_COLORS.green : CYBER_COLORS.blue,
                      fontSize: '0.75rem',
                    }}
                  >
                    <Icon
                      name={
                        slot.type === 'chassis'
                          ? (BRAND_ICONS[option.key] || 'robot')
                          : slot.type === 'brain'
                            ? (BRAIN_ICONS[option.key] || 'brain')
                            : 'industry'
                      }
                    />
                  </Box>
                  <Box style={{ flex: 1, minWidth: 0 }}>
                    <Box
                      style={{
                        fontSize: '0.75rem',
                        fontWeight: 600,
                        color: CYBER_COLORS.textPrimary,
                      }}
                    >
                      {option.name}
                    </Box>
                    {option.description && (
                      <Box
                        style={{
                          fontSize: '0.6rem',
                          color: CYBER_COLORS.textSecondary,
                          marginTop: '0.1rem',
                          whiteSpace: 'nowrap',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
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
                        textShadow: `0 0 5px ${CYBER_COLORS.green}`,
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

  // Используем Ripperdoc-style layout
  return (
    <Modal width="650px" height="500px">
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
            padding: '0.5rem 0.75rem',
            background: `linear-gradient(90deg, rgba(0,128,255,0.2), transparent 50%, rgba(157,78,221,0.2))`,
            borderBottom: `1px solid rgba(0,128,255,0.3)`,
          }}
        >
          <Box
            bold
            style={{
              fontSize: '1rem',
              color: CYBER_COLORS.blue,
              textTransform: 'uppercase',
              letterSpacing: '2px',
              textShadow: `0 0 10px rgba(0,128,255,0.5)`,
            }}
          >
            <Icon name="robot" /> КОНФИГУРАЦИЯ КПБ
            {isHEF && (
              <Box
                as="span"
                ml={1}
                style={{
                  fontSize: '0.6rem',
                  background: 'rgba(255,200,0,0.2)',
                  border: '1px solid rgba(255,200,0,0.5)',
                  padding: '0.1rem 0.3rem',
                  borderRadius: '2px',
                  color: CYBER_COLORS.yellow,
                  textShadow: 'none',
                }}
              >
                HEF MODE
              </Box>
            )}
          </Box>
          <Button compact icon="times" color="red" onClick={props.handleClose}>
            Закрыть
          </Button>
        </Box>

        {/* Основной контент - Ripperdoc layout */}
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
              <Icon name="exclamation-triangle" size={3} color="red" />
              <Box mt={1} bold fontSize={1.2}>
                ДОСТУП ЗАПРЕЩЁН
              </Box>
              <Box mt={0.5} color="label">
                Только для КПБ (IPC)
              </Box>
            </Stack>
          </Box>
        ) : (
          <Box style={{ display: 'flex', flex: 1, overflow: 'hidden' }}>
            {/* Левая панель - слоты */}
            <Box
              style={{
                width: '150px',
                minWidth: '150px',
                background: 'rgba(0,0,0,0.3)',
                borderRight: `1px solid rgba(0,128,255,0.2)`,
                padding: '0.5rem',
                overflowY: 'auto',
              }}
            >
              {leftSlots.map(renderSlot)}
            </Box>

            {/* Центр - персонаж и информация */}
            <Box
              style={{
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                padding: '0.5rem',
                background: `radial-gradient(ellipse at 50% 50%, rgba(0,128,255,0.05) 0%, transparent 70%)`,
                position: 'relative',
              }}
            >
              {/* Сетка на фоне */}
              <Box
                style={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  backgroundImage: `
                    linear-gradient(rgba(0,128,255,0.02) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(0,128,255,0.02) 1px, transparent 1px)
                  `,
                  backgroundSize: '20px 20px',
                  pointerEvents: 'none',
                }}
              />

              {/* Персонаж */}
              <Box style={{ position: 'relative', zIndex: 1 }}>
                <CharacterPreview
                  height="180px"
                  id={data.character_preview_view}
                />
              </Box>

              {/* Информация */}
              <Box
                mt={0.5}
                style={{
                  textAlign: 'center',
                  zIndex: 1,
                }}
              >
                <Box
                  bold
                  style={{
                    fontSize: '0.85rem',
                    textTransform: 'uppercase',
                    letterSpacing: '1px',
                    color: CYBER_COLORS.textPrimary,
                  }}
                >
                  {currentChassis?.name || 'STANDARD'}
                </Box>
                <Box
                  style={{
                    fontSize: '0.7rem',
                    color: CYBER_COLORS.purple,
                  }}
                >
                  <Icon name="brain" /> {currentBrain?.name || 'Positronic'}
                </Box>
                {isHEF && (
                  <Box
                    mt={0.25}
                    style={{
                      fontSize: '0.6rem',
                      color: CYBER_COLORS.yellow,
                    }}
                  >
                    HEF модульная система
                  </Box>
                )}
              </Box>
            </Box>

            {/* Правая панель - слоты или выбор */}
            <Box
              style={{
                width: '180px',
                minWidth: '180px',
                background: 'rgba(0,0,0,0.2)',
                borderLeft: `1px solid rgba(0,128,255,0.2)`,
                display: 'flex',
                flexDirection: 'column',
                overflow: 'hidden',
              }}
            >
              {activeSlot ? (
                renderSelectionPanel()
              ) : (
                <Box style={{ padding: '0.5rem', overflowY: 'auto' }}>
                  {rightSlots.map(renderSlot)}
                  {rightSlots.length === 0 && (
                    <Box
                      style={{
                        textAlign: 'center',
                        color: CYBER_COLORS.textSecondary,
                        fontSize: '0.7rem',
                        padding: '1rem',
                      }}
                    >
                      <Icon name="info-circle" />
                      <Box mt={0.5}>
                        Выберите шасси HEF для настройки отдельных частей тела
                      </Box>
                    </Box>
                  )}
                </Box>
              )}
            </Box>
          </Box>
        )}

        {/* Подвал */}
        <Box
          style={{
            padding: '0.4rem 0.75rem',
            background: 'rgba(0,0,0,0.4)',
            borderTop: `1px solid rgba(0,128,255,0.2)`,
            fontSize: '0.65rem',
            color: CYBER_COLORS.textSecondary,
            textAlign: 'center',
          }}
        >
          {isHEF
            ? 'HEF режим: настройте производителя для каждой части тела'
            : 'Выберите шасси "HEF (Frankensteinian)" для модульной настройки'}
        </Box>
      </Box>
    </Modal>
  );
};
