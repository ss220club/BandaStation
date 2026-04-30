import { useMemo, useState } from 'react';
import { Box, Button, Icon, Modal } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { LoadingScreen } from '../../common/LoadingScreen';
import type { BodyModification, PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { CategoriesPanel } from './body_modifications/CategoriesPanel';
import {
  CATEGORY_CONFIG,
  DEFAULT_CATEGORY_CONFIG,
} from './body_modifications/constants';
import { IPCAccessDeniedScreen } from './body_modifications/IPCAccessDeniedScreen';
import { ModificationsListPanel } from './body_modifications/ModificationsListPanel';
import { PreviewPanel } from './body_modifications/PreviewPanel';
import { RipperDocBootScreen } from './body_modifications/RipperDocBootScreen';
import { bodyModStyles } from './body_modifications/styles';

type BodyModificationsProps = {
  handleClose: () => void;
};

let ripperDocBootPlayed = false;

export function BodyModificationsPage(props: BodyModificationsProps) {
  const serverData = useServerPrefs();
  const [bootComplete, setBootComplete] = useState(ripperDocBootPlayed);

  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <Modal width="880px" height="630px">
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
          position: 'relative',
        }}
      >
        <style>{`
          @keyframes rd-ambient-pulse {
            0%, 100% { opacity: 0.35; transform: scale(1); }
            50% { opacity: 0.65; transform: scale(1.06); }
          }
          @keyframes rd-scan-sweep {
            0% { transform: translateX(-120%); opacity: 0; }
            20% { opacity: 0.18; }
            65% { opacity: 0.12; }
            100% { transform: translateX(120%); opacity: 0; }
          }
          @keyframes rd-frame-pulse {
            0%, 100% { box-shadow: inset 0 0 0 1px rgba(255,42,109,0.16), 0 0 0 rgba(255,42,109,0); }
            50% { box-shadow: inset 0 0 0 1px rgba(255,42,109,0.35), 0 0 18px rgba(255,42,109,0.18); }
          }
        `}</style>
        <Box
          style={{
            position: 'absolute',
            inset: '-25%',
            background:
              'radial-gradient(circle at 10% 15%, rgba(255,42,109,0.2), transparent 40%), radial-gradient(circle at 90% 85%, rgba(0,240,255,0.13), transparent 44%)',
            pointerEvents: 'none',
            animation: 'rd-ambient-pulse 8s ease-in-out infinite',
            zIndex: 0,
          }}
        />
        <Box
          style={{
            position: 'absolute',
            top: 0,
            bottom: 0,
            width: '42%',
            background:
              'linear-gradient(90deg, transparent 0%, rgba(0,240,255,0.08) 48%, transparent 100%)',
            pointerEvents: 'none',
            animation: 'rd-scan-sweep 9s linear infinite',
            zIndex: 0,
          }}
        />
        <Box
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '0.75rem 1rem',
            background:
              'linear-gradient(90deg, rgba(255,42,109,0.2), transparent)',
            borderBottom: '1px solid rgba(255,42,109,0.3)',
            position: 'relative',
            zIndex: 1,
          }}
        >
          <Box
            bold
            style={{
              fontSize: '1.1rem',
              color: '#dff8ff',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              textShadow: '0 0 10px rgba(0,240,255,0.45)',
            }}
          >
            <Icon name="user-astronaut" /> МОДИФИКАЦИИ ТЕЛА
            <Box
              as="span"
              ml={1}
              style={{
                fontSize: '0.65rem',
                color: '#9fd9e4',
                letterSpacing: '1px',
                textShadow: 'none',
              }}
            >
              {'RIPPERDOC // SURGICAL SUITE v2.77'}
            </Box>
          </Box>
          <Button icon="times" color="red" onClick={props.handleClose}>
            Закрыть
          </Button>
        </Box>

        <Box style={{ position: 'relative', zIndex: 1, display: 'flex', flex: 1 }}>
          {!bootComplete ? (
            <RipperDocBootScreen
              onComplete={() => {
                ripperDocBootPlayed = true;
                setBootComplete(true);
              }}
            />
          ) : (
            <BodyModificationsContent
              bodyModifications={serverData.body_modifications || []}
              handleClose={props.handleClose}
            />
          )}
        </Box>
      </Box>
    </Modal>
  );
}

type BodyModificationsContentProps = {
  bodyModifications: BodyModification[];
  handleClose: () => void;
};

function BodyModificationsContent(props: BodyModificationsContentProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    applied_body_modifications = [],
    incompatible_body_modifications = [],
  } = data;

  const isIPC = data.character_preferences?.misc?.species === 'ipc';

  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const [selectedMod, setSelectedMod] = useState<BodyModification | null>(null);

  const AUGMENTED_LIMB_CATEGORIES = [
    'Роботизация',
    'Robotic',
    'Импланты',
    'Amputations',
  ];
  const isAugmentedLimbCategory = (cat: string) =>
    AUGMENTED_LIMB_CATEGORIES.includes(cat);

  const IPC_ONLY_CATEGORIES = ['IPC Chassis', 'IPC Chassis (HEF)'];
  const IPC_ONLY_MODIFICATIONS = [
    'positronic',
    'mmi',
    'borg',
    'ipc',
    'позитрон',
  ];
  const isIPCOnlyModification = (mod: BodyModification): boolean => {
    const lowerName = mod.name.toLowerCase();
    const lowerKey = mod.key.toLowerCase();
    return IPC_ONLY_MODIFICATIONS.some(
      (term) => lowerName.includes(term) || lowerKey.includes(term),
    );
  };

  const { categories, modificationsByCategory } = useMemo(() => {
    if (isIPC)
      return {
        categories: [] as string[],
        modificationsByCategory: {} as Record<string, BodyModification[]>,
      };

    const byCategory: Record<string, BodyModification[]> = {};
    props.bodyModifications.forEach((mod) => {
      const category = mod.category || 'Прочее';
      if (IPC_ONLY_CATEGORIES.includes(category)) return;
      if (isIPCOnlyModification(mod)) return;
      if (!byCategory[category]) byCategory[category] = [];
      byCategory[category].push(mod);
    });

    const sortedCategories = Object.keys(byCategory).sort((a, b) => {
      const orderA = CATEGORY_CONFIG[a]?.order ?? DEFAULT_CATEGORY_CONFIG.order;
      const orderB = CATEGORY_CONFIG[b]?.order ?? DEFAULT_CATEGORY_CONFIG.order;
      return orderA - orderB;
    });

    return {
      categories: sortedCategories,
      modificationsByCategory: byCategory,
    };
  }, [props.bodyModifications, isIPC]);

  const installedMods = useMemo(() => {
    if (isIPC) return [] as BodyModification[];
    return props.bodyModifications.filter((mod) =>
      applied_body_modifications.includes(mod.key),
    );
  }, [props.bodyModifications, applied_body_modifications, isIPC]);

  if (isIPC) {
    return <IPCAccessDeniedScreen onClose={props.handleClose} />;
  }

  const filteredModsCount = useMemo(() => {
    return Object.values(modificationsByCategory).reduce(
      (sum, mods) => sum + mods.length,
      0,
    );
  }, [modificationsByCategory]);

  const currentCategory = activeCategory || categories[0] || null;
  const currentMods =
    currentCategory && currentCategory !== '__installed__'
      ? modificationsByCategory[currentCategory] || []
      : [];

  return (
    <Box style={bodyModStyles.contentRoot}>
      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.45rem',
          padding: '0.45rem 0.6rem',
          background:
            'linear-gradient(90deg, rgba(255,42,109,0.14) 0%, rgba(0,240,255,0.08) 100%)',
          border: '1px solid rgba(255,42,109,0.2)',
          borderRadius: '6px',
        }}
      >
        <Box
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.35rem',
            padding: '0.22rem 0.45rem',
            borderRadius: '4px',
            background: 'rgba(57,255,20,0.12)',
            border: '1px solid rgba(57,255,20,0.3)',
            color: '#39ff14',
            fontSize: '0.75rem',
          }}
        >
          <Icon name="check-circle" />
          <Box as="span">{installedMods.length}</Box>
        </Box>
        <Box
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.35rem',
            padding: '0.22rem 0.45rem',
            borderRadius: '4px',
            background: 'rgba(0,240,255,0.12)',
            border: '1px solid rgba(0,240,255,0.3)',
            color: '#00f0ff',
            fontSize: '0.75rem',
          }}
        >
          <Icon name="list" />
          <Box as="span">{filteredModsCount}</Box>
        </Box>
        <Box
          style={{
            marginLeft: 'auto',
            fontSize: '0.7rem',
            color: '#9ea3b0',
            letterSpacing: '0.5px',
            textTransform: 'uppercase',
          }}
        >
          {currentCategory || ''}
        </Box>
      </Box>

      <Box style={bodyModStyles.row}>
        <CategoriesPanel
          categories={categories}
          installedCount={installedMods.length}
          activeCategory={activeCategory}
          currentCategory={currentCategory}
          modificationsByCategory={modificationsByCategory}
          onSelectCategory={(category) => {
            act('play_click_sound');
            setActiveCategory(category);
          }}
          onSelectInstalled={() => {
            act('play_click_sound');
            setActiveCategory('__installed__');
          }}
        />

        <PreviewPanel
          selectedMod={selectedMod}
          installedCount={installedMods.length}
          filteredModsCount={filteredModsCount}
          characterPreviewView={data.character_preview_view}
          isAugmentedLimbCategory={isAugmentedLimbCategory}
        />

        <ModificationsListPanel
          activeCategory={activeCategory}
          currentCategory={currentCategory}
          currentMods={currentMods}
          installedMods={installedMods}
          incompatibleKeys={incompatible_body_modifications}
          selectedMod={selectedMod}
          appliedKeys={applied_body_modifications}
          onAdd={(mod) =>
            act('apply_body_modification', {
              body_modification_key: mod.key,
            })
          }
          onRemove={(mod) =>
            act('remove_body_modification', {
              body_modification_key: mod.key,
            })
          }
          onSelect={(mod) => setSelectedMod(mod)}
        />
      </Box>
    </Box>
  );
}
