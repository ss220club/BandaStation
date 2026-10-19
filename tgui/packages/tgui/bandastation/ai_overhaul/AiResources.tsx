import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  CpuThermalStatus,
  NetworkHeader,
  NetworkLogin,
  TaskSignal,
} from './Common';
import { NeuralNavigation } from './NeuralNavigation';
import { NeuralShell } from './NeuralOS';
import { NeuralWorkspace } from './NeuralWorkspace';
import { ResourcePolicy } from './ResourcePolicy';
import { resourceAvailability, safeRatio } from './resourceMath';
import { SubnetPanel } from './SubnetPanel';

type Ai = {
  name: string;
  ref: string;
  assigned_cpu: number;
  assigned_ram: number;
};
type Data = {
  can_withdraw: BooleanLike;
  subnets?: { ref: string; name: string; quota: number; cpu: number }[];
  job_weights: Record<string, number>;
  job_weight_total: number;
  background_job_count: number;
  research_rate: number;
  mining_rate: number;
  research_hosts: {
    ref: string;
    name: string;
    area: string;
    subnet: string;
    research_cpu: number;
    science_cpu: number;
    mining_cpu: number;
    enabled: BooleanLike;
    mining_enabled: BooleanLike;
    mining_balance: number;
    mining_ready: BooleanLike;
    science_enabled: BooleanLike;
    science_points: number;
    science_pending: number;
    ready: BooleanLike;
    points: number;
    pending: number;
    disk: {
      cpu: number;
      progress: number;
      cost: number;
      reward: number;
      enabled: BooleanLike;
      ready: BooleanLike;
    } | null;
  }[];
  recovery_cost: number;
  recovery_cpu: number;
  recoveries: {
    cpu: number;
    ref: string;
    name: string;
    area: string;
    progress: number;
    enabled: BooleanLike;
    ready: BooleanLike;
    battery: number;
  }[];
  total_cpu: number;
  nominal_cpu?: number;
  total_ram: number;
  total_assigned_cpu: number;
  total_assigned_ram: number;
  authenticated: BooleanLike;
  username: string;
  has_access: BooleanLike;
  human_only: BooleanLike;
  policy_revision: number;
  can_manage: BooleanLike;
  can_change_policy: BooleanLike;
  ais: Ai[];
  networks: { ref: string; name: string }[];
  selected_network: string | null;
};

export function AiResources() {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState('ais');
  const [search, setSearch] = useState('');
  const ais = data.ais || [];
  const hosts = (data.research_hosts || []).filter((host) =>
    `${host.name} ${host.area} ${host.subnet}`
      .toLowerCase()
      .includes(search.toLowerCase()),
  );
  const free = resourceAvailability(
    data.total_cpu || 0,
    data.total_assigned_cpu || 0,
    data.total_ram || 0,
    data.total_assigned_ram || 0,
  );
  const locked = !data.can_manage;
  return (
    <Window title="Распределение ресурсов ИИ" width={940} height={760}>
      <Window.Content fitted className="AiOS">
        <NeuralShell
          application="Ресурсы сети"
          telemetry={
            data.authenticated
              ? {
                  cpuReserved:
                    data.total_cpu > 0 ? data.total_assigned_cpu : undefined,
                  cpuScope: 'network',
                  memoryUsed: data.total_assigned_ram,
                  memoryCapacity: data.total_ram,
                }
              : undefined
          }
        >
          <NetworkHeader
            signal={
              data.authenticated && !data.selected_network
                ? 'degraded'
                : 'nominal'
            }
            status={
              !data.authenticated
                ? 'ТРЕБУЕТСЯ АВТОРИЗАЦИЯ'
                : !data.selected_network
                  ? 'ВЫБЕРИТЕ НЕЙРОННУЮ СЕТЬ'
                  : 'СВЯЗЬ С РЕСУРСНОЙ СЕТЬЮ'
            }
            title={
              data.networks?.find(
                (network) => network.ref === data.selected_network,
              )?.name || 'Управление нейросетью'
            }
            subtitle="Ресурсы / топология / фоновые задачи"
          />
          {!data.authenticated ? (
            <NetworkLogin
              username={data.username}
              hasAccess={data.has_access}
              onLogin={() => act('log_in')}
            />
          ) : (
            <NeuralWorkspace
              navigation={
                <NeuralNavigation
                  selected={tab}
                  onSelect={setTab}
                  items={[
                    {
                      id: 'ais',
                      label: 'ИИ',
                      icon: 'brain',
                      count: ais.length,
                    },
                    {
                      id: 'subnets',
                      label: 'Сеть',
                      icon: 'network-wired',
                      count: data.subnets?.length || 0,
                    },
                    { id: 'jobs', label: 'Задачи', icon: 'microchip' },
                    {
                      id: 'recovery',
                      label: 'Восстановление',
                      icon: 'heart-pulse',
                      count: data.recoveries?.length || 0,
                    },
                  ]}
                />
              }
              instruments={
                <>
                  <Section title="Физическая сеть">
                    {(data.networks || []).map((network) => (
                      <Button
                        key={network.ref}
                        selected={data.selected_network === network.ref}
                        onClick={() =>
                          act('select_network', { network: network.ref })
                        }
                      >
                        {network.name}
                      </Button>
                    ))}
                    {!data.networks?.length && (
                      <Box color="label">Подключённого оборудования нет.</Box>
                    )}
                  </Section>
                  <Section
                    title="Ресурсы сети"
                    buttons={
                      <Button
                        icon="sign-out-alt"
                        onClick={() => act('log_out')}
                      >
                        {' '}
                        Выйти{' '}
                      </Button>
                    }
                  >
                    <Stack vertical>
                      <Stack.Item grow>
                        <Box color="label" mb={0.5}>
                          {' '}
                          Свободный CPU{' '}
                        </Box>
                        <ProgressBar value={free.cpuFraction} color="blue">
                          {free.cpuThz.toFixed(2)} /{' '}
                          {(data.total_cpu || 0).toFixed(2)} ТГц{' '}
                        </ProgressBar>
                        <CpuThermalStatus
                          nominal={data.nominal_cpu}
                          effective={data.total_cpu}
                        />
                      </Stack.Item>
                      <Stack.Item grow>
                        <Box color="label" mb={0.5}>
                          {' '}
                          Свободная RAM{' '}
                        </Box>
                        <ProgressBar
                          value={safeRatio(free.ram, data.total_ram)}
                          color="teal"
                        >
                          {free.ram} / {data.total_ram || 0} ТБ{' '}
                        </ProgressBar>
                      </Stack.Item>
                    </Stack>
                    <Collapsible title="При отказе оборудования">
                      <Box color="label">
                        {' '}
                        Доли CPU распределяют общий ресурс работающего
                        оборудования. При отказе серверов вычисления
                        замедляются, а лишние резервы RAM отзываются.{' '}
                      </Box>
                    </Collapsible>
                  </Section>
                  <dl className="AiOS__railFacts">
                    <div>
                      <dt title="Свободно в этой сети до резервирования подсетями">
                        {' '}
                        Свободный CPU сегмента{' '}
                      </dt>
                      <dd>{(data.recovery_cpu || 0).toFixed(2)} ТГц</dd>
                    </div>
                    <div>
                      <dt>Готовые задачи</dt>
                      <dd>{data.background_job_count || 0}</dd>
                    </div>
                    <div>
                      <dt>Кабельные сегменты</dt>
                      <dd>{data.subnets?.length || 0}</dd>
                    </div>
                  </dl>
                  <Button
                    fluid
                    color="transparent"
                    icon="user-shield"
                    onClick={() => setTab('subnets')}
                  >
                    {data.human_only
                      ? 'Только операторы-люди'
                      : 'Доступ разрешён синтетикам'}
                  </Button>
                </>
              }
            >
              {tab === 'subnets' && (
                <ResourcePolicy
                  network={data.selected_network}
                  humanOnly={data.human_only}
                  revision={data.policy_revision}
                  canChange={data.can_change_policy}
                  onChange={(human_only, expected_human_only) =>
                    act('set_human_policy', {
                      network: data.selected_network,
                      human_only,
                      expected_human_only,
                      expected_revision: data.policy_revision,
                    })
                  }
                />
              )}
              {!data.total_cpu && (
                <NoticeBox>
                  {' '}
                  Рабочих процессоров нет. Проверьте питание, охлаждение и
                  установленные серверные модули.{' '}
                </NoticeBox>
              )}
              {tab === 'recovery' && !!data.recoveries?.length && (
                <Section title="Восстановление нейроструктуры">
                  <Box color="label" mb={1}>
                    {(data.recovery_cpu || 0).toFixed(2)} ТГц свободного CPU
                    распределяются по квотам подсетей и приоритетам задач.
                    Ресурсы действующих ИИ имеют преимущество. Рабочее ядро
                    сохраняет заряд накопителя даже при приостановленном
                    восстановлении.{' '}
                  </Box>
                  {data.recoveries.map((recovery) => (
                    <Section
                      key={recovery.ref}
                      title={`${recovery.name} · ${recovery.area}`}
                    >
                      <ProgressBar
                        value={safeRatio(recovery.progress, data.recovery_cost)}
                        color="teal"
                      >
                        {recovery.progress.toFixed(1)} / {data.recovery_cost}{' '}
                        CPU·с{' '}
                      </ProgressBar>
                      <Box
                        mt={1}
                        mb={1}
                        color={recovery.ready ? 'label' : 'average'}
                      >
                        {!recovery.ready
                          ? 'Ядро недоступно — используется батарея накопителя'
                          : !recovery.enabled
                            ? 'Приостановлено — накопитель подключён'
                            : !recovery.cpu
                              ? 'Ожидание CPU — проверьте квоту подсети и резервы ИИ'
                              : 'Восстановление нейроструктуры'}
                        {' · '}
                        {recovery.battery} с хранения без питания осталось{' '}
                      </Box>
                      <Button
                        icon={recovery.enabled ? 'pause' : 'play'}
                        disabled={locked}
                        onClick={() =>
                          act('toggle_recovery', { core: recovery.ref })
                        }
                      >
                        {recovery.enabled
                          ? 'Приостановить'
                          : 'Начать восстановление'}
                      </Button>
                    </Section>
                  ))}
                </Section>
              )}
              {tab === 'recovery' && !data.recoveries?.length && (
                <NoticeBox info>
                  {' '}
                  В этой сети нет нейронных накопителей, ожидающих
                  восстановления.{' '}
                </NoticeBox>
              )}
              {locked && (
                <NoticeBox>
                  {' '}
                  У этого оператора нет доступа к управлению ресурсами.{' '}
                </NoticeBox>
              )}
              {tab === 'subnets' && (
                <SubnetPanel
                  key={data.selected_network}
                  subnets={data.subnets || []}
                  available={data.recovery_cpu || 0}
                  locked={locked}
                  activityLocked={locked}
                  onActivity={(subnet, category, action, amount) =>
                    act(action, {
                      network: data.selected_network,
                      subnet,
                      category,
                      amount,
                      expected_revision: data.policy_revision,
                    })
                  }
                  onQuota={(subnet, amount) =>
                    act('set_subnet_quota', {
                      network: data.selected_network,
                      subnet,
                      amount,
                    })
                  }
                  onRename={(subnet, name) =>
                    act('rename_subnet', {
                      network: data.selected_network,
                      subnet,
                      name,
                    })
                  }
                />
              )}
              {tab === 'jobs' && (
                <Section title="Серверные задачи">
                  <Box color="label" mb={1}>
                    {' '}
                    Исследования инфраструктуры ИИ и общие исследования станции
                    не требуют размещённого в ядре ИИ. Используется только
                    свободный CPU, пропорционально приоритетам задач (1–10).
                    Каждая готовая задача получает вес своей категории;
                    недоступные задачи не расходуют ресурсы. Выделения
                    действующим ИИ имеют преимущество.{' '}
                  </Box>
                  <Box mb={1}>
                    {data.background_job_count || 0} активных задач ·{' '}
                    {(data.recovery_cpu || 0).toFixed(2)} ТГц свободно до
                    резервирования подсетями{' '}
                  </Box>
                  <LabeledList>
                    {Object.entries({
                      recovery: 'Восстановление ИИ',
                      research: 'Исследования ИИ',
                      archive: 'Архивы',
                      science: 'Исследования станции',
                      mining: 'Майнинг',
                    }).map(([category, label]) => (
                      <LabeledList.Item key={category} label={label}>
                        <NumberInput
                          value={data.job_weights?.[category] || 1}
                          minValue={1}
                          maxValue={10}
                          step={1}
                          disabled={locked}
                          onChange={(amount) =>
                            act('set_job_weight', {
                              network: data.selected_network,
                              category,
                              amount,
                            })
                          }
                        />
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                  <Input
                    fluid
                    placeholder="Поиск сервера, помещения или подсети…"
                    value={search}
                    onChange={setSearch}
                    mb={1}
                  />
                  {!hosts.length && (
                    <NoticeBox>
                      Нет серверов, подходящих под этот фильтр.
                    </NoticeBox>
                  )}
                  {hosts.map((host) => (
                    <Section
                      key={host.ref}
                      title={`${host.name} · ${host.area} · ${host.subnet}`}
                    >
                      <TaskSignal
                        enabled={!!host.enabled}
                        ready={!!host.ready}
                        cpu={host.research_cpu}
                      />
                      <Box color={host.ready ? 'label' : 'average'} mb={1}>
                        {!host.enabled
                          ? 'Приостановлено'
                          : !host.ready
                            ? 'Сервер недоступен — проверьте питание, охлаждение и процессоры'
                            : !host.research_cpu
                              ? 'Ожидание CPU — проверьте квоту подсети и резервы ИИ'
                              : `Вычисления · ${(host.research_cpu * data.research_rate).toFixed(2)} очков исследований ИИ/с`}
                        {' · '}
                        {host.points.toFixed(1)} очков получено{' '}
                      </Box>
                      <ProgressBar
                        value={host.pending || 0}
                        color="teal"
                        mb={1}
                      >
                        {' '}
                        До следующего очка:{' '}
                        {Math.floor((host.pending || 0) * 100)}%
                      </ProgressBar>
                      <Button
                        icon={host.enabled ? 'pause' : 'play'}
                        disabled={locked}
                        onClick={() =>
                          act('toggle_background_research', {
                            host: host.ref,
                          })
                        }
                      >
                        {host.enabled
                          ? 'Приостановить исследования ИИ'
                          : 'Начать исследования ИИ'}
                      </Button>
                      <Box mt={2}>
                        <Box bold mb={1}>
                          {' '}
                          Помощь исследованиям{' '}
                        </Box>
                        <Box color="label" mb={1}>
                          {' '}
                          Создаёт очки общих исследований для научной сети
                          станции. Использует отдельную долю свободного CPU.{' '}
                          {' · '}
                          {host.science_points || 0} очков получено {' · '}
                          {!host.science_enabled
                            ? 'Приостановлено'
                            : !host.ready
                              ? 'Сервер недоступен'
                              : !host.science_cpu
                                ? 'Ожидание CPU'
                                : 'Вычисления'}
                        </Box>
                        <ProgressBar
                          value={host.science_pending || 0}
                          color="blue"
                          mb={1}
                        >
                          {' '}
                          До следующего очка общих исследований:{' '}
                          {Math.floor((host.science_pending || 0) * 100)}%
                        </ProgressBar>
                        <Button
                          icon={host.science_enabled ? 'pause' : 'play'}
                          disabled={locked}
                          onClick={() =>
                            act('toggle_station_research', { host: host.ref })
                          }
                        >
                          {host.science_enabled
                            ? 'Приостановить исследования станции'
                            : 'Начать исследования станции'}
                        </Button>
                      </Box>
                      <Box mt={2}>
                        <Box bold>Сетевой майнинг</Box>
                        <Box color="label" mb={1}>
                          {' '}
                          Доходность снижается с ростом общего майнинга всех
                          сетей; жёсткого лимита дохода нет. Доход этой сети:{' '}
                          {(data.mining_rate || 0).toFixed(3)} кредитов/с. Здесь
                          можно снять целые кредиты; дробный остаток остаётся на
                          сервере.{' '}
                        </Box>
                        <Box mb={1}>
                          {(host.mining_balance || 0).toFixed(2)} кредитов
                          накоплено ·{' '}
                          {!host.mining_enabled
                            ? 'Приостановлено'
                            : !host.mining_ready
                              ? 'Сервер недоступен'
                              : host.mining_cpu <= 0
                                ? 'Ожидание свободного CPU'
                                : 'Майнинг'}
                        </Box>
                        <Button
                          icon={host.mining_enabled ? 'pause' : 'play'}
                          disabled={locked}
                          onClick={() =>
                            act('toggle_mining', { host: host.ref })
                          }
                        >
                          {host.mining_enabled
                            ? 'Приостановить майнинг'
                            : 'Начать майнинг'}
                        </Button>
                        <Button
                          icon="money-bill"
                          disabled={
                            locked ||
                            !data.can_withdraw ||
                            !host.mining_ready ||
                            host.mining_balance < 1
                          }
                          onClick={() =>
                            act('withdraw_mining', { host: host.ref })
                          }
                        >
                          {' '}
                          Снять кредиты{' '}
                        </Button>
                      </Box>
                      {host.disk && (
                        <Box mt={2}>
                          <Box bold mb={1}>
                            {' '}
                            Восстановление архива{' '}
                          </Box>
                          <ProgressBar
                            value={safeRatio(
                              host.disk.progress,
                              host.disk.cost,
                            )}
                            color="blue"
                          >
                            {host.disk.progress.toFixed(1)} / {host.disk.cost}{' '}
                            CPU·с{' '}
                          </ProgressBar>
                          <Box color="label" my={1}>
                            {!host.disk.enabled
                              ? 'Приостановлено'
                              : !host.disk.ready
                                ? 'Сервер недоступен'
                                : !host.disk.cpu
                                  ? 'Ожидание CPU — проверьте квоту подсети и резервы ИИ'
                                  : 'Восстановление исследовательских данных'}
                            {' · '}Для досрочного извлечения используйте
                            мультитул на сервере. Прогресс сохраняется на диске.
                            После завершения выдаётся {host.disk.reward} очков
                            исследований ИИ один раз, после чего использованный
                            архив извлекается.{' '}
                          </Box>
                          <Button
                            icon={host.disk.enabled ? 'pause' : 'play'}
                            disabled={locked}
                            onClick={() =>
                              act('toggle_decryption', { host: host.ref })
                            }
                          >
                            {host.disk.enabled
                              ? 'Приостановить'
                              : 'Восстановить архив'}
                          </Button>
                        </Box>
                      )}
                    </Section>
                  ))}
                </Section>
              )}
              {tab === 'ais' && (
                <>
                  {!ais.length && (
                    <NoticeBox info>
                      {' '}
                      В сети нет зарегистрированных ИИ.{' '}
                    </NoticeBox>
                  )}
                  {ais.map((ai) => {
                    const maxCpu = Math.min(
                      100,
                      (free.cpuFraction + ai.assigned_cpu) * 100,
                    );
                    const maxRam = free.ram + ai.assigned_ram;
                    return (
                      <Section
                        key={ai.ref}
                        title={ai.name}
                        buttons={
                          <Button.Confirm
                            key={`${data.selected_network}:${data.policy_revision}:${ai.ref}:${ai.assigned_cpu}:${ai.assigned_ram}`}
                            icon="eraser"
                            color="bad"
                            disabled={
                              locked || (!ai.assigned_cpu && !ai.assigned_ram)
                            }
                            confirmContent="Освободить все ресурсы?"
                            onClick={() =>
                              act('clear_ai_resources', {
                                network: data.selected_network,
                                targetAI: ai.ref,
                                expected_revision: data.policy_revision,
                                expected_cpu: ai.assigned_cpu,
                                expected_ram: ai.assigned_ram,
                              })
                            }
                          >
                            {' '}
                            Освободить ресурсы{' '}
                          </Button.Confirm>
                        }
                      >
                        <LabeledList>
                          <LabeledList.Item label="Доля CPU">
                            <NumberInput
                              value={Math.round(ai.assigned_cpu * 100)}
                              minValue={0}
                              maxValue={maxCpu}
                              step={1}
                              unit="%"
                              width={9}
                              disabled={locked || !data.total_cpu}
                              onChange={(value) =>
                                act('set_cpu', {
                                  network: data.selected_network,
                                  targetAI: ai.ref,
                                  amount_cpu: value / 100,
                                })
                              }
                            />
                            <Box inline ml={1} color="label">
                              {(ai.assigned_cpu * data.total_cpu).toFixed(2)}{' '}
                              ТГц{' '}
                            </Box>
                            <Button
                              ml={1}
                              disabled={locked || !data.total_cpu}
                              onClick={() =>
                                act('max_cpu', {
                                  network: data.selected_network,
                                  targetAI: ai.ref,
                                  expected_revision: data.policy_revision,
                                })
                              }
                            >
                              {' '}
                              Выделить остаток{' '}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label="Память">
                            <NumberInput
                              value={ai.assigned_ram}
                              minValue={0}
                              maxValue={maxRam}
                              step={1}
                              unit="ТБ"
                              width={9}
                              disabled={locked}
                              onChange={(value) =>
                                act('set_ram', {
                                  network: data.selected_network,
                                  targetAI: ai.ref,
                                  amount_ram: value,
                                })
                              }
                            />
                            <Button
                              ml={1}
                              disabled={locked}
                              onClick={() =>
                                act('max_ram', {
                                  network: data.selected_network,
                                  targetAI: ai.ref,
                                  expected_revision: data.policy_revision,
                                })
                              }
                            >
                              {' '}
                              Выделить остаток{' '}
                            </Button>
                          </LabeledList.Item>
                        </LabeledList>
                      </Section>
                    );
                  })}
                </>
              )}
            </NeuralWorkspace>
          )}
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}
