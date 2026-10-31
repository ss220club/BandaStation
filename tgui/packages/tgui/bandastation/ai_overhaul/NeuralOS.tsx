import { storage } from 'common/storage';
import {
  createContext,
  type PropsWithChildren,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';
import { addScrollableNode, removeScrollableNode } from 'tgui-core/events';
import { useBackend } from '../../backend';
import {
  type DisplayTelemetry,
  displayFeedback,
  type FeedbackLevel,
} from './displayFeedback';
import { NeuralGlyph } from './NeuralGlyph';

export type NeuralSignal = 'nominal' | 'busy' | 'degraded' | 'alert';

export type Effects = 'full' | 'soft' | 'off';

export const EFFECTS: Effects[] = ['full', 'soft', 'off'];
const BOOT_STEPS = [
  'ПОДГОТОВКА БУФЕРА ЭКРАНА',
  'ПОДКЛЮЧЕНИЕ РАБОЧЕЙ СРЕДЫ',
  'ОТКРЫТИЕ ПРИЛОЖЕНИЯ',
];
const seenApplications = new Set<string>();

function rememberApplication(key: string) {
  seenApplications.add(key);
  try {
    sessionStorage.setItem(key, 'ready');
  } catch {}
}

function applicationSeen(key: string) {
  try {
    return seenApplications.has(key) || sessionStorage.getItem(key) === 'ready';
  } catch {
    return seenApplications.has(key);
  }
}

type DisplayContext = {
  effects: Effects;
  effectiveEffects: Effects;
  loaded: boolean;
  reduced: boolean;
  chooseEffects: (mode: Effects) => void;
  replayStartup: () => void;
  feedbackLevel: FeedbackLevel;
};

const NeuralOSContext = createContext<DisplayContext | null>(null);

export function useNeuralOS() {
  const context = useContext(NeuralOSContext);
  if (!context) {
    throw new Error('Neural header requires a NeuralShell');
  }
  return context;
}

export function NeuralShell({
  children,
  application,
  telemetry,
}: PropsWithChildren<{ application: string; telemetry?: DisplayTelemetry }>) {
  const { config } = useBackend();
  const feedback = displayFeedback(telemetry);
  const [heldLevel, setHeldLevel] = useState<FeedbackLevel>(feedback.level);
  useEffect(() => {
    if (feedback.level >= heldLevel) {
      setHeldLevel(feedback.level);
      return;
    }
    const timer = window.setTimeout(() => setHeldLevel(feedback.level), 2500);
    return () => window.clearTimeout(timer);
  }, [feedback.level, heldLevel]);
  const feedbackLevel = Math.max(heldLevel, feedback.level) as FeedbackLevel;
  const preferenceKey = `aiOS-effects-v1:${config.client.ckey}`;
  const bootKey = `aiOS-application-v3:${config.client.ckey}:${config.interface.name}:${config.window.key}`;
  const [effects, setEffects] = useState<Effects>('soft');
  const [loaded, setLoaded] = useState(false);
  const preferenceEdited = useRef(false);
  const [reduced, setReduced] = useState(false);
  const [phase, setPhase] = useState(() => (applicationSeen(bootKey) ? 3 : 0));
  const [replay, setReplay] = useState(0);
  const handledReplay = useRef(0);
  const bootTimers = useRef<number[]>([]);
  const workspace = useRef<HTMLDivElement>(null);
  const bootScreen = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement | null>(null);
  useEffect(() => {
    let alive = true;
    preferenceEdited.current = false;
    setLoaded(false);
    const apply = (mode: Effects) => {
      if (alive && !preferenceEdited.current) {
        setEffects(mode);
        setLoaded(true);
      }
    };
    const fallback = window.setTimeout(() => apply('soft'), 1500);
    storage
      .get(preferenceKey)
      .then((value) => {
        window.clearTimeout(fallback);
        apply(EFFECTS.includes(value) ? value : 'full');
      })
      .catch(() => {
        window.clearTimeout(fallback);
        apply('full');
      });
    return () => {
      alive = false;
      window.clearTimeout(fallback);
    };
  }, [preferenceKey]);
  useEffect(() => {
    const query = window.matchMedia('(prefers-reduced-motion: reduce)');
    const update = () => setReduced(query.matches);
    update();
    query.addEventListener('change', update);
    return () => query.removeEventListener('change', update);
  }, []);
  useEffect(() => {
    const node = workspace.current;
    if (node) {
      addScrollableNode(node);
    }
    return () => {
      if (node) {
        removeScrollableNode(node);
      }
    };
  }, []);
  useEffect(() => {
    if (!loaded) {
      return;
    }
    const requested = replay !== handledReplay.current;
    handledReplay.current = replay;
    if (
      reduced ||
      effects === 'off' ||
      (!requested && applicationSeen(bootKey))
    ) {
      setPhase(3);
      rememberApplication(bootKey);
      return;
    }
    rememberApplication(bootKey);
    setPhase(0);
    bootTimers.current = [1, 2, 3].map((step) =>
      window.setTimeout(() => setPhase(step), step * 700),
    );
    return () => bootTimers.current.forEach(window.clearTimeout);
  }, [bootKey, loaded, replay, reduced, effects]);
  const effectiveEffects = reduced || !loaded ? 'off' : effects;
  const booting = phase < 3 && !reduced && (!loaded || effects !== 'off');
  useEffect(() => {
    if (!booting) {
      return;
    }
    previousFocus.current =
      document.activeElement instanceof HTMLElement
        ? document.activeElement
        : null;
    const screen = bootScreen.current;
    screen?.focus();
    return () => {
      if (
        document.activeElement === screen ||
        document.activeElement === document.body
      ) {
        const prior = previousFocus.current;
        if (prior?.isConnected && !prior.closest('.Floating')) {
          prior.focus();
        } else {
          workspace.current?.focus();
        }
      }
    };
  }, [booting]);
  const skipStartup = () => {
    rememberApplication(bootKey);
    bootTimers.current.forEach(window.clearTimeout);
    setPhase(3);
  };
  const chooseEffects = (mode: Effects) => {
    preferenceEdited.current = true;
    setEffects(mode);
    setLoaded(true);
    storage.set(preferenceKey, mode).catch(() => {});
  };
  return (
    <NeuralOSContext.Provider
      value={{
        effects,
        effectiveEffects,
        loaded,
        reduced,
        feedbackLevel,
        chooseEffects,
        replayStartup: () => setReplay((count) => count + 1),
      }}
    >
      <div
        className={`AiOS__shell AiOS__shell--${effectiveEffects} AiOS__shell--load${feedbackLevel}${booting ? ' AiOS__shell--booting' : ' AiOS__shell--ready'}`}
      >
        <div
          className="AiOS__desktop"
          inert={booting}
          aria-hidden={booting || undefined}
        >
          <div className="AiOS__systemBar">
            <span className="AiOS__brandEmblem" aria-hidden="true">
              <NeuralGlyph compact />
            </span>
            <span className="AiOS__wordmark">
              NT<span>/</span>OS
            </span>
            <span className="AiOS__applicationName">{application}</span>
            <span className="AiOS__systemEdition">
              {' '}
              СИСТЕМНЫЙ НЕЙРОИНТЕРФЕЙС{' '}
            </span>
          </div>
          <div className="AiOS__workspace" ref={workspace} tabIndex={-1}>
            {children}
          </div>
          <div className="AiOS__systemFooter">
            <span>СИСТЕМЫ NT / ЛОКАЛЬНЫЙ СЕАНС</span>
            <span className="AiOS__displayFeedback" title={feedback.reason}>
              {heldLevel > feedback.level
                ? 'СТАБИЛИЗАЦИЯ ЭКРАНА'
                : feedback.level === 0
                  ? 'ЛОКАЛЬНЫЙ ЭКРАН'
                  : `${['', 'СЛАБЫЕ ПОМЕХИ', 'УМЕРЕННЫЕ ПОМЕХИ', 'СИЛЬНЫЕ ПОМЕХИ'][feedback.level]} · ${feedback.reason}`}
            </span>
          </div>
        </div>
        <div className="AiOS__interference" aria-hidden="true">
          <i className="AiOS__interferenceBand" />
          <i className="AiOS__interferenceNoise" />
        </div>
        {booting && (
          <div
            ref={bootScreen}
            className={`AiOS__bootScreen AiOS__bootScreen--phase${phase}`}
            role="button"
            tabIndex={0}
            aria-label="Запуск NT OS. Двойной клик или Enter — пропустить."
            onDoubleClick={skipStartup}
            onKeyDown={(event) => {
              if (['Enter', ' ', 'Escape'].includes(event.key)) {
                event.preventDefault();
                skipStartup();
              }
            }}
          >
            <div className="AiOS__bootTopline">
              <span>СИСТЕМЫ НАНОТРЕЙЗЕН</span>
              <span>НЕЙРОИНТЕРФЕЙС / ЛОКАЛЬНЫЙ СЕАНС</span>
            </div>
            <div className="AiOS__bootCenter">
              <div className="AiOS__bootEmblem" aria-hidden="true">
                <svg viewBox="0 0 160 160" fill="none">
                  <path
                    className="AiOS__bootOrbit"
                    d="M80 8a72 72 0 1 1-72 72"
                  />
                  <path
                    className="AiOS__bootOrbitInner"
                    d="M80 22a58 58 0 1 0 58 58"
                  />
                  <path d="M28 42V28h14M118 28h14v14M132 118v14h-14M42 132H28v-14" />
                  <path
                    className="AiOS__bootTrace"
                    d="M42 99V61l30 38V61M84 61h34M101 61v38"
                  />
                  <path d="M56 115h48M60 46h40" />
                </svg>
              </div>
              <div className="AiOS__bootWordmark">
                NT<span>/</span>OS
              </div>
              <div className="AiOS__bootEdition">СИСТЕМНЫЙ НЕЙРОИНТЕРФЕЙС</div>
              <div className="AiOS__bootApplication">{application}</div>
              <div className="AiOS__bootConsole" aria-hidden="true">
                {['БУФЕР ЭКРАНА', 'РАБОЧАЯ СРЕДА', 'ПРИЛОЖЕНИЕ'].map(
                  (label, step) => (
                    <div
                      key={label}
                      className={phase === step ? 'AiOS__bootRow--active' : ''}
                    >
                      <span>
                        {String(step + 1).padStart(2, '0')} / {label}
                      </span>
                      <span>
                        {phase > step
                          ? 'ДОСТУПНО'
                          : phase === step
                            ? 'ЗАГРУЗКА'
                            : 'ОЖИДАНИЕ'}
                      </span>
                    </div>
                  ),
                )}
              </div>
              <div className="AiOS__bootProgress" aria-hidden="true">
                {[0, 1, 2].map((step) => (
                  <i
                    key={step}
                    className={phase >= step ? 'AiOS__bootSegment--ready' : ''}
                  />
                ))}
              </div>
              <div className="AiOS__bootPhase" aria-live="polite">
                {loaded ? BOOT_STEPS[phase] : 'ПОДГОТОВКА ЛОКАЛЬНОГО ЭКРАНА'}
              </div>
            </div>
            <div className="AiOS__bootBottomline">
              <span>ЗАПУСК ЛОКАЛЬНОГО ЭКРАНА</span>
              <span>ПРОПУСТИТЬ: ДВОЙНОЙ КЛИК · ENTER / ESC</span>
            </div>
          </div>
        )}
      </div>
    </NeuralOSContext.Provider>
  );
}
