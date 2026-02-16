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
};

type InstalledApp = {
  name: string;
  desc: string;
  category: string;
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
  net_catalog: NetApp[];
  installed_apps: InstalledApp[];
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

function safeBool(val: boolean | null | undefined): boolean {
  return val === true;
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
            {current_app === 'netdoor' && <NetDoorApp />}
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

const DesktopScreen = () => {
  const { act, data } = useBackend<IpcOsData>();

  const os_name = safeStr(data.os_name, 'IPC-OS');
  const os_version = safeStr(data.os_version, '2.4.1');
  const theme_color = safeStr(data.theme_color, '#6a6a6a');
  const virus_count = safeNum(data.virus_count, 0);
  const has_serious_viruses = safeBool(data.has_serious_viruses);
  const installed_apps = safeArray(data.installed_apps);

  const apps = [
    {
      id: 'diagnostics',
      name: 'Самодиагностика',
      faIcon: 'heartbeat',
      desc: 'Сканирование систем',
    },
    {
      id: 'antivirus',
      name: 'Антивирус',
      faIcon: 'shield-alt',
      desc: 'Защита системы',
      badge: virus_count > 0 ? `${virus_count}` : undefined,
      badgeColor: has_serious_viruses ? 'bad' : 'average',
    },
    {
      id: 'netdoor',
      name: 'NET-door',
      faIcon: 'network-wired',
      desc: 'Каталог приложений',
    },
  ];

  return (
    <Flex direction="column" height="100%">
      {/* Top bar */}
      <Flex.Item>
        <Box
          p={0.5}
          style={{
            background: hexToRgba(theme_color, 0.15),
            borderBottom: `1px solid ${hexToRgba(theme_color, 0.3)}`,
          }}
        >
          <Flex justify="space-between" align="center">
            <Flex.Item>
              <Box bold color={theme_color} fontSize="0.85em" ml={1}>
                {os_name} v{os_version}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="power-off"
                color="bad"
                compact
                onClick={() => act('logout')}
                tooltip="Выйти из системы"
              />
            </Flex.Item>
          </Flex>
        </Box>
      </Flex.Item>

      {/* Desktop area */}
      <Flex.Item grow={1}>
        <Flex
          direction="column"
          align="center"
          justify="center"
          height="100%"
        >
          {/* OS Logo */}
          <Flex.Item mb={4}>
            <Box textAlign="center">
              <Box
                fontSize="3em"
                bold
                color={theme_color}
                style={{
                  textShadow: `0 0 30px ${hexToRgba(theme_color, 0.4)}`,
                  letterSpacing: '5px',
                }}
              >
                {os_name}
              </Box>
              <Box color="label" fontSize="0.8em" mt={0.5}>
                Integrated Positronic OS
              </Box>
            </Box>
          </Flex.Item>

          {/* App icons */}
          <Flex.Item>
            <Flex wrap="wrap" justify="center">
              {apps.map((app) => (
                <Flex.Item key={app.id} mx={2} mb={2}>
                  <Box
                    textAlign="center"
                    style={{ cursor: 'pointer', position: 'relative' }}
                    onClick={() => act('open_app', { app: app.id })}
                  >
                    <Box
                      p={1.5}
                      style={{
                        border: `1px solid ${hexToRgba(theme_color, 0.4)}`,
                        borderRadius: '6px',
                        background: hexToRgba(theme_color, 0.08),
                        width: '90px',
                        height: '70px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        transition: 'background 0.2s',
                      }}
                    >
                      <Icon
                        name={app.faIcon}
                        size={2.5}
                        color={theme_color}
                        style={{
                          textShadow: `0 0 8px ${hexToRgba(theme_color, 0.6)}`,
                        }}
                      />
                    </Box>
                    {'badge' in app && app.badge && (
                      <Box
                        style={{
                          position: 'absolute',
                          top: '-4px',
                          right: '-4px',
                          background:
                            app.badgeColor === 'bad' ? '#cc3333' : '#cc9933',
                          borderRadius: '50%',
                          width: '18px',
                          height: '18px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '0.7em',
                          fontWeight: 'bold',
                        }}
                      >
                        {app.badge}
                      </Box>
                    )}
                    <Box fontSize="0.8em" mt={0.5} bold>
                      {app.name}
                    </Box>
                    <Box fontSize="0.65em" color="label">
                      {app.desc}
                    </Box>
                  </Box>
                </Flex.Item>
              ))}
            </Flex>
          </Flex.Item>

          {/* Installed apps */}
          {installed_apps.length > 0 && (
            <Flex.Item mt={2}>
              <Box textAlign="center" color="label" fontSize="0.75em" mb={1}>
                Установленные приложения:
              </Box>
              <Flex wrap="wrap" justify="center">
                {installed_apps.map((app) => (
                  <Flex.Item key={app.name} mx={1}>
                    <Box
                      p={0.5}
                      px={1}
                      fontSize="0.75em"
                      style={{
                        border: `1px solid ${hexToRgba(theme_color, 0.2)}`,
                        borderRadius: '3px',
                        background: hexToRgba(theme_color, 0.05),
                      }}
                    >
                      {app.name}
                    </Box>
                  </Flex.Item>
                ))}
              </Flex>
            </Flex.Item>
          )}
        </Flex>
      </Flex.Item>

      {/* Bottom bar */}
      <Flex.Item>
        <Box
          p={0.3}
          textAlign="center"
          style={{
            background: hexToRgba(theme_color, 0.1),
            borderTop: `1px solid ${hexToRgba(theme_color, 0.2)}`,
          }}
        >
          <Box fontSize="0.7em" color="label">
            {virus_count > 0 ? (
              <Box as="span" color={has_serious_viruses ? 'bad' : 'average'}>
                Обнаружено угроз: {virus_count}
              </Box>
            ) : (
              <Box as="span" color="good">
                Система защищена
              </Box>
            )}
            {' | '}
            Установлено приложений: {installed_apps.length}
          </Box>
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
  const theme_color = safeStr(data.theme_color, '#6a6a6a');

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
// NET-DOOR APP
// ============================================

const NetDoorApp = () => {
  const { act, data } = useBackend<IpcOsData>();

  const network_connected = safeBool(data.network_connected);
  const net_catalog = safeArray(data.net_catalog);
  const installed_apps = safeArray(data.installed_apps);
  const theme_color = safeStr(data.theme_color, '#6a6a6a');

  return (
    <Flex direction="column" height="100%">
      <AppHeader title="NET-door" icon="network-wired" />

      <Flex.Item grow={1} style={{ overflowY: 'auto' }}>
        <Box p={1}>
          {/* Connection status */}
          <Box
            mb={2}
            p={1}
            textAlign="center"
            style={{
              border: `1px solid ${network_connected ? '#33cc33' : '#cc3333'}`,
              borderRadius: '4px',
              background: network_connected
                ? 'rgba(0,200,0,0.1)'
                : 'rgba(200,0,0,0.1)',
            }}
          >
            <Box
              bold
              color={network_connected ? 'good' : 'bad'}
              fontSize="1em"
            >
              {network_connected
                ? 'Подключено к сети'
                : 'Нет подключения к сети'}
            </Box>
            {!network_connected && (
              <Box fontSize="0.8em" color="label" mt={0.5}>
                Подключитесь к диагностическому столу или встаньте на тайл с
                сетевым кабелем.
              </Box>
            )}
          </Box>

          {/* App catalog */}
          <Section title="Каталог приложений">
            {!network_connected ? (
              <Box textAlign="center" color="label" p={2}>
                <Box bold mb={1}>
                  Каталог недоступен
                </Box>
                <Box fontSize="0.9em">
                  Подключитесь к сети для доступа к каталогу.
                </Box>
              </Box>
            ) : (
              <Table>
                <Table.Row header>
                  <Table.Cell width="25%">Приложение</Table.Cell>
                  <Table.Cell width="35%">Описание</Table.Cell>
                  <Table.Cell width="15%">Категория</Table.Cell>
                  <Table.Cell width="25%">Действие</Table.Cell>
                </Table.Row>
                {net_catalog.map((app, idx) => (
                  <Table.Row key={idx}>
                    <Table.Cell>
                      <Box bold fontSize="0.9em">
                        {app.name}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box fontSize="0.8em" color="label">
                        {app.desc}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box
                        fontSize="0.75em"
                        color={
                          app.category === 'diagnostic'
                            ? 'good'
                            : app.category === 'utility'
                              ? 'label'
                              : 'average'
                        }
                      >
                        {app.category === 'diagnostic'
                          ? 'Диагностика'
                          : app.category === 'utility'
                            ? 'Утилита'
                            : 'Прочее'}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      {app.installed ? (
                        <Button
                          compact
                          color="bad"
                          onClick={() =>
                            act('uninstall_app', { app_name: app.name })
                          }
                        >
                          Удалить
                        </Button>
                      ) : (
                        <Button
                          compact
                          color="good"
                          onClick={() =>
                            act('install_app', { app_name: app.name })
                          }
                        >
                          Установить
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>

          {/* Installed */}
          {installed_apps.length > 0 && (
            <Section title="Установленные приложения">
              <Stack vertical>
                {installed_apps.map((app, idx) => (
                  <Stack.Item key={idx}>
                    <Box
                      p={0.5}
                      style={{
                        borderLeft: `3px solid ${theme_color}`,
                        paddingLeft: '8px',
                      }}
                    >
                      <Box bold fontSize="0.9em">
                        {app.name}
                      </Box>
                      <Box fontSize="0.75em" color="label">
                        {app.desc}
                      </Box>
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
