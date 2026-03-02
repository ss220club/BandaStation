import { Box, Button, Icon, Stack, Tooltip } from 'tgui-core/components';

export type ReactionEntry = {
  reagent: string;
  reaction: string;
  locked: boolean;
};

type Props = {
  slimeName: string;
  lore: string | null;
  poolReactions: string[];
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
    poolReactions,
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
        <Stack.Item shrink style={{ minHeight: 0, overflow: 'auto' }}>
          <Box
            className="XenobioRecipes__Wiki"
            style={{
              fontSize: '0.85rem',
              color: 'rgba(200,210,220,0.95)',
              padding: '0.5rem',
              marginBottom: '0.5rem',
              backgroundColor: 'rgba(15,20,28,0.7)',
              borderRadius: '8px',
              border: '1px solid rgba(80,100,130,0.35)',
            }}
          >
            {lore && (
              <Box style={{ marginBottom: '0.75rem' }}>
                <Box
                  style={{
                    fontSize: '0.75rem',
                    fontWeight: 'bold',
                    color: 'rgba(140,180,220,0.95)',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    marginBottom: '0.35rem',
                  }}
                >
                  Описание
                </Box>
                <Box style={{ whiteSpace: 'pre-line', lineHeight: 1.4 }}>
                  {lore}
                </Box>
              </Box>
            )}
            <Box>
              <Box
                style={{
                  fontSize: '0.75rem',
                  fontWeight: 'bold',
                  color: 'rgba(140,180,220,0.95)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  marginBottom: '0.35rem',
                }}
              >
                Потенциальные реакции
              </Box>
              <Box
                style={{
                  fontSize: '0.8rem',
                  color: 'rgba(180,195,210,0.9)',
                  marginBottom: '0.25rem',
                }}
              >
                Потенциальный список реакций, которые могут быть спровоцированы
                этим видом слайма. Вероятно, в текущей селекции слайма доступна
                лишь часть из них.
              </Box>
              {poolReactions.length > 0 ? (
                <Box
                  style={{
                    display: 'flex',
                    flexWrap: 'wrap',
                    gap: '0.35rem',
                    marginTop: '0.4rem',
                  }}
                >
                  {poolReactions.map((name, i) => (
                    <Box
                      key={i}
                      style={{
                        padding: '0.2rem 0.5rem',
                        backgroundColor: 'rgba(50,65,90,0.5)',
                        borderRadius: '4px',
                        border: '1px solid rgba(90,120,160,0.25)',
                        fontSize: '0.8rem',
                      }}
                    >
                      {name}
                    </Box>
                  ))}
                </Box>
              ) : (
                <Box
                  style={{
                    fontStyle: 'italic',
                    color: 'rgba(140,150,160,0.85)',
                    marginTop: '0.25rem',
                  }}
                >
                  Нет данных о реакциях.
                </Box>
              )}
            </Box>
          </Box>
        </Stack.Item>
        <Stack.Item shrink>
          <Button
            icon="flask"
            fluid
            disabled={!canStudy}
            onClick={onStudySlimeProperty}
            style={{ marginBottom: '0.5rem' }}
          >
            Изучить свойство слайма ({recipeCost} ксенобио)
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
            Открытые рецепты реакций
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
