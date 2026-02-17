import React from 'react';
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
  // Remote access
  pending_access_request: boolean;
  requesting_user_name: string;
  has_remote_viewer: boolean;
  remote_viewer_name: string;
  is_remote_user: boolean;
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
            {current_app === 'net' && <NetApp />}
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

  const [password, setPassword] = React.useState('');
  const [error, setError] = React.useState('');

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

  return (
    <Flex direction="column" height="100%">
      {/* Top bar — title bar style */}
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

      {/* Desktop icons area */}
      <Flex.Item grow={1} style={{ overflowY: 'auto' }}>
        <Box p={1}>
          <Flex wrap="wrap">
            {/* System apps */}
            {SYSTEM_APPS.map((app) => (
              <Flex.Item key={app.id} m={0.5}>
                <DesktopIcon
                  name={app.name}
                  icon={app.faIcon}
                  color={theme_color}
                  badge={
                    app.id === 'antivirus' && virus_count > 0
                      ? virus_count
                      : undefined
                  }
                  badgeSevere={has_serious_viruses}
                  onClick={() => act('open_app', { app: app.id })}
                />
              </Flex.Item>
            ))}

            {/* Installed NET apps */}
            {installed_apps.map((app) => (
              <Flex.Item key={app.name} m={0.5}>
                <DesktopIcon
                  name={app.name}
                  icon={
                    safeBool(app.is_blackwall) ? 'skull-crossbones' : 'cube'
                  }
                  color={
                    safeBool(app.is_blackwall)
                      ? '#cc3333'
                      : hexToRgba(theme_color, 1)
                  }
                  small
                  onClick={() => {}}
                />
              </Flex.Item>
            ))}
          </Flex>
        </Box>
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
// DESKTOP ICON COMPONENT
// ============================================

type DesktopIconProps = {
  name: string;
  icon: string;
  color: string;
  badge?: number;
  badgeSevere?: boolean;
  small?: boolean;
  onClick: () => void;
};

const DesktopIcon = (props: DesktopIconProps) => {
  const size = props.small ? '70px' : '80px';
  const iconSize = props.small ? 1.8 : 2.2;
  return (
    <Box
      textAlign="center"
      style={{
        cursor: 'pointer',
        position: 'relative',
        width: size,
      }}
      onClick={props.onClick}
    >
      <Box
        py={1}
        style={{
          border: `1px solid ${hexToRgba(props.color, 0.3)}`,
          borderRadius: '4px',
          background: hexToRgba(props.color, 0.06),
        }}
      >
        <Icon
          name={props.icon}
          size={iconSize}
          color={props.color}
          style={{
            textShadow: `0 0 6px ${hexToRgba(props.color, 0.5)}`,
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
        fontSize={props.small ? '0.6em' : '0.7em'}
        mt={0.3}
        style={{
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          whiteSpace: 'nowrap',
        }}
      >
        {props.name}
      </Box>
    </Box>
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

const NetApp = () => {
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
