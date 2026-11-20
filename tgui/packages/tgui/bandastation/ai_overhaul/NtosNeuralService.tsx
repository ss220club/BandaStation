import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { NtosWindow } from '../../layouts';
import {
  CpuThermalStatus,
  NetworkHeader,
  NetworkTelemetry,
  TaskSignal,
} from './Common';
import { NeuralNavigation } from './NeuralNavigation';
import { NeuralShell } from './NeuralOS';
import { NeuralWorkspace } from './NeuralWorkspace';
import { ResourcePolicy } from './ResourcePolicy';
import { type Subnet, SubnetPanel } from './SubnetPanel';

type Data = {
  hacked_law_ref?: string | null;
  law_signature?: string;
  can_upload_law?: BooleanLike;
  law_upload_targets?: Data['upgrade_targets'];
  intrusions?: { ref: string; name: string; source: string; elapsed: number }[];
  subnets?: Subnet[];
  segment_count: number;
  benchmark: BooleanLike;
  connected: BooleanLike;
  network: string;
  name: string;
  cpu: number;
  nominal_cpu?: number;
  ram: number;
  spare_cpu: number;
  free_ram: number;
  jobs: number;
  can_manage: BooleanLike;
  can_allocate: BooleanLike;
  human_only?: BooleanLike;
  policy_revision?: number;
  can_change_policy?: BooleanLike;
  bridges?: {
    ref: string;
    area: string;
    responding: BooleanLike;
    enabled: BooleanLike;
    heading: number | null;
    bearing: number | null;
    status: string;
  }[];
  slot_installed: BooleanLike;
  card_present: BooleanLike;
  card_name: string | null;
  card_busy: BooleanLike;
  can_transfer: BooleanLike;
  can_eject: BooleanLike;
  downloading: string | null;
  download_progress: number;
  mmi_ref: string | null;
  mmi_name: string | null;
  mmi_ready: BooleanLike;
  upgrade_ref?: string | null;
  upgrade_name?: string | null;
  can_install_upgrade?: BooleanLike;
  upgrade_targets?: {
    ref: string;
    name: string;
    ready: BooleanLike;
    racks: {
      ref: string;
      name: string;
      online: BooleanLike;
      slots: number[];
      recipients: string[];
      signature: string;
    }[];
  }[];
  cores?: { ref: string; area: string; ready: BooleanLike }[];
  ais: {
    ref: string;
    name: string;
    cpu: number;
    ram: number;
    can_download: BooleanLike;
  }[];
  baseline: { cpu: number; ram: number } | null;
  records?: {
    cpu: { value: number; date: string }[];
    ram: { value: number; date: string }[];
  };
  servers: {
    ref: string;
    area: string;
    responding: BooleanLike;
    status: string;
    temperature: number | null;
    effective_cpu?: number | null;
    nominal_cpu?: number | null;
    thermal_status?: string | null;
    subnet: string;
    job_cpu: number | null;
    jobs_ready: BooleanLike;
    research: BooleanLike;
    science: BooleanLike;
    mining: BooleanLike;
    mining_balance: number | null;
    archive: BooleanLike;
    recovering: BooleanLike;
  }[];
};

export const NtosNeuralService = () => {
  const { act, data } = useBackend<Data>();
  const [selectedTab, setTab] = useState('servers');
  const tab = data.benchmark
    ? selectedTab === 'records'
      ? 'records'
      : 'compare'
    : ['servers', 'network', 'ais', 'maintenance'].includes(selectedTab)
      ? selectedTab
      : 'servers';
  const maintenance = (
    <div className="AiOS__serviceWorkspace">
      {!data.benchmark && (
        <Section
          title="Перенос ИИ"
          buttons={
            <Button
              icon="eject"
              disabled={!data.can_eject || !data.card_present || data.card_busy}
              onClick={() => act('eject_card')}
            >
              {' '}
              Извлечь карту{' '}
            </Button>
          }
        >
          {!data.slot_installed ? (
            <NoticeBox>
              {' '}
              Для работы с intelliCard установите на этот компьютер программу
              «Управление и восстановление ИИ».{' '}
            </NoticeBox>
          ) : !data.card_present ? (
            <NoticeBox>
              {' '}
              Вставьте intelliCard в компьютер. Для выгрузки нужна пустая карта.{' '}
            </NoticeBox>
          ) : (
            <Box className="AiOS__eyebrow">
              {data.card_busy
                ? 'КАРТА ЗАНЯТА / ВОССТАНОВЛЕНИЕ ИЛИ ОЧИСТКА'
                : data.downloading
                  ? 'КАРТА ЗАРЕЗЕРВИРОВАНА / ВЫГРУЗКА'
                  : data.card_name
                    ? `ИИ НА КАРТЕ / ${data.card_name}`
                    : 'КАРТА ПУСТА / ГОТОВА'}
            </Box>
          )}
          {!!data.downloading && (
            <Box mt={1}>
              <ProgressBar value={data.download_progress / 100}>
                {' '}
                Выгрузка {data.downloading}: {data.download_progress.toFixed(0)}
                %
              </ProgressBar>
              <Button
                mt={1}
                icon="stop"
                disabled={!data.can_transfer}
                onClick={() => act('stop_download')}
              >
                {' '}
                Остановить выгрузку{' '}
              </Button>
            </Box>
          )}
          <Box color="label" mt={1}>
            {' '}
            Для переноса нужен доступ РД или телекоммуникаций. Оставайтесь рядом
            с компьютером и подключённым узлом. Разрешение ИИ проверяется на
            протяжении всего переноса. Извлечение карты отменяет выгрузку.{' '}
          </Box>
          {!!data.connected && !!data.card_name && (
            <Box mt={1}>
              <Box mb={1}>Выберите ядро назначения в этой сети:</Box>
              {!(data.cores || []).length && (
                <NoticeBox>Подключённых ядер ИИ нет.</NoticeBox>
              )}
              {(data.cores || []).map((core) => (
                <Button.Confirm
                  key={core.ref}
                  icon="upload"
                  fluid
                  mb={1}
                  disabled={
                    !data.can_transfer ||
                    data.card_busy ||
                    !!data.downloading ||
                    !core.ready
                  }
                  confirmContent="Загрузить ИИ в это ядро?"
                  onClick={() =>
                    act('upload_card', {
                      network: data.network,
                      core: core.ref,
                    })
                  }
                >
                  {core.area}
                  {!core.ready && ' — недоступно'}
                </Button.Confirm>
              ))}
            </Box>
          )}
        </Section>
      )}
      {!data.benchmark && (
        <Section title="Создание ИИ из ММИ">
          {!data.mmi_ref ? (
            <Box color="label">
              {' '}
              Держите в руке занятый ММИ или позитронный мозг, чтобы загрузить
              его игрока в ядро ИИ. ММИ будет израсходован.{' '}
            </Box>
          ) : (
            <>
              <Box className="AiOS__eyebrow">
                {' '}
                ИНТЕРФЕЙС В РУКЕ / {data.mmi_name}
              </Box>
              {!data.mmi_ready && (
                <NoticeBox mt={1}>
                  {' '}
                  Создание ИИ недоступно. Требуется живой игрок в активном
                  состоянии; создание ИИ должно быть разрешено на сервере.{' '}
                </NoticeBox>
              )}
              {!data.connected ? (
                <NoticeBox mt={1}>
                  Подключитесь к местной нейронной сети.
                </NoticeBox>
              ) : (
                <Box mt={1}>
                  <Box color="label" mb={1}>
                    {' '}
                    Выберите ядро назначения. Нужен доступ РД или
                    телекоммуникаций. Законы ММИ сохраняются; при их отсутствии
                    применяются законы станции. При запуске выделяются только
                    свободные CPU и RAM.{' '}
                  </Box>
                  {!(data.cores || []).length && (
                    <NoticeBox>Подключённых ядер ИИ нет.</NoticeBox>
                  )}
                  {(data.cores || []).map((core) => (
                    <Button.Confirm
                      key={`${data.network}:${data.mmi_ref}:${core.ref}`}
                      icon="brain"
                      fluid
                      mb={1}
                      disabled={
                        !data.can_transfer ||
                        !data.mmi_ready ||
                        !!data.downloading ||
                        !core.ready
                      }
                      confirmContent="Израсходовать ММИ и создать ИИ?"
                      onClick={() =>
                        act('upload_mmi', {
                          network: data.network,
                          core: core.ref,
                          mmi: data.mmi_ref,
                        })
                      }
                    >
                      {core.area}
                      {!core.ready && ' — недоступно'}
                    </Button.Confirm>
                  ))}
                </Box>
              )}
            </>
          )}
        </Section>
      )}
      {!data.benchmark && !!data.hacked_law_ref && (
        <Section title="Загрузка приоритетного закона">
          <NoticeBox danger>
            {' '}
            Взломанный модуль ИИ / Подключение занимает 5,5 секунды, загрузка —
            четыре минуты. Оставайтесь рядом с терминалом и выбранной стойкой.
            Модуль остаётся в стойке. Закон получат все связанные синтетики, в
            том числе вне этой нейронной сети. Экипаж может прервать загрузку за
            10 секунд.{' '}
          </NoticeBox>
          {(data.law_upload_targets || []).map((target) => (
            <Section key={target.ref} title={target.name} mt={1}>
              {!target.racks.length && (
                <Box color="label">
                  В пределах досягаемости нет связанной стойки законов.
                </Box>
              )}
              {target.racks.map((rack) => (
                <Box key={rack.ref} mb={1}>
                  <Box bold>{rack.name}</Box>
                  <Box color="label" my={1}>
                    {' '}
                    Закон получат: {rack.recipients.join(', ')}
                  </Box>
                  {!rack.slots.length && (
                    <Box color="label">
                      Нет свободных дополнительных слотов.
                    </Box>
                  )}
                  {rack.slots.map((slot) => (
                    <Button.Confirm
                      key={`${data.network}:${data.hacked_law_ref}:${data.law_signature}:${rack.signature}:${slot}`}
                      icon="plug"
                      disabled={
                        !data.can_upload_law || !target.ready || !rack.online
                      }
                      confirmContent="Начать загрузку для указанных синтетиков?"
                      onClick={() =>
                        act('upload_hacked_law', {
                          network: data.network,
                          host: target.ref,
                          rack: rack.ref,
                          slot,
                          module: data.hacked_law_ref,
                          signature: rack.signature,
                          law_signature: data.law_signature,
                        })
                      }
                    >
                      {' '}
                      Подключить в слот {slot}
                    </Button.Confirm>
                  ))}
                </Box>
              ))}
            </Section>
          ))}
        </Section>
      )}
      {!data.benchmark && !!data.upgrade_ref && (
        <Section title="Установка модуля">
          <Box className="AiOS__eyebrow">
            {' '}
            МОДУЛЬ В РУКЕ / {data.upgrade_name}
          </Box>
          <Box color="label" mt={1} mb={1}>
            {' '}
            Держите модуль в активной руке и оставайтесь рядом со стойкой и
            терминалом. Нужен доступ робототехники, РД или телекоммуникаций.
            Модуль остаётся в стойке; законы не меняются.{' '}
          </Box>
          <NoticeBox>
            {' '}
            Установка затрагивает всех ИИ, связанных со стойкой, в том числе вне
            этой нейронной сети. Улучшения наблюдения сохраняются после
            извлечения. Извлекать и закреплять модули нужно через саму стойку.{' '}
          </NoticeBox>
          {!(data.upgrade_targets || []).length && (
            <Box mt={1}>Подключённых ИИ нет.</Box>
          )}
          {(data.upgrade_targets || []).map((target) => (
            <Section key={target.ref} title={target.name} mt={1}>
              {!target.ready && (
                <Box color="bad" mb={1}>
                  {' '}
                  Ядро ИИ недоступно.{' '}
                </Box>
              )}
              {!target.racks.length && (
                <Box color="label">
                  В пределах досягаемости нет связанной стойки модулей.
                </Box>
              )}
              {target.racks.map((rack) => (
                <Box key={rack.ref} mb={1}>
                  <Box bold>{rack.name}</Box>
                  <Box color="label" my={1}>
                    {' '}
                    Улучшение получат: {rack.recipients.join(', ')}
                  </Box>
                  {!rack.online && (
                    <Box color="bad" mb={1}>
                      {' '}
                      Стойка не отвечает.{' '}
                    </Box>
                  )}
                  {!rack.slots.length && (
                    <Box color="label">Нет свободных слотов улучшений.</Box>
                  )}
                  {rack.slots.map((slot) => (
                    <Button.Confirm
                      key={`${data.network}:${data.upgrade_ref}:${target.ref}:${rack.ref}:${rack.signature}:${slot}`}
                      icon="microchip"
                      mb={1}
                      disabled={
                        !data.can_install_upgrade ||
                        !target.ready ||
                        !rack.online
                      }
                      confirmContent="Установить для указанных ИИ?"
                      onClick={() =>
                        act('install_upgrade', {
                          network: data.network,
                          host: target.ref,
                          rack: rack.ref,
                          module: data.upgrade_ref,
                          slot,
                          signature: rack.signature,
                        })
                      }
                    >
                      {' '}
                      Установить в слот {slot}
                    </Button.Confirm>
                  ))}
                </Box>
              ))}
            </Section>
          ))}
        </Section>
      )}
    </div>
  );
  const command = (action: string, host?: string) =>
    act(action, { network: data.network, host });
  return (
    <NtosWindow width={940} height={740}>
      <NtosWindow.Content fitted className="AiOS">
        <NeuralShell
          application={
            data.benchmark
              ? 'Тест ресурсов нейросети'
              : 'Обслуживание нейросети'
          }
          telemetry={
            data.connected
              ? {
                  cpuReserved:
                    data.cpu > 0 && Number.isFinite(data.spare_cpu)
                      ? 1 - data.spare_cpu / data.cpu
                      : undefined,
                  cpuScope: 'network',
                  memoryUsed:
                    Number.isFinite(data.ram) && Number.isFinite(data.free_ram)
                      ? data.ram - data.free_ram
                      : undefined,
                  memoryCapacity: data.ram,
                }
              : undefined
          }
        >
          <NetworkHeader
            title={
              data.benchmark
                ? 'Тест ресурсов нейросети'
                : 'Обслуживание нейросети'
            }
            signal={
              data.intrusions?.length
                ? 'alert'
                : !data.connected
                  ? 'degraded'
                  : 'nominal'
            }
            status={
              !data.connected
                ? 'НЕТ МЕСТНОЙ СВЯЗИ'
                : data.intrusions?.length
                  ? 'ПОСТОРОННЕЕ ПОДКЛЮЧЕНИЕ К СТОЙКЕ ЗАКОНОВ'
                  : data.benchmark
                    ? 'МЕСТНЫЙ АНАЛИЗ / ТОЛЬКО ЧТЕНИЕ'
                    : 'МЕСТНАЯ СВЯЗЬ УСТАНОВЛЕНА'
            }
            subtitle={
              data.benchmark
                ? 'Анализ ресурсов / рекорды станции'
                : 'Переносной терминал / местное оборудование'
            }
          />
          {!data.benchmark && !!data.intrusions?.length && (
            <Section title="Телеметрия безопасности">
              {data.intrusions.map((session) => (
                <NoticeBox danger key={session.ref}>
                  {session.name} / постороннее подключение к стойке законов ·
                  источник: {session.source} · обнаружено {session.elapsed}с
                  назад. Нажмите ПКМ пустой рукой по исходной стойке законов или
                  затронутому ядру ИИ, чтобы отключить устройство (10 секунд).{' '}
                </NoticeBox>
              ))}
            </Section>
          )}
          {!!data.downloading && tab !== 'maintenance' && !data.benchmark && (
            <NoticeBox info>
              {' '}
              Выполняется перенос ИИ: {data.downloading} ·{' '}
              {data.download_progress.toFixed(0)}%
              <Button ml={1} onClick={() => setTab('maintenance')}>
                {' '}
                Открыть перенос{' '}
              </Button>
            </NoticeBox>
          )}
          {!!data.connected && (
            <CpuThermalStatus nominal={data.nominal_cpu} effective={data.cpu} />
          )}
          <NeuralWorkspace
            navigation={
              (!data.benchmark || !!data.connected) && (
                <NeuralNavigation
                  selected={tab}
                  onSelect={setTab}
                  items={
                    data.benchmark
                      ? [
                          {
                            id: 'compare',
                            label: 'Сравнение',
                            icon: 'gauge-high',
                          },
                          {
                            id: 'records',
                            label: 'Рекорды станции',
                            icon: 'trophy',
                          },
                        ]
                      : [
                          {
                            id: 'servers',
                            label: 'Серверы',
                            icon: 'server',
                            count: data.servers?.length || 0,
                          },
                          {
                            id: 'network',
                            label: 'Сеть и ретрансляторы',
                            icon: 'network-wired',
                          },
                          {
                            id: 'maintenance',
                            label: 'Обслуживание ядра',
                            icon: 'tools',
                          },
                          {
                            id: 'ais',
                            label: 'ИИ',
                            icon: 'brain',
                            count: data.ais?.length || 0,
                          },
                        ]
                  }
                />
              )
            }
            instruments={
              <>
                <Section title="Подключение">
                  <Box color="label">
                    {' '}
                    МЕСТНАЯ НЕЙРОННАЯ СВЯЗЬ /{' '}
                    {data.connected ? 'ПОДКЛЮЧЕНО' : 'ОТКЛЮЧЕНО'}
                  </Box>
                  {!data.connected ? (
                    <NoticeBox mt={1}>
                      {' '}
                      Вставьте ID-карту с доступом робототехники, РД или
                      телекоммуникаций. Для подключения нажмите этим устройством
                      ПКМ по оптоволоконному кабелю, ядру или серверу
                      поблизости. Оставайтесь рядом с узлом. Компьютер на одном
                      оптоволоконном кабеле подключается автоматически; на
                      пересечении нужно выбрать линию.{' '}
                    </NoticeBox>
                  ) : (
                    <Box mt={1}>
                      {data.name}{' '}
                      {!data.benchmark && (
                        <Button
                          icon="pen"
                          disabled={!data.can_allocate}
                          onClick={() => command('rename_network')}
                        >
                          {' '}
                          Переименовать сеть{' '}
                        </Button>
                      )}
                    </Box>
                  )}
                </Section>
                {!!data.connected && (
                  <NetworkTelemetry
                    cpu={data.spare_cpu || 0}
                    ram={data.free_ram || 0}
                    jobs={data.jobs || 0}
                    segments={data.segment_count || 0}
                  />
                )}
              </>
            }
          >
            {!data.benchmark && tab === 'maintenance' && maintenance}
            {!!data.connected && (
              <>
                {!data.benchmark && tab === 'network' && (
                  <ResourcePolicy
                    network={data.network}
                    humanOnly={data.human_only || false}
                    revision={data.policy_revision || 0}
                    canChange={data.can_change_policy || false}
                    onChange={(human_only, expected_human_only) =>
                      act('set_human_policy', {
                        network: data.network,
                        human_only,
                        expected_human_only,
                        expected_revision: data.policy_revision,
                      })
                    }
                  />
                )}
                {!data.benchmark && tab === 'network' && (
                  <SubnetPanel
                    key={data.network}
                    subnets={data.subnets || []}
                    available={data.spare_cpu || 0}
                    locked={!data.can_allocate}
                    activityLocked={!data.can_transfer}
                    onActivity={(subnet, category, action, amount) =>
                      act(action, {
                        network: data.network,
                        subnet,
                        category,
                        amount,
                        expected_revision: data.policy_revision,
                      })
                    }
                    onQuota={(subnet, amount) =>
                      act('set_subnet_quota', {
                        network: data.network,
                        subnet,
                        amount,
                      })
                    }
                    onRename={(subnet, name) =>
                      act('rename_subnet', {
                        network: data.network,
                        subnet,
                        name,
                      })
                    }
                  />
                )}
                {!data.benchmark &&
                  tab === 'network' &&
                  !!data.bridges?.length && (
                    <Section title="Сетевые ретрансляторы">
                      <NoticeBox>
                        {' '}
                        Отключение ретранслятора может разорвать связь с
                        удалёнными CPU, RAM и ядрами ИИ. Привязка сохраняется.
                        Для включения изолированного ретранслятора подключитесь
                        к нему на месте.{' '}
                      </NoticeBox>
                      {data.bridges.map((bridge) => (
                        <Section key={bridge.ref} title={bridge.area}>
                          <Box mb={1}>{bridge.status}</Box>
                          {bridge.heading !== null && (
                            <Box color="label" mb={1}>
                              {' '}
                              Антенна: {bridge.heading?.toFixed(1)}° по часовой
                              стрелке от севера{' '}
                              {bridge.bearing !== null &&
                                ` · Направление на целевой узел: ${bridge.bearing?.toFixed(1)}°`}{' '}
                              . Настройте антенну гаечным ключом на месте;
                              отклонение от цели не должно превышать 20°. После
                              перемещения узла повторите привязку, чтобы
                              обновить координаты.{' '}
                            </Box>
                          )}
                          <Button
                            icon="power-off"
                            selected={!!bridge.enabled}
                            disabled={!data.can_allocate || !bridge.responding}
                            onClick={() => command('toggle_bridge', bridge.ref)}
                          >
                            {bridge.enabled
                              ? 'Отключить ретранслятор'
                              : 'Включить ретранслятор'}
                          </Button>
                        </Section>
                      ))}
                    </Section>
                  )}
                {!data.benchmark && tab === 'ais' && (
                  <Section title="Выделение ресурсов ИИ">
                    <Box color="label" mb={1}>
                      {' '}
                      CPU выделяется долей ресурсов этой сети, RAM резервируется
                      в ТБ. Нужен доступ РД или телекоммуникаций. Уменьшение
                      памяти может остановить программы ИИ. «Выделить остаток»
                      выделяет текущие свободные ресурсы; резервы других ИИ
                      сохраняются.{' '}
                    </Box>
                    {(data.ais || []).length === 0 && (
                      <NoticeBox>В этом сегменте нет ИИ.</NoticeBox>
                    )}
                    {(data.ais || []).map((ai) => (
                      <Section
                        key={ai.ref}
                        title={ai.name}
                        buttons={
                          <Button.Confirm
                            key={`${data.network}:${data.policy_revision}:${ai.ref}:${ai.cpu}:${ai.ram}`}
                            icon="eraser"
                            color="bad"
                            disabled={
                              !data.can_transfer || (!ai.cpu && !ai.ram)
                            }
                            confirmContent="Освободить CPU и RAM?"
                            onClick={() =>
                              act('clear_ai_resources', {
                                network: data.network,
                                host: ai.ref,
                                expected_revision: data.policy_revision,
                                expected_cpu: ai.cpu,
                                expected_ram: ai.ram,
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
                              value={ai.cpu * 100}
                              unit="%"
                              minValue={0}
                              maxValue={Math.min(
                                100,
                                (ai.cpu +
                                  (data.cpu > 0
                                    ? data.spare_cpu / data.cpu
                                    : 0)) *
                                  100,
                              )}
                              step={1}
                              disabled={!data.can_allocate || !data.cpu}
                              onChange={(value) =>
                                act('set_cpu', {
                                  network: data.network,
                                  host: ai.ref,
                                  amount: value / 100,
                                })
                              }
                            />
                            <Button
                              ml={1}
                              disabled={!data.can_transfer || !data.cpu}
                              onClick={() =>
                                act('max_cpu', {
                                  network: data.network,
                                  host: ai.ref,
                                  expected_revision: data.policy_revision,
                                })
                              }
                            >
                              {' '}
                              Выделить остаток{' '}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label="Зарезервированная RAM">
                            <NumberInput
                              value={ai.ram}
                              unit="ТБ"
                              minValue={0}
                              maxValue={ai.ram + data.free_ram}
                              step={1}
                              disabled={!data.can_allocate}
                              onChange={(value) =>
                                act('set_ram', {
                                  network: data.network,
                                  host: ai.ref,
                                  amount: value,
                                })
                              }
                            />
                            <Button
                              ml={1}
                              disabled={!data.can_transfer || data.free_ram < 1}
                              onClick={() =>
                                act('add_ram', {
                                  network: data.network,
                                  host: ai.ref,
                                  expected_revision: data.policy_revision,
                                })
                              }
                            >
                              {' '}
                              +1 ТБ{' '}
                            </Button>
                            <Button
                              disabled={!data.can_transfer || ai.ram < 1}
                              onClick={() =>
                                act('remove_ram', {
                                  network: data.network,
                                  host: ai.ref,
                                  expected_revision: data.policy_revision,
                                })
                              }
                            >
                              {' '}
                              −1 ТБ{' '}
                            </Button>
                          </LabeledList.Item>
                        </LabeledList>
                        <Button.Confirm
                          mt={1}
                          icon="download"
                          disabled={
                            !data.can_transfer ||
                            !data.card_present ||
                            !!data.card_name ||
                            data.card_busy ||
                            !!data.downloading ||
                            !ai.can_download
                          }
                          confirmContent="Начать выгрузку ИИ?"
                          onClick={() => command('start_download', ai.ref)}
                        >
                          {ai.can_download
                            ? 'Выгрузить на intelliCard'
                            : 'Выгрузка недоступна'}
                        </Button.Confirm>
                      </Section>
                    ))}
                  </Section>
                )}
                {!!data.benchmark && tab === 'records' && (
                  <Section title="Рекорды прошлых смен">
                    <Box color="label" mb={1}>
                      {' '}
                      Лучшие показатели завершённых смен этого сервера. Рекорды
                      CPU и RAM — независимые максимумы одной сети станции.
                      Результаты текущей смены сохраняются после её завершения.{' '}
                    </Box>
                    {(['cpu', 'ram'] as const).map((metric) => (
                      <Section
                        key={metric}
                        title={
                          metric === 'cpu'
                            ? 'Рекорды CPU · ТГц'
                            : 'Рекорды RAM · ТБ'
                        }
                      >
                        {(data.records?.[metric] || []).length === 0 && (
                          <Box color="label">
                            {' '}
                            Рекордов завершённых смен пока нет.{' '}
                          </Box>
                        )}
                        {(data.records?.[metric] || []).map((record, index) => (
                          <Box key={`${metric}-${index}`}>
                            {index + 1}.{' '}
                            {record.value.toFixed(metric === 'cpu' ? 2 : 0)} ·{' '}
                            {record.date}
                          </Box>
                        ))}
                      </Section>
                    ))}
                  </Section>
                )}
                {data.benchmark ? (
                  tab === 'compare' && (
                    <Section
                      title="Сравнение после обслуживания"
                      buttons={
                        <Button
                          icon="camera"
                          onClick={() => command('snapshot')}
                        >
                          {' '}
                          Сохранить исходные значения{' '}
                        </Button>
                      }
                    >
                      <Box color="label" mb={1}>
                        {' '}
                        Только сравнение ресурсов: CPU не резервируется, работа
                        ИИ не прерывается. Исходные значения сбрасываются при
                        смене подключения или закрытии программы.{' '}
                      </Box>
                      {data.baseline ? (
                        <LabeledList>
                          <LabeledList.Item label="CPU до / сейчас">
                            {data.baseline.cpu.toFixed(2)} /{' '}
                            {data.cpu.toFixed(2)} ТГц{' '}
                          </LabeledList.Item>
                          <LabeledList.Item label="Изменение CPU">
                            {(data.cpu - data.baseline.cpu).toFixed(2)} ТГц{' '}
                          </LabeledList.Item>
                          <LabeledList.Item label="RAM до / сейчас">
                            {data.baseline.ram} / {data.ram} ТБ{' '}
                          </LabeledList.Item>
                          <LabeledList.Item label="Изменение RAM">
                            {data.ram - data.baseline.ram} ТБ{' '}
                          </LabeledList.Item>
                        </LabeledList>
                      ) : (
                        <NoticeBox>
                          {' '}
                          Сохраните текущие ресурсы, затем замените оборудование
                          или измените частоту для сравнения результата.{' '}
                        </NoticeBox>
                      )}
                    </Section>
                  )
                ) : tab === 'servers' ? (
                  <Section title="Подключённые серверные шкафы">
                    {!data.can_manage && (
                      <NoticeBox>
                        {' '}
                        Для управления задачами нужен оператор-человек с
                        доступом, находящийся рядом с компьютером.{' '}
                      </NoticeBox>
                    )}
                    {data.servers.length === 0 && (
                      <NoticeBox>
                        {' '}
                        В этом сегменте нет серверных шкафов. Проверьте
                        оптоволоконные кабели.{' '}
                      </NoticeBox>
                    )}
                    {data.servers.map((server) => (
                      <Section key={server.ref} title={server.area}>
                        <Box className="AiOS__eyebrow">
                          {server.subnet || 'МЕСТНЫЙ СЕГМЕНТ'}
                        </Box>
                        <TaskSignal
                          enabled={
                            !!(
                              server.research ||
                              server.science ||
                              server.mining ||
                              server.recovering
                            )
                          }
                          ready={!!server.jobs_ready}
                          cpu={server.job_cpu || 0}
                        />
                        <Box color={server.responding ? 'label' : 'bad'} mb={1}>
                          {server.status}
                          {server.temperature !== null &&
                            ` · ${server.temperature.toFixed(1)} К`}
                        </Box>
                        {server.effective_cpu !== null &&
                          server.effective_cpu !== undefined && (
                            <Box color="label" mb={1}>
                              CPU: {server.effective_cpu.toFixed(2)} /{' '}
                              {server.nominal_cpu?.toFixed(2)} ТГц ·{' '}
                              {server.thermal_status}
                            </Box>
                          )}
                        {server.mining_balance !== null && (
                          <Box color="label" mb={1}>
                            {' '}
                            Баланс майнинга: {server.mining_balance.toFixed(2)}{' '}
                            кредитов. Целые кредиты можно снять на консоли
                            ресурсов.{' '}
                          </Box>
                        )}
                        <Stack wrap>
                          <Stack.Item>
                            <Button
                              icon="flask"
                              selected={!!server.research}
                              disabled={!data.can_manage || !server.responding}
                              onClick={() => command('research', server.ref)}
                            >
                              {server.research
                                ? 'Приостановить исследования ИИ'
                                : 'Включить исследования ИИ'}
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="microscope"
                              selected={!!server.science}
                              disabled={!data.can_manage || !server.responding}
                              onClick={() => command('science', server.ref)}
                            >
                              {server.science
                                ? 'Приостановить исследования станции'
                                : 'Включить исследования станции'}
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="coins"
                              selected={!!server.mining}
                              disabled={!data.can_manage || !server.responding}
                              onClick={() => command('mining', server.ref)}
                            >
                              {server.mining
                                ? 'Приостановить майнинг'
                                : 'Включить майнинг'}
                            </Button>
                          </Stack.Item>
                          {!!server.archive && (
                            <Stack.Item>
                              <Button
                                icon="file-medical"
                                selected={!!server.recovering}
                                disabled={
                                  !data.can_manage || !server.responding
                                }
                                onClick={() => command('archive', server.ref)}
                              >
                                {server.recovering
                                  ? 'Приостановить архив'
                                  : 'Восстановить архив'}
                              </Button>
                            </Stack.Item>
                          )}
                        </Stack>
                      </Section>
                    ))}
                    <Box color="label">
                      {' '}
                      Активные задачи делят свободный CPU по квотам подсетей и
                      приоритетам. Выделения ИИ имеют преимущество; задача может
                      ожидать питание, охлаждение или свободные ресурсы.{' '}
                    </Box>
                  </Section>
                ) : null}
              </>
            )}
          </NeuralWorkspace>
        </NeuralShell>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
