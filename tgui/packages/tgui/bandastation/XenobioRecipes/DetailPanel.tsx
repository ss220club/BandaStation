import { Box, Button, Icon, Stack, Tooltip } from 'tgui-core/components';

export type ReactionEntry = {
  reagent: string;
  reaction: string;
  locked: boolean;
};

type Props = {
  slimeName: string;
  lore: string | null;
  reactions: ReactionEntry[];
  reactionCount: number;
  selectedSlimePath: string;
  loadedSlimePath: string | null;
  recipeCost: number;
  researchPoints: number;
  studyAvailable: boolean;
  onClose: () => void;
  onStudySlimeProperty: () => void;
};

export function DetailPanel(props: Props) {
  const {
    slimeName,
    lore,
    reactions,
    reactionCount,
    selectedSlimePath,
    loadedSlimePath,
    recipeCost,
    researchPoints,
    studyAvailable,
    onClose,
    onStudySlimeProperty,
  } = props;

  const canStudy =
    loadedSlimePath === selectedSlimePath &&
    researchPoints >= recipeCost &&
    studyAvailable;

  return (
    <Box
      className="XenobioRecipes__DetailPanel"
      style={{
        width: '340px',
        minWidth: '300px',
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: 'rgba(20,25,35,0.95)',
        borderLeft: '1px solid rgba(100,120,160,0.4)',
        padding: '0.6rem',
      }}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Stack align="center" justify="space-between">
            <span style={{ fontWeight: 'bold', fontSize: '1.05rem' }}>
              {slimeName}
            </span>
            <Button icon="times" onClick={onClose} compact />
          </Stack>
        </Stack.Item>
        {lore && (
          <Stack.Item shrink>
            <Box
              style={{
                fontSize: '0.85rem',
                color: 'rgba(200,210,220,0.95)',
                marginBottom: '0.5rem',
                padding: '0.4rem',
                borderBottom: '1px solid rgba(100,120,160,0.3)',
              }}
            >
              {lore}
            </Box>
          </Stack.Item>
        )}
        <Stack.Item shrink>
          <Button
            icon="flask"
            fluid
            disabled={!canStudy}
            onClick={onStudySlimeProperty}
            style={{ marginBottom: '0.5rem' }}
          >
            Изучить свойство слайма ({recipeCost})
          </Button>
        </Stack.Item>
        <Stack.Item grow style={{ overflow: 'auto', minHeight: 0 }}>
          <Box
            style={{
              marginBottom: '0.4rem',
              fontWeight: 'bold',
              fontSize: '0.9rem',
              color: 'rgba(200,210,230,0.98)',
            }}
          >
            Открытые рецепты
          </Box>
          {reactions.length === 0 && (
            <Box
              style={{
                color: 'rgba(140,150,160,0.9)',
                fontSize: '0.85rem',
                fontStyle: 'italic',
                padding: '0.5rem',
              }}
            >
              Список пуст. Откройте случайный рецепт при помощи реконструтора
              или изучите свойство слайма. Для этого - просканируйте ручным
              сканером слайма, и перенесите данные в консоль, нажав на неё
              сканнером.
            </Box>
          )}
          {reactions.map((entry, i) => (
            <Box
              key={i}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                marginBottom: '0.35rem',
                padding: '0.4rem 0.5rem',
                backgroundColor: 'rgba(30,38,52,0.6)',
                borderRadius: '6px',
                borderLeft: `3px solid ${entry.locked ? 'rgba(100,180,255,0.6)' : 'rgba(120,130,150,0.4)'}`,
              }}
            >
              <Box
                style={{
                  flex: 1,
                  minWidth: 0,
                  fontSize: '0.9rem',
                  fontWeight: 500,
                  color: 'rgba(220,228,240,0.98)',
                }}
              >
                {entry.reaction}
              </Box>
              <Box
                style={{
                  flexShrink: 0,
                  fontSize: '0.8rem',
                  color: 'rgba(160,180,200,0.9)',
                  padding: '0.15rem 0.4rem',
                  backgroundColor: 'rgba(50,60,80,0.5)',
                  borderRadius: '4px',
                }}
              >
                {entry.reagent}
              </Box>
              {entry.locked && (
                <Tooltip content="Открыт за очки" position="left">
                  <Box as="span" style={{ opacity: 0.75, flexShrink: 0 }}>
                    <Icon name="lock" />
                  </Box>
                </Tooltip>
              )}
            </Box>
          ))}
        </Stack.Item>
      </Stack>
    </Box>
  );
}
