import { Box, Button, Icon, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export { NetworkHeader } from './NeuralHeader';

export function CpuThermalStatus({
  nominal,
  effective,
}: {
  nominal?: number;
  effective: number;
}) {
  if (
    !nominal ||
    !Number.isFinite(nominal) ||
    !Number.isFinite(effective) ||
    effective >= nominal - 0.001
  )
    return null;
  return (
    <Box color="average" mb={1}>
      Тепловое ограничение CPU: {effective.toFixed(2)} из {nominal.toFixed(2)}{' '}
      ТГц ({Math.round((effective / nominal) * 100)}%). Проверьте охлаждение
      серверов. После охлаждения частота восстанавливается постепенно.
    </Box>
  );
}

export function NetworkLogin(props: {
  username: string;
  hasAccess: BooleanLike;
  onLogin: () => void;
}) {
  return (
    <Section title="Авторизация оператора">
      <Box mb={1}>{props.username || 'Оператор неизвестен'}</Box>
      <NoticeBox>
        {props.hasAccess
          ? 'Доступ подтверждён. Войдите для управления сетью.'
          : 'Ваша ID-карта не даёт доступа к этой консоли.'}
      </NoticeBox>
      <Button
        fluid
        icon="sign-in-alt"
        disabled={!props.hasAccess}
        onClick={props.onLogin}
      >
        {' '}
        Войти{' '}
      </Button>
    </Section>
  );
}

export function NetworkTelemetry(props: {
  cpu: number;
  ram: number;
  jobs: number;
  segments: number;
}) {
  return (
    <Box className="AiOS__telemetry">
      {[
        [
          'СВОБОДНЫЙ CPU',
          `${Math.max(0, props.cpu).toFixed(2)} ТГц`,
          'Свободно до резервирования подсетями',
          'До квот подсетей',
        ],
        [
          'СВОБОДНАЯ ПАМЯТЬ',
          `${Math.max(0, props.ram)} ТБ`,
          'Незарезервированная физическая RAM',
          'Свободная память',
        ],
        [
          'ГОТОВЫЕ ЗАДАЧИ',
          `${props.jobs}`,
          'Готовые задачи; некоторые могут ожидать CPU',
          'Готовые задачи',
        ],
        [
          'КАБЕЛЬНЫЕ СЕГМЕНТЫ',
          `${props.segments}`,
          'Физически раздельные сегменты общего ресурсного пула',
          'Сегменты этого пула',
        ],
      ].map(([label, value, caption, summary]) => (
        <div key={label} className="AiOS__metric" title={caption}>
          <Box className="AiOS__eyebrow">{label}</Box>
          <Box className="AiOS__metricValue">{value}</Box>
          <Box color="label" fontSize={0.85}>
            {summary}
          </Box>
        </div>
      ))}
    </Box>
  );
}

export function TaskSignal(props: {
  enabled: boolean;
  ready: boolean;
  cpu: number;
}) {
  const [label, color, icon] = !props.enabled
    ? ['ПРИОСТАНОВЛЕНО', 'label', 'pause']
    : !props.ready
      ? ['УЗЕЛ НЕДОСТУПЕН', 'bad', 'unlink']
      : props.cpu <= 0
        ? ['ОЖИДАНИЕ CPU', 'average', 'hourglass-half']
        : ['ВЫЧИСЛЕНИЯ', 'good', 'microchip'];
  return (
    <Box className="AiOS__signal" color={color}>
      <Icon name={icon} /> {label}
      {props.enabled && props.ready && props.cpu > 0
        ? ` · ${props.cpu.toFixed(2)} ТГц`
        : ''}
    </Box>
  );
}
