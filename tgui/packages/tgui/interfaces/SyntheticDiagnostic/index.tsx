import '../../styles/interfaces/SyntheticDiagnostic.scss';

import React from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { useBackend, useLocalState } from '../../backend';
import { type BodyZone, BodyZoneSelector } from '../common/BodyZoneSelector';
import { Window } from '../../layouts';

// ============================================
// TYPES
// ============================================

type Component = {
  name: string;
  status: string;
  status_color: string;
  damage: number;
  details: string;
};

type Bodypart = {
  name: string;
  status: string;
  damage: number;
  max_damage: number;
  brute: number;
  burn: number;
  panel_status: string;
};

type SystemMessage = {
  type: string;
  message: string;
};

type Surgery = {
  name: string;
  desc: string;
  tool_rec: string;
};

type Zone = {
  id: string;
  name: string;
};

type OsVirus = {
  name: string;
  desc: string;
  severity: string;
  removable: boolean;
  index: number;
};

type OsApp = {
  name: string;
  desc: string;
  category: string;
};

type Implant = {
  name: string;
  location: string;
  status: string;
  status_color: string;
};

type PatientData = {
  name: string;
  type: string;
  id: string;
  status: string;
  status_color: string;
  integrity: number;
  integrity_max: number;
  integrity_percent: number;
  mechanical_damage: number;
  electrical_damage: number;
  system_damage: number;
  cooling_damage: number;
  mechanical_damage_percent: number;
  electrical_damage_percent: number;
  cpu_temperature?: number;
  cpu_temp_optimal_min?: number;
  cpu_temp_optimal_max?: number;
  cpu_temp_critical?: number;
  cpu_temp_status?: string;
  overclock_active?: boolean;
  overclock_speed_bonus?: number;
  chassis_brand?: string;
  chassis_visual_brand?: string;
  components: Component[];
  bodyparts: Bodypart[];
  implants: Implant[];
  system_messages: SystemMessage[];
  os_version?: string;
  os_manufacturer?: string;
  os_theme_color?: string;
  os_brand_key?: string;
  os_viruses?: OsVirus[];
  os_virus_count?: number;
  os_installed_apps?: OsApp[];
  os_logged_in?: boolean;
  os_has_password?: boolean;
  os_remote_active?: boolean;
  os_remote_viewer_name?: string;
  os_access_pending?: boolean;
};

type SyntheticDiagnosticData = {
  patient?: PatientData;
  error?: string;
  patient_name?: string;
  patient_species?: string;
  target_zone?: string;
  has_table: boolean;
  is_synthetic_table?: boolean;
  table_charging?: boolean;
  table_cooling?: boolean;
  table_network?: boolean;
  table_charge_rate?: number;
  table_cooling_rate?: number;
  surgeries?: Surgery[];
  zones?: Zone[];
};

// ============================================
// HELPERS
// ============================================

function getStatusColor(color: string): string {
  if (color === 'good') return 'good';
  if (color === 'average') return 'average';
  return 'bad';
}

// ============================================
// MAIN COMPONENT
// ============================================

export const SyntheticDiagnostic = () => {
  const { act, data } = useBackend<SyntheticDiagnosticData>();
  const { patient, error, patient_name, patient_species, has_table } = data;

  const [selectedTab, setSelectedTab] = useLocalState(
    'syntheticDiagnosticTab',
    0,
  );

  return (
    <Window
      width={680}
      height={750}
      title="Синтетический диагностический терминал"
      theme="synthetic_diagnostic"
    >
      <Window.Content scrollable>
        {/* No table */}
        {!has_table && (
          <Box p={2} mt={2}>
            <NoticeBox color="red" align="center">
              <Icon name="unlink" mr={1} />
              Диагностический стол не подключён
            </NoticeBox>
          </Box>
        )}

        {/* Error */}
        {has_table && error && (
          <Box p={2} mt={1}>
            <NoticeBox color="red" align="center">
              {error}
            </NoticeBox>
            {patient_name && (
              <Box textAlign="center" color="label" mt={1} fontSize="0.85em">
                Пациент: {patient_name} ({patient_species})
              </Box>
            )}
          </Box>
        )}

        {/* Patient detected */}
        {patient && (
          <>
            <Tabs>
              <Tabs.Tab
                icon="stethoscope"
                selected={selectedTab === 0}
                onClick={() => setSelectedTab(0)}
              >
                Диагностика
              </Tabs.Tab>
              <Tabs.Tab
                icon="microchip"
                selected={selectedTab === 1}
                onClick={() => setSelectedTab(1)}
              >
                ОС
              </Tabs.Tab>
            </Tabs>

            {selectedTab === 0 && <MainDiagnosticsView />}
            {selectedTab === 1 && <OsTab />}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

// ============================================
// MAIN DIAGNOSTICS VIEW (merged ops + diagnostics)
// ============================================

const MainDiagnosticsView = () => {
  const { act, data } = useBackend<SyntheticDiagnosticData>();
  const patient = data.patient!;
  const { target_zone, surgeries, zones } = data;

  return (
    <Stack vertical>
      {/* Patient header bar */}
      <Stack.Item>
        <Box
          p={0.5}
          style={{
            background: 'rgba(200, 30, 30, 0.08)',
            borderBottom: '1px solid rgba(200, 30, 30, 0.2)',
          }}
        >
          <Stack fill>
            <Stack.Item grow>
              <Box bold>
                {patient.name}
                <Box as="span" color="label" ml={1} fontSize="0.85em">
                  [{patient.id}]
                </Box>
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box
                bold
                color={getStatusColor(patient.status_color)}
                fontSize="0.9em"
              >
                {patient.status}
              </Box>
            </Stack.Item>
            {patient.chassis_brand && (
              <Stack.Item ml={1}>
                <Box color="label" fontSize="0.85em">
                  {patient.chassis_brand}
                </Box>
              </Stack.Item>
            )}
            {patient.overclock_active && (
              <Stack.Item ml={1}>
                <Box color="average" fontSize="0.85em" bold>
                  <Icon name="bolt" mr={0.5} />
                  OC +{patient.overclock_speed_bonus}%
                </Box>
              </Stack.Item>
            )}
          </Stack>
        </Box>
      </Stack.Item>

      {/* SPLIT LAYOUT: Left = Operations | Right = Vitals */}
      <Stack.Item>
        <Stack fill>
          {/* LEFT: Body zone + operations */}
          <Stack.Item basis="45%">
            <Section title="Операции">
              <Box textAlign="center" mb={1}>
                <BodyZoneSelector
                  theme="slimecore"
                  precise={false}
                  selectedZone={(target_zone as BodyZone) || null}
                  onClick={(zone: BodyZone) =>
                    zone !== target_zone &&
                    act('change_zone', { new_zone: zone })
                  }
                />
              </Box>

              {/* Zone buttons */}
              <Stack wrap justify="center" mb={1}>
                {zones &&
                  zones.map((zone) => (
                    <Stack.Item key={zone.id} m={0.2}>
                      <Button
                        compact
                        fontSize="0.8em"
                        selected={target_zone === zone.id}
                        onClick={() =>
                          act('change_zone', { new_zone: zone.id })
                        }
                      >
                        {zone.name}
                      </Button>
                    </Stack.Item>
                  ))}
              </Stack>

              {/* Available operations */}
              {!target_zone && (
                <Box
                  textAlign="center"
                  color="label"
                  fontSize="0.8em"
                  p={1}
                >
                  Выберите зону
                </Box>
              )}

              {target_zone && surgeries && surgeries.length > 0 && (
                <Stack vertical>
                  {surgeries.map((surgery, idx) => (
                    <Stack.Item key={idx}>
                      <Box
                        p={0.5}
                        style={{
                          borderLeft: '2px solid rgba(200, 30, 30, 0.5)',
                          background: 'rgba(200, 30, 30, 0.05)',
                        }}
                        mb={0.3}
                      >
                        <Box bold fontSize="0.85em" color="#cc6666">
                          {surgery.name}
                        </Box>
                        <Box fontSize="0.75em" color="label">
                          {surgery.desc}
                        </Box>
                        <Box
                          fontSize="0.7em"
                          italic
                          color="label"
                          mt={0.2}
                        >
                          Инструмент: {surgery.tool_rec}
                        </Box>
                      </Box>
                    </Stack.Item>
                  ))}
                </Stack>
              )}

              {target_zone && surgeries && surgeries.length === 0 && (
                <Box
                  textAlign="center"
                  color="label"
                  fontSize="0.8em"
                  p={1}
                >
                  Нет операций для данной зоны
                </Box>
              )}
            </Section>
          </Stack.Item>

          {/* RIGHT: Vitals + damage */}
          <Stack.Item grow>
            <Section title="Показатели">
              <LabeledList>
                <LabeledList.Item label="Целостность">
                  <ProgressBar
                    value={patient.integrity}
                    minValue={-100}
                    maxValue={patient.integrity_max}
                    ranges={{
                      good: [70, Infinity],
                      average: [30, 70],
                      bad: [-Infinity, 30],
                    }}
                  >
                    <AnimatedNumber
                      value={patient.integrity_percent}
                      format={(v) => `${Math.round(v)}%`}
                    />
                  </ProgressBar>
                </LabeledList.Item>

                {patient.cpu_temperature !== undefined && (
                  <LabeledList.Item label="CPU">
                    <ProgressBar
                      value={patient.cpu_temperature}
                      minValue={0}
                      maxValue={patient.cpu_temp_critical || 150}
                      ranges={{
                        good: [0, patient.cpu_temp_optimal_max || 70],
                        average: [patient.cpu_temp_optimal_max || 70, 90],
                        bad: [90, Infinity],
                      }}
                    >
                      <AnimatedNumber
                        value={patient.cpu_temperature}
                        format={(v) => `${Math.round(v)}°C`}
                      />
                    </ProgressBar>
                  </LabeledList.Item>
                )}

                <LabeledList.Item label="Механ.">
                  <ProgressBar
                    value={patient.mechanical_damage / 200}
                    ranges={{
                      good: [-Infinity, 0.1],
                      average: [0.1, 0.4],
                      bad: [0.4, Infinity],
                    }}
                  >
                    <AnimatedNumber value={patient.mechanical_damage} />
                  </ProgressBar>
                </LabeledList.Item>

                <LabeledList.Item label="Ожоги">
                  <ProgressBar
                    value={patient.electrical_damage / 200}
                    ranges={{
                      good: [-Infinity, 0.1],
                      average: [0.1, 0.4],
                      bad: [0.4, Infinity],
                    }}
                  >
                    <AnimatedNumber value={patient.electrical_damage} />
                  </ProgressBar>
                </LabeledList.Item>

                <LabeledList.Item label="Система">
                  <ProgressBar
                    value={patient.system_damage / 200}
                    ranges={{
                      good: [-Infinity, 0.1],
                      average: [0.1, 0.4],
                      bad: [0.4, Infinity],
                    }}
                  >
                    <AnimatedNumber value={patient.system_damage} />
                  </ProgressBar>
                </LabeledList.Item>

                <LabeledList.Item label="Нагрев">
                  <ProgressBar
                    value={patient.cooling_damage / 200}
                    ranges={{
                      good: [-Infinity, 0.1],
                      average: [0.1, 0.4],
                      bad: [0.4, Infinity],
                    }}
                  >
                    <AnimatedNumber value={patient.cooling_damage} />
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>

            {/* Table status */}
            {data.is_synthetic_table && (
              <Section title="Стол">
                <Stack>
                  <Stack.Item grow>
                    <Box fontSize="0.8em">
                      <Icon name="bolt" color="good" mr={0.5} />
                      +{data.table_charge_rate} u/t
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box fontSize="0.8em">
                      <Icon name="snowflake" color="good" mr={0.5} />
                      -{data.table_cooling_rate}°C/t
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box fontSize="0.8em">
                      <Icon name="network-wired" color="good" mr={0.5} />
                      NET
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Components */}
      <Stack.Item>
        <Section title="Компоненты">
          <Table>
            <Table.Row header>
              <Table.Cell>Модуль</Table.Cell>
              <Table.Cell>Статус</Table.Cell>
              <Table.Cell>Детали</Table.Cell>
            </Table.Row>
            {patient.components.map((comp, idx) => (
              <Table.Row key={idx}>
                <Table.Cell bold>{comp.name}</Table.Cell>
                <Table.Cell color={getStatusColor(comp.status_color)}>
                  {comp.status}
                </Table.Cell>
                <Table.Cell>
                  <Box fontSize="0.85em">{comp.details}</Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>

      {/* Limbs */}
      <Stack.Item>
        <Section title="Шасси">
          <Table>
            <Table.Row header>
              <Table.Cell>Часть</Table.Cell>
              <Table.Cell>Статус</Table.Cell>
              <Table.Cell>Панель</Table.Cell>
              <Table.Cell>Урон</Table.Cell>
              <Table.Cell>Механ.</Table.Cell>
              <Table.Cell>Ожоги</Table.Cell>
            </Table.Row>
            {patient.bodyparts.map((part, idx) => (
              <Table.Row key={idx}>
                <Table.Cell bold>{part.name}</Table.Cell>
                <Table.Cell
                  color={
                    part.status === 'Подключена' ||
                    part.status === 'Подключён'
                      ? 'good'
                      : 'bad'
                  }
                >
                  {part.status}
                </Table.Cell>
                <Table.Cell>
                  <Box
                    color={
                      part.panel_status === 'Закрыта'
                        ? 'good'
                        : part.panel_status === 'Открыта'
                          ? 'average'
                          : part.panel_status === 'Подготовлена'
                            ? 'label'
                            : 'bad'
                    }
                  >
                    {part.panel_status}
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  {part.max_damage > 0 ? (
                    <ProgressBar
                      value={part.damage}
                      minValue={0}
                      maxValue={part.max_damage}
                      ranges={{
                        good: [-Infinity, part.max_damage * 0.3],
                        average: [
                          part.max_damage * 0.3,
                          part.max_damage * 0.7,
                        ],
                        bad: [part.max_damage * 0.7, Infinity],
                      }}
                    >
                      {part.damage}/{part.max_damage}
                    </ProgressBar>
                  ) : (
                    '\u2014'
                  )}
                </Table.Cell>
                <Table.Cell>{part.brute || '\u2014'}</Table.Cell>
                <Table.Cell>{part.burn || '\u2014'}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>

      {/* Implants */}
      {patient.implants &&
        patient.implants.length > 0 &&
        patient.implants[0].name !== 'Нет установленных имплантов' && (
          <Stack.Item>
            <Section title="Импланты">
              <Table>
                <Table.Row header>
                  <Table.Cell>Имплант</Table.Cell>
                  <Table.Cell>Расположение</Table.Cell>
                  <Table.Cell>Статус</Table.Cell>
                </Table.Row>
                {patient.implants.map((imp, idx) => (
                  <Table.Row key={idx}>
                    <Table.Cell bold>{imp.name}</Table.Cell>
                    <Table.Cell>{imp.location}</Table.Cell>
                    <Table.Cell color={getStatusColor(imp.status_color)}>
                      {imp.status}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
        )}

      {/* System log */}
      <Stack.Item>
        <Section title="Системный журнал">
          <Stack vertical>
            {patient.system_messages.map((msg, idx) => (
              <Stack.Item key={idx}>
                <Box
                  p={0.3}
                  fontFamily="monospace"
                  fontSize="0.8em"
                  backgroundColor={
                    msg.type === 'critical'
                      ? 'rgba(200, 0, 0, 0.15)'
                      : msg.type === 'warning'
                        ? 'rgba(200, 150, 0, 0.1)'
                        : 'rgba(0, 150, 0, 0.05)'
                  }
                  color={
                    msg.type === 'critical'
                      ? 'bad'
                      : msg.type === 'warning'
                        ? 'average'
                        : 'good'
                  }
                  bold={msg.type === 'critical'}
                >
                  <Icon
                    name={
                      msg.type === 'critical'
                        ? 'exclamation-triangle'
                        : msg.type === 'warning'
                          ? 'exclamation-circle'
                          : 'check-circle'
                    }
                    mr={0.5}
                  />
                  {msg.message}
                </Box>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>

      {/* Reference */}
      <Stack.Item>
        <Section title="Справка">
          <Stack>
            <Stack.Item grow basis="33%">
              <Box
                p={0.5}
                fontSize="0.75em"
                style={{ borderLeft: '2px solid rgba(40, 80, 200, 0.5)' }}
              >
                <Box bold mb={0.3}>
                  <Icon name="microchip" mr={0.5} />
                  Грудь/Голова
                </Box>
                <Box color="label">1. Отвёртка</Box>
                <Box color="label">2. Мультитул</Box>
                <Box color="label">3. Орган/Мультитул</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow basis="33%">
              <Box
                p={0.5}
                fontSize="0.75em"
                style={{ borderLeft: '2px solid rgba(80, 150, 40, 0.5)' }}
              >
                <Box bold mb={0.3}>
                  <Icon name="wrench" mr={0.5} />
                  Руки/Ноги
                </Box>
                <Box color="label">1. Отвёртка</Box>
                <Box color="label">2. Сварка/Кабель</Box>
                <Box color="label">3. Отвёртка</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow basis="33%">
              <Box
                p={0.5}
                fontSize="0.75em"
                style={{ borderLeft: '2px solid rgba(200, 40, 40, 0.5)' }}
              >
                <Box bold mb={0.3}>
                  <Icon name="unlink" mr={0.5} />
                  Демонтаж
                </Box>
                <Box color="label">1. Мультитул</Box>
                <Box color="label">2. Гаечный ключ</Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>

        {/* Dark Industries footer */}
        <Box
          textAlign="center"
          mt={1}
          py={0.3}
          style={{
            borderTop: '1px solid rgba(200, 30, 30, 0.15)',
          }}
        >
          <Box
            fontSize="0.55em"
            style={{
              color: '#444',
              letterSpacing: '3px',
            }}
          >
            DARK INDUSTRIES
          </Box>
        </Box>
      </Stack.Item>
    </Stack>
  );
};

// ============================================
// OS TAB
// ============================================

const OsTab = () => {
  const { act, data } = useBackend<SyntheticDiagnosticData>();
  const patient = data.patient!;

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="Операционная система">
          <LabeledList>
            <LabeledList.Item label="ОС">
              <Box bold color={patient.os_theme_color || '#cc6666'}>
                {patient.os_version || 'IPC-OS v2.4.1'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Платформа">
              {patient.os_manufacturer || 'Generic Systems'}
            </LabeledList.Item>
            <LabeledList.Item label="Статус">
              <Box
                bold
                color={
                  (patient.os_virus_count || 0) > 0 ? 'bad' : 'good'
                }
              >
                {(patient.os_virus_count || 0) > 0 ? (
                  <>
                    <Icon name="virus" mr={0.5} />
                    ЗАРАЖЕНА ({patient.os_virus_count})
                  </>
                ) : (
                  <>
                    <Icon name="shield-alt" mr={0.5} />
                    Стабильна
                  </>
                )}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Пароль">
              <Box color={patient.os_has_password ? 'good' : 'average'}>
                {patient.os_has_password ? 'Установлен' : 'Не установлен'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Сессия">
              <Box color={patient.os_logged_in ? 'good' : 'label'}>
                {patient.os_logged_in ? 'Активна' : 'Неактивна'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Viruses */}
      <Stack.Item>
        <Section
          title="Угрозы"
          buttons={
            <Box
              color={
                (patient.os_viruses?.length || 0) > 0 ? 'bad' : 'good'
              }
              fontSize="0.85em"
            >
              {patient.os_viruses?.length || 0} обнаружено
            </Box>
          }
        >
          {(!patient.os_viruses || patient.os_viruses.length === 0) && (
            <Box
              textAlign="center"
              p={0.5}
              color="good"
              fontSize="0.85em"
            >
              <Icon name="check-circle" mr={0.5} />
              Угроз не обнаружено.
            </Box>
          )}
          {patient.os_viruses && patient.os_viruses.length > 0 && (
            <Table>
              <Table.Row header>
                <Table.Cell>Вирус</Table.Cell>
                <Table.Cell>Опасность</Table.Cell>
                <Table.Cell>Тип</Table.Cell>
                <Table.Cell>Действие</Table.Cell>
              </Table.Row>
              {patient.os_viruses.map((virus, idx) => (
                <Table.Row key={idx}>
                  <Table.Cell>
                    <Box
                      bold
                      color={
                        virus.severity === 'high'
                          ? 'bad'
                          : virus.severity === 'medium'
                            ? 'average'
                            : 'label'
                      }
                    >
                      {virus.name}
                    </Box>
                    <Box fontSize="0.75em" color="label">
                      {virus.desc}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box
                      bold
                      color={
                        virus.severity === 'high'
                          ? 'bad'
                          : virus.severity === 'medium'
                            ? 'average'
                            : 'good'
                      }
                    >
                      {virus.severity === 'high'
                        ? 'HIGH'
                        : virus.severity === 'medium'
                          ? 'MED'
                          : 'LOW'}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box
                      fontSize="0.8em"
                      color={virus.removable ? 'label' : 'bad'}
                    >
                      {virus.removable ? 'Стандартный' : 'Руткит'}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      compact
                      color="bad"
                      icon="trash"
                      onClick={() =>
                        act('remove_virus', {
                          virus_index: virus.index,
                        })
                      }
                    >
                      Удалить
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Stack.Item>

      {/* Installed apps */}
      <Stack.Item>
        <Section
          title="Приложения"
          buttons={
            <Box color="label" fontSize="0.8em">
              {patient.os_installed_apps?.length || 0}
            </Box>
          }
        >
          {(!patient.os_installed_apps ||
            patient.os_installed_apps.length === 0) && (
            <Box textAlign="center" p={0.5} color="label" fontSize="0.85em">
              Дополнительных приложений нет.
            </Box>
          )}
          {patient.os_installed_apps &&
            patient.os_installed_apps.length > 0 && (
              <Table>
                <Table.Row header>
                  <Table.Cell>Приложение</Table.Cell>
                  <Table.Cell>Описание</Table.Cell>
                  <Table.Cell>Категория</Table.Cell>
                </Table.Row>
                {patient.os_installed_apps.map((app, idx) => (
                  <Table.Row key={idx}>
                    <Table.Cell bold>{app.name}</Table.Cell>
                    <Table.Cell>
                      <Box fontSize="0.85em">{app.desc}</Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box fontSize="0.8em" color="label">
                        {app.category === 'diagnostic'
                          ? 'Диагн.'
                          : app.category === 'utility'
                            ? 'Утил.'
                            : 'Другое'}
                      </Box>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
        </Section>
      </Stack.Item>

      {/* Remote OS Access */}
      <Stack.Item>
        <RemoteAccessSection />
      </Stack.Item>

      {/* System logs */}
      <Stack.Item>
        <Section title="Логи">
          <Box
            fontFamily="monospace"
            fontSize="0.8em"
            p={0.5}
            backgroundColor="rgba(0, 0, 0, 0.4)"
            style={{
              maxHeight: '150px',
              overflowY: 'auto',
            }}
          >
            {patient.components.map((comp, idx) => (
              <Box key={idx} color={getStatusColor(comp.status_color)}>
                [
                {comp.status_color === 'good'
                  ? 'OK'
                  : comp.status_color === 'average'
                    ? 'WARN'
                    : 'ERR'}
                ] {comp.name}: {comp.details}
              </Box>
            ))}
            {patient.system_messages.map((msg, idx) => (
              <Box
                key={`msg-${idx}`}
                color={
                  msg.type === 'critical'
                    ? 'bad'
                    : msg.type === 'warning'
                      ? 'average'
                      : 'good'
                }
                mt={idx === 0 ? 0.3 : 0}
              >
                [
                {msg.type === 'critical'
                  ? 'CRIT'
                  : msg.type === 'warning'
                    ? 'WARN'
                    : 'INFO'}
                ] {msg.message}
              </Box>
            ))}
          </Box>
        </Section>
      </Stack.Item>

      {/* Dark Industries footer */}
      <Stack.Item>
        <Box
          textAlign="center"
          mt={1}
          py={0.3}
          style={{
            borderTop: '1px solid rgba(200, 30, 30, 0.15)',
          }}
        >
          <Box
            fontSize="0.55em"
            style={{
              color: '#444',
              letterSpacing: '3px',
            }}
          >
            DARK INDUSTRIES
          </Box>
        </Box>
      </Stack.Item>
    </Stack>
  );
};

// ============================================
// REMOTE ACCESS SECTION (in OS tab)
// ============================================

const RemoteAccessSection = () => {
  const { act, data } = useBackend<SyntheticDiagnosticData>();
  const patient = data.patient!;
  const [osPassword, setOsPassword] = React.useState('');

  const remoteActive = !!patient.os_remote_active;
  const accessPending = !!patient.os_access_pending;

  return (
    <Section
      title="Удалённый доступ к ОС"
      buttons={
        <Box
          color={remoteActive ? 'good' : accessPending ? 'average' : 'label'}
          fontSize="0.8em"
        >
          {remoteActive ? (
            <>
              <Icon name="link" mr={0.5} />
              Подключено
            </>
          ) : accessPending ? (
            <>
              <Icon name="clock" mr={0.5} />
              Ожидание
            </>
          ) : (
            <>
              <Icon name="unlink" mr={0.5} />
              Не подключено
            </>
          )}
        </Box>
      }
    >
      {/* Active connection */}
      {remoteActive && (
        <Box mb={1}>
          <Box
            p={0.5}
            style={{
              border: '1px solid rgba(50, 200, 50, 0.3)',
              borderRadius: '3px',
              background: 'rgba(0, 200, 0, 0.08)',
            }}
          >
            <Stack justify="space-between" align="center">
              <Stack.Item>
                <Box fontSize="0.85em" color="good">
                  <Icon name="desktop" mr={0.5} />
                  Удалённый доступ активен:{' '}
                  <Box as="span" bold>
                    {patient.os_remote_viewer_name}
                  </Box>
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  compact
                  color="bad"
                  icon="times"
                  onClick={() => act('disconnect_os_remote')}
                >
                  Отключить
                </Button>
              </Stack.Item>
            </Stack>
          </Box>
        </Box>
      )}

      {/* Pending request */}
      {!remoteActive && accessPending && (
        <Box
          p={0.5}
          mb={1}
          style={{
            border: '1px solid rgba(200, 150, 0, 0.3)',
            borderRadius: '3px',
            background: 'rgba(200, 150, 0, 0.08)',
          }}
        >
          <Box fontSize="0.85em" color="average" textAlign="center">
            <Icon name="hourglass-half" mr={0.5} />
            Запрос отправлен. Ожидание подтверждения от пациента...
          </Box>
        </Box>
      )}

      {/* Access methods */}
      {!remoteActive && !accessPending && (
        <Stack vertical>
          {/* Method 1: Request */}
          <Stack.Item>
            <Box
              p={0.5}
              mb={0.5}
              style={{
                borderLeft: '2px solid rgba(40, 80, 200, 0.5)',
                background: 'rgba(40, 80, 200, 0.05)',
              }}
            >
              <Box bold fontSize="0.85em" mb={0.3}>
                <Icon name="paper-plane" mr={0.5} />
                Запрос доступа
              </Box>
              <Box fontSize="0.75em" color="label" mb={0.5}>
                Отправить запрос пациенту. Требуется подтверждение.
              </Box>
              <Button
                compact
                color="good"
                icon="paper-plane"
                onClick={() => act('request_os_access')}
              >
                Отправить запрос
              </Button>
            </Box>
          </Stack.Item>

          {/* Method 2: Password */}
          {!!patient.os_has_password && (
            <Stack.Item>
              <Box
                p={0.5}
                style={{
                  borderLeft: '2px solid rgba(200, 80, 40, 0.5)',
                  background: 'rgba(200, 80, 40, 0.05)',
                }}
              >
                <Box bold fontSize="0.85em" mb={0.3}>
                  <Icon name="key" mr={0.5} />
                  Вход по паролю
                </Box>
                <Box fontSize="0.75em" color="label" mb={0.5}>
                  Ввести пароль ОС пациента. Пациент получит уведомление.
                </Box>
                <Stack align="center">
                  <Stack.Item grow>
                    <Input
                      fluid
                      placeholder="Пароль ОС..."
                      value={osPassword}
                      onChange={(val: string) => setOsPassword(val)}
                      onEnter={() => {
                        if (osPassword) {
                          act('login_os_password', { password: osPassword });
                          setOsPassword('');
                        }
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      compact
                      color="caution"
                      icon="sign-in-alt"
                      disabled={!osPassword}
                      onClick={() => {
                        act('login_os_password', { password: osPassword });
                        setOsPassword('');
                      }}
                    >
                      Войти
                    </Button>
                  </Stack.Item>
                </Stack>
              </Box>
            </Stack.Item>
          )}

          {!patient.os_has_password && (
            <Stack.Item>
              <Box fontSize="0.8em" color="label" p={0.5}>
                <Icon name="info-circle" mr={0.5} />
                Пароль ОС не установлен — вход по паролю недоступен.
              </Box>
            </Stack.Item>
          )}
        </Stack>
      )}
    </Section>
  );
};
