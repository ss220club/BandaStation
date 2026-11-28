import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CpuThermalStatus, NetworkHeader } from './Common';
import type { DisplayTelemetry } from './displayFeedback';
import { NeuralCatalog } from './NeuralCatalog';
import { NeuralNavigation } from './NeuralNavigation';
import { NeuralShell } from './NeuralOS';
import { NeuralOverview } from './NeuralOverview';
import { NeuralProfiles, type WorkProfile } from './NeuralProfiles';
import { NeuralTelemetry, type TelemetryHistory } from './NeuralTelemetry';
import { NeuralWorkspace } from './NeuralWorkspace';
import { safeRatio } from './resourceMath';

type Project = {
  name: string;
  display_name?: string;
  description: string;
  category: string;
  ram_required: number;
  available: BooleanLike;
  assigned_cpu: number;
  research_progress: number;
  research_cost: number;
  research_requirements: string;
  running: BooleanLike;
  can_be_run: BooleanLike;
  memory_priority: number;
  stop_reason?: string;
};
type Ability = {
  name: string;
  project_name: string;
  uses: number;
  max_uses: number;
  progress: number;
  cost: number;
  assigned_cpu: number;
};
type Data = {
  display_telemetry?: DisplayTelemetry;
  intrusion?: { source: string; elapsed: number } | null;
  subcontroller_connected: BooleanLike;
  subcontroller_areas: number;
  events: { id: number; time: string; message: string; severity: string }[];
  telemetry_recording: BooleanLike;
  telemetry: TelemetryHistory;
  current_cpu: number;
  nominal_cpu?: number;
  profiles: WorkProfile[];
  profile_report: string[];
  used_cpu: number;
  current_ram: number;
  used_ram: number;
  integrity: number;
  location_name: string;
  location_coords: string;
  temperature: number;
  temperature_limit: number;
  core_status: string;
  core_status_label?: string;
  identity: string;
  network_name: string;
  contribute_spare_cpu: BooleanLike;
  categories: string[];
  available_projects: Project[];
  completed_projects: Project[];
  chargeable_abilities: Ability[];
};

export function AiDashboard() {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState('overview');
  const [selectedName, setSelectedName] = useState('');
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('All');
  const projects =
    (tab === 'research' ? data.available_projects : data.completed_projects) ||
    [];
  const filtered = projects.filter(
    (p) =>
      (category === 'All' || p.category === category) &&
      `${p.display_name || p.name} ${p.name} ${p.description}`
        .toLowerCase()
        .includes(search.toLowerCase()),
  );
  const selectedProject =
    filtered.find((project) => project.name === selectedName) || filtered[0];
  const freeCpu = Math.max(0, 1 - data.used_cpu);
  const freeRam = Math.max(0, data.current_ram - data.used_ram);
  return (
    <Window title="Нейронная панель ИИ" width={1000} height={780}>
      <Window.Content fitted className="AiOS">
        <NeuralShell
          application="Нейронная панель"
          telemetry={data.display_telemetry}
        >
          <NetworkHeader
            title={data.identity || 'Нейронная среда'}
            signal={
              data.intrusion ||
              (data.temperature_limit > 0 &&
                data.temperature >= data.temperature_limit)
                ? 'alert'
                : data.core_status !== 'Online' ||
                    data.integrity < 40 ||
                    !data.current_cpu ||
                    (data.nominal_cpu || 0) > data.current_cpu + 0.001
                  ? 'degraded'
                  : 'nominal'
            }
            status={
              data.intrusion
                ? 'ПОСТОРОННЕЕ ПОДКЛЮЧЕНИЕ К СТОЙКЕ ЗАКОНОВ'
                : data.temperature_limit > 0 &&
                    data.temperature >= data.temperature_limit
                  ? 'ПРЕВЫШЕН ПРЕДЕЛ ТЕМПЕРАТУРЫ'
                  : data.core_status !== 'Online'
                    ? 'НЕТ СВЯЗИ С ЯДРОМ'
                    : data.integrity < 40
                      ? 'ЦЕЛОСТНОСТЬ СНИЖЕНА'
                      : !data.current_cpu
                        ? 'CPU НЕ ВЫДЕЛЕН'
                        : (data.nominal_cpu || 0) > data.current_cpu + 0.001
                          ? 'ТЕПЛОВОЕ ОГРАНИЧЕНИЕ CPU'
                          : 'ЯДРО В СЕТИ'
            }
            subtitle={`${data.network_name || 'Нейронная сеть'} · ${data.core_status_label || 'Неизвестно'} · ${data.location_name || 'Местоположение неизвестно'}`}
          />
          <CpuThermalStatus
            nominal={data.nominal_cpu}
            effective={data.current_cpu}
          />
          <Button icon="scale-balanced" onClick={() => act('show_laws')} mb={1}>
            Мои законы
          </Button>
          {!!data.intrusion && (
            <NoticeBox danger>
              {' '}
              БЕЗОПАСНОСТЬ / Постороннее подключение к стойке законов ·
              источник: {data.intrusion.source} · обнаружено{' '}
              {data.intrusion.elapsed}с назад. Попросите экипаж нажать ПКМ
              пустой рукой по вашему ядру или исходной стойке законов и
              отключить устройство (10 секунд). Переход в другое ядро также
              разрывает соединение.{' '}
            </NoticeBox>
          )}
          {!data.current_cpu && (
            <NoticeBox>
              {' '}
              CPU не выделен. Попросите оператора с доступом выделить
              вычислительные ресурсы.{' '}
            </NoticeBox>
          )}
          <NeuralWorkspace
            focus={tab === 'research' || tab === 'programs'}
            navigation={
              <NeuralNavigation
                selected={tab}
                onSelect={setTab}
                items={[
                  { id: 'overview', label: 'Обзор', icon: 'gauge-high' },
                  {
                    id: 'research',
                    label: 'Исследования',
                    icon: 'flask',
                    count: data.available_projects?.length || 0,
                  },
                  {
                    id: 'programs',
                    label: 'Программы',
                    icon: 'microchip',
                    count: data.completed_projects?.length || 0,
                  },
                  {
                    id: 'abilities',
                    label: 'Способности',
                    icon: 'bolt',
                    count: data.chargeable_abilities?.length || 0,
                  },
                  {
                    id: 'profiles',
                    label: 'Профили',
                    icon: 'sliders',
                  },
                  {
                    id: 'telemetry',
                    label: 'Телеметрия',
                    icon: 'chart-line',
                  },
                  {
                    id: 'events',
                    label: 'Журнал',
                    icon: 'list',
                    count: data.events?.length || 0,
                  },
                ]}
              />
            }
            instruments={
              <>
                <div className="AiOS__railLabel">ТЕЛЕМЕТРИЯ ЯДРА</div>
                <div className="AiOS__vitals">
                  <div className="AiOS__vital">
                    <Box className="AiOS__eyebrow">ВЫЧИСЛЕНИЯ</Box>
                    <div className="AiOS__vitalValue">
                      {(data.current_cpu || 0).toFixed(2)} <span>ТГц</span>
                    </div>
                    <ProgressBar value={data.used_cpu || 0} color="blue">
                      {((data.used_cpu || 0) * 100).toFixed(0)}% выделено{' '}
                    </ProgressBar>
                  </div>
                  <div className="AiOS__vital">
                    <Box className="AiOS__eyebrow">ПАМЯТЬ</Box>
                    <div className="AiOS__vitalValue">
                      {data.used_ram || 0} / {data.current_ram || 0}{' '}
                      <span>ТБ</span>
                    </div>
                    <ProgressBar
                      value={safeRatio(data.used_ram, data.current_ram)}
                      color="teal"
                    >
                      {freeRam} ТБ свободно{' '}
                    </ProgressBar>
                  </div>
                  <div className="AiOS__vital">
                    <Box className="AiOS__eyebrow">ТЕМПЕРАТУРА</Box>
                    <div
                      className="AiOS__vitalValue"
                      style={{
                        color:
                          data.temperature_limit > 0 &&
                          data.temperature >= data.temperature_limit
                            ? '#ffada1'
                            : undefined,
                      }}
                    >
                      {data.temperature?.toFixed(1) || '—'} <span>К</span>
                    </div>
                    <Box color="label">
                      {data.temperature_limit?.toFixed(1) || '—'} К — предел{' '}
                    </Box>
                  </div>
                  <div className="AiOS__vital">
                    <Box className="AiOS__eyebrow">ЦЕЛОСТНОСТЬ</Box>
                    <div className="AiOS__vitalValue">
                      {Math.max(
                        0,
                        Math.min(100, (data.integrity + 100) / 2),
                      ).toFixed(0)}{' '}
                      <span>%</span>
                    </div>
                    <Box color="label">
                      {data.core_status_label || 'Состояние ядра неизвестно'}
                    </Box>
                  </div>
                </div>
                <Section fitted className="AiOS__diagnostics">
                  <Collapsible title="Диагностика связи" icon="network-wired">
                    <dl className="AiOS__diagnosticRows">
                      <div>
                        <dt>Расположение ядра</dt>
                        <dd>
                          {data.location_name || 'Местоположение неизвестно'} ·{' '}
                          {data.location_coords || '—'}
                        </dd>
                      </div>
                      <div>
                        <dt>Нейронная сеть</dt>
                        <dd>{data.network_name || 'Нет нейронной сети'}</dd>
                      </div>
                      <div>
                        <dt>Координатор ИИ</dt>
                        <dd>
                          {data.subcontroller_connected
                            ? `Подключён · ${data.subcontroller_areas} зон разрешено этим контроллером`
                            : 'Нет ответа — совместные команды для помещений недоступны'}
                        </dd>
                      </div>
                      <div>
                        <dt>Журнал наблюдений</dt>
                        <dd>
                          {data.telemetry_recording
                            ? 'Запись местной телеметрии'
                            : 'Телеметрия недоступна'}
                        </dd>
                      </div>
                    </dl>
                  </Collapsible>
                </Section>
              </>
            }
          >
            {tab === 'overview' ? (
              <NeuralOverview data={data} onNavigate={setTab} />
            ) : tab === 'profiles' ? (
              <NeuralProfiles
                profiles={data.profiles || []}
                report={data.profile_report || []}
                act={act}
              />
            ) : tab === 'telemetry' ? (
              <NeuralTelemetry history={data.telemetry} />
            ) : tab === 'events' ? (
              <Section title="Журнал местных наблюдений">
                <Box color={data.telemetry_recording ? 'good' : 'label'} mb={1}>
                  {data.telemetry_recording
                    ? 'Запись местной телеметрии'
                    : 'Телеметрия недоступна'}
                </Box>
                <Box color="label" mb={2}>
                  {' '}
                  Последние 64 наблюдения, сначала новые. Время соответствует
                  обнаружению, а не моменту отказа. Отсутствие ответа не
                  раскрывает причину. События вне вашей сети или во время
                  перерывов наблюдения неизвестны.{' '}
                </Box>
                {!data.events?.length && (
                  <NoticeBox info> Местных наблюдений пока нет. </NoticeBox>
                )}
                {(data.events || []).map((event) => (
                  <div
                    key={event.id}
                    className={`AiOS__logEntry${event.severity === 'warning' ? ' AiOS__logEntry--warning' : ''}`}
                  >
                    <time>{event.time}</time>
                    <span>{event.message}</span>
                  </div>
                ))}
              </Section>
            ) : tab === 'abilities' ? (
              <>
                {!data.chargeable_abilities?.length && (
                  <NoticeBox info>
                    {' '}
                    Исследуйте активную способность, чтобы открыть действия с
                    восстанавливаемыми зарядами.{' '}
                  </NoticeBox>
                )}
                {(data.chargeable_abilities || []).map((ability) => (
                  <Section key={ability.project_name} title={ability.name}>
                    <Box mb={1}>
                      {' '}
                      Заряды: {ability.uses} / {ability.max_uses}
                    </Box>
                    <ProgressBar
                      value={safeRatio(ability.progress, ability.cost)}
                      color="blue"
                    >
                      {ability.progress.toFixed(0)} / {ability.cost} CPU·с{' '}
                    </ProgressBar>
                    <Box mt={1}>
                      {' '}
                      CPU на восстановление зарядов{' '}
                      <NumberInput
                        value={(ability.assigned_cpu || 0) * 100}
                        unit="%"
                        minValue={0}
                        maxValue={(freeCpu + (ability.assigned_cpu || 0)) * 100}
                        disabled={
                          !data.current_cpu || ability.uses >= ability.max_uses
                        }
                        onChange={(value) =>
                          act('allocate_recharge_cpu', {
                            project_name: ability.project_name,
                            amount: value / 100,
                          })
                        }
                      />
                    </Box>
                  </Section>
                ))}
              </>
            ) : (
              <NeuralCatalog
                tools={
                  <Section
                    className="AiOS__workspaceTools"
                    title={
                      tab === 'research'
                        ? 'Рабочая область исследований'
                        : 'Установленные программы'
                    }
                    buttons={
                      tab === 'research' && (
                        <Button
                          icon="flask"
                          selected={!!data.contribute_spare_cpu}
                          tooltip="Передавать свободные вычислительные ресурсы ИИ на исследования станции."
                          onClick={() => act('toggle_contribute_cpu')}
                        >
                          {' '}
                          Свободный CPU на исследования:{' '}
                          {data.contribute_spare_cpu ? 'вкл.' : 'выкл.'}
                        </Button>
                      )
                    }
                  >
                    <div className="AiOS__catalogBudget">
                      <span>
                        CPU свободно:{' '}
                        <strong>
                          {data.current_cpu > 0
                            ? (freeCpu * 100).toFixed(0)
                            : '0'}
                          %
                        </strong>{' '}
                        / {(data.current_cpu || 0).toFixed(2)} ТГц
                      </span>
                      <span>
                        Память свободна: <strong>{freeRam} ТБ</strong> /{' '}
                        {data.current_ram || 0} ТБ
                      </span>
                    </div>
                    <Input
                      fluid
                      value={search}
                      onChange={setSearch}
                      placeholder="Поиск по названиям и описаниям…"
                    />
                    <Box mt={1} className="AiOS__filters">
                      {['All', ...(data.categories || [])].map((item) => (
                        <Button
                          key={item === 'All' ? 'Все' : item}
                          selected={category === item}
                          onClick={() => setCategory(item)}
                        >
                          {item === 'All' ? 'Все' : item}
                        </Button>
                      ))}
                    </Box>
                  </Section>
                }
                key={tab}
                filterKey={`${category}:${search}`}
                title={tab === 'research' ? 'ИССЛЕДОВАНИЯ' : 'ПРОГРАММЫ'}
                selected={selectedProject?.name}
                onSelect={setSelectedName}
                items={filtered.map((project) => ({
                  name: project.name,
                  label: project.display_name || project.name,
                  category: project.category,
                  description: project.description,
                  memory: project.ram_required,
                  cpu: project.assigned_cpu,
                  tone:
                    project.running || project.assigned_cpu
                      ? 'active'
                      : tab === 'research' && !project.available
                        ? 'locked'
                        : 'ready',
                  status: project.running
                    ? `ВЫПОЛНЯЕТСЯ${project.ram_required > 0 ? ` · ${['ФОНОВЫЙ', 'ОБЫЧНЫЙ', 'ВАЖНЫЙ'][project.memory_priority - 1]}` : ''}`
                    : project.assigned_cpu
                      ? 'ИССЛЕДУЕТСЯ'
                      : tab === 'programs'
                        ? 'УСТАНОВЛЕНО'
                        : project.available
                          ? 'ДОСТУПНО'
                          : 'НЕДОСТУПНО',
                  progress:
                    tab === 'research'
                      ? safeRatio(
                          project.research_progress,
                          project.research_cost,
                        )
                      : undefined,
                }))}
              >
                {[selectedProject]
                  .filter((project): project is Project => !!project)
                  .map((project) => (
                    <Section
                      key={project.name}
                      title={project.display_name || project.name}
                    >
                      <Box
                        className="AiOS__projectStatus"
                        color={
                          project.running || project.assigned_cpu
                            ? 'good'
                            : 'label'
                        }
                      >
                        {project.running
                          ? '● ВЫПОЛНЯЕТСЯ'
                          : project.assigned_cpu
                            ? '● ИССЛЕДУЕТСЯ'
                            : tab === 'programs'
                              ? '○ УСТАНОВЛЕНО'
                              : project.available
                                ? '○ ДОСТУПНО ДЛЯ ИССЛЕДОВАНИЯ'
                                : '○ НУЖНЫ ПРЕДШЕСТВУЮЩИЕ ИССЛЕДОВАНИЯ'}
                        {' · '}
                        {project.category}
                      </Box>
                      <Box mb={2} className="AiOS__projectDescription">
                        {project.description}
                      </Box>
                      <Box color="label" mb={1}>
                        {' '}
                        Требуется памяти: {project.ram_required} ТБ · Свободно:{' '}
                        {freeRam} ТБ{' '}
                      </Box>
                      {tab === 'research' ? (
                        <>
                          <ProgressBar
                            value={safeRatio(
                              project.research_progress,
                              project.research_cost,
                            )}
                            color={project.available ? 'blue' : 'grey'}
                          >
                            {project.research_progress.toFixed(0)} /{' '}
                            {project.research_cost} CPU·с{' '}
                          </ProgressBar>
                          <Box mt={0.5} mb={0.5} color="label">
                            {project.assigned_cpu > 0 && data.current_cpu > 0
                              ? `До завершения примерно: ${Math.ceil(Math.max(0, project.research_cost - project.research_progress) / (project.assigned_cpu * data.current_cpu))} с`
                              : 'Ожидание выделения CPU'}
                          </Box>
                          {!project.available ? (
                            <NoticeBox mt={1}>
                              {' '}
                              Требуется: {project.research_requirements}
                            </NoticeBox>
                          ) : (
                            <Stack mt={1} align="center" wrap>
                              <Stack.Item>Доля CPU</Stack.Item>
                              <Stack.Item>
                                <NumberInput
                                  unit="%"
                                  value={project.assigned_cpu * 100}
                                  minValue={0}
                                  maxValue={
                                    (freeCpu + project.assigned_cpu) * 100
                                  }
                                  disabled={!data.current_cpu}
                                  onChange={(value) =>
                                    act('allocate_cpu', {
                                      project_name: project.name,
                                      amount: value / 100,
                                    })
                                  }
                                />
                              </Stack.Item>
                              <Stack.Item>
                                <Button
                                  disabled={!data.current_cpu}
                                  onClick={() =>
                                    act('max_cpu', {
                                      project_name: project.name,
                                    })
                                  }
                                >
                                  {' '}
                                  Выделить остаток{' '}
                                </Button>
                              </Stack.Item>
                              <Stack.Item>
                                <Button
                                  disabled={!project.assigned_cpu}
                                  onClick={() =>
                                    act('allocate_cpu', {
                                      project_name: project.name,
                                      amount: 0,
                                    })
                                  }
                                >
                                  {' '}
                                  Приостановить{' '}
                                </Button>
                              </Stack.Item>
                            </Stack>
                          )}
                        </>
                      ) : project.can_be_run ? (
                        <>
                          {!!project.stop_reason && (
                            <NoticeBox>
                              {project.stop_reason}. После освобождения памяти
                              запустите программу вручную.
                            </NoticeBox>
                          )}
                          {project.ram_required > 0 && (
                            <Box mb={2}>
                              <Box mb={0.5}>
                                Приоритет сохранения при нехватке RAM
                              </Box>
                              <div className="AiOS__filters">
                                {['Фоновый', 'Обычный', 'Важный'].map(
                                  (label, index) => (
                                    <Button
                                      key={label}
                                      selected={
                                        project.memory_priority === index + 1
                                      }
                                      onClick={() =>
                                        act('set_memory_priority', {
                                          project_name: project.name,
                                          priority: index + 1,
                                        })
                                      }
                                    >
                                      {label}
                                    </Button>
                                  ),
                                )}
                              </div>
                              <Box color="label" mt={0.5}>
                                Сначала останавливаются фоновые программы, затем
                                обычные и важные. При равном приоритете — раньше
                                запущенные.
                              </Box>
                            </Box>
                          )}
                          {!project.running && project.ram_required > 0 && (
                            <Box color="label" mb={1}>
                              После запуска останется:{' '}
                              {Math.max(0, freeRam - project.ram_required)} ТБ
                              {freeRam < project.ram_required
                                ? ` · не хватает ${project.ram_required - freeRam} ТБ`
                                : ''}
                            </Box>
                          )}
                          <Button
                            icon={project.running ? 'stop' : 'play'}
                            color={project.running ? 'average' : 'good'}
                            disabled={
                              !project.running && freeRam < project.ram_required
                            }
                            tooltip={
                              !project.running && freeRam < project.ram_required
                                ? 'Недостаточно свободной памяти'
                                : undefined
                            }
                            onClick={() =>
                              act(
                                project.running
                                  ? 'stop_project'
                                  : 'run_project',
                                {
                                  project_name: project.name,
                                },
                              )
                            }
                          >
                            {project.running ? 'Остановить' : 'Запустить'}
                          </Button>
                        </>
                      ) : (
                        <Box color="good">Улучшение установлено</Box>
                      )}
                    </Section>
                  ))}
              </NeuralCatalog>
            )}
          </NeuralWorkspace>
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}
