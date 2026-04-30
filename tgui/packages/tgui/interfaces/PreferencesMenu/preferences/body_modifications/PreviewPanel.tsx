import { Box, Icon } from 'tgui-core/components';

import { CharacterPreview } from '../../../common/CharacterPreview';
import type { BodyModification } from '../../types';
import { CATEGORY_CONFIG, DEFAULT_CATEGORY_CONFIG } from './constants';
import { bodyModStyles } from './styles';

type PreviewPanelProps = {
  selectedMod: BodyModification | null;
  installedCount: number;
  filteredModsCount: number;
  characterPreviewView: string;
  isAugmentedLimbCategory: (category: string) => boolean;
};

export function PreviewPanel(props: PreviewPanelProps) {
  const {
    selectedMod,
    installedCount,
    filteredModsCount,
    characterPreviewView,
    isAugmentedLimbCategory,
  } = props;

  const getCategoryConfig = (category: string) =>
    CATEGORY_CONFIG[category] || DEFAULT_CATEGORY_CONFIG;

  return (
    <Box style={bodyModStyles.previewPanel}>
      <Box
        style={{
          fontSize: '0.65rem',
          textTransform: 'uppercase',
          letterSpacing: '1px',
          color: '#8a8a9a',
          textAlign: 'center',
          marginBottom: '0.5rem',
          fontWeight: 600,
          paddingBottom: '0.35rem',
          borderBottom: '1px solid rgba(255,42,109,0.16)',
        }}
      >
        Превью
      </Box>

      <Box style={bodyModStyles.previewViewport}>
        <Box style={bodyModStyles.previewInner}>
          <CharacterPreview height="270px" id={characterPreviewView} />
        </Box>
      </Box>

      {selectedMod && !isAugmentedLimbCategory(selectedMod.category) ? (
        <Box
          style={{
            flex: 1,
            padding: '0.6rem',
            background:
              'linear-gradient(180deg, rgba(255,42,109,0.08) 0%, rgba(0,0,0,0.3) 100%)',
            border: '1px solid rgba(255,42,109,0.3)',
            borderRadius: '4px',
            overflow: 'hidden',
          }}
        >
          <Box style={{ textAlign: 'center', marginBottom: '0.4rem' }}>
            <Icon
              name={getCategoryConfig(selectedMod.category).icon}
              style={{
                fontSize: '1.6rem',
                color: getCategoryConfig(selectedMod.category).color,
                filter: `drop-shadow(0 0 8px ${getCategoryConfig(selectedMod.category).color})`,
              }}
            />
          </Box>
          <Box
            bold
            style={{
              fontSize: '0.85rem',
              color: '#e0e0e0',
              textAlign: 'center',
              marginBottom: '0.35rem',
              lineHeight: 1.3,
            }}
          >
            {selectedMod.name}
          </Box>
          <Box
            style={{
              fontSize: '0.65rem',
              color: getCategoryConfig(selectedMod.category).color,
              textTransform: 'uppercase',
              textAlign: 'center',
              letterSpacing: '0.5px',
              marginBottom: '0.4rem',
            }}
          >
            {selectedMod.category}
          </Box>
          {selectedMod.description && (
            <Box
              style={{
                fontSize: '0.75rem',
                color: '#8a8a9a',
                lineHeight: 1.4,
                marginBottom: '0.4rem',
                borderTop: '1px solid rgba(255,42,109,0.15)',
                paddingTop: '0.4rem',
              }}
            >
              {selectedMod.description}
            </Box>
          )}
        </Box>
      ) : (
        <Box style={{ display: 'flex', flexDirection: 'column', gap: '0.3rem' }}>
          <Box
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              padding: '0.35rem 0.6rem',
              background: 'rgba(57,255,20,0.1)',
              border: '1px solid rgba(57,255,20,0.25)',
              borderRadius: '3px',
            }}
          >
            <Box style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.75rem', color: '#b0b0b0' }}>
              <Icon name="check-circle" style={{ color: '#39ff14' }} />
              Установлено
            </Box>
            <Box bold style={{ fontSize: '1rem', color: '#39ff14' }}>
              {installedCount}
            </Box>
          </Box>
          <Box
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              padding: '0.35rem 0.6rem',
              background: 'rgba(0,240,255,0.1)',
              border: '1px solid rgba(0,240,255,0.25)',
              borderRadius: '3px',
            }}
          >
            <Box style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.75rem', color: '#b0b0b0' }}>
              <Icon name="list" style={{ color: '#00f0ff' }} />
              Доступно
            </Box>
            <Box bold style={{ fontSize: '1rem', color: '#00f0ff' }}>
              {filteredModsCount}
            </Box>
          </Box>
        </Box>
      )}
    </Box>
  );
}
