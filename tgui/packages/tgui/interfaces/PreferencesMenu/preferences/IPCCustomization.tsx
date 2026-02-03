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

// Части тела для HEF режима
const HEF_BODY_PARTS = [
  { key: 'hef_head', label: 'Голова', icon: 'head-side-virus' },
  { key: 'hef_chest', label: 'Торс', icon: 'heart' },
  { key: 'hef_l_arm', label: 'Л. Рука', icon: 'hand-paper' },
  { key: 'hef_r_arm', label: 'П. Рука', icon: 'hand-paper' },
  { key: 'hef_l_leg', label: 'Л. Нога', icon: 'shoe-prints' },
  { key: 'hef_r_leg', label: 'П. Нога', icon: 'shoe-prints' },
] as const;

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverData = useServerPrefs();

  // Какой выбор сейчас открыт
  const [activeSelection, setActiveSelection] = useState<string | null>(null);

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

  // Функция получения имени производителя для HEF части
  const getPartManufacturerName = (partKey: string) => {
    const manufacturerKey =
      customization[partKey as keyof IPCCustomization] || 'unbranded';
    const manufacturer = hefManufacturers.find(
      (m) => m.key === manufacturerKey,
    );
    return manufacturer?.name || 'Unbranded';
  };

  // Используем простой Modal со встроенными стилями для тестирования
  return (
    <Modal width="500px" height="500px">
      <Box
        style={{
          background: 'linear-gradient(135deg, #0a1628 0%, #1a2a4a 100%)',
          border: '2px solid #00aaff',
          borderRadius: '4px',
          padding: '0',
          color: 'white',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        {/* Заголовок */}
        <Box
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '0.75rem 1rem',
            background: 'linear-gradient(90deg, rgba(0,170,255,0.2), transparent)',
            borderBottom: '1px solid rgba(0,170,255,0.3)',
          }}
        >
          <Box
            bold
            style={{
              fontSize: '1.1rem',
              color: '#00aaff',
              textTransform: 'uppercase',
              letterSpacing: '2px',
            }}
          >
            <Icon name="robot" /> КОНФИГУРАЦИЯ КПБ
            {isHEF && (
              <Box
                as="span"
                ml={1}
                style={{
                  fontSize: '0.7rem',
                  background: 'rgba(255,200,0,0.2)',
                  border: '1px solid rgba(255,200,0,0.5)',
                  padding: '0.1rem 0.3rem',
                  borderRadius: '2px',
                  color: '#ffc800',
                }}
              >
                HEF
              </Box>
            )}
          </Box>
          <Button icon="times" color="red" onClick={props.handleClose}>
            Закрыть
          </Button>
        </Box>

        {/* Debug info */}
        <Box
          style={{
            background: 'rgba(0,0,0,0.3)',
            padding: '0.5rem',
            fontSize: '0.75rem',
            color: '#888',
          }}
        >
          species: {data.character_preferences?.misc?.species || 'N/A'} |
          is_ipc: {String(isIPC)} | chassis: {chassisBrands.length} |
          brains: {brainTypes.length}
        </Box>

        {/* Основной контент */}
        <Box style={{ flex: 1, overflow: 'auto', padding: '0.75rem' }}>
          {!isIPC ? (
            <Stack fill vertical align="center" justify="center">
              <Icon name="exclamation-triangle" size={3} color="red" />
              <Box mt={1} bold fontSize={1.2}>
                ДОСТУП ЗАПРЕЩЁН
              </Box>
              <Box mt={0.5} color="label">
                Только для КПБ (IPC)
              </Box>
            </Stack>
          ) : (
            <Stack vertical>
              {/* Превью персонажа */}
              <Stack.Item>
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'center',
                    marginBottom: '1rem',
                  }}
                >
                  <CharacterPreview
                    height="150px"
                    id={data.character_preview_view}
                  />
                </Box>
              </Stack.Item>

              {/* Выбор шасси */}
              <Stack.Item>
                <Box bold mb={0.5} style={{ color: '#00aaff' }}>
                  <Icon name="robot" /> Шасси: {currentChassis?.name || 'Unbranded'}
                </Box>
                <Stack wrap>
                  {chassisBrands.length === 0 ? (
                    <Box color="bad">Нет данных о шасси</Box>
                  ) : (
                    chassisBrands.map((brand) => (
                      <Stack.Item key={brand.key} m={0.25}>
                        <Button
                          compact
                          selected={brand.key === customization.chassis_brand}
                          tooltip={brand.description}
                          onClick={() =>
                            act('set_chassis_brand', { brand: brand.key })
                          }
                        >
                          <Icon name={BRAND_ICONS[brand.key] || 'robot'} />{' '}
                          {brand.name}
                        </Button>
                      </Stack.Item>
                    ))
                  )}
                </Stack>
              </Stack.Item>

              {/* Выбор мозга */}
              <Stack.Item mt={1}>
                <Box bold mb={0.5} style={{ color: '#aa55ff' }}>
                  <Icon name="brain" /> Тип ядра: {currentBrain?.name || 'Positronic'}
                </Box>
                <Stack wrap>
                  {brainTypes.length === 0 ? (
                    <Box color="bad">Нет данных о типах ядра</Box>
                  ) : (
                    brainTypes.map((brain) => (
                      <Stack.Item key={brain.key} m={0.25}>
                        <Button
                          compact
                          selected={brain.key === customization.brain_type}
                          tooltip={brain.description}
                          onClick={() =>
                            act('set_brain_type', { brain_type: brain.key })
                          }
                        >
                          <Icon name={BRAIN_ICONS[brain.key] || 'brain'} />{' '}
                          {brain.name}
                        </Button>
                      </Stack.Item>
                    ))
                  )}
                </Stack>
              </Stack.Item>

              {/* HEF части - только если HEF режим */}
              {isHEF && (
                <Stack.Item mt={1}>
                  <Box bold mb={0.5} style={{ color: '#ffc800' }}>
                    <Icon name="puzzle-piece" /> HEF Части
                  </Box>
                  <Box
                    style={{
                      fontSize: '0.75rem',
                      color: '#888',
                      marginBottom: '0.5rem',
                    }}
                  >
                    Выберите производителя для каждой части тела
                  </Box>
                  {HEF_BODY_PARTS.map((part) => (
                    <Box key={part.key} mb={0.5}>
                      <Box
                        inline
                        mr={1}
                        style={{ width: '80px', display: 'inline-block' }}
                      >
                        <Icon name={part.icon} /> {part.label}:
                      </Box>
                      <Button
                        compact
                        onClick={() =>
                          setActiveSelection(
                            activeSelection === part.key ? null : part.key,
                          )
                        }
                      >
                        {getPartManufacturerName(part.key)}{' '}
                        <Icon
                          name={
                            activeSelection === part.key
                              ? 'chevron-up'
                              : 'chevron-down'
                          }
                        />
                      </Button>
                      {activeSelection === part.key && (
                        <Box
                          mt={0.5}
                          ml={2}
                          style={{
                            background: 'rgba(0,0,0,0.2)',
                            padding: '0.5rem',
                            borderRadius: '2px',
                          }}
                        >
                          <Stack wrap>
                            {hefManufacturers.map((m) => (
                              <Stack.Item key={m.key} m={0.25}>
                                <Button
                                  compact
                                  selected={
                                    m.key ===
                                    customization[
                                      part.key as keyof IPCCustomization
                                    ]
                                  }
                                  onClick={() => {
                                    act('set_hef_part', {
                                      part: part.key,
                                      manufacturer: m.key,
                                    });
                                    setActiveSelection(null);
                                  }}
                                >
                                  {m.name}
                                </Button>
                              </Stack.Item>
                            ))}
                          </Stack>
                        </Box>
                      )}
                    </Box>
                  ))}
                </Stack.Item>
              )}
            </Stack>
          )}
        </Box>

        {/* Подвал */}
        <Box
          style={{
            padding: '0.5rem 1rem',
            background: 'rgba(0,0,0,0.3)',
            borderTop: '1px solid rgba(0,170,255,0.2)',
            fontSize: '0.7rem',
            color: '#666',
            textAlign: 'center',
          }}
        >
          {isHEF
            ? 'HEF режим активен - настройте каждую часть тела отдельно'
            : 'Выберите шасси "HEF" для настройки каждой части тела'}
        </Box>
      </Box>
    </Modal>
  );
};
