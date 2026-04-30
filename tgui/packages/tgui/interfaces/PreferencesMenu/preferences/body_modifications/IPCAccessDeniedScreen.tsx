import { useEffect, useState } from 'react';
import { Box, Icon } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import type { PreferencesMenuData } from '../../types';


type IPCAccessDeniedScreenProps = {
  onClose: () => void;
};

export function IPCAccessDeniedScreen(props: IPCAccessDeniedScreenProps) {
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
}

