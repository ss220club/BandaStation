import { useEffect, useRef, useState } from 'react';
import { Box } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import type { PreferencesMenuData } from '../../types';

const BOOT_SEQUENCE = [
  'Инициализация нейроинтерфейса',
  'Проверка сенсорного ядра',
  'Инициализация блока имплантов',
  'Загрузка лицензий Dark Industries',
  'Подключение диагностических модулей',
  'Калибровка сенсорного профиля',
];

const BOOT_TS = [
  '[ 00:00.312 ]',
  '[ 00:00.498 ]',
  '[ 00:00.671 ]',
  '[ 00:00.843 ]',
  '[ 00:01.015 ]',
  '[ 00:01.247 ]',
];

const BOOT_DELAYS = [350, 620, 890, 1140, 1390, 1640, 2050, 2500];

type RipperDocBootScreenProps = {
  onComplete: () => void;
};

export function RipperDocBootScreen(props: RipperDocBootScreenProps) {
  const { act } = useBackend<PreferencesMenuData>();
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

      <Box
        style={{
          position: 'relative',
          zIndex: 2,
          width: '100%',
          maxWidth: '560px',
        }}
      >
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
            DARK INDUSTRIES
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
            RipperDoc
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
          Инициализация систем
        </Box>

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
                  {'>'}
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
                      ...
                    </span>
                  ) : (
                    '[ OK ]'
                  )}
                </Box>
              </Box>
            );
          })}
        </Box>

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
            Система готова. Добро пожаловать, док.
          </Box>
        )}
      </Box>

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
}
