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
  { icon: string; colorClass: string; order: number }
> = {
  Протезы: { icon: 'hand-paper', colorClass: 'prosthetics', order: 1 },
  Prosthetics: { icon: 'hand-paper', colorClass: 'prosthetics', order: 1 },
  Импланты: { icon: 'microchip', colorClass: 'implants', order: 2 },
  Implants: { icon: 'microchip', colorClass: 'implants', order: 2 },
  Органы: { icon: 'heart', colorClass: 'organs', order: 3 },
  Organs: { icon: 'heart', colorClass: 'organs', order: 3 },
  Ампутации: { icon: 'cut', colorClass: 'prosthetics', order: 4 },
  Amputations: { icon: 'cut', colorClass: 'prosthetics', order: 4 },
  Роботизация: { icon: 'robot', colorClass: 'chassis', order: 5 },
  Robotic: { icon: 'robot', colorClass: 'chassis', order: 5 },
};

const DEFAULT_CATEGORY_CONFIG = {
  icon: 'cog',
  colorClass: 'implants',
  order: 99,
};

export const BodyModificationsPage = (props: BodyModificationsProps) => {
  const serverData = useServerPrefs();
  const { data } = useBackend<PreferencesMenuData>();

  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <Modal className="CyberpunkMods CyberpunkMods--organic">
      {/* Scanline эффект */}
      <div className="CyberpunkMods__Scanline" />

      {/* Заголовок */}
      <div className="CyberpunkMods__Header">
        <div className="CyberpunkMods__HeaderTitle">
          <Icon name="user-astronaut" className="CyberpunkMods__HeaderTitleIcon" />
          <span>МОДИФИКАЦИИ ТЕЛА</span>
          <span className="CyberpunkMods__HeaderTitleSubtitle">
            RIPPERDOC INTERFACE v2.77
          </span>
        </div>
        <Button
          className="CyberpunkMods__HeaderClose"
          icon="times"
          onClick={props.handleClose}
        >
          ЗАКРЫТЬ
        </Button>
      </div>

      {/* Основной контент */}
      <BodyModificationsContent
        bodyModifications={serverData.body_modifications}
        characterPreviewId={data.character_preview_view}
      />
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

  return (
    <div className="CyberpunkMods__Content">
      {/* Левая панель - Категории */}
      <div className="CyberpunkMods__Categories">
        <div className="CyberpunkMods__CategoriesTitle">КАТЕГОРИИ</div>

        {/* Установленные */}
        {installedMods.length > 0 && (
          <div
            className={`CyberpunkMods__Category ${activeCategory === '__installed__' ? 'CyberpunkMods__Category--active' : ''}`}
            onClick={() => setActiveCategory('__installed__')}
          >
            <Icon name="check-circle" className="CyberpunkMods__CategoryIcon" />
            <span className="CyberpunkMods__CategoryName">Установлено</span>
            <span className="CyberpunkMods__CategoryCount">
              {installedMods.length}
            </span>
          </div>
        )}

        {/* Категории модификаций */}
        {categories.map((category) => {
          const config = getCategoryConfig(category);
          const count = modificationsByCategory[category]?.length || 0;

          return (
            <div
              key={category}
              className={`CyberpunkMods__Category CyberpunkMods__Category--${config.colorClass} ${currentCategory === category ? 'CyberpunkMods__Category--active' : ''}`}
              onClick={() => setActiveCategory(category)}
            >
              <Icon name={config.icon} className="CyberpunkMods__CategoryIcon" />
              <span className="CyberpunkMods__CategoryName">{category}</span>
              <span className="CyberpunkMods__CategoryCount">{count}</span>
            </div>
          );
        })}
      </div>

      {/* Центральная панель - Превью персонажа */}
      <div className="CyberpunkMods__Preview">
        <div className="CyberpunkMods__PreviewCharacter">
          <CharacterPreview height="280px" id={props.characterPreviewId} />
        </div>
        <div className="CyberpunkMods__PreviewInfo">
          <div className="CyberpunkMods__PreviewInfoName">ПАЦИЕНТ</div>
          <div className="CyberpunkMods__PreviewInfoStats">
            <div className="CyberpunkMods__PreviewInfoStat">
              <div className="CyberpunkMods__PreviewInfoStatValue">
                {installedMods.length}
              </div>
              <div className="CyberpunkMods__PreviewInfoStatLabel">
                Модификаций
              </div>
            </div>
            <div className="CyberpunkMods__PreviewInfoStat">
              <div className="CyberpunkMods__PreviewInfoStatValue">
                {props.bodyModifications.length}
              </div>
              <div className="CyberpunkMods__PreviewInfoStatLabel">Доступно</div>
            </div>
          </div>
        </div>
      </div>

      {/* Правая панель - Список модификаций */}
      <div className="CyberpunkMods__List">
        <div className="CyberpunkMods__ListHeader">
          <span className="CyberpunkMods__ListHeaderTitle">
            {activeCategory === '__installed__'
              ? 'УСТАНОВЛЕННЫЕ'
              : currentCategory?.toUpperCase() || 'МОДИФИКАЦИИ'}
          </span>
        </div>
        <div className="CyberpunkMods__ListContent">
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
          ) : (
            // Показываем модификации категории
            currentMods.map((mod) => {
              const isInstalled = applied_body_modifications.includes(mod.key);
              const isIncompatible =
                !isInstalled &&
                (applied_body_modifications.includes(mod.key) ||
                  incompatible_body_modifications.includes(mod.key));

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
          )}
        </div>
      </div>
    </div>
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

  let cardClass = 'CyberpunkMods__ModCard';
  if (isInstalled) cardClass += ' CyberpunkMods__ModCard--installed';
  if (isIncompatible) cardClass += ' CyberpunkMods__ModCard--incompatible';

  return (
    <div className={cardClass} onClick={() => setExpanded(!expanded)}>
      <div className="CyberpunkMods__ModCardHeader">
        <div className="CyberpunkMods__ModCardIcon">
          <Icon name={categoryConfig.icon} />
        </div>
        <div className="CyberpunkMods__ModCardInfo">
          <div className="CyberpunkMods__ModCardName">{modification.name}</div>
          <div className="CyberpunkMods__ModCardCategory">
            {modification.category}
          </div>
        </div>
        <div
          className="CyberpunkMods__ModCardActions"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Выбор производителя для протезов */}
          {Array.isArray(manufacturers) && isInstalled && (
            <Dropdown
              className="CyberpunkMods__ModCardBtn CyberpunkMods__ModCardBtn--manufacturer"
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
            <Button
              className="CyberpunkMods__ModCardBtn CyberpunkMods__ModCardBtn--remove"
              icon="times"
              onClick={onRemove}
            >
              УДАЛИТЬ
            </Button>
          ) : (
            <Tooltip
              content={
                isIncompatible ? 'Несовместимо с текущими модификациями' : ''
              }
            >
              <Button
                className="CyberpunkMods__ModCardBtn CyberpunkMods__ModCardBtn--add"
                icon="plus"
                disabled={isIncompatible}
                onClick={onAdd}
              >
                УСТАНОВИТЬ
              </Button>
            </Tooltip>
          )}
        </div>
      </div>

      {/* Развернутое описание */}
      {expanded && modification.description && (
        <div className="CyberpunkMods__ModCardDetails">
          <div className="CyberpunkMods__ModCardDetailsDesc">
            {modification.description}
          </div>
          {modification.cost !== undefined && modification.cost > 0 && (
            <div className="CyberpunkMods__ModCardDetailsCost">
              <span className="CyberpunkMods__ModCardDetailsCostLabel">
                Стоимость очков:
              </span>
              <span className="CyberpunkMods__ModCardDetailsCostValue">
                {modification.cost}
              </span>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
