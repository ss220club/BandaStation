import { useState, useMemo } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Modal,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { CharacterPreview } from '../../common/CharacterPreview';
import { LoadingScreen } from '../../common/LoadingScreen';
import type { BodyModification, PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

type BodyModificationsProps = {
  handleClose: () => void;
};

// Маппинг категорий на иконки и цвета
const CATEGORY_CONFIG: Record<
  string,
  { icon: string; colorClass: string; order: number; color: string }
> = {
  Протезы: {
    icon: 'hand-paper',
    colorClass: 'prosthetics',
    order: 1,
    color: '#ffc800',
  },
  Prosthetics: {
    icon: 'hand-paper',
    colorClass: 'prosthetics',
    order: 1,
    color: '#ffc800',
  },
  Импланты: {
    icon: 'microchip',
    colorClass: 'implants',
    order: 2,
    color: '#ff2a6d',
  },
  Implants: {
    icon: 'microchip',
    colorClass: 'implants',
    order: 2,
    color: '#ff2a6d',
  },
  Органы: { icon: 'heart', colorClass: 'organs', order: 3, color: '#ff3333' },
  Organs: { icon: 'heart', colorClass: 'organs', order: 3, color: '#ff3333' },
  Ампутации: {
    icon: 'cut',
    colorClass: 'prosthetics',
    order: 4,
    color: '#ffc800',
  },
  Amputations: {
    icon: 'cut',
    colorClass: 'prosthetics',
    order: 4,
    color: '#ffc800',
  },
  Роботизация: {
    icon: 'robot',
    colorClass: 'chassis',
    order: 5,
    color: '#0080ff',
  },
  Robotic: {
    icon: 'robot',
    colorClass: 'chassis',
    order: 5,
    color: '#0080ff',
  },
};

const DEFAULT_CATEGORY_CONFIG = {
  icon: 'cog',
  colorClass: 'implants',
  order: 99,
  color: '#00f0ff',
};

export const BodyModificationsPage = (props: BodyModificationsProps) => {
  const serverData = useServerPrefs();
  const { data } = useBackend<PreferencesMenuData>();

  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <Modal width="700px" height="550px">
      <Box
        style={{
          background: 'linear-gradient(135deg, #0a0a12 0%, #1a1a24 100%)',
          border: '2px solid #ff2a6d',
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
            padding: '0.75rem 1rem',
            background:
              'linear-gradient(90deg, rgba(255,42,109,0.2), transparent)',
            borderBottom: '1px solid rgba(255,42,109,0.3)',
          }}
        >
          <Box
            bold
            style={{
              fontSize: '1.1rem',
              color: '#ff2a6d',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              textShadow: '0 0 10px rgba(255,42,109,0.5)',
            }}
          >
            <Icon name="user-astronaut" /> МОДИФИКАЦИИ ТЕЛА
            <Box
              as="span"
              ml={1}
              style={{
                fontSize: '0.65rem',
                color: '#8a8a9a',
                letterSpacing: '1px',
                textShadow: 'none',
              }}
            >
              RIPPERDOC v2.77
            </Box>
          </Box>
          <Button icon="times" color="red" onClick={props.handleClose}>
            Закрыть
          </Button>
        </Box>

        {/* Основной контент */}
        <BodyModificationsContent
          bodyModifications={serverData.body_modifications || []}
          characterPreviewId={data.character_preview_view}
        />
      </Box>
    </Modal>
  );
};

type BodyModificationsContentProps = {
  bodyModifications: BodyModification[];
  characterPreviewId: string;
};

const BodyModificationsContent = (props: BodyModificationsContentProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    applied_body_modifications = [],
    incompatible_body_modifications = [],
  } = data;

  const [activeCategory, setActiveCategory] = useState<string | null>(null);

  // Группируем модификации по категориям
  const { categories, modificationsByCategory } = useMemo(() => {
    const byCategory: Record<string, BodyModification[]> = {};

    props.bodyModifications.forEach((mod) => {
      const category = mod.category || 'Прочее';
      if (!byCategory[category]) {
        byCategory[category] = [];
      }
      byCategory[category].push(mod);
    });

    // Сортируем категории по порядку
    const sortedCategories = Object.keys(byCategory).sort((a, b) => {
      const orderA = CATEGORY_CONFIG[a]?.order ?? DEFAULT_CATEGORY_CONFIG.order;
      const orderB = CATEGORY_CONFIG[b]?.order ?? DEFAULT_CATEGORY_CONFIG.order;
      return orderA - orderB;
    });

    return {
      categories: sortedCategories,
      modificationsByCategory: byCategory,
    };
  }, [props.bodyModifications]);

  // Установленные модификации
  const installedMods = useMemo(() => {
    return props.bodyModifications.filter((mod) =>
      applied_body_modifications.includes(mod.key),
    );
  }, [props.bodyModifications, applied_body_modifications]);

  // Текущая выбранная категория или первая
  const currentCategory = activeCategory || categories[0] || null;
  const currentMods = currentCategory
    ? modificationsByCategory[currentCategory] || []
    : [];

  const getCategoryConfig = (category: string) =>
    CATEGORY_CONFIG[category] || DEFAULT_CATEGORY_CONFIG;

  // Стили для панелей
  const panelStyles = {
    categories: {
      width: '160px',
      minWidth: '160px',
      background: 'rgba(0, 0, 0, 0.3)',
      borderRight: '1px solid rgba(255, 42, 109, 0.2)',
      display: 'flex',
      flexDirection: 'column' as const,
      overflowY: 'auto' as const,
    },
    preview: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column' as const,
      alignItems: 'center',
      justifyContent: 'center',
      padding: '1rem',
      background:
        'radial-gradient(circle at 50% 50%, rgba(255,42,109,0.05) 0%, transparent 70%)',
      minWidth: '200px',
    },
    list: {
      width: '260px',
      minWidth: '260px',
      background: 'rgba(0, 0, 0, 0.2)',
      borderLeft: '1px solid rgba(255, 42, 109, 0.2)',
      display: 'flex',
      flexDirection: 'column' as const,
      overflow: 'hidden',
    },
  };

  return (
    <Box style={{ display: 'flex', flex: 1, overflow: 'hidden' }}>
      {/* Левая панель - Категории */}
      <Box style={panelStyles.categories}>
        <Box
          style={{
            padding: '0.5rem 0.75rem',
            fontSize: '0.65rem',
            textTransform: 'uppercase',
            letterSpacing: '1px',
            color: '#8a8a9a',
            borderBottom: '1px solid rgba(255,42,109,0.1)',
          }}
        >
          КАТЕГОРИИ
        </Box>

        {/* Установленные */}
        {installedMods.length > 0 && (
          <Box
            style={{
              padding: '0.5rem 0.75rem',
              cursor: 'pointer',
              borderLeft:
                activeCategory === '__installed__'
                  ? '3px solid #39ff14'
                  : '3px solid transparent',
              background:
                activeCategory === '__installed__'
                  ? 'rgba(57,255,20,0.1)'
                  : 'transparent',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
            }}
            onClick={() => setActiveCategory('__installed__')}
          >
            <Icon name="check-circle" color="#39ff14" />
            <span style={{ fontSize: '0.75rem' }}>Установлено</span>
            <Box
              as="span"
              ml="auto"
              style={{
                fontSize: '0.65rem',
                padding: '0.1rem 0.3rem',
                background: 'rgba(57,255,20,0.2)',
                borderRadius: '2px',
                color: '#39ff14',
              }}
            >
              {installedMods.length}
            </Box>
          </Box>
        )}

        {/* Категории модификаций */}
        {categories.map((category) => {
          const config = getCategoryConfig(category);
          const count = modificationsByCategory[category]?.length || 0;
          const isActive = currentCategory === category;

          return (
            <Box
              key={category}
              style={{
                padding: '0.5rem 0.75rem',
                cursor: 'pointer',
                borderLeft: isActive
                  ? `3px solid ${config.color}`
                  : '3px solid transparent',
                background: isActive ? `rgba(255,42,109,0.1)` : 'transparent',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
              onClick={() => setActiveCategory(category)}
            >
              <Icon name={config.icon} style={{ color: config.color }} />
              <span style={{ fontSize: '0.75rem' }}>{category}</span>
              <Box
                as="span"
                ml="auto"
                style={{
                  fontSize: '0.65rem',
                  padding: '0.1rem 0.3rem',
                  background: 'rgba(255,42,109,0.2)',
                  borderRadius: '2px',
                  color: '#ff2a6d',
                }}
              >
                {count}
              </Box>
            </Box>
          );
        })}

        {categories.length === 0 && (
          <Box
            style={{ padding: '1rem', color: '#8a8a9a', textAlign: 'center' }}
          >
            Нет доступных категорий
          </Box>
        )}
      </Box>

      {/* Центральная панель - Превью персонажа */}
      <Box style={panelStyles.preview}>
        <CharacterPreview height="200px" id={props.characterPreviewId} />
        <Box mt={1} style={{ textAlign: 'center' }}>
          <Box
            bold
            style={{
              fontSize: '0.9rem',
              textTransform: 'uppercase',
              letterSpacing: '1px',
            }}
          >
            ПАЦИЕНТ
          </Box>
          <Stack mt={0.5} justify="center">
            <Stack.Item>
              <Box style={{ textAlign: 'center' }}>
                <Box
                  bold
                  style={{ fontSize: '1.1rem', color: '#ffc800' }}
                >
                  {installedMods.length}
                </Box>
                <Box
                  style={{
                    fontSize: '0.6rem',
                    color: '#8a8a9a',
                    textTransform: 'uppercase',
                  }}
                >
                  Модификаций
                </Box>
              </Box>
            </Stack.Item>
            <Stack.Item ml={2}>
              <Box style={{ textAlign: 'center' }}>
                <Box
                  bold
                  style={{ fontSize: '1.1rem', color: '#00f0ff' }}
                >
                  {props.bodyModifications.length}
                </Box>
                <Box
                  style={{
                    fontSize: '0.6rem',
                    color: '#8a8a9a',
                    textTransform: 'uppercase',
                  }}
                >
                  Доступно
                </Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Box>
      </Box>

      {/* Правая панель - Список модификаций */}
      <Box style={panelStyles.list}>
        <Box
          style={{
            padding: '0.5rem 0.75rem',
            borderBottom: '1px solid rgba(255,42,109,0.2)',
            fontSize: '0.8rem',
            textTransform: 'uppercase',
            letterSpacing: '1px',
          }}
        >
          {activeCategory === '__installed__'
            ? 'УСТАНОВЛЕННЫЕ'
            : currentCategory?.toUpperCase() || 'МОДИФИКАЦИИ'}
        </Box>
        <Box style={{ flex: 1, overflowY: 'auto', padding: '0.5rem' }}>
          {activeCategory === '__installed__' ? (
            // Показываем установленные
            installedMods.length > 0 ? (
              installedMods.map((mod) => (
                <ModificationCard
                  key={mod.key}
                  modification={mod}
                  isInstalled
                  isIncompatible={false}
                  onAdd={() =>
                    act('apply_body_modification', {
                      body_modification_key: mod.key,
                    })
                  }
                  onRemove={() =>
                    act('remove_body_modification', {
                      body_modification_key: mod.key,
                    })
                  }
                />
              ))
            ) : (
              <Box color="label" textAlign="center" mt={2}>
                Нет установленных модификаций
              </Box>
            )
          ) : currentMods.length > 0 ? (
            // Показываем модификации категории
            currentMods.map((mod) => {
              const isInstalled = applied_body_modifications.includes(mod.key);
              const isIncompatible =
                !isInstalled &&
                incompatible_body_modifications.includes(mod.key);

              return (
                <ModificationCard
                  key={mod.key}
                  modification={mod}
                  isInstalled={isInstalled}
                  isIncompatible={isIncompatible}
                  onAdd={() =>
                    act('apply_body_modification', {
                      body_modification_key: mod.key,
                    })
                  }
                  onRemove={() =>
                    act('remove_body_modification', {
                      body_modification_key: mod.key,
                    })
                  }
                />
              );
            })
          ) : (
            <Box color="label" textAlign="center" mt={2}>
              Выберите категорию
            </Box>
          )}
        </Box>
      </Box>
    </Box>
  );
};

// Карточка модификации
type ModificationCardProps = {
  modification: BodyModification;
  isInstalled: boolean;
  isIncompatible: boolean;
  onAdd: () => void;
  onRemove: () => void;
};

const ModificationCard = (props: ModificationCardProps) => {
  const { modification, isInstalled, isIncompatible, onAdd, onRemove } = props;
  const { act, data } = useBackend<PreferencesMenuData>();
  const [expanded, setExpanded] = useState(false);

  const manufacturers = data.manufacturers?.[modification.key] || null;
  const selectedManufacturer =
    data.selected_manufacturer?.[modification.key] ||
    (manufacturers ? manufacturers[0] : null);

  const categoryConfig =
    CATEGORY_CONFIG[modification.category] || DEFAULT_CATEGORY_CONFIG;

  // Определяем цвет границы в зависимости от состояния
  let borderColor = 'rgba(0,240,255,0.2)';
  let bgGradient =
    'linear-gradient(135deg, rgba(26,26,36,0.8) 0%, rgba(10,10,18,0.9) 100%)';

  if (isInstalled) {
    borderColor = '#39ff14';
    bgGradient =
      'linear-gradient(135deg, rgba(57,255,20,0.1) 0%, rgba(10,10,18,0.9) 100%)';
  } else if (isIncompatible) {
    borderColor = 'rgba(255,51,51,0.3)';
  }

  return (
    <Box
      style={{
        background: bgGradient,
        border: `1px solid ${borderColor}`,
        borderRadius: '3px',
        marginBottom: '0.5rem',
        overflow: 'hidden',
        cursor: 'pointer',
        position: 'relative',
        opacity: isIncompatible ? 0.5 : 1,
      }}
      onClick={() => setExpanded(!expanded)}
    >
      {/* Индикатор установленной модификации */}
      {isInstalled && (
        <Box
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '3px',
            height: '100%',
            background: '#39ff14',
            boxShadow: '0 0 10px #39ff14',
          }}
        />
      )}

      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          padding: '0.5rem 0.6rem',
          gap: '0.5rem',
        }}
      >
        {/* Иконка */}
        <Box
          style={{
            width: '28px',
            height: '28px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: `rgba(${isInstalled ? '57,255,20' : '0,240,255'},0.1)`,
            border: `1px solid rgba(${isInstalled ? '57,255,20' : '0,240,255'},0.3)`,
            borderRadius: '2px',
            fontSize: '0.85rem',
            color: isInstalled ? '#39ff14' : categoryConfig.color,
          }}
        >
          <Icon name={categoryConfig.icon} />
        </Box>

        {/* Информация */}
        <Box style={{ flex: 1, minWidth: 0, overflow: 'hidden' }}>
          <Box
            style={{
              fontSize: '0.75rem',
              fontWeight: 600,
              color: '#e0e0e0',
              textTransform: 'uppercase',
              letterSpacing: '0.5px',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {modification.name}
          </Box>
          <Box
            style={{
              fontSize: '0.6rem',
              color: '#8a8a9a',
              textTransform: 'uppercase',
            }}
          >
            {modification.category}
          </Box>
        </Box>

        {/* Действия */}
        <Box
          style={{ display: 'flex', gap: '0.3rem' }}
          onClick={(e: React.MouseEvent) => e.stopPropagation()}
        >
          {/* Выбор производителя для протезов */}
          {Array.isArray(manufacturers) && isInstalled && (
            <Dropdown
              selected={selectedManufacturer ?? ''}
              options={manufacturers.map((brand: string) => ({
                value: brand,
                displayText: brand === 'None' ? 'Без протеза' : brand,
              }))}
              onSelected={(brand) =>
                act('set_body_modification_manufacturer', {
                  body_modification_key: modification.key,
                  manufacturer: brand,
                })
              }
            />
          )}

          {isInstalled ? (
            <Button compact icon="times" color="red" onClick={onRemove}>
              Удалить
            </Button>
          ) : (
            <Tooltip
              content={
                isIncompatible ? 'Несовместимо с текущими модификациями' : ''
              }
            >
              <Button
                compact
                icon="plus"
                color="green"
                disabled={isIncompatible}
                onClick={onAdd}
              >
                Установить
              </Button>
            </Tooltip>
          )}
        </Box>
      </Box>

      {/* Развернутое описание */}
      {expanded && modification.description && (
        <Box
          style={{
            padding: '0 0.6rem 0.5rem',
            borderTop: '1px solid rgba(0,240,255,0.1)',
            marginTop: '0.3rem',
            paddingTop: '0.3rem',
          }}
        >
          <Box style={{ fontSize: '0.7rem', color: '#8a8a9a', lineHeight: 1.4 }}>
            {modification.description}
          </Box>
          {modification.cost !== undefined && modification.cost > 0 && (
            <Box
              mt={0.3}
              style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}
            >
              <Box as="span" style={{ fontSize: '0.65rem', color: '#8a8a9a' }}>
                Стоимость:
              </Box>
              <Box
                as="span"
                style={{ fontSize: '0.7rem', color: '#ffc800', fontWeight: 600 }}
              >
                {modification.cost}
              </Box>
            </Box>
          )}
        </Box>
      )}
    </Box>
  );
};
