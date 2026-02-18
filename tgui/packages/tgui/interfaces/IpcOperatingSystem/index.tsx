import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';

// ============================================
// TYPES
// ============================================

type ScanResult = {
  category: string;
  item: string;
  value: string;
  status: string;
  color: string;
};

type AntivirusResult = {
  message: string;
  type: string;
};

type Virus = {
  name: string;
  desc: string;
  severity: string;
  removable: boolean;
};

type NetApp = {
  name: string;
  desc: string;
  category: string;
  installed: boolean;
  file_size: number;
};

type InstalledApp = {
  name: string;
  desc: string;
  category: string;
  is_blackwall: boolean;
  toggleable: boolean;
  active: boolean;
  has_effect: boolean;
  is_passive: boolean;
  last_message: string;
};

type IconPosition = {
  x: number;
  y: number;
};

type IpcOsData = {
  os_name: string;
  os_version: string;
  theme_color: string;
  brand_key: string;
  has_password: boolean;
  logged_in: boolean;
  current_app: string;
  scan_in_progress: boolean;
  scan_progress: number;
  scan_results: ScanResult[];
  last_scan_time: string;
  antivirus_scanning: boolean;
  antivirus_progress: number;
  antivirus_results: AntivirusResult[];
  virus_count: number;
  has_serious_viruses: boolean;
  viruses: Virus[];
  network_connected: boolean;
  net_wall: string;
  downloading: boolean;
  download_progress: number;
  download_app_name: string;
  net_catalog: NetApp[];
  black_wall_catalog: NetApp[];
  installed_apps: InstalledApp[];
  icon_positions: Record<string, IconPosition>;
  current_installed_app_name: string;
  // Remote access
  pending_access_request: boolean;
  requesting_user_name: string;
  has_remote_viewer: boolean;
  remote_viewer_name: string;
  is_remote_user: boolean;
  remote_access_mode: string;
  pending_action_approval: boolean;
  pending_action_desc: string;
};

// ============================================
// SAFE DATA ACCESS HELPERS
// ============================================

function safeArray<T>(arr: T[] | null | undefined): T[] {
  return arr || [];
}

function safeStr(val: string | null | undefined, fallback: string): string {
  return val || fallback;
}

function safeNum(val: number | null | undefined, fallback: number): number {
  return val ?? fallback;
}

function safeBool(val: boolean | number | null | undefined): boolean {
  return !!val;
}

// ============================================
// MAIN COMPONENT
// ============================================

export const IpcOperatingSystem = () => {
  const { data } = useBackend<IpcOsData>();

  const logged_in = safeBool(data.logged_in);
  const current_app = safeStr(data.current_app, 'desktop');
  const os_name = safeStr(data.os_name, 'IPC-OS');
  const theme_color = safeStr(data.theme_color, '#6a6a6a');

  return (
    <Window width={700} height={650} title={os_name}>
      <Window.Content
        style={{
          background: `linear-gradient(135deg, rgba(0,0,0,0.95) 0%, ${hexToRgba(theme_color, 0.15)} 50%, rgba(0,0,0,0.95) 100%)`,
        }}
      >
        {!logged_in ? (
          <LoginScreen />
        ) : (
          <>
            {current_app === 'desktop' && <DesktopScreen />}
            {current_app === 'diagnostics' && <DiagnosticsApp />}
            {current_app === 'antivirus' && <AntivirusApp />}
            {current_app === 'net' && <NetAppScreen />}
            {current_app === 'installed_app' && <InstalledAppScreen />}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

// ============================================
// UTILITIES
// ============================================

function hexToRgba(hex: string | null | undefined, alpha: number): string {
  if (!hex || typeof hex !== 'string' || hex.length < 7) {
    return `rgba(106, 106, 106, ${alpha})`;
  }
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  if (isNaN(r) || isNaN(g) || isNaN(b)) {
    return `rgba(106, 106, 106, ${alpha})`;
  }
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function getSeverityColor(severity: string | null | undefined): string {
  switch (severity) {
    case 'low':
      return 'average';
    case 'medium':
      return 'orange';
    case 'high':
      return 'bad';
    default:
      return 'label';
  }
}

function getAppIcon(app: InstalledApp): string {
  if (safeBool(app.is_blackwall)) {
    return 'skull-crossbones';
  }
  switch (app.category) {
    case 'pda':
      return 'mobile-alt';
    case 'diagnostic':
      return 'stethoscope';
    case 'exploit':
      return 'bug';
    case 'mod':
      return 'cogs';
    default:
      return 'cube';
  }
}

function getCategoryLabel(cat: string): string {
  switch (cat) {
    case 'diagnostic':
      return 'Диагн.';
    case 'utility':
      return 'Утилита';
    case 'exploit':
      return 'Эксплойт';
    case 'mod':
      return 'Мод';
    case 'pda':
      return 'КПК';
    default:
      return 'Прочее';
  }
}

// ============================================
// LOGIN SCREEN
// ============================================

const LoginScreen = () => {
  const { act, data } = useBackend<IpcOsData>();

  const os_name = safeStr(data.os_name, 'IPC-OS');
  const os_version = safeStr(data.os_version, '2.4.1');
  const theme_color = safeStr(data.theme_color, '#6a6a6a');
  const has_password = safeBool(data.has_password);

  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = () => {
    if (!has_password) {
      if (!password || password.length < 1) {
        setError('Введите пароль (минимум 1 символ)');
        return;
      }
      act('set_password', { password });
    } else {
      act('login', { password });
    }
    setPassword('');
  };

  return (
    <Flex direction="column" align="center" justify="center" height="100%">
      <Flex.Item>
        <Box textAlign="center" mb={3}>
          <Box
            fontSize="2.5em"
            bold
            color={theme_color}
            style={{
              textShadow: `0 0 20px ${hexToRgba(theme_color, 0.5)}`,
              letterSpacing: '3px',
            }}
          >
            {os_name}
          </Box>
          <Box fontSize="0.9em" color="label" mt={1}>
            v{os_version}
          </Box>
        </Box>
      </Flex.Item>

      <Flex.Item>
        <Box
          p={2}
          style={{
            border: `1px solid ${hexToRgba(theme_color, 0.3)}`,
            borderRadius: '4px',
            background: 'rgba(0,0,0,0.5)',
            width: '300px',
          }}
        >
          <Box textAlign="center" mb={2} color="label" fontSize="0.95em">
            {has_password
              ? 'Введите пароль для входа'
              : 'Установите пароль для системы'}
          </Box>

          <Box mb={2}>
            <Input
              fluid
              placeholder={has_password ? 'Пароль...' : 'Новый пароль...'}
              value={password}
              onChange={(val: string) => {
                setPassword(val);
                setError('');
              }}
              onEnter={handleSubmit}
            />
          </Box>

          {error && (
            <Box color="bad" fontSize="0.85em" mb={1} textAlign="center">
              {error}
            </Box>
          )}

          <Button
            fluid
            color="good"
            textAlign="center"
            onClick={handleSubmit}
          >
            {has_password ? 'Войти' : 'Установить пароль'}
          </Button>
        </Box>
      </Flex.Item>

      <Flex.Item mt={4}>
        <Box textAlign="center" color="label" fontSize="0.75em" italic>
          Integrated Positronic Chassis Operating System
        </Box>
      </Flex.Item>
    </Flex>
  );
};

// ============================================
// DRAGGABLE DESKTOP ICON
// ============================================

type DraggableIconProps = {
  iconId: string;
  name: string;
  faIcon: string;
  color: string;
  initialX: number;
  initialY: number;
  badge?: number;
  badgeSevere?: boolean;
  small?: boolean;
  onOpen: () => void;
};

const DraggableDesktopIcon = (props: DraggableIconProps) => {
  const { act } = useBackend();
  const { iconId, name, faIcon, color, initialX, initialY, small } = props;
  const size = small ? '70px' : '80px';
  const iconSize = small ? 1.8 : 2.2;

  const [position, setPosition] = useState({ x: initialX, y: initialY });
  const [dragging, setDragging] = useState(false);
  const lastMouseRef = useRef({ x: 0, y: 0 });
  const hasDraggedRef = useRef(false);

  // Sync with server-provided positions
  useEffect(() => {
    if (!dragging) {
      setPosition({ x: initialX, y: initialY });
    }
  }, [initialX, initialY, dragging]);

  const handleMouseDown = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
      setDragging(true);
      hasDraggedRef.current = false;
      lastMouseRef.current = { x: e.screenX, y: e.screenY };
    },
    [],
  );

  useEffect(() => {
    if (!dragging) {
      return;
    }

    const handleMouseMove = (e: MouseEvent) => {
      const dx = e.screenX - lastMouseRef.current.x;
      const dy = e.screenY - lastMouseRef.current.y;
      if (Math.abs(dx) > 2 || Math.abs(dy) > 2) {
        hasDraggedRef.current = true;
      }
      setPosition((prev) => ({
        x: Math.max(0, Math.min(600, prev.x + dx)),
        y: Math.max(0, Math.min(500, prev.y + dy)),
      }));
      lastMouseRef.current = { x: e.screenX, y: e.screenY };
    };

    const handleMouseUp = () => {
      setDragging(false);
      if (hasDraggedRef.current) {
        // Send final position to backend
        setPosition((prev) => {
          act('set_icon_position', {
            icon_id: iconId,
            x: prev.x,
            y: prev.y,
          });
          return prev;
        });
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [dragging, iconId, act]);

  const handleClick = useCallback(() => {
    if (!hasDraggedRef.current) {
      props.onOpen();
    }
  }, [props.onOpen]);

  return (
    <Box
      style={{
        position: 'absolute',
        left: `${position.x}px`,
        top: `${position.y}px`,
        cursor: dragging ? 'grabbing' : 'grab',
        zIndex: dragging ? 100 : 1,
        userSelect: 'none',
        width: size,
        opacity: dragging ? 0.85 : 1,
        transition: dragging ? 'none' : 'opacity 0.15s',
      }}
      textAlign="center"
      onMouseDown={handleMouseDown}
      onClick={handleClick}
    >
      <Box
        py={1}
        style={{
          border: `1px solid ${hexToRgba(color, 0.3)}`,
          borderRadius: '4px',
          background: hexToRgba(color, dragging ? 0.15 : 0.06),
          boxShadow: dragging
            ? `0 4px 12px ${hexToRgba(color, 0.3)}`
            : 'none',
        }}
      >
        <Icon
          name={faIcon}
          size={iconSize}
          color={color}
          style={{
            textShadow: `0 0 6px ${hexToRgba(color, 0.5)}`,
          }}
        />
      </Box>
      {props.badge !== undefined && (
        <Box
          style={{
            position: 'absolute',
            top: '-3px',
            right: '-3px',
            background: props.badgeSevere ? '#cc3333' : '#cc9933',
            borderRadius: '50%',
            width: '16px',
            height: '16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '0.65em',
            fontWeight: 'bold',
          }}
        >
          {props.badge}
        </Box>
      )}
      <Box
        fontSize={small ? '0.6em' : '0.7em'}
        mt={0.3}
        style={{
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          whiteSpace: 'nowrap',
        }}
      >
        {name}
      </Box>
    </Box>
  );
};

// ============================================
// DESKTOP
// ============================================

const SYSTEM_APPS = [
  {
    id: 'diagnostics',
    name: 'Диагностика',
    faIcon: 'heartbeat',
  },
  {
    id: 'antivirus',
    name: 'Антивирус',
    faIcon: 'shield-alt',
  },
  {
    id: 'net',
    name: 'NET',
    faIcon: 'globe',
  },
];

const DesktopScreen = () => {
  const { act, data } = useBackend<IpcOsData>();

  const os_name = safeStr(data.os_name, 'IPC-OS');
  const os_version = safeStr(data.os_version, '2.4.1');
  const theme_color = safeStr(data.theme_color, '#6a6a6a');
  const virus_count = safeNum(data.virus_count, 0);
  const has_serious_viruses = safeBool(data.has_serious_viruses);
  const installed_apps = safeArray(data.installed_apps);
  const pending_request = safeBool(data.pending_access_request);
  const requesting_name = safeStr(data.requesting_user_name, '');
  const has_remote = safeBool(data.has_remote_viewer);
  const remote_name = safeStr(data.remote_viewer_name, '');
  const is_remote = safeBool(data.is_remote_user);
  const icon_positions = data.icon_positions || {};
  const pending_action = safeBool(data.pending_action_approval);
  const pending_action_desc = safeStr(data.pending_action_desc, '');
  const remote_mode = safeStr(data.remote_access_mode, 'permission');

  return (
    <Flex direction="column" height="100%">
      {/* Top bar */}
      <Flex.Item>
        <Box
          py={0.3}
          px={1}
          style={{
            background: hexToRgba(theme_color, 0.2),
            borderBottom: `1px solid ${hexToRgba(theme_color, 0.3)}`,
          }}
        >
          <Flex justify="space-between" align="center">
            <Flex.Item>
              <Box bold color={theme_color} fontSize="0.8em">
                <Icon name="desktop" mr={0.5} />
                {os_name} v{os_version}
                {is_remote && (
                  <Box
                    as="span"
                    ml={1}
                    color="average"
                    fontSize="0.85em"
                  >
                    [УДАЛЁННЫЙ ДОСТУП]
                  </Box>
                )}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Flex align="center">
                {has_remote && !is_remote && (
                  <Flex.Item mr={1}>
                    <Box fontSize="0.7em" color="average">
                      <Icon name="eye" mr={0.3} />
                      {remote_name}
                      {remote_mode === 'permission' && (
                        <Box as="span" ml={0.3} color="label">
                          [разр.]
                        </Box>
                      )}
                      {remote_mode === 'password' && (
                        <Box as="span" ml={0.3} color="bad">
                          [полн.]
                        </Box>
                      )}
                    </Box>
                  </Flex.Item>
                )}
                {has_remote && !is_remote && (
                  <Flex.Item mr={1}>
                    <Button
                      icon="unlink"
                      color="caution"
                      compact
                      tooltip="Отключить удалённый доступ"
                      onClick={() => act('revoke_remote')}
                    />
                  </Flex.Item>
                )}
                {virus_count > 0 && (
                  <Flex.Item mr={1}>
                    <Box
                      fontSize="0.7em"
                      bold
                      color={has_serious_viruses ? 'bad' : 'average'}
                    >
                      <Icon name="virus" mr={0.3} />
                      {virus_count}
                    </Box>
                  </Flex.Item>
                )}
                {!is_remote && (
                  <Flex.Item>
                    <Button
                      icon="power-off"
                      color="bad"
                      compact
                      onClick={() => act('logout')}
                      tooltip="Выйти"
                    />
                  </Flex.Item>
                )}
              </Flex>
            </Flex.Item>
          </Flex>
        </Box>
      </Flex.Item>

      {/* Access request notification */}
      {pending_request && !is_remote && (
        <Flex.Item>
          <Box
            p={0.5}
            style={{
              background: 'rgba(200, 150, 0, 0.15)',
              borderBottom: '1px solid rgba(200, 150, 0, 0.3)',
            }}
          >
            <Flex justify="space-between" align="center">
              <Flex.Item grow>
                <Box fontSize="0.85em" color="average" bold>
                  <Icon name="bell" mr={0.5} />
                  Запрос доступа от:{' '}
                  <Box as="span" color="white">
                    {requesting_name}
                  </Box>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  compact
                  color="good"
                  icon="check"
                  mr={0.5}
                  onClick={() => act('approve_access')}
                >
                  Разрешить
                </Button>
                <Button
                  compact
                  color="bad"
                  icon="times"
                  onClick={() => act('deny_access')}
                >
                  Отклонить
                </Button>
              </Flex.Item>
            </Flex>
          </Box>
        </Flex.Item>
      )}

      {/* Pending action approval notification */}
      {pending_action && !is_remote && (
        <Flex.Item>
          <Box
            p={0.5}
            style={{
              background: 'rgba(100, 150, 220, 0.15)',
              borderBottom: '1px solid rgba(100, 150, 220, 0.3)',
            }}
          >
            <Flex justify="space-between" align="center">
              <Flex.Item grow>
                <Box fontSize="0.85em" color="label" bold>
                  <Icon name="cog" mr={0.5} />
                  Запрос действия:{' '}
                  <Box as="span" color="white">
                    {pending_action_desc}
                  </Box>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  compact
                  color="good"
                  icon="check"
                  mr={0.5}
                  onClick={() => act('approve_action')}
                >
                  Разрешить
                </Button>
                <Button
                  compact
                  color="bad"
                  icon="times"
                  onClick={() => act('deny_action')}
                >
                  Отклонить
                </Button>
              </Flex.Item>
            </Flex>
          </Box>
        </Flex.Item>
      )}

      {/* Remote user: waiting for approval indicator */}
      {pending_action && is_remote && (
        <Flex.Item>
          <Box
            p={0.5}
            textAlign="center"
            style={{
              background: 'rgba(100, 150, 220, 0.1)',
              borderBottom: '1px solid rgba(100, 150, 220, 0.2)',
            }}
          >
            <Box fontSize="0.85em" color="label">
              <Icon name="clock" mr={0.5} />
              Ожидание подтверждения: {pending_action_desc}
            </Box>
          </Box>
        </Flex.Item>
      )}

      {/* Desktop icons area — free positioning */}
      <Flex.Item
        grow={1}
        style={{
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        {/* System apps */}
        {SYSTEM_APPS.map((app) => {
          const pos = icon_positions[app.id];
          const defaultIdx = SYSTEM_APPS.indexOf(app);
          return (
            <DraggableDesktopIcon
              key={app.id}
              iconId={app.id}
              name={app.name}
              faIcon={app.faIcon}
              color={theme_color}
              initialX={pos?.x ?? 10 + defaultIdx * 90}
              initialY={pos?.y ?? 10}
              badge={
                app.id === 'antivirus' && virus_count > 0
                  ? virus_count
                  : undefined
              }
              badgeSevere={has_serious_viruses}
              onOpen={() => act('open_app', { app: app.id })}
            />
          );
        })}

        {/* Installed NET apps */}
        {installed_apps.map((app, idx) => {
          const posKey = `installed_${app.name}`;
          const pos = icon_positions[posKey];
          const appIcon = getAppIcon(app);
          const appColor = safeBool(app.active)
            ? '#39ff14'
            : safeBool(app.is_blackwall)
              ? '#cc3333'
              : hexToRgba(theme_color, 1);
          return (
            <DraggableDesktopIcon
              key={app.name}
              iconId={posKey}
              name={
                safeBool(app.active) ? `[ON] ${app.name}` : app.name
              }
              faIcon={appIcon}
              color={appColor}
              initialX={pos?.x ?? 10 + (idx % 7) * 90}
              initialY={pos?.y ?? 100 + Math.floor(idx / 7) * 90}
              small
              onOpen={() =>
                act('open_installed_app', { app_name: app.name })
              }
            />
          );
        })}
      </Flex.Item>

      {/* Taskbar */}
      <Flex.Item>
        <Box
          py={0.3}
          px={1}
          style={{
            background: hexToRgba(theme_color, 0.12),
            borderTop: `1px solid ${hexToRgba(theme_color, 0.25)}`,
          }}
        >
          <Flex justify="space-between" align="center">
            <Flex.Item>
              <Flex align="center">
                {SYSTEM_APPS.map((app) => (
                  <Flex.Item key={app.id} mr={0.3}>
                    <Button
                      compact
                      icon={app.faIcon}
                      color="transparent"
                      tooltip={app.name}
                      onClick={() => act('open_app', { app: app.id })}
                    />
                  </Flex.Item>
                ))}
              </Flex>
            </Flex.Item>
            <Flex.Item>
              <Box fontSize="0.65em" color="label">
                {virus_count > 0 ? (
                  <Box
                    as="span"
                    color={has_serious_viruses ? 'bad' : 'average'}
                  >
                    <Icon name="exclamation-triangle" mr={0.3} />
                    {virus_count} угроз
                  </Box>
                ) : (
                  <Box as="span" color="good">
                    <Icon name="check-circle" mr={0.3} />
                    Защищено
                  </Box>
                )}
                {' | '}
                <Icon name="cube" mr={0.3} />
                {installed_apps.length} прил.
                {has_remote && (
                  <>
                    {' | '}
                    <Box as="span" color="average">
                      <Icon name="eye" mr={0.3} />
                      Удалённый доступ
                    </Box>
                  </>
                )}
              </Box>
            </Flex.Item>
          </Flex>
        </Box>
      </Flex.Item>
    </Flex>
  );
};

// ============================================
// INSTALLED APP SCREEN
// ============================================

const InstalledAppScreen = () => {
  const { act, data } = useBackend<IpcOsData>();

  const app_name = safeStr(data.current_installed_app_name, '');
  const theme_color = safeStr(data.theme_color, '#6a6a6a');
  const installed_apps = safeArray(data.installed_apps);

  const app = installed_apps.find((a) => a.name === app_name);

  if (!app) {
    return (
      <Flex direction="column" height="100%">
        <AppHeader title="Приложение" icon="cube" />
        <Flex.Item grow={1}>
          <Box p={2} textAlign="center" color="label">
            Приложение не найдено.
          </Box>
        </Flex.Item>
      </Flex>
    );
  }

  const isBlackwall = safeBool(app.is_blackwall);

  return (
    <Flex direction="column" height="100%">
      <AppHeader
        title={app.name}
        icon={isBlackwall ? 'skull-crossbones' : 'cube'}
      />

      <Flex.Item grow={1} style={{ overflowY: 'auto' }}>
        <Box p={2}>
          {/* App info card */}
          <Box
            p={2}
            mb={2}
            style={{
              border: `1px solid ${hexToRgba(isBlackwall ? '#cc3333' : theme_color, 0.4)}`,
              borderRadius: '6px',
              background: hexToRgba(
                isBlackwall ? '#cc3333' : theme_color,
                0.08,
              ),
            }}
          >
            <Flex align="center" mb={1.5}>
              <Flex.Item mr={1.5}>
                <Box
                  style={{
                    width: '48px',
                    height: '48px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    border: `1px solid ${hexToRgba(isBlackwall ? '#cc3333' : theme_color, 0.3)}`,
                    borderRadius: '8px',
                    background: hexToRgba(
                      isBlackwall ? '#cc3333' : theme_color,
                      0.12,
                    ),
                  }}
                >
                  <Icon
                    name={isBlackwall ? 'skull-crossbones' : 'cube'}
                    size={2}
                    color={isBlackwall ? '#cc3333' : theme_color}
                  />
                </Box>
              </Flex.Item>
              <Flex.Item grow>
                <Box bold fontSize="1.3em">
                  {app.name}
                </Box>
                <Box fontSize="0.85em" color="label" mt={0.3}>
                  {getCategoryLabel(app.category)}
                  {isBlackwall && (
                    <Box as="span" color="bad" ml={1}>
                      Black Wall
                    </Box>
                  )}
                </Box>
              </Flex.Item>
            </Flex>

            <Box
              fontSize="0.9em"
              color="label"
              p={1}
              style={{
                background: 'rgba(0,0,0,0.2)',
                borderRadius: '4px',
              }}
            >
              {app.desc}
            </Box>
          </Box>

          {/* Status */}
          <Box
            p={1}
            mb={2}
            textAlign="center"
            style={{
              border: safeBool(app.is_passive)
                ? '1px solid rgba(100,150,255,0.3)'
                : '1px solid rgba(50,200,50,0.3)',
              borderRadius: '4px',
              background: safeBool(app.is_passive)
                ? 'rgba(100,150,255,0.05)'
                : 'rgba(0,200,0,0.05)',
            }}
          >
            <Box
              color={safeBool(app.is_passive) ? 'blue' : 'good'}
              bold
              fontSize="0.9em"
            >
              <Icon
                name={safeBool(app.is_passive) ? 'cog' : 'check-circle'}
                mr={0.5}
              />
              {safeBool(app.is_passive)
                ? 'Пассивный мод — работает пока установлен'
                : 'Приложение установлено и активно'}
            </Box>
          </Box>

          {isBlackwall && (
            <Box
              p={1}
              mb={2}
              textAlign="center"
              style={{
                border: '1px solid rgba(200,50,50,0.3)',
                borderRadius: '4px',
                background: 'rgba(200,0,0,0.08)',
              }}
            >
              <Box color="bad" fontSize="0.8em">
                <Icon name="exclamation-triangle" mr={0.5} />
                ВНИМАНИЕ: Нелегальное ПО. Обнаружение может привести к
                последствиям.
              </Box>
            </Box>
          )}

          {/* Last message from app */}
          {app.last_message && (
            <Box
              p={1}
              mb={2}
              style={{
                border: `1px solid ${hexToRgba(theme_color, 0.3)}`,
                borderRadius: '4px',
                background: 'rgba(0,0,0,0.3)',
              }}
            >
              <Box fontSize="0.7em" color="label" mb={0.3}>
                <Icon name="terminal" mr={0.3} />
                Последний вывод:
              </Box>
              <Box fontSize="0.85em" style={{ whiteSpace: 'pre-wrap' }}>
                {app.last_message}
              </Box>
            </Box>
          )}

          {/* Action buttons */}
          {safeBool(app.has_effect) && (
            <Box mb={1}>
              {safeBool(app.toggleable) ? (
                <Button
                  fluid
                  color={safeBool(app.active) ? 'caution' : 'good'}
                  icon={safeBool(app.active) ? 'stop' : 'play'}
                  textAlign="center"
                  onClick={() =>
                    act('toggle_app', { app_name: app.name })
                  }
                >
                  {safeBool(app.active)
                    ? 'Деактивировать'
                    : 'Активировать'}
                </Button>
              ) : (
                <Button
                  fluid
                  color="good"
                  icon="play"
                  textAlign="center"
                  onClick={() =>
                    act('activate_app', { app_name: app.name })
                  }
                >
                  Запустить
                </Button>
              )}
            </Box>
          )}

          {/* Uninstall */}
          <Button
            fluid
            color="bad"
            icon="trash"
            textAlign="center"
            onClick={() => {
              act('uninstall_app', { app_name: app.name });
              act('close_installed_app');
            }}
          >
            Удалить приложение
          </Button>
        </Box>
      </Flex.Item>
    </Flex>
  );
};

// ============================================
// DIAGNOSTICS APP
// ============================================

const DiagnosticsApp = () => {
  const { act, data } = useBackend<IpcOsData>();

  const scan_in_progress = safeBool(data.scan_in_progress);
  const scan_progress = safeNum(data.scan_progress, 0);
  const scan_results = safeArray(data.scan_results);
  const last_scan_time = safeStr(data.last_scan_time, '');

  return (
    <Flex direction="column" height="100%">
      <AppHeader title="Самодиагностика" icon="heartbeat" />

      <Flex.Item grow={1} style={{ overflowY: 'auto' }}>
        <Box p={1}>
          <Box mb={2}>
            <Button
              fluid
              color={scan_in_progress ? 'average' : 'good'}
              disabled={scan_in_progress}
              onClick={() => act('start_scan')}
              textAlign="center"
              bold
            >
              {scan_in_progress
                ? 'Сканирование...'
                : 'Запустить сканирование систем'}
            </Button>
          </Box>

          {scan_in_progress && (
            <Box mb={2}>
              <ProgressBar
                value={scan_progress}
                minValue={0}
                maxValue={100}
                ranges={{
                  average: [-Infinity, 50],
                  good: [50, 100],
                }}
              >
                Сканирование: {scan_progress}%
              </ProgressBar>
              <Box
                mt={0.5}
                textAlign="center"
                color="label"
                fontSize="0.8em"
              >
                Анализ подсистем...
              </Box>
            </Box>
          )}

          {!scan_in_progress && scan_results.length > 0 && (
            <Section title="Результаты сканирования">
              {!!last_scan_time && (
                <Box mb={1} color="label" fontSize="0.8em">
                  {last_scan_time}
                </Box>
              )}
              <Table>
                <Table.Row header>
                  <Table.Cell width="20%">Категория</Table.Cell>
                  <Table.Cell width="30%">Параметр</Table.Cell>
                  <Table.Cell width="20%">Значение</Table.Cell>
                  <Table.Cell width="30%">Статус</Table.Cell>
                </Table.Row>
                {scan_results.map((result, idx) => (
                  <Table.Row key={idx}>
                    <Table.Cell>
                      <Box fontSize="0.85em" color="label">
                        {result.category}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box bold fontSize="0.9em">
                        {result.item}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box fontSize="0.9em">{result.value}</Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box bold color={result.color} fontSize="0.85em">
                        {result.status}
                      </Box>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          )}

          {!scan_in_progress && scan_results.length === 0 && (
            <Box textAlign="center" color="label" mt={4} fontSize="1em">
              <Box mb={1} fontSize="1.2em" bold>
                Сканирование не проводилось
              </Box>
              <Box>
                Нажмите кнопку выше для запуска диагностики всех подсистем.
              </Box>
            </Box>
          )}
        </Box>
      </Flex.Item>
    </Flex>
  );
};

// ============================================
// ANTIVIRUS APP
// ============================================

const AntivirusApp = () => {
  const { act, data } = useBackend<IpcOsData>();

  const antivirus_scanning = safeBool(data.antivirus_scanning);
  const antivirus_progress = safeNum(data.antivirus_progress, 0);
  const antivirus_results = safeArray(data.antivirus_results);
  const viruses = safeArray(data.viruses);
  const virus_count = safeNum(data.virus_count, 0);
  const has_serious_viruses = safeBool(data.has_serious_viruses);

  return (
    <Flex direction="column" height="100%">
      <AppHeader title="Антивирус" icon="shield-alt" />

      <Flex.Item grow={1} style={{ overflowY: 'auto' }}>
        <Box p={1}>
          {/* Status */}
          <Box
            mb={2}
            p={1.5}
            textAlign="center"
            style={{
              border: `1px solid ${virus_count > 0 ? (has_serious_viruses ? '#cc3333' : '#cc9933') : '#33cc33'}`,
              borderRadius: '4px',
              background:
                virus_count > 0
                  ? has_serious_viruses
                    ? 'rgba(200,0,0,0.15)'
                    : 'rgba(200,150,0,0.15)'
                  : 'rgba(0,200,0,0.15)',
            }}
          >
            <Box
              bold
              fontSize="1.1em"
              color={
                virus_count > 0
                  ? has_serious_viruses
                    ? 'bad'
                    : 'average'
                  : 'good'
              }
            >
              {virus_count > 0
                ? `Обнаружено угроз: ${virus_count}`
                : 'Система чиста'}
            </Box>
            {has_serious_viruses && (
              <Box fontSize="0.85em" color="bad" mt={0.5}>
                Обнаружены серьёзные угрозы! Требуется вмешательство
                роботехника.
              </Box>
            )}
          </Box>

          {/* Virus list */}
          {viruses.length > 0 && (
            <Section title="Обнаруженные угрозы">
              <Stack vertical>
                {viruses.map((virus, idx) => (
                  <Stack.Item key={idx}>
                    <Box
                      p={1}
                      style={{
                        border: `1px solid ${virus.severity === 'high' ? '#cc3333' : virus.severity === 'medium' ? '#cc9933' : '#999933'}`,
                        borderRadius: '3px',
                        background:
                          virus.severity === 'high'
                            ? 'rgba(200,0,0,0.1)'
                            : virus.severity === 'medium'
                              ? 'rgba(200,150,0,0.1)'
                              : 'rgba(150,150,0,0.1)',
                      }}
                    >
                      <Flex justify="space-between" align="center">
                        <Flex.Item>
                          <Box bold color={getSeverityColor(virus.severity)}>
                            {virus.name}
                          </Box>
                          <Box fontSize="0.8em" color="label">
                            {virus.desc}
                          </Box>
                        </Flex.Item>
                        <Flex.Item>
                          <Box
                            fontSize="0.75em"
                            color={virus.removable ? 'good' : 'bad'}
                          >
                            {virus.removable
                              ? 'Удаляемый'
                              : 'Только роботехник'}
                          </Box>
                        </Flex.Item>
                      </Flex>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          )}

          {/* Scan button */}
          <Box mb={2} mt={1}>
            <Button
              fluid
              color={antivirus_scanning ? 'average' : 'good'}
              disabled={antivirus_scanning}
              onClick={() => act('start_antivirus')}
              textAlign="center"
              bold
            >
              {antivirus_scanning
                ? 'Проверка...'
                : 'Запустить антивирусную проверку'}
            </Button>
          </Box>

          {/* Progress */}
          {antivirus_scanning && (
            <Box mb={2}>
              <ProgressBar
                value={antivirus_progress}
                minValue={0}
                maxValue={100}
                ranges={{
                  average: [-Infinity, 50],
                  good: [50, 100],
                }}
              >
                Проверка: {antivirus_progress}%
              </ProgressBar>
            </Box>
          )}

          {/* Results */}
          {!antivirus_scanning && antivirus_results.length > 0 && (
            <Section title="Результаты проверки">
              <Stack vertical>
                {antivirus_results.map((result, idx) => (
                  <Stack.Item key={idx}>
                    <Box
                      p={0.5}
                      color={
                        result.type === 'critical'
                          ? 'bad'
                          : result.type === 'warning'
                            ? 'average'
                            : 'good'
                      }
                      backgroundColor={
                        result.type === 'critical'
                          ? 'rgba(200,0,0,0.15)'
                          : result.type === 'warning'
                            ? 'rgba(200,150,0,0.15)'
                            : 'rgba(0,200,0,0.15)'
                      }
                      fontSize="0.9em"
                    >
                      {result.message}
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          )}
        </Box>
      </Flex.Item>
    </Flex>
  );
};

// ============================================
// NET APP (White Wall / Black Wall)
// ============================================

const NetAppScreen = () => {
  const { act, data } = useBackend<IpcOsData>();

  const network_connected = safeBool(data.network_connected);
  const net_wall = safeStr(data.net_wall, 'white');
  const net_catalog = safeArray(data.net_catalog);
  const black_wall_catalog = safeArray(data.black_wall_catalog);
  const installed_apps = safeArray(data.installed_apps);
  const theme_color = safeStr(data.theme_color, '#6a6a6a');
  const downloading = safeBool(data.downloading);
  const download_progress = safeNum(data.download_progress, 0);
  const download_app_name = safeStr(data.download_app_name, '');

  const catalog = net_wall === 'black' ? black_wall_catalog : net_catalog;
  const isBlack = net_wall === 'black';

  return (
    <Flex direction="column" height="100%">
      <AppHeader title="NET" icon="globe" />

      <Flex.Item grow={1} style={{ overflowY: 'auto' }}>
        <Box p={1}>
          {/* Connection status */}
          <Box
            mb={1}
            p={0.5}
            textAlign="center"
            style={{
              border: `1px solid ${network_connected ? 'rgba(50,200,50,0.3)' : 'rgba(200,50,50,0.3)'}`,
              borderRadius: '3px',
              background: network_connected
                ? 'rgba(0,200,0,0.05)'
                : 'rgba(200,0,0,0.05)',
            }}
          >
            <Box
              bold
              color={network_connected ? 'good' : 'bad'}
              fontSize="0.85em"
            >
              <Icon
                name={network_connected ? 'wifi' : 'times-circle'}
                mr={0.5}
              />
              {network_connected
                ? 'Подключено к сети'
                : 'Нет подключения к сети'}
            </Box>
          </Box>

          {/* Wall tabs */}
          <Tabs>
            <Tabs.Tab
              icon="building"
              selected={!isBlack}
              onClick={() => act('switch_wall', { wall: 'white' })}
            >
              White Wall
            </Tabs.Tab>
            <Tabs.Tab
              icon="skull-crossbones"
              selected={isBlack}
              onClick={() => act('switch_wall', { wall: 'black' })}
              color={isBlack ? 'bad' : undefined}
            >
              Black Wall
            </Tabs.Tab>
          </Tabs>

          {/* Black Wall warning */}
          {isBlack && (
            <Box
              p={0.5}
              mb={1}
              textAlign="center"
              fontSize="0.75em"
              color="bad"
              style={{
                background: 'rgba(200,0,0,0.08)',
                borderBottom: '1px solid rgba(200,0,0,0.2)',
              }}
            >
              <Icon name="exclamation-triangle" mr={0.5} />
              ВНИМАНИЕ: Нелегальное ПО. Использование на свой страх и риск.
            </Box>
          )}

          {/* Download progress */}
          {downloading && (
            <Box mb={1}>
              <Box fontSize="0.8em" color="label" mb={0.3}>
                <Icon name="download" mr={0.5} />
                Загрузка: {download_app_name}
              </Box>
              <ProgressBar
                value={download_progress}
                minValue={0}
                maxValue={100}
                ranges={{
                  average: [-Infinity, 60],
                  good: [60, 100],
                }}
              >
                {download_progress}%
              </ProgressBar>
              <Box mt={0.3} textAlign="right">
                <Button
                  compact
                  color="bad"
                  icon="times"
                  onClick={() => act('cancel_download')}
                >
                  Отмена
                </Button>
              </Box>
            </Box>
          )}

          {/* App catalog */}
          {!network_connected ? (
            <Box textAlign="center" color="label" p={2}>
              <Icon name="plug" size={2} mb={1} />
              <Box bold>Каталог недоступен</Box>
              <Box fontSize="0.85em" mt={0.5}>
                Встаньте на сетевой кабель для подключения.
              </Box>
            </Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell width="28%">Приложение</Table.Cell>
                <Table.Cell width="32%">Описание</Table.Cell>
                <Table.Cell width="12%">Тип</Table.Cell>
                <Table.Cell width="10%">Размер</Table.Cell>
                <Table.Cell width="18%">Действие</Table.Cell>
              </Table.Row>
              {catalog.map((app, idx) => (
                <Table.Row key={idx}>
                  <Table.Cell>
                    <Box bold fontSize="0.85em">
                      <Icon
                        name={isBlack ? 'skull' : 'cube'}
                        mr={0.3}
                        color={isBlack ? 'bad' : 'label'}
                      />
                      {app.name}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box fontSize="0.75em" color="label">
                      {app.desc}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box
                      fontSize="0.7em"
                      color={
                        app.category === 'exploit'
                          ? 'bad'
                          : app.category === 'mod'
                            ? 'average'
                            : app.category === 'diagnostic'
                              ? 'good'
                              : 'label'
                      }
                    >
                      {getCategoryLabel(app.category)}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box fontSize="0.7em" color="label">
                      {app.file_size || 256} КБ
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    {safeBool(app.installed) ? (
                      <Button
                        compact
                        color="bad"
                        icon="trash"
                        disabled={downloading}
                        onClick={() =>
                          act('uninstall_app', { app_name: app.name })
                        }
                      >
                        Удалить
                      </Button>
                    ) : (
                      <Button
                        compact
                        color={isBlack ? 'caution' : 'good'}
                        icon="download"
                        disabled={downloading}
                        onClick={() =>
                          act('download_app', {
                            app_name: app.name,
                            wall: net_wall,
                          })
                        }
                      >
                        Скачать
                      </Button>
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}

          {/* Installed apps */}
          {installed_apps.length > 0 && (
            <Section title="Установленные">
              <Stack vertical>
                {installed_apps.map((app, idx) => (
                  <Stack.Item key={idx}>
                    <Flex align="center" justify="space-between">
                      <Flex.Item>
                        <Box fontSize="0.85em">
                          <Icon
                            name={
                              safeBool(app.is_blackwall)
                                ? 'skull-crossbones'
                                : 'cube'
                            }
                            mr={0.3}
                            color={
                              safeBool(app.is_blackwall) ? 'bad' : 'label'
                            }
                          />
                          <Box as="span" bold>
                            {app.name}
                          </Box>
                          <Box as="span" color="label" ml={0.5}>
                            — {app.desc}
                          </Box>
                        </Box>
                      </Flex.Item>
                      <Flex.Item>
                        <Button
                          compact
                          color="bad"
                          icon="trash"
                          disabled={downloading}
                          onClick={() =>
                            act('uninstall_app', { app_name: app.name })
                          }
                        />
                      </Flex.Item>
                    </Flex>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          )}
        </Box>
      </Flex.Item>
    </Flex>
  );
};

// ============================================
// COMMON COMPONENTS
// ============================================

type AppHeaderProps = {
  title: string;
  icon: string;
};

const AppHeader = (props: AppHeaderProps) => {
  const { act, data } = useBackend<IpcOsData>();

  const theme_color = safeStr(data.theme_color, '#6a6a6a');
  const os_name = safeStr(data.os_name, 'IPC-OS');

  return (
    <Box
      p={0.5}
      style={{
        background: hexToRgba(theme_color, 0.15),
        borderBottom: `1px solid ${hexToRgba(theme_color, 0.3)}`,
      }}
    >
      <Flex align="center" justify="space-between">
        <Flex.Item>
          <Flex align="center">
            <Flex.Item mr={1}>
              <Button
                compact
                icon="arrow-left"
                color="transparent"
                onClick={() => act('open_app', { app: 'desktop' })}
                tooltip="На рабочий стол"
              />
            </Flex.Item>
            <Flex.Item>
              <Box bold color={theme_color} fontSize="0.95em">
                <Icon name={props.icon} mr={0.5} />
                {props.title}
              </Box>
            </Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item>
          <Box fontSize="0.7em" color="label">
            {os_name}
          </Box>
        </Flex.Item>
      </Flex>
    </Box>
  );
};
