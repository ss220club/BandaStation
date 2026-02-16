import '../../styles/interfaces/SyntheticDiagnostic.scss';

import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
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
// HELPER FUNCTIONS
// ============================================

function getCpuTempColor(status?: string): string {
  switch (status) {
    case 'critical':
      return 'bad';
    case 'hot':
      return 'bad';
    case 'warm':
      return 'average';
    case 'cold':
      return 'blue';
    default:
      return 'good';
  }
}

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
      width={520}
      height={700}
      title="Synthetic Diagnostic Terminal"
      theme="synthetic_diagnostic"
    >
      <Window.Content scrollable>
        {/* No table connected */}
        {!has_table && (
          <Section fill>
            <NoticeBox color="yellow" align="center">
              Diagnostic table not connected
            </NoticeBox>
          </Section>
        )}

        {/* Error state */}
        {has_table && error && (
          <Section fill>
            <NoticeBox color="red" align="center">
              {error}
            </NoticeBox>
            {patient_name && (
              <Box textAlign="center" color="label" mt={1} fontSize="0.9em">
                Patient: {patient_name} ({patient_species})
              </Box>
            )}
          </Section>
        )}

        {/* Patient detected */}
        {patient && (
          <>
            <Tabs>
              <Tabs.Tab
                icon="heartbeat"
                selected={selectedTab === 0}
                onClick={() => setSelectedTab(0)}
              >
                Diagnostics
              </Tabs.Tab>
              <Tabs.Tab
                icon="wrench"
                selected={selectedTab === 1}
                onClick={() => setSelectedTab(1)}
              >
                Operations
              </Tabs.Tab>
              <Tabs.Tab
                icon="microchip"
                selected={selectedTab === 2}
                onClick={() => setSelectedTab(2)}
              >
                OS
              </Tabs.Tab>
            </Tabs>

            {selectedTab === 0 && <DiagnosticsTab />}
            {selectedTab === 1 && <OperationsTab />}
            {selectedTab === 2 && <OsTab />}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

// ============================================
// DIAGNOSTICS TAB
// ============================================

const DiagnosticsTab = () => {
  const { data } = useBackend<SyntheticDiagnosticData>();
  const patient = data.patient!;

  return (
    <Stack vertical>
      {/* Patient Info + Vital Signs */}
      <Stack.Item>
        <Section title="Patient">
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Name">
                  <Box bold>{patient.name}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="ID">{patient.id}</LabeledList.Item>
                <LabeledList.Item
                  label="Status"
                  color={getStatusColor(patient.status_color)}
                >
                  {patient.status}
                </LabeledList.Item>
                {patient.chassis_brand && (
                  <LabeledList.Item label="Chassis">
                    {patient.chassis_brand}
                    {patient.chassis_visual_brand &&
                      patient.chassis_visual_brand !== patient.chassis_brand && (
                        <Box as="span" color="label" ml={1}>
                          ({patient.chassis_visual_brand})
                        </Box>
                      )}
                  </LabeledList.Item>
                )}
                {patient.overclock_active && (
                  <LabeledList.Item label="Overclock" color="average">
                    <Icon name="bolt" mr={0.5} />
                    Active (+{patient.overclock_speed_bonus}%)
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Vital Gauges */}
      <Stack.Item>
        <Section title="Vitals">
          <LabeledList>
            <LabeledList.Item label="Integrity">
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
              <LabeledList.Item
                label="CPU Temp"
                color={getCpuTempColor(patient.cpu_temp_status)}
              >
                <ProgressBar
                  value={patient.cpu_temperature}
                  minValue={0}
                  maxValue={patient.cpu_temp_critical || 150}
                  ranges={{
                    good: [0, patient.cpu_temp_optimal_max || 70],
                    average: [
                      patient.cpu_temp_optimal_max || 70,
                      90,
                    ],
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

            <LabeledList.Item label="Mechanical">
              <ProgressBar
                value={patient.mechanical_damage / 200}
                color="bad"
              >
                <AnimatedNumber value={patient.mechanical_damage} />
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Electrical">
              <ProgressBar
                value={patient.electrical_damage / 200}
                color="bad"
              >
                <AnimatedNumber value={patient.electrical_damage} />
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="System">
              <ProgressBar value={patient.system_damage / 200} color="bad">
                <AnimatedNumber value={patient.system_damage} />
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Overheat">
              <ProgressBar value={patient.cooling_damage / 200} color="bad">
                <AnimatedNumber value={patient.cooling_damage} />
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Components */}
      <Stack.Item>
        <Section title="Components">
          <Table>
            <Table.Row header>
              <Table.Cell>Component</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              <Table.Cell>Details</Table.Cell>
            </Table.Row>
            {patient.components.map((comp, idx) => (
              <Table.Row key={idx}>
                <Table.Cell bold>{comp.name}</Table.Cell>
                <Table.Cell color={getStatusColor(comp.status_color)}>
                  {comp.status}
                </Table.Cell>
                <Table.Cell>
                  <Box fontSize="0.9em">{comp.details}</Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>

      {/* Limbs */}
      <Stack.Item>
        <Section title="Limbs">
          <Table>
            <Table.Row header>
              <Table.Cell>Limb</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              <Table.Cell>Panel</Table.Cell>
              <Table.Cell>Damage</Table.Cell>
              <Table.Cell>Brute</Table.Cell>
              <Table.Cell>Burn</Table.Cell>
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
                    '—'
                  )}
                </Table.Cell>
                <Table.Cell>{part.brute}</Table.Cell>
                <Table.Cell>{part.burn}</Table.Cell>
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
            <Section title="Implants">
              <Table>
                <Table.Row header>
                  <Table.Cell>Implant</Table.Cell>
                  <Table.Cell>Location</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
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

      {/* System Messages */}
      <Stack.Item>
        <Section title="System Log">
          <Stack vertical>
            {patient.system_messages.map((msg, idx) => (
              <Stack.Item key={idx}>
                <Box
                  p={0.5}
                  fontFamily="monospace"
                  fontSize="0.85em"
                  backgroundColor={
                    msg.type === 'critical'
                      ? 'rgba(200, 0, 0, 0.15)'
                      : msg.type === 'warning'
                        ? 'rgba(200, 150, 0, 0.15)'
                        : 'rgba(0, 150, 0, 0.1)'
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
                    mr={1}
                  />
                  {msg.message}
                </Box>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>

      {/* Diagnostic Table Status */}
      {data.is_synthetic_table && (
        <Stack.Item>
          <Section title="Diagnostic Table">
            <LabeledList>
              <LabeledList.Item label="Type" color="good">
                <Icon name="table" mr={0.5} />
                Synthetic Diagnostic Table
              </LabeledList.Item>
              <LabeledList.Item label="Charging" color="good">
                <Icon name="bolt" mr={0.5} />
                Active ({data.table_charge_rate} units/tick)
              </LabeledList.Item>
              <LabeledList.Item label="Cooling" color="good">
                <Icon name="snowflake" mr={0.5} />
                Active (-{data.table_cooling_rate}°C/tick)
              </LabeledList.Item>
              <LabeledList.Item label="Network" color="good">
                <Icon name="network-wired" mr={0.5} />
                Connected
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

// ============================================
// OPERATIONS TAB
// ============================================

const OperationsTab = () => {
  const { act, data } = useBackend<SyntheticDiagnosticData>();
  const { target_zone, surgeries, zones } = data;

  return (
    <Stack vertical>
      {/* Body Zone Selector + Surgery State */}
      <Stack.Item>
        <Section title="Target Zone">
          <Stack>
            <Stack.Item>
              <BodyZoneSelector
                theme="slimecore"
                precise={false}
                selectedZone={(target_zone as BodyZone) || null}
                onClick={(zone: BodyZone) =>
                  zone !== target_zone &&
                  act('change_zone', { new_zone: zone })
                }
              />
            </Stack.Item>
            <Stack.Item grow ml={1}>
              <Stack vertical>
                <Stack.Item>
                  <Box bold fontSize="1em" mb={0.5}>
                    {target_zone && zones
                      ? zones.find((z) => z.id === target_zone)?.name ||
                        'Select zone'
                      : 'Select a body zone'}
                  </Box>
                </Stack.Item>
                {/* Zone buttons as fallback */}
                <Stack.Item>
                  <Stack wrap>
                    {zones &&
                      zones.map((zone) => (
                        <Stack.Item key={zone.id} m={0.25}>
                          <Button
                            compact
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
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Available Operations */}
      <Stack.Item>
        <Section
          title="Available Operations"
          buttons={
            surgeries &&
            surgeries.length > 0 && (
              <Box color="good" fontSize="0.85em">
                {surgeries.length} available
              </Box>
            )
          }
        >
          {!target_zone && (
            <NoticeBox color="yellow" align="center">
              Select a body zone to view available operations
            </NoticeBox>
          )}

          {target_zone && surgeries && surgeries.length > 0 && (
            <Stack vertical>
              {surgeries.map((surgery, idx) => (
                <Stack.Item key={idx}>
                  <Button fluid color="transparent">
                    <Stack fill>
                      <Stack.Item grow>
                        <Box bold color="good">
                          {surgery.name}
                        </Box>
                        <Box fontSize="0.85em" color="label">
                          {surgery.desc}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box italic color="label" fontSize="0.85em">
                          {surgery.tool_rec}
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          )}

          {target_zone && surgeries && surgeries.length === 0 && (
            <NoticeBox color="green" align="center">
              No operations available for this zone
            </NoticeBox>
          )}
        </Section>
      </Stack.Item>

      {/* Surgery Instructions */}
      <Stack.Item>
        <Section title="Reference">
          <Stack vertical>
            <Stack.Item>
              <Box p={0.5} backgroundColor="rgba(40, 80, 160, 0.15)">
                <Box bold mb={0.5} fontSize="0.9em">
                  <Icon name="microchip" mr={0.5} />
                  Chest / Head (organ access):
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  1. Open panel (Screwdriver)
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  2. Prepare electronics (Multitool)
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  3. Install/Extract organs (Organ or Multitool)
                </Box>
              </Box>
            </Stack.Item>

            <Stack.Item>
              <Box p={0.5} backgroundColor="rgba(80, 120, 40, 0.15)">
                <Box bold mb={0.5} fontSize="0.9em">
                  <Icon name="wrench" mr={0.5} />
                  Arms / Legs (repair):
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  1. Open panel (Screwdriver)
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  2. Weld brute (Welder) or fix burn (Cable)
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  3. Close panel (Screwdriver)
                </Box>
              </Box>
            </Stack.Item>

            <Stack.Item>
              <Box p={0.5} backgroundColor="rgba(160, 40, 40, 0.15)">
                <Box bold mb={0.5} fontSize="0.9em">
                  <Icon name="unlink" mr={0.5} />
                  Limb removal:
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  1. Disconnect electronics (Multitool)
                </Box>
                <Box ml={1.5} fontSize="0.85em" color="label">
                  2. Detach limb (Wrench)
                </Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
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
      {/* OS Info */}
      <Stack.Item>
        <Section title="Operating System">
          <LabeledList>
            <LabeledList.Item label="OS">
              <Box bold color={patient.os_theme_color || 'good'}>
                {patient.os_version || 'IPC-OS v2.4.1'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Platform">
              {patient.os_manufacturer || 'Generic Systems'}
            </LabeledList.Item>
            <LabeledList.Item label="Status">
              <Box
                bold
                color={
                  (patient.os_virus_count || 0) > 0 ? 'bad' : 'good'
                }
              >
                {(patient.os_virus_count || 0) > 0 ? (
                  <>
                    <Icon name="virus" mr={0.5} />
                    INFECTED ({patient.os_virus_count} threats)
                  </>
                ) : (
                  <>
                    <Icon name="shield-alt" mr={0.5} />
                    System stable
                  </>
                )}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Password">
              <Box color={patient.os_has_password ? 'good' : 'average'}>
                {patient.os_has_password ? 'Set' : 'Not set'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Session">
              <Box color={patient.os_logged_in ? 'good' : 'label'}>
                {patient.os_logged_in ? 'Active' : 'Inactive'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Viruses */}
      <Stack.Item>
        <Section
          title="Threats"
          buttons={
            <Box
              color={
                (patient.os_viruses?.length || 0) > 0 ? 'bad' : 'good'
              }
              fontSize="0.85em"
            >
              {patient.os_viruses?.length || 0} detected
            </Box>
          }
        >
          {(!patient.os_viruses || patient.os_viruses.length === 0) && (
            <NoticeBox color="green" align="center">
              No viruses detected. System clean.
            </NoticeBox>
          )}
          {patient.os_viruses && patient.os_viruses.length > 0 && (
            <Table>
              <Table.Row header>
                <Table.Cell>Virus</Table.Cell>
                <Table.Cell>Severity</Table.Cell>
                <Table.Cell>Type</Table.Cell>
                <Table.Cell>Action</Table.Cell>
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
                    <Box fontSize="0.8em" color="label">
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
                      fontSize="0.85em"
                      color={virus.removable ? 'label' : 'bad'}
                    >
                      {virus.removable ? 'Standard' : 'Rootkit'}
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
                      Remove
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Stack.Item>

      {/* Installed Apps */}
      <Stack.Item>
        <Section
          title="Installed Apps"
          buttons={
            <Box color="label" fontSize="0.85em">
              {patient.os_installed_apps?.length || 0} apps
            </Box>
          }
        >
          {(!patient.os_installed_apps ||
            patient.os_installed_apps.length === 0) && (
            <Box textAlign="center" p={1} color="label" fontSize="0.9em">
              No additional apps installed.
            </Box>
          )}
          {patient.os_installed_apps &&
            patient.os_installed_apps.length > 0 && (
              <Table>
                <Table.Row header>
                  <Table.Cell>App</Table.Cell>
                  <Table.Cell>Description</Table.Cell>
                  <Table.Cell>Category</Table.Cell>
                </Table.Row>
                {patient.os_installed_apps.map((app, idx) => (
                  <Table.Row key={idx}>
                    <Table.Cell bold>{app.name}</Table.Cell>
                    <Table.Cell>
                      <Box fontSize="0.85em">{app.desc}</Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box fontSize="0.85em" color="label">
                        {app.category === 'diagnostic'
                          ? 'Diagnostic'
                          : app.category === 'utility'
                            ? 'Utility'
                            : 'Other'}
                      </Box>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
        </Section>
      </Stack.Item>

      {/* System Logs */}
      <Stack.Item>
        <Section title="System Logs">
          <Box
            fontFamily="monospace"
            fontSize="0.85em"
            p={0.5}
            backgroundColor="rgba(0, 0, 0, 0.3)"
            style={{
              maxHeight: '180px',
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
                mt={idx === 0 ? 0.5 : 0}
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
    </Stack>
  );
};
