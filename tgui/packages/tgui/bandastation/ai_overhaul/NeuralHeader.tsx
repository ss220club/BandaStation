import { Box, Button, Floating, Section } from 'tgui-core/components';
import { NeuralGlyph } from './NeuralGlyph';
import { EFFECTS, type NeuralSignal, useNeuralOS } from './NeuralOS';

export function NetworkHeader(props: {
  title: string;
  subtitle: string;
  signal?: NeuralSignal;
  status?: string;
  compact?: boolean;
}) {
  const {
    title,
    subtitle,
    signal = 'nominal',
    status = 'ЛОКАЛЬНЫЙ ТЕРМИНАЛ',
    compact,
  } = props;
  const {
    effects,
    loaded,
    reduced,
    effectiveEffects,
    feedbackLevel,
    chooseEffects,
    replayStartup,
  } = useNeuralOS();

  return (
    <Section
      className={`AiOS__header AiOS__header--${signal} AiOS__header--${effectiveEffects} AiOS__header--load${feedbackLevel}${compact ? ' AiOS__header--compact' : ''}`}
    >
      <div className="AiOS__masthead">
        <div
          className="AiOS__monitor"
          role="img"
          aria-label={`Экран состояния ИИ: ${status}`}
        >
          <div className="AiOS__monitorLabel">КОРТЕКС</div>
          <div className="AiOS__glass">
            <div className="AiOS__glyph">
              <NeuralGlyph />
            </div>
            <div className="AiOS__ghost AiOS__ghost--upper">
              <NeuralGlyph />
            </div>
            <div className="AiOS__ghost AiOS__ghost--lower">
              <NeuralGlyph />
            </div>
            <div className="AiOS__scan" />
          </div>
          <div className="AiOS__monitorLights">
            <i />
            <i />
            <i />
            <span>ЛОКАЛЬНО</span>
          </div>
        </div>
        <div className="AiOS__identity">
          <Box className="AiOS__eyebrow">НАНОТРЕЙЗЕН / НЕЙРОИНТЕРФЕЙС</Box>
          <div className="AiOS__identityTitle">{title}</div>
          <div className="AiOS__subtitle">{subtitle}</div>
        </div>
        <div className="AiOS__headerTools">
          <div className="AiOS__eyebrow">СОСТОЯНИЕ УЗЛА</div>
          <div className="AiOS__linkStatus">
            <span className="AiOS__statusDot" />
            {status}
          </div>
          <Floating
            placement="bottom-end"
            closeAfterInteract
            contentClasses="AiOS AiOS__settings"
            contentStyles={{ width: '310px', maxWidth: 'calc(100vw - 32px)' }}
            content={
              <Section title="Настройки интерфейса">
                <Box color="label" mb={1}>
                  {' '}
                  Эффекты интерфейса{' '}
                </Box>
                <div className="AiOS__effectChoices">
                  {EFFECTS.map((mode) => (
                    <Button
                      key={mode}
                      selected={effects === mode}
                      disabled={!loaded || reduced}
                      onClick={() => chooseEffects(mode)}
                    >
                      {mode === 'full'
                        ? 'Полные'
                        : mode === 'soft'
                          ? 'Мягкие'
                          : 'Отключены'}
                    </Button>
                  ))}
                </div>
                <Box color="label" mt={1} mb={1}>
                  {reduced
                    ? 'В системе включено уменьшение движения. Анимации запуска и интерфейса отключены.'
                    : !loaded
                      ? 'Загрузка настроек экрана…'
                      : 'Полные: анимированный экран и помехи от нагрузки. Мягкие: плавная анимация без помех. Отключены: неподвижный интерфейс. Выбор сохраняется для вашего клиента.'}
                </Box>
                <Button
                  fluid
                  icon="power-off"
                  disabled={effectiveEffects === 'off'}
                  onClick={replayStartup}
                >
                  {' '}
                  Повторить запуск{' '}
                </Button>
              </Section>
            }
          >
            <div>
              <Button
                color="transparent"
                icon="cog"
                tooltip="Настройки интерфейса"
                aria-label="Настройки интерфейса"
              >
                {' '}
                Настройки экрана{' '}
              </Button>
            </div>
          </Floating>
        </div>
      </div>
    </Section>
  );
}
