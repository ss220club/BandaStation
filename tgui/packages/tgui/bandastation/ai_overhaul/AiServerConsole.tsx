import { useState } from 'react';
import {
  Box,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { NetworkHeader } from './Common';
import { NeuralNavigation } from './NeuralNavigation';
import { NeuralShell } from './NeuralOS';
import { NeuralWorkspace } from './NeuralWorkspace';
import { safeRatio } from './resourceMath';

type Machine = {
  ref: string;
  area: string;
  status: string;
  working: BooleanLike;
  temp: number;
  network: string;
  temperature_limit: number;
  throttle_temperature?: number;
  recovery_temperature?: number;
  primary?: BooleanLike;
  total_cpu?: number;
  effective_cpu?: number;
  thermal_status?: string;
  module_power?: number;
  ram?: number;
  card_capacity?: string;
};
type Bridge = Pick<
  Machine,
  'ref' | 'area' | 'network' | 'status' | 'working'
> & {
  remote_area: string;
};
type Data = {
  servers: Machine[];
  cores: Machine[];
  bridges: Bridge[];
  temperature_limit: number;
};
export function AiServerConsole() {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState('all');
  const machines = [...(data.cores || []), ...(data.servers || [])];
  return (
    <Window title="Инфраструктура ИИ" width={920} height={720}>
      <Window.Content fitted className="AiOS">
        <NeuralShell
          application="Контроль инфраструктуры"
          telemetry={{
            temperatures: machines.map((machine) => ({
              value: machine.temp,
              limit: machine.temperature_limit,
            })),
          }}
        >
          <NetworkHeader
            title="Состояние оборудования"
            signal={
              machines.some((machine) => !machine.working) ||
              data.bridges?.some((bridge) => !bridge.working) ||
              (!machines.length && !data.bridges?.length)
                ? 'degraded'
                : 'nominal'
            }
            status={
              !machines.length && !data.bridges?.length
                ? 'НЕТ ОТВЕТА ОТ УЗЛОВ'
                : machines.some((machine) => !machine.working) ||
                    data.bridges?.some((bridge) => !bridge.working)
                  ? 'УЗЛЫ ТРЕБУЮТ ОБСЛУЖИВАНИЯ'
                  : 'ОБОРУДОВАНИЕ ОТВЕЧАЕТ'
            }
            subtitle="Температура ядер, причины отказов и установленные ресурсы серверов."
          />
          <NeuralWorkspace
            navigation={
              <NeuralNavigation
                selected={tab}
                onSelect={setTab}
                items={[
                  { id: 'all', label: 'Обзор', icon: 'gauge-high' },
                  {
                    id: 'cores',
                    label: 'Ядра',
                    icon: 'brain',
                    count: data.cores?.length || 0,
                  },
                  {
                    id: 'servers',
                    label: 'Серверы',
                    icon: 'server',
                    count: data.servers?.length || 0,
                  },
                  {
                    id: 'bridges',
                    label: 'Мосты',
                    icon: 'network-wired',
                    count: data.bridges?.length || 0,
                  },
                ]}
              />
            }
            instruments={
              <Section title="Обнаруженное оборудование">
                <dl className="AiOS__diagnosticRows">
                  <div>
                    <dt>Доступные узлы</dt>
                    <dd>{machines.length + (data.bridges?.length || 0)}</dd>
                  </div>
                  <div>
                    <dt>Без ответа</dt>
                    <dd>
                      {machines.filter((machine) => !machine.working).length +
                        (data.bridges || []).filter((bridge) => !bridge.working)
                          .length}
                    </dd>
                  </div>
                  <div>
                    <dt>Источник температуры</dt>
                    <dd>
                      {' '}
                      Текущие показания и пределы каждого обнаруженного
                      устройства. История показаний не восстанавливается.{' '}
                    </dd>
                  </div>
                </dl>
              </Section>
            }
          >
            {!machines.length && !data.bridges?.length && (
              <NoticeBox>Оборудование ИИ не обнаружено.</NoticeBox>
            )}
            {((tab === 'cores' && !data.cores?.length) ||
              (tab === 'servers' && !data.servers?.length) ||
              (tab === 'bridges' && !data.bridges?.length)) && (
              <NoticeBox>В этой категории оборудования нет.</NoticeBox>
            )}
            {(tab === 'all' || tab === 'bridges' ? data.bridges || [] : []).map(
              (bridge) => (
                <Section
                  key={bridge.ref}
                  title={`Сетевой мост — ${bridge.area}`}
                >
                  <Box color={bridge.working ? 'good' : 'bad'} bold mb={1}>
                    {bridge.status}
                  </Box>
                  <LabeledList>
                    <LabeledList.Item label="Удалённый узел">
                      {bridge.remote_area}
                    </LabeledList.Item>
                    <LabeledList.Item label="Сеть">
                      {bridge.network}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ),
            )}
            {(tab === 'cores'
              ? data.cores || []
              : tab === 'servers'
                ? data.servers || []
                : tab === 'bridges'
                  ? []
                  : machines
            ).map((machine) => (
              <Section
                key={machine.ref}
                title={`${machine.card_capacity ? 'Серверный шкаф' : machine.primary ? 'Основное ядро ИИ' : 'Ядро ИИ'} - ${machine.area}`}
              >
                <Box color={machine.working ? 'good' : 'bad'} bold mb={1}>
                  {machine.status} · {machine.network}
                </Box>
                <ProgressBar
                  value={safeRatio(machine.temp, machine.temperature_limit)}
                  color={
                    machine.temp >= machine.temperature_limit ? 'bad' : 'blue'
                  }
                >
                  {machine.temp.toFixed(1)} К /{' '}
                  {machine.temperature_limit.toFixed(1)} К — предел{' '}
                </ProgressBar>
                {machine.card_capacity && (
                  <>
                    <LabeledList>
                      <LabeledList.Item label="CPU доступно / номинал">
                        {machine.effective_cpu?.toFixed(2)} /{' '}
                        {machine.total_cpu?.toFixed(2)} ТГц
                      </LabeledList.Item>
                      <LabeledList.Item label="Частота">
                        {machine.thermal_status}
                      </LabeledList.Item>
                      <LabeledList.Item label="Расчётное питание модулей">
                        {machine.module_power?.toFixed(0)} Вт
                      </LabeledList.Item>
                      <LabeledList.Item label="RAM">
                        {machine.ram} ТБ{' '}
                      </LabeledList.Item>
                      <LabeledList.Item label="Разъёмы модулей">
                        {machine.card_capacity}
                      </LabeledList.Item>
                    </LabeledList>
                    <ServerThermalLimits machine={machine} />
                  </>
                )}
              </Section>
            ))}
          </NeuralWorkspace>
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}

export function ServerThermalLimits({
  machine,
}: {
  machine: Pick<
    Machine,
    'temperature_limit' | 'throttle_temperature' | 'recovery_temperature'
  >;
}) {
  const { temperature_limit, throttle_temperature, recovery_temperature } =
    machine;
  if (
    !Number.isFinite(temperature_limit) ||
    typeof throttle_temperature !== 'number' ||
    !Number.isFinite(throttle_temperature) ||
    typeof recovery_temperature !== 'number' ||
    !Number.isFinite(recovery_temperature)
  ) {
    return null;
  }
  const celsius = (kelvin: number) => `${(kelvin - 273.15).toFixed(1)} °C`;
  return (
    <Box mt={1}>
      <LabeledList>
        <LabeledList.Item label="Снижение частоты CPU">
          Выше {celsius(throttle_temperature)}
        </LabeledList.Item>
        <LabeledList.Item label="Восстановление частоты">
          При {celsius(recovery_temperature)} и ниже
        </LabeledList.Item>
        <LabeledList.Item label="Аварийный предел">
          {celsius(temperature_limit)}
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1} color="label">
        Охлаждайте шкаф до порога восстановления: частота возвращается
        постепенно. Длительный перегрев выше аварийного предела отключает шкаф.
      </Box>
    </Box>
  );
}
