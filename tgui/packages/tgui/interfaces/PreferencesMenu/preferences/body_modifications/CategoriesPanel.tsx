import { Box, Icon } from 'tgui-core/components';

import { CATEGORY_CONFIG, DEFAULT_CATEGORY_CONFIG } from './constants';
import { bodyModStyles } from './styles';

type CategoriesPanelProps = {
  categories: string[];
  installedCount: number;
  activeCategory: string | null;
  currentCategory: string | null;
  modificationsByCategory: Record<string, unknown[]>;
  onSelectCategory: (category: string) => void;
  onSelectInstalled: () => void;
};

export function CategoriesPanel(props: CategoriesPanelProps) {
  const {
    categories,
    installedCount,
    activeCategory,
    currentCategory,
    modificationsByCategory,
    onSelectCategory,
    onSelectInstalled,
  } = props;

  const getCategoryConfig = (category: string) =>
    CATEGORY_CONFIG[category] || DEFAULT_CATEGORY_CONFIG;

  return (
    <Box style={bodyModStyles.categoriesPanel}>
      <Box
        style={{
          padding: '0.62rem 0.75rem',
          fontSize: '0.75rem',
          textTransform: 'uppercase',
          letterSpacing: '1px',
          color: '#8a8a9a',
          borderBottom: '1px solid rgba(255,42,109,0.16)',
          fontWeight: 600,
          position: 'sticky',
          top: 0,
          zIndex: 2,
          background: 'rgba(15,12,20,0.92)',
          backdropFilter: 'blur(2px)',
        }}
      >
        Категории
      </Box>

      {installedCount > 0 && (
        <Box
          style={{
            padding: '0.6rem 0.75rem',
            cursor: 'pointer',
            borderLeft:
              activeCategory === '__installed__'
                ? '3px solid #39ff14'
                : '3px solid transparent',
            background:
              activeCategory === '__installed__'
                ? 'rgba(57,255,20,0.1)'
                : 'transparent',
            boxShadow:
              activeCategory === '__installed__'
                ? 'inset 0 0 18px rgba(57,255,20,0.15)'
                : 'none',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
            transition: 'background 0.18s ease, border-color 0.18s ease',
          }}
          onClick={onSelectInstalled}
        >
          <Icon name="check-circle" color="#39ff14" size={1.1} />
          <span style={{ fontSize: '0.85rem' }}>Установлено</span>
          <Box
            as="span"
            ml="auto"
            style={{
              fontSize: '0.75rem',
              padding: '0.15rem 0.4rem',
              background: 'rgba(57,255,20,0.2)',
              borderRadius: '2px',
              color: '#39ff14',
            }}
          >
            {installedCount}
          </Box>
        </Box>
      )}

      {categories.map((category) => {
        const config = getCategoryConfig(category);
        const count = modificationsByCategory[category]?.length || 0;
        const isActive = currentCategory === category;
        return (
          <Box
            key={category}
            style={{
              padding: '0.6rem 0.75rem',
              cursor: 'pointer',
              borderLeft: isActive
                ? `3px solid ${config.color}`
                : '3px solid transparent',
              background: isActive ? 'rgba(255,42,109,0.1)' : 'transparent',
              boxShadow: isActive ? `inset 0 0 18px ${config.color}22` : 'none',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              transition: 'background 0.18s ease, border-color 0.18s ease',
            }}
            onClick={() => onSelectCategory(category)}
          >
            <Icon name={config.icon} style={{ color: config.color, fontSize: '1rem' }} />
            <span style={{ fontSize: '0.85rem' }}>{category}</span>
            <Box
              as="span"
              ml="auto"
              style={{
                fontSize: '0.75rem',
                padding: '0.15rem 0.4rem',
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
    </Box>
  );
}
