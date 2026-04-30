import { useState } from 'react';
import { Box } from 'tgui-core/components';

import type { BodyModification } from '../../types';
import { ModificationCard } from './ModificationCard';
import { bodyModStyles } from './styles';

type ModificationsListPanelProps = {
  activeCategory: string | null;
  currentCategory: string | null;
  currentMods: BodyModification[];
  installedMods: BodyModification[];
  incompatibleKeys: string[];
  selectedMod: BodyModification | null;
  appliedKeys: string[];
  onAdd: (mod: BodyModification) => void;
  onRemove: (mod: BodyModification) => void;
  onSelect: (mod: BodyModification) => void;
};

export function ModificationsListPanel(props: ModificationsListPanelProps) {
  const [openDropdownKey, setOpenDropdownKey] = useState<string | null>(null);
  const {
    activeCategory,
    currentCategory,
    currentMods,
    installedMods,
    incompatibleKeys,
    selectedMod,
    appliedKeys,
    onAdd,
    onRemove,
    onSelect,
  } = props;

  return (
    <Box style={bodyModStyles.listPanel}>
      <style>{`
        @keyframes bodymod-card-in {
          from { opacity: 0; transform: translateY(6px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
      <Box
        style={{
          padding: '0.65rem 0.75rem',
          borderBottom: '2px solid rgba(255,42,109,0.3)',
          fontSize: '0.95rem',
          textTransform: 'uppercase',
          letterSpacing: '1px',
          fontWeight: 600,
          color: '#ff2a6d',
          position: 'sticky',
          top: 0,
          zIndex: 2,
          background: 'rgba(14,11,20,0.94)',
          backdropFilter: 'blur(2px)',
        }}
      >
        {activeCategory === '__installed__'
          ? 'Установленные'
          : currentCategory?.toUpperCase() || 'Модификации'}
      </Box>
      <Box
        style={{
          flex: 1,
          overflowY: 'auto',
          overflowX: 'visible',
          padding: '0.55rem',
          position: 'relative',
        }}
      >
        {activeCategory === '__installed__' ? (
          installedMods.length > 0 ? (
            installedMods.map((mod, index) => (
              <Box
                key={mod.key}
                style={{
                  position: 'relative',
                  zIndex: openDropdownKey === mod.key ? 2000 : 1,
                  animation: 'bodymod-card-in 180ms ease-out both',
                  animationDelay: `${Math.min(index * 20, 180)}ms`,
                }}
              >
                <ModificationCard
                  modification={mod}
                  isInstalled
                  isIncompatible={false}
                  isSelected={selectedMod?.key === mod.key}
                  isDropdownOpen={openDropdownKey === mod.key}
                  onSetDropdownOpen={(open) =>
                    setOpenDropdownKey(open ? mod.key : null)
                  }
                  onAdd={() => onAdd(mod)}
                  onRemove={() => onRemove(mod)}
                  onSelect={() => onSelect(mod)}
                />
              </Box>
            ))
          ) : (
            <Box color="label" textAlign="center" mt={2}>
              Нет установленных модификаций
            </Box>
          )
        ) : currentMods.length > 0 ? (
          currentMods.map((mod, index) => {
            const isInstalled = appliedKeys.includes(mod.key);
            const isIncompatible =
              !isInstalled && incompatibleKeys.includes(mod.key);

            return (
              <Box
                key={mod.key}
                style={{
                  position: 'relative',
                  zIndex: openDropdownKey === mod.key ? 2000 : 1,
                  animation: 'bodymod-card-in 180ms ease-out both',
                  animationDelay: `${Math.min(index * 20, 180)}ms`,
                }}
              >
                <ModificationCard
                  modification={mod}
                  isInstalled={isInstalled}
                  isIncompatible={isIncompatible}
                  isSelected={selectedMod?.key === mod.key}
                  isDropdownOpen={openDropdownKey === mod.key}
                  onSetDropdownOpen={(open) =>
                    setOpenDropdownKey(open ? mod.key : null)
                  }
                  onAdd={() => onAdd(mod)}
                  onRemove={() => onRemove(mod)}
                  onSelect={() => onSelect(mod)}
                />
              </Box>
            );
          })
        ) : (
          <Box color="label" textAlign="center" mt={2}>
            Выберите категорию
          </Box>
        )}
      </Box>
    </Box>
  );
}
