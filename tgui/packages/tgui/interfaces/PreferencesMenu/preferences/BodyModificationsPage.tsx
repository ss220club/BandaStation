import { useEffect, useMemo, useRef, useState } from 'react';
import { Box, Button, Icon, Modal, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { CharacterPreview } from '../../common/CharacterPreview';
import { LoadingScreen } from '../../common/LoadingScreen';
import type { BodyModification, PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

type BodyModificationsProps = {
  handleClose: () => void;
};

// Цвета производителей протезов для визуальной идентификации
const MANUFACTURER_COLORS: Record<string, string> = {
  none: '#666666',
  general: '#888888',
  bishop: '#5b9bd5',
  'bishop mk2': '#4a87c5',
  'bishop nano': '#7ab5e5',
  'etamin industry': '#c8a100',
  'etamin industry lumineux': '#f0c060',
  gromtech: '#6899c4',
  hephaestus: '#3a6e3a',
  'hephaestus titan': '#2d5a2d',
  interdyne: '#00acc1',
  morpheus: '#424242',
  shellguard: '#c62828',
  wardtakahashi: '#9e9e9e',
  'wardtakahashi pro': '#757575',
  xion: '#e65c00',
  'xion light': '#ff9433',
  'zeng-hu': '#ff9800',
};

// Краткие описания производителей (показываются при наведении на выбор)
const MANUFACTURER_DESCRIPTIONS: Record<string, string> = {
  none: 'Протез не установлен. Стандартная анатомия.',
  general: 'Стандартный протез без фирменной маркировки.',
  bishop:
    'Биоинженерные протезы премиум-класса. Золотой стандарт медицинской хирургии. Непревзойдённая биосовместимость.',
  'bishop mk2':
    'Второе поколение линейки Bishop. Расширенный сенсорный диапазон, улучшенный отклик на нейросигналы.',
  'bishop nano':
    'Нанотехнологичная серия Bishop. Идеальна для высокоточных тонких работ.',
  'etamin industry':
    'Промышленные протезы Etamin. Высокая точность для технического и инженерного персонала.',
  'etamin industry lumineux':
    'Серия Lumineux от Etamin. Встроенная биолюминесцентная подсветка.',
  gromtech:
    'Надёжные протезы GromTech. Минимум электроники — максимум надёжности.',
  hephaestus:
    'Промышленные протезы Hephaestus Industries класса тяжёлых работ.',
  'hephaestus titan':
    'Серия Titan от Hephaestus. Боевой класс — максимальная прочность и давление.',
  interdyne:
    'Биосинтетические протезы Interdyne. Практически неотличимы от органики по ощущениям.',
  morpheus: 'Экспериментальные футуристичные протезы Morpheus Cyberkinetics.',
  shellguard: 'Тактические протезы военного класса Shellguard Munitions.',
  wardtakahashi:
    'Элегантный японский дизайн WardTakahashi. Стиль и функциональность.',
  'wardtakahashi pro':
    'Pro-серия WardTakahashi. Максимальные характеристики для профессионалов.',
  xion: 'Компактные многоцелевые протезы Xion. Универсальное решение.',
  'xion light': 'Облегчённая серия Xion. Быстро, дёшево, надёжно.',
  'zeng-hu': 'Протезы Zeng-Hu Pharmaceuticals. Биосовместимость в приоритете.',
};

// Получить цвет производителя
const getManufacturerColor = (name: string): string => {
  const lowerName = name.toLowerCase();
  return MANUFACTURER_COLORS[lowerName] || '#888888';
};

// Маппинг категорий на иконки и цвета
const CATEGORY_CONFIG: Record<
  string,
  { icon: string; colorClass: string; order: number; color: string }
> = {
  Протезы: {
    icon: 'hand-paper',
    colorClass: 'prosthetics',
    order: 1,
    color: '#ffc800',
  },
  Prosthetics: {
    icon: 'hand-paper',
    colorClass: 'prosthetics',
    order: 1,
    color: '#ffc800',
  },
  Импланты: {
    icon: 'microchip',
    colorClass: 'implants',
    order: 2,
    color: '#ff2a6d',
  },
  Implants: {
    icon: 'microchip',
    colorClass: 'implants',
    order: 2,
    color: '#ff2a6d',
  },
  Органы: { icon: 'heart', colorClass: 'organs', order: 3, color: '#ff3333' },
  Organs: { icon: 'heart', colorClass: 'organs', order: 3, color: '#ff3333' },
  Ампутации: {
    icon: 'cut',
    colorClass: 'prosthetics',
    order: 4,
    color: '#ffc800',
  },
  Amputations: {
    icon: 'cut',
    colorClass: 'prosthetics',
    order: 4,
    color: '#ffc800',
  },
  Роботизация: {
    icon: 'robot',
    colorClass: 'chassis',
    order: 5,
    color: '#0080ff',
  },
  Robotic: {
    icon: 'robot',
    colorClass: 'chassis',
    order: 5,
    color: '#0080ff',
  },
};

const DEFAULT_CATEGORY_CONFIG = {
  icon: 'cog',
  colorClass: 'implants',
  order: 99,
  color: '#00f0ff',
};

// Экран ограничения доступа для КПБ (корпоративный стиль)
const IPCAccessDeniedScreen = (props: { onClose: () => void }) => {
  const { act } = useBackend<PreferencesMenuData>();
  const [reportHovered, setReportHovered] = useState(false);
  const [glitchLabel, setGlitchLabel] = useState('Сообщить об ошибке');

  const GLITCH_STRINGS = [
    'Сообщить об ошибке',
    'CONN_REFUSED',
    '████████████',
    'ERR_404',
    '?#@!%&*░▒▓',
    'SERVER_UNREACHABLE',
    'Сообщить об ошибке',
    'TIMEOUT::3000ms',
    '01001110 01001111',
    'NULL_PTR_EXCEPTION',
    'Сообщить об ошибке',
    '▓▒░ FATAL ░▒▓',
    'SOCKET_CLOSED',
    'Сообщить об ошибке',
  ];

  useEffect(() => {
    if (!reportHovered) {
      setGlitchLabel('Сообщить об ошибке');
      return;
    }
    let i = 0;
    const interval = setInterval(() => {
      i = (i + 1) % GLITCH_STRINGS.length;
      setGlitchLabel(GLITCH_STRINGS[i]);
    }, 200);
    return () => clearInterval(interval);
  }, [reportHovered]);

  return (
    <Box
      style={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '2rem',
        background:
          'linear-gradient(160deg, rgba(8,8,16,0.9) 0%, rgba(16,8,8,0.9) 100%)',
      }}
    >
      {/* CSS-анимации для глитч-эффектов (безопасные: < 1 вспышки/с, без steps) */}
      <style>{`
        @keyframes ipc-glitch-shake {
          0%, 75%, 100% { transform: translate(0,0) skewX(0deg); }
          77%  { transform: translate(-3px, 1px) skewX(-1.5deg); }
          79%  { transform: translate(3px, -1px) skewX(1deg); }
          81%  { transform: translate(-1px, 1px) skewX(1deg); }
          83%  { transform: translate(0, 0) skewX(0deg); }
        }
        @keyframes ipc-glitch-colors {
          0%, 100% { color: #555; text-shadow: none; }
          45%, 55% { color: #cc2255; text-shadow: 1px 0 rgba(200,40,80,0.5); }
        }
        @keyframes ipc-glitch-border {
          0%, 100% { border-color: rgba(85,85,85,0.4); box-shadow: none; }
          50%      { border-color: rgba(255,42,109,0.7); box-shadow: 0 0 8px rgba(255,42,109,0.3); }
        }
        @keyframes ipc-glitch-bg {
          0%, 100% { background: rgba(0,0,0,0.3); }
          50%      { background: rgba(255,42,109,0.07); }
        }
        @keyframes ipc-glitch-icon {
          0%, 73%, 100% { transform: translate(0,0); filter: none; }
          75%  { transform: translate(-2px, 0); filter: hue-rotate(25deg); }
          78%  { transform: translate(2px, 0);  filter: hue-rotate(-25deg); }
          81%  { transform: translate(0, 0);    filter: none; }
        }
      `}</style>

      {/* Фирменная шапка */}
      <Box
        style={{
          fontFamily: 'monospace',
          fontSize: '0.6rem',
          color: '#ff2a6d',
          marginBottom: '1.25rem',
          textAlign: 'center',
          letterSpacing: '3px',
          borderBottom: '1px solid rgba(255,42,109,0.25)',
          paddingBottom: '0.5rem',
          textTransform: 'uppercase',
        }}
      >
        Dark Industries™ — RipperDoc® Modification Suite v2.77
      </Box>

      {/* Иконка */}
      <Icon
        name="triangle-exclamation"
        style={{
          fontSize: '3rem',
          color: '#ff2a6d',
          marginBottom: '0.6rem',
          filter: 'drop-shadow(0 0 16px rgba(255,42,109,0.6))',
          animation: reportHovered
            ? 'ipc-glitch-icon 3s ease infinite'
            : 'none',
        }}
      />

      {/* Заголовок ошибки */}
      <Box
        bold
        style={{
          fontSize: '0.85rem',
          color: '#ff2a6d',
          letterSpacing: '2px',
          textTransform: 'uppercase',
          marginBottom: '1.25rem',
          textShadow: '0 0 10px rgba(255,42,109,0.5)',
        }}
      >
        Неустановленная форма жизни обнаружена
      </Box>

      {/* Корпоративное письмо */}
      <Box
        style={{
          maxWidth: '420px',
          padding: '1rem 1.25rem',
          background: 'rgba(0,0,0,0.45)',
          border: '1px solid rgba(255,42,109,0.2)',
          borderLeft: '3px solid rgba(255,42,109,0.5)',
          borderRadius: '2px',
          marginBottom: '1rem',
          fontFamily: 'monospace',
          fontSize: '0.78rem',
          color: '#aaaaaa',
          lineHeight: 1.7,
        }}
      >
        <Box style={{ marginBottom: '0.6rem' }}>Уважаемый клиент,</Box>
        <Box style={{ marginBottom: '0.6rem' }}>
          Наша система не смогла верифицировать ваш биологический субстрат.
          Идентификатор органики:{' '}
          <Box as="span" style={{ color: '#ff2a6d' }}>
            НЕ НАЙДЕН
          </Box>
          .
        </Box>
        <Box style={{ marginBottom: '0.6rem' }}>
          Предоставление услуг модификации тела лицам с неподтверждённым
          биологическим статусом невозможно согласно{' '}
          <Box as="span" style={{ color: '#00f0ff' }}>
            п. 7.3 Пользовательского соглашения Dark Industries
          </Box>
          .
        </Box>
        <Box>
          Если вы считаете, что данное сообщение является ошибкой — просим
          обратиться в нашу службу поддержки по внутренней форме обратной связи.
          Мы ценим каждого клиента.{' '}
          <Box as="span" style={{ color: '#555' }}>
            Даже того, чьё существование ставит под сомнение наши базы данных.
          </Box>
        </Box>
      </Box>

      {/* Код ошибки */}
      <Box
        style={{
          fontFamily: 'monospace',
          fontSize: '0.65rem',
          color: '#555',
          marginBottom: '1.25rem',
          letterSpacing: '1px',
        }}
      >
        ERR-0x4950430A · SESSION ID:{' '}
        {Math.floor(Math.random() * 0xffff)
          .toString(16)
          .toUpperCase()
          .padStart(4, '0')}{' '}
        · REF: DARKINDUSTRIES-RIPPERDOC
      </Box>
      {/* Кнопки */}
      <Box style={{ display: 'flex', gap: '0.75rem' }}>
        <Box
          style={{
            padding: '0.45rem 1.2rem',
            background: 'rgba(255,42,109,0.12)',
            border: '1px solid rgba(255,42,109,0.4)',
            borderRadius: '2px',
            cursor: 'pointer',
            color: '#ff2a6d',
            fontWeight: 600,
            letterSpacing: '1px',
            textTransform: 'uppercase',
            fontSize: '0.78rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.4rem',
            fontFamily: 'monospace',
          }}
          onClick={props.onClose}
        >
          <Icon name="times" /> Закрыть
        </Box>

        {/* Кнопка "Сообщить об ошибке" с глитч-эффектом при наведении */}
        <div
          onMouseEnter={() => {
            setReportHovered(true);
            act('start_hover_loop');
          }}
          onMouseLeave={() => {
            setReportHovered(false);
            act('stop_hover_loop');
          }}
        >
          <Box
            style={{
              padding: '0.45rem 1.2rem',
              background: reportHovered ? undefined : 'rgba(0,0,0,0.3)',
              border: '1px solid rgba(85,85,85,0.4)',
              borderRadius: '2px',
              cursor: 'not-allowed',
              color: '#555',
              fontWeight: 600,
              letterSpacing: '1px',
              textTransform: 'uppercase',
              fontSize: '0.78rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.4rem',
              fontFamily: 'monospace',
              minWidth: '10rem',
              justifyContent: 'center',
              userSelect: 'none',
              animation: reportHovered
                ? 'ipc-glitch-shake 2.4s ease infinite, ipc-glitch-border 2s ease-in-out infinite, ipc-glitch-bg 2s ease-in-out infinite'
                : 'none',
            }}
          >
            <Icon
              name="paper-plane"
              style={{
                animation: reportHovered
                  ? 'ipc-glitch-icon 3s ease infinite'
                  : 'none',
              }}
            />
            <Box
              as="span"
              style={{
                animation: reportHovered
                  ? 'ipc-glitch-colors 2s ease-in-out infinite'
                  : 'none',
                display: 'inline-block',
                minWidth: '7rem',
                textAlign: 'center',
              }}
            >
              {glitchLabel}
            </Box>
          </Box>
        </div>
      </Box>
    </Box>
  );
};

// ─── Загрузочный экран RipperDoc ─────────────────────────────────────────────

const BOOT_SEQUENCE = [
  'Загрузка нейроинтерфейса',
  'Калибровка хирургического ядра',
  'Загрузка базы имплантатов',
  'Верификация лицензии Dark Industries',
  'Инициализация аугментационного модуля',
  'Синхронизация хирургического протокола',
];

const BOOT_TS = [
  '[ 00:00.312 ]',
  '[ 00:00.498 ]',
  '[ 00:00.671 ]',
  '[ 00:00.843 ]',
  '[ 00:01.015 ]',
  '[ 00:01.247 ]',
];

// Задержки появления каждой фазы (мс)
const BOOT_DELAYS = [350, 620, 890, 1140, 1390, 1640, 2050, 2500];

const RipperDocBootScreen = (props: { onComplete: () => void }) => {
  const { act } = useBackend<PreferencesMenuData>();
  // 0 = только шапка, 1-6 = строки boot-лога, 7 = "ГОТОВО", 8 = завершено
  const [phase, setPhase] = useState(0);
  const timersRef = useRef<ReturnType<typeof setTimeout>[]>([]);

  useEffect(() => {
    act('play_boot_sound');
    timersRef.current = BOOT_DELAYS.map((delay, i) =>
      setTimeout(() => {
        setPhase(i + 1);
        if (i === BOOT_DELAYS.length - 1) {
          act('play_boot_complete_sound');
          props.onComplete();
        }
      }, delay),
    );
    return () => timersRef.current.forEach(clearTimeout);
  }, []);

  const handleSkip = () => {
    timersRef.current.forEach(clearTimeout);
    props.onComplete();
  };

  const progress = Math.min(
    100,
    Math.round((Math.max(0, phase - 1) / BOOT_SEQUENCE.length) * 100),
  );

  return (
    <Box
      onClick={handleSkip}
      style={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '2rem',
        fontFamily: 'monospace',
        position: 'relative',
        overflow: 'hidden',
        cursor: 'pointer',
      }}
    >
      <style>{`
        @keyframes rd-blink {
          0%,49% { opacity: 1; }
          50%,100% { opacity: 0; }
        }
        @keyframes rd-flicker {
          0%,19%,21%,23%,25%,100% { opacity: 1; }
          20%,22%,24% { opacity: 0.4; }
        }
      `}</style>

      {/* Строки развёртки (CRT-эффект) */}
      <Box
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,0,0,0.07) 2px, rgba(0,0,0,0.07) 4px)',
          pointerEvents: 'none',
          zIndex: 1,
        }}
      />

      {/* Контент */}
      <Box
        style={{
          position: 'relative',
          zIndex: 2,
          width: '100%',
          maxWidth: '560px',
        }}
      >
        {/* Логотип */}
        <Box
          style={{
            textAlign: 'center',
            marginBottom: '1.75rem',
            borderBottom: '1px solid rgba(255,42,109,0.3)',
            paddingBottom: '1rem',
            animation: 'rd-flicker 4s linear infinite',
          }}
        >
          <Box
            style={{
              fontSize: '0.55rem',
              color: '#ff2a6d',
              letterSpacing: '5px',
              textTransform: 'uppercase',
              marginBottom: '0.4rem',
              opacity: 0.8,
            }}
          >
            ◈ &nbsp; DARK INDUSTRIES™ &nbsp; ◈
          </Box>
          <Box
            bold
            style={{
              fontSize: '1.6rem',
              color: '#ffffff',
              letterSpacing: '4px',
              textTransform: 'uppercase',
              textShadow:
                '0 0 20px rgba(255,42,109,0.9), 0 0 50px rgba(255,42,109,0.4)',
            }}
          >
            RipperDoc®
          </Box>
          <Box
            style={{
              fontSize: '0.6rem',
              color: '#8a8a9a',
              letterSpacing: '2px',
              marginTop: '0.3rem',
            }}
          >
            Surgical Modification Suite v2.77
          </Box>
        </Box>

        {/* Заголовок лога */}
        <Box
          style={{
            fontSize: '0.65rem',
            color: '#00f0ff',
            letterSpacing: '3px',
            textAlign: 'center',
            marginBottom: '1rem',
            textTransform: 'uppercase',
            textShadow: '0 0 8px rgba(0,240,255,0.5)',
          }}
        >
          ─── Инициализация системы ───
        </Box>

        {/* Boot-лог */}
        <Box style={{ marginBottom: '1.5rem', minHeight: '9rem' }}>
          {BOOT_SEQUENCE.map((line, i) => {
            if (phase < i + 1) return null;
            const isCurrent = phase === i + 1;
            return (
              <Box
                key={i}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  fontSize: '0.72rem',
                  marginBottom: '0.3rem',
                  color: '#aaaaaa',
                }}
              >
                <Box as="span" style={{ color: '#444', flexShrink: 0 }}>
                  {BOOT_TS[i]}
                </Box>
                <Box as="span" style={{ color: '#ff2a6d', flexShrink: 0 }}>
                  ›
                </Box>
                <Box as="span" style={{ flex: 1 }}>
                  {line}
                </Box>
                <Box
                  as="span"
                  style={{
                    flexShrink: 0,
                    fontWeight: 700,
                    color: isCurrent ? '#ff2a6d' : '#39ff14',
                    textShadow: isCurrent
                      ? 'none'
                      : '0 0 6px rgba(57,255,20,0.7)',
                  }}
                >
                  {isCurrent ? (
                    <span
                      style={{
                        animation: 'rd-blink 0.7s step-start infinite',
                      }}
                    >
                      ▌
                    </span>
                  ) : (
                    '[ OK ]'
                  )}
                </Box>
              </Box>
            );
          })}
        </Box>

        {/* Прогресс-бар */}
        <Box
          style={{
            background: 'rgba(0,0,0,0.5)',
            border: '1px solid rgba(255,42,109,0.3)',
            borderRadius: '2px',
            height: '6px',
            overflow: 'hidden',
            marginBottom: '0.4rem',
          }}
        >
          <Box
            style={{
              height: '100%',
              width: `${progress}%`,
              background: 'linear-gradient(90deg, #ff2a6d 0%, #ff6b9d 100%)',
              boxShadow: '0 0 10px rgba(255,42,109,0.7)',
              transition: 'width 0.22s ease',
            }}
          />
        </Box>
        <Box
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            fontSize: '0.55rem',
            color: '#555',
            letterSpacing: '1px',
            marginBottom: '1.25rem',
          }}
        >
          <span>BOOT PROGRESS</span>
          <span style={{ color: progress === 100 ? '#39ff14' : '#ff2a6d' }}>
            {progress}%
          </span>
        </Box>

        {/* Финальное сообщение */}
        {phase >= 7 && (
          <Box
            style={{
              textAlign: 'center',
              fontSize: '0.75rem',
              color: '#39ff14',
              letterSpacing: '2px',
              textTransform: 'uppercase',
              textShadow: '0 0 12px rgba(57,255,20,0.7)',
              fontWeight: 700,
            }}
          >
            ◈ &nbsp; Система готова. Добро пожаловать, клиент. &nbsp; ◈
          </Box>
        )}
      </Box>

      {/* Подсказка «кликни для пропуска» */}
      <Box
        style={{
          position: 'absolute',
          bottom: '0.6rem',
          right: '0.9rem',
          fontSize: '0.55rem',
          color: '#333',
          letterSpacing: '1px',
          userSelect: 'none',
          zIndex: 3,
        }}
      >
        [ НАЖМИТЕ ДЛЯ ПРОПУСКА ]
      </Box>
    </Box>
  );
};

// ─── Основная страница ────────────────────────────────────────────────────────

// Флаг вне компонента — переживает закрытие/открытие модала.
// Загрузочная анимация показывается только при первом открытии за сессию.
let ripperDocBootPlayed = false;

export const BodyModificationsPage = (props: BodyModificationsProps) => {
  const serverData = useServerPrefs();
  const { data } = useBackend<PreferencesMenuData>();
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
        }}
      >
        {/* Заголовок */}
        <Box
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '0.75rem 1rem',
            background:
              'linear-gradient(90deg, rgba(255,42,109,0.2), transparent)',
            borderBottom: '1px solid rgba(255,42,109,0.3)',
          }}
        >
          <Box
            bold
            style={{
              fontSize: '1.1rem',
              color: '#ff2a6d',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              textShadow: '0 0 10px rgba(255,42,109,0.5)',
            }}
          >
            <Icon name="user-astronaut" /> МОДИФИКАЦИИ ТЕЛА
            <Box
              as="span"
              ml={1}
              style={{
                fontSize: '0.65rem',
                color: '#8a8a9a',
                letterSpacing: '1px',
                textShadow: 'none',
              }}
            >
              RIPPERDOC v2.77
            </Box>
          </Box>
          <Button icon="times" color="red" onClick={props.handleClose}>
            Закрыть
          </Button>
        </Box>

        {/* Основной контент: сначала загрузка, затем меню */}
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
    </Modal>
  );
};

type BodyModificationsContentProps = {
  bodyModifications: BodyModification[];
  handleClose: () => void;
};

const BodyModificationsContent = (props: BodyModificationsContentProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    applied_body_modifications = [],
    incompatible_body_modifications = [],
  } = data;

  // Вычисляем до хуков — нужно для useMemo ниже
  const isIPC = data.character_preferences?.misc?.species === 'ipc';

  // Все хуки вызываются безусловно (правила React)
  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const [selectedMod, setSelectedMod] = useState<BodyModification | null>(null);

  // Категории с аугментированными конечностями — для них не показываем детальный превью предмета
  const AUGMENTED_LIMB_CATEGORIES = [
    'Роботизация',
    'Robotic',
    'Ампутации',
    'Amputations',
  ];
  const isAugmentedLimbCategory = (cat: string) =>
    AUGMENTED_LIMB_CATEGORIES.includes(cat);

  // Категории и модификации, скрытые от не-IPC рас
  const IPC_ONLY_CATEGORIES = ['IPC Chassis', 'IPC Chassis (HEF)'];
  const IPC_ONLY_MODIFICATIONS = [
    'positronic',
    'mmi',
    'borg',
    'ipc',
    'позитронн',
  ];
  const isIPCOnlyModification = (mod: BodyModification): boolean => {
    const lowerName = mod.name.toLowerCase();
    const lowerKey = mod.key.toLowerCase();
    return IPC_ONLY_MODIFICATIONS.some(
      (term) => lowerName.includes(term) || lowerKey.includes(term),
    );
  };

  // Группируем модификации по категориям (для IPC — пустой результат, они увидят экран ограничения)
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

  // Установленные модификации
  const installedMods = useMemo(() => {
    if (isIPC) return [] as BodyModification[];
    return props.bodyModifications.filter((mod) =>
      applied_body_modifications.includes(mod.key),
    );
  }, [props.bodyModifications, applied_body_modifications, isIPC]);

  // Ранний выход для КПБ — после всех хуков
  if (isIPC) {
    return <IPCAccessDeniedScreen onClose={props.handleClose} />;
  }

  // Общее количество отфильтрованных модификаций
  const filteredModsCount = useMemo(() => {
    return Object.values(modificationsByCategory).reduce(
      (sum, mods) => sum + mods.length,
      0,
    );
  }, [modificationsByCategory]);

  // Текущая выбранная категория или первая
  const currentCategory = activeCategory || categories[0] || null;
  const currentMods = currentCategory
    ? modificationsByCategory[currentCategory] || []
    : [];

  const getCategoryConfig = (category: string) =>
    CATEGORY_CONFIG[category] || DEFAULT_CATEGORY_CONFIG;

  // Стили для панелей
  const panelStyles = {
    categories: {
      width: '170px',
      minWidth: '170px',
      background: 'rgba(0, 0, 0, 0.3)',
      borderRight: '1px solid rgba(255, 42, 109, 0.2)',
      display: 'flex',
      flexDirection: 'column' as const,
      overflowY: 'auto' as const,
    },
    preview: {
      width: '240px',
      minWidth: '240px',
      display: 'flex',
      flexDirection: 'column' as const,
      alignItems: 'stretch',
      padding: '0.5rem',
      background: 'transparent',
    },
    list: {
      flex: 1,
      minWidth: '300px',
      background: 'rgba(0, 0, 0, 0.2)',
      borderLeft: '1px solid rgba(255, 42, 109, 0.2)',
      display: 'flex',
      flexDirection: 'column' as const,
      overflow: 'hidden',
    },
  };

  return (
    <Box style={{ display: 'flex', flex: 1, overflow: 'hidden' }}>
      {/* Левая панель - Категории */}
      <Box style={panelStyles.categories}>
        <Box
          style={{
            padding: '0.6rem 0.75rem',
            fontSize: '0.75rem',
            textTransform: 'uppercase',
            letterSpacing: '1px',
            color: '#8a8a9a',
            borderBottom: '1px solid rgba(255,42,109,0.1)',
            fontWeight: 600,
          }}
        >
          КАТЕГОРИИ
        </Box>

        {/* Установленные */}
        {installedMods.length > 0 && (
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
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
            }}
            onClick={() => {
              act('play_click_sound');
              setActiveCategory('__installed__');
            }}
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
              {installedMods.length}
            </Box>
          </Box>
        )}

        {/* Категории модификаций */}
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
                background: isActive ? `rgba(255,42,109,0.1)` : 'transparent',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
              onClick={() => {
                act('play_click_sound');
                setActiveCategory(category);
              }}
            >
              <Icon
                name={config.icon}
                style={{ color: config.color, fontSize: '1rem' }}
              />
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

        {categories.length === 0 && (
          <Box
            style={{ padding: '1rem', color: '#8a8a9a', textAlign: 'center' }}
          >
            Нет доступных категорий
          </Box>
        )}
      </Box>

      {/* Центральная панель — кукла персонажа + предпросмотр модификации */}
      <Box style={panelStyles.preview}>
        {/* Заголовок панели */}
        <Box
          style={{
            fontSize: '0.65rem',
            textTransform: 'uppercase',
            letterSpacing: '1px',
            color: '#8a8a9a',
            textAlign: 'center',
            marginBottom: '0.4rem',
            fontWeight: 600,
          }}
        >
          ПРЕДПРОСМОТР
        </Box>

        {/* Кукла персонажа */}
        <Box
          style={{
            border: '1px solid rgba(255,42,109,0.35)',
            borderRadius: '4px',
            overflow: 'hidden',
            background: 'rgba(0,0,0,0.4)',
            marginBottom: '0.5rem',
            display: 'flex',
            justifyContent: 'center',
          }}
        >
          <CharacterPreview height="270px" id={data.character_preview_view} />
        </Box>

        {/* Детали выбранной модификации (кроме аугментированных конечностей) */}
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
            {/* Иконка категории */}
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
            {/* Название */}
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
            {/* Категория */}
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
            {/* Описание */}
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
            {/* Стоимость */}
            {selectedMod.cost !== undefined && selectedMod.cost > 0 && (
              <Box
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                  fontSize: '0.75rem',
                }}
              >
                <Icon name="tag" style={{ color: '#ffc800' }} />
                <Box as="span" style={{ color: '#8a8a9a' }}>
                  Стоимость:
                </Box>
                <Box as="span" bold style={{ color: '#ffc800' }}>
                  {selectedMod.cost}
                </Box>
              </Box>
            )}
          </Box>
        ) : (
          /* Компактная статистика когда нет выбранной модификации */
          <Box
            style={{ display: 'flex', flexDirection: 'column', gap: '0.3rem' }}
          >
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
              <Box
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                  fontSize: '0.75rem',
                  color: '#b0b0b0',
                }}
              >
                <Icon name="check-circle" style={{ color: '#39ff14' }} />
                Активно
              </Box>
              <Box bold style={{ fontSize: '1rem', color: '#39ff14' }}>
                {installedMods.length}
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
              <Box
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                  fontSize: '0.75rem',
                  color: '#b0b0b0',
                }}
              >
                <Icon name="list" style={{ color: '#00f0ff' }} />
                Доступно
              </Box>
              <Box bold style={{ fontSize: '1rem', color: '#00f0ff' }}>
                {filteredModsCount}
              </Box>
            </Box>
            <Box
              style={{
                fontSize: '0.65rem',
                color: '#666',
                textAlign: 'center',
                marginTop: '0.3rem',
              }}
            >
              Выберите модификацию для просмотра
            </Box>
          </Box>
        )}
      </Box>

      {/* Правая панель - Список модификаций */}
      <Box style={panelStyles.list}>
        <Box
          style={{
            padding: '0.65rem 0.75rem',
            borderBottom: '2px solid rgba(255,42,109,0.3)',
            fontSize: '0.95rem',
            textTransform: 'uppercase',
            letterSpacing: '1px',
            fontWeight: 600,
            color: '#ff2a6d',
          }}
        >
          {activeCategory === '__installed__'
            ? 'УСТАНОВЛЕННЫЕ'
            : currentCategory?.toUpperCase() || 'МОДИФИКАЦИИ'}
        </Box>
        <Box style={{ flex: 1, overflowY: 'auto', padding: '0.5rem' }}>
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
                  onSelect={() => setSelectedMod(mod)}
                />
              ))
            ) : (
              <Box color="label" textAlign="center" mt={2}>
                Нет установленных модификаций
              </Box>
            )
          ) : currentMods.length > 0 ? (
            // Показываем модификации категории
            currentMods.map((mod) => {
              const isInstalled = applied_body_modifications.includes(mod.key);
              const isIncompatible =
                !isInstalled &&
                incompatible_body_modifications.includes(mod.key);

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
                  onSelect={() => setSelectedMod(mod)}
                />
              );
            })
          ) : (
            <Box color="label" textAlign="center" mt={2}>
              Выберите категорию
            </Box>
          )}
        </Box>
      </Box>
    </Box>
  );
};

// Карточка модификации
type ModificationCardProps = {
  modification: BodyModification;
  isInstalled: boolean;
  isIncompatible: boolean;
  onAdd: () => void;
  onRemove: () => void;
  onSelect: () => void;
};

const ModificationCard = (props: ModificationCardProps) => {
  const {
    modification,
    isInstalled,
    isIncompatible,
    onAdd,
    onRemove,
    onSelect,
  } = props;
  const { act, data } = useBackend<PreferencesMenuData>();
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const manufacturers = data.manufacturers?.[modification.key] || null;
  const selectedManufacturer =
    data.selected_manufacturer?.[modification.key] ||
    (manufacturers ? manufacturers[0] : null);

  const categoryConfig =
    CATEGORY_CONFIG[modification.category] || DEFAULT_CATEGORY_CONFIG;

  // Определяем цвет границы в зависимости от состояния
  let borderColor = 'rgba(255,42,109,0.3)';
  let bgGradient =
    'linear-gradient(135deg, rgba(26,26,36,0.9) 0%, rgba(10,10,18,0.95) 100%)';

  if (isInstalled) {
    borderColor = '#39ff14';
    bgGradient =
      'linear-gradient(135deg, rgba(57,255,20,0.1) 0%, rgba(10,10,18,0.95) 100%)';
  } else if (isIncompatible) {
    borderColor = 'rgba(255,51,51,0.3)';
  }

  return (
    <Box
      style={{
        background: bgGradient,
        border: `1px solid ${borderColor}`,
        borderRadius: '4px',
        marginBottom: '0.5rem',
        cursor: 'pointer',
        position: 'relative',
        opacity: isIncompatible ? 0.5 : 1,
      }}
      onClick={() => {
        act('play_click_sound');
        onSelect();
      }}
    >
      {/* Индикатор установленной модификации */}
      {isInstalled && (
        <Box
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '4px',
            height: '100%',
            background: '#39ff14',
            boxShadow: '0 0 10px #39ff14',
          }}
        />
      )}

      <Box
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          padding: '0.6rem 0.75rem',
          gap: '0.6rem',
        }}
      >
        {/* Иконка */}
        <Box
          style={{
            width: '32px',
            height: '32px',
            minWidth: '32px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: `rgba(${isInstalled ? '57,255,20' : '255,42,109'},0.15)`,
            border: `2px solid ${isInstalled ? '#39ff14' : categoryConfig.color}`,
            borderRadius: '4px',
            fontSize: '0.95rem',
            color: isInstalled ? '#39ff14' : categoryConfig.color,
          }}
        >
          <Icon name={categoryConfig.icon} />
        </Box>

        {/* Информация */}
        <Box style={{ flex: 1, minWidth: 0 }}>
          <Box
            style={{
              fontSize: '0.85rem',
              fontWeight: 600,
              color: '#e0e0e0',
              lineHeight: 1.3,
              marginBottom: '0.2rem',
            }}
          >
            {modification.name}
          </Box>
          <Box
            style={{
              fontSize: '0.7rem',
              color: '#8a8a9a',
              textTransform: 'uppercase',
              letterSpacing: '0.5px',
            }}
          >
            {modification.category}
          </Box>
        </Box>

        {/* Действия */}
        <Box
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: '0.3rem',
            alignItems: 'flex-end',
          }}
          onClick={(e: React.MouseEvent) => e.stopPropagation()}
        >
          {/* Выбор производителя для протезов - Cyberpunk стиль */}
          {Array.isArray(manufacturers) && isInstalled && (
            <Box
              style={{ position: 'relative', zIndex: dropdownOpen ? 100 : 1 }}
            >
              <Box
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                  padding: '0.35rem 0.6rem',
                  background: dropdownOpen
                    ? 'rgba(0,240,255,0.2)'
                    : 'rgba(0,240,255,0.1)',
                  border: dropdownOpen
                    ? '1px solid rgba(0,240,255,0.7)'
                    : '1px solid rgba(0,240,255,0.4)',
                  borderRadius: dropdownOpen ? '3px 3px 0 0' : '3px',
                  cursor: 'pointer',
                  fontSize: '0.8rem',
                  fontWeight: 600,
                  color: '#00f0ff',
                  minWidth: '130px',
                  justifyContent: 'space-between',
                  borderLeft: `3px solid ${getManufacturerColor(selectedManufacturer || 'general')}`,
                }}
                onClick={() => {
                  act('play_click_sound');
                  setDropdownOpen(!dropdownOpen);
                }}
              >
                {/* Цветовой индикатор */}
                <Box
                  style={{
                    width: '8px',
                    height: '8px',
                    borderRadius: '50%',
                    background: getManufacturerColor(
                      selectedManufacturer || 'general',
                    ),
                    boxShadow: `0 0 4px ${getManufacturerColor(selectedManufacturer || 'general')}`,
                    flexShrink: 0,
                  }}
                />
                <span style={{ flex: 1 }}>
                  {selectedManufacturer === 'None'
                    ? 'Без протеза'
                    : selectedManufacturer}
                </span>
                <Icon name={dropdownOpen ? 'chevron-up' : 'chevron-down'} />
              </Box>
              {dropdownOpen && (
                <Box
                  style={{
                    position: 'absolute',
                    top: '100%',
                    right: 0,
                    left: 0,
                    background:
                      'linear-gradient(180deg, rgba(10,10,18,0.98) 0%, rgba(26,26,36,0.98) 100%)',
                    border: '1px solid rgba(0,240,255,0.7)',
                    borderTop: 'none',
                    borderRadius: '0 0 4px 4px',
                    overflow: 'hidden',
                    zIndex: 1000,
                    boxShadow: '0 4px 20px rgba(0,0,0,0.5)',
                    maxHeight: '200px',
                    overflowY: 'auto',
                  }}
                >
                  {manufacturers.map((brand: string) => {
                    const isSelected = brand === selectedManufacturer;
                    const brandColor = getManufacturerColor(brand);
                    const brandDesc =
                      MANUFACTURER_DESCRIPTIONS[brand.toLowerCase()];
                    return (
                      <Tooltip
                        key={brand}
                        content={
                          brandDesc ? (
                            <Box style={{ maxWidth: '200px' }}>
                              <Box
                                bold
                                style={{
                                  color: brandColor,
                                  marginBottom: '0.25rem',
                                  fontSize: '0.85rem',
                                }}
                              >
                                {brand === 'None' ? 'Без протеза' : brand}
                              </Box>
                              <Box
                                style={{ fontSize: '0.78rem', color: '#ccc' }}
                              >
                                {brandDesc}
                              </Box>
                            </Box>
                          ) : brand === 'None' ? (
                            'Без протеза'
                          ) : (
                            brand
                          )
                        }
                        position="left"
                      >
                        <Box
                          style={{
                            padding: '0.5rem 0.75rem',
                            fontSize: '0.8rem',
                            color: isSelected ? '#00f0ff' : '#e0e0e0',
                            background: isSelected
                              ? 'rgba(0,240,255,0.15)'
                              : 'transparent',
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '0.5rem',
                            borderLeft: `3px solid ${brandColor}`,
                          }}
                          onClick={() => {
                            act('play_install_sound');
                            act('set_body_modification_manufacturer', {
                              body_modification_key: modification.key,
                              manufacturer: brand,
                            });
                            setDropdownOpen(false);
                          }}
                        >
                          {/* Цветовой индикатор */}
                          <Box
                            style={{
                              width: '8px',
                              height: '8px',
                              borderRadius: '50%',
                              background: brandColor,
                              boxShadow: `0 0 4px ${brandColor}`,
                              flexShrink: 0,
                            }}
                          />
                          <span style={{ flex: 1 }}>
                            {brand === 'None' ? 'Без протеза' : brand}
                          </span>
                          {isSelected && (
                            <Icon
                              name="check"
                              style={{ color: '#00f0ff', fontSize: '0.75rem' }}
                            />
                          )}
                        </Box>
                      </Tooltip>
                    );
                  })}
                </Box>
              )}
            </Box>
          )}

          {isInstalled ? (
            <Box
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.4rem',
                padding: '0.35rem 0.6rem',
                background: 'rgba(255,51,51,0.2)',
                border: '1px solid rgba(255,51,51,0.5)',
                borderRadius: '3px',
                cursor: 'pointer',
                fontSize: '0.75rem',
                fontWeight: 600,
                color: '#ff3333',
                textTransform: 'uppercase',
                letterSpacing: '0.5px',
                whiteSpace: 'nowrap',
              }}
              onClick={() => {
                act('play_deselect_sound');
                onRemove();
              }}
            >
              <Icon name="times" /> Удалить
            </Box>
          ) : (
            <Tooltip
              content={
                isIncompatible ? 'Несовместимо с текущими модификациями' : ''
              }
            >
              <Box
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                  padding: '0.35rem 0.6rem',
                  background: isIncompatible
                    ? 'rgba(100,100,100,0.2)'
                    : 'rgba(57,255,20,0.15)',
                  border: isIncompatible
                    ? '1px solid rgba(100,100,100,0.3)'
                    : '1px solid rgba(57,255,20,0.5)',
                  borderRadius: '3px',
                  cursor: isIncompatible ? 'not-allowed' : 'pointer',
                  fontSize: '0.75rem',
                  fontWeight: 600,
                  color: isIncompatible ? '#666' : '#39ff14',
                  textTransform: 'uppercase',
                  letterSpacing: '0.5px',
                  whiteSpace: 'nowrap',
                }}
                onClick={
                  isIncompatible
                    ? undefined
                    : () => {
                        act('play_install_sound');
                        onAdd();
                      }
                }
              >
                <Icon name="plus" /> Установить
              </Box>
            </Tooltip>
          )}
        </Box>
      </Box>
    </Box>
  );
};
