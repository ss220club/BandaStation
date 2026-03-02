import { Box, DmIcon, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

const SLIMES_ICON = 'icons/mob/simple/slimes.dmi';

export type SlimeEntry = {
  path: string;
  name: string;
  /** Русское название для подписи под иконкой в меню */
  display_name?: string;
  icon_state: string;
  tier?: number;
  reaction_count?: number;
};

const NODE_WIDTH = 96;
const NODE_HEIGHT = 76;
const ICON_SIZE = 48;
const TIER_LABEL_WIDTH = 100;
const TIER_ROW_PADDING = '0.75rem 1rem';
const TIER_ROW_GAP = '1rem';
const TIER_ROW_MARGIN = '0.85rem';
const TIER_ROW_MIN_HEIGHT = 88;

const TIER_COLORS: Record<number, { bg: string; border: string }> = {
  0: { bg: 'rgba(90,95,100,0.28)', border: 'rgba(140,145,150,0.55)' },
  1: { bg: 'rgba(60,80,120,0.25)', border: 'rgba(80,110,160,0.5)' },
  2: { bg: 'rgba(70,65,120,0.25)', border: 'rgba(100,90,160,0.5)' },
  3: { bg: 'rgba(50,90,100,0.25)', border: 'rgba(70,130,150,0.5)' },
  4: { bg: 'rgba(100,60,70,0.25)', border: 'rgba(150,80,100,0.5)' },
  5: { bg: 'rgba(90,50,90,0.28)', border: 'rgba(140,70,140,0.55)' },

  6: { bg: 'rgba(50,52,58,0.22)', border: 'rgba(80,85,95,0.4)' },
  7: { bg: 'rgba(50,52,58,0.22)', border: 'rgba(80,85,95,0.4)' },
  8: { bg: 'rgba(50,52,58,0.22)', border: 'rgba(80,85,95,0.4)' },
};

const TIER_FLAVOR: Record<number, string> = {
  0: 'Базовый геном',
  1: 'Стабильные цепочки',
  2: 'Рекомбиннированные цепочки',
  3: 'Аномальные цепочки',
  4: 'Редуцированные цепочки',
  5: 'Нестабильный кластер',
  6: 'Класс не определён',
  7: 'Неизвестный ДНК маркер',
  8: 'Класс не определён',
};

function getTierFlavor(tier: number): string {
  return TIER_FLAVOR[tier] ?? 'Неизвестный ДНК маркер';
}

function getTierStyle(tier: number) {
  return TIER_COLORS[tier] ?? TIER_COLORS[0];
}

function slimeColorLabel(name: string): string {
  return name.replace(/ slime extract$/i, '');
}

type Props = {
  slimes: SlimeEntry[];
  selectedPath: string | null;
  onSelect: (path: string) => void;
};

export function XenobioMenu(props: Props) {
  const { slimes, selectedPath, onSelect } = props;

  const byTier = new Map<number, SlimeEntry[]>();
  for (const s of slimes) {
    const t = s.tier ?? 0;
    if (!byTier.has(t)) byTier.set(t, []);
    byTier.get(t)!.push(s);
  }
  const tiers = [0, 1, 2, 3, 4, 5, 6, 7, 8];

  return (
    <Box
      className="XenobioRecipes__NodeMap XenobioRecipes__NodeMap--byTier"
      style={{
        width: '100%',
        height: '100%',
        minHeight: '340px',
        padding: '0.75rem',
        overflow: 'auto',
      }}
    >
      {tiers.map((tierNum) => {
        const tierSlimes = byTier.get(tierNum) ?? [];
        const style = getTierStyle(tierNum);
        return (
          <Box
            key={tierNum}
            className="XenobioRecipes__TierRow"
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: TIER_ROW_GAP,
              marginBottom: TIER_ROW_MARGIN,
              padding: TIER_ROW_PADDING,
              minHeight: TIER_ROW_MIN_HEIGHT,
              borderRadius: '10px',
              backgroundColor: style.bg,
              border: `1px solid ${style.border}`,
            }}
          >
            <Box
              style={{
                flexShrink: 0,
                width: TIER_LABEL_WIDTH,
                textAlign: 'center',
              }}
            >
              <Box
                style={{
                  fontWeight: 'bold',
                  fontSize: '1rem',
                  color: 'rgba(200,210,230,0.98)',
                }}
              >
                Мутация: {tierNum}
              </Box>
              <Box
                style={{
                  fontSize: '0.7rem',
                  color: 'rgba(160,175,200,0.9)',
                  marginTop: '0.2rem',
                  lineHeight: 1.2,
                }}
              >
                {getTierFlavor(tierNum)}
              </Box>
            </Box>
            <Box
              style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: '0.5rem',
                alignItems: 'center',
              }}
            >
              {tierSlimes.map((slime) => {
                const isSelected = selectedPath === slime.path;
                return (
                  <Tooltip
                    key={slime.path}
                    content={slime.name}
                    position="bottom"
                  >
                    <Box
                      className={classes([
                        'XenobioRecipes__Node',
                        isSelected && 'XenobioRecipes__Node--selected',
                      ])}
                      style={{
                        width: NODE_WIDTH,
                        height: NODE_HEIGHT,
                        minWidth: NODE_WIDTH,
                        minHeight: NODE_HEIGHT,
                        borderRadius: '8px',
                        overflow: 'hidden',
                        flexShrink: 0,
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        justifyContent: 'flex-start',
                        cursor: 'pointer',
                        paddingBottom: '8px',
                        boxSizing: 'border-box',
                        backgroundColor: isSelected
                          ? 'rgba(100,180,255,0.5)'
                          : 'rgba(35,42,58,0.92)',
                        border: isSelected
                          ? '2px solid rgba(150,200,255,0.95)'
                          : '1px solid rgba(90,110,140,0.5)',
                        boxShadow: isSelected
                          ? '0 0 14px rgba(100,180,255,0.35)'
                          : '0 0 8px rgba(0,0,0,0.3)',
                      }}
                      onClick={() => onSelect(slime.path)}
                    >
                      <Box
                        style={{
                          width: ICON_SIZE,
                          height: ICON_SIZE,
                          flexShrink: 0,
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          padding: '2px 4px 0 4px',
                        }}
                      >
                        <DmIcon
                          icon={SLIMES_ICON}
                          icon_state={slime.icon_state}
                          style={{
                            width: '100%',
                            height: '100%',
                            objectFit: 'contain',
                          }}
                        />
                      </Box>
                      <Box
                        style={{
                          flexShrink: 0,
                          fontSize: '0.8rem',
                          lineHeight: 1.2,
                          textAlign: 'center',
                          padding: '2px 4px 0',
                        }}
                      >
                        {slime.display_name ?? slimeColorLabel(slime.name)}
                      </Box>
                    </Box>
                  </Tooltip>
                );
              })}
            </Box>
          </Box>
        );
      })}
    </Box>
  );
}
