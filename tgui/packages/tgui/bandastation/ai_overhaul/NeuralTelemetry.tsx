import { Box, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type Sample = {
  time: number;
  segment: number;
  source: string;
  cpu: number;
  cpu_nominal?: number;
  cpu_reserved: number;
  ram: number;
  ram_used: number;
  temperature: number;
  temperature_limit: number;
};

export type TelemetryHistory = {
  samples: Sample[];
  now: number;
  age: number | null;
  recording: BooleanLike;
};

export function NeuralTelemetry({ history }: { history: TelemetryHistory }) {
  const samples = history.samples || [];
  const latest = samples[samples.length - 1];
  return (
    <Section title="История телеметрии">
      <Box
        color={history.recording && (history.age ?? 99) < 5 ? 'good' : 'label'}
        mb={1}
      >
        {history.age === null
          ? 'Измерений ещё нет'
          : `Последний замер: ${Math.ceil(history.age)} с назад · ${history.recording ? 'запись идёт' : 'нет связи'}`}
      </Box>
      <Box color="label" mb={2}>
        Последние две минуты · замер каждые 2 с. Источник температуры — текущее
        ядро. Разрывы связи и смена ядра или сети разрывают линии. CPU
        показывает назначение и резерв программ, а не фактическую загрузку
        процессоров.
      </Box>
      {!latest ? (
        <NoticeBox info>
          В этом интервале нет измерений. Для записи нужно подключение к
          работающему ядру.
        </NoticeBox>
      ) : (
        <>
          <Box mb={1}>Источник последнего замера: {latest.source}</Box>
          <div className="AiOS__historyGrid">
            <HistoryChart
              history={history}
              title="Личный CPU"
              unit="ТГц"
              first="cpu"
              second="cpu_reserved"
              firstLabel="Доступно"
              secondLabel="Резерв программ"
            />
            <HistoryChart
              history={history}
              title="Память"
              unit="ТБ"
              first="ram"
              second="ram_used"
              firstLabel="Доступно с компрессором"
              secondLabel="Занято программами"
            />
            <HistoryChart
              history={history}
              title="Температура ядра"
              unit="К"
              first="temperature"
              second="temperature_limit"
              firstLabel="Измерено"
              secondLabel="Предел"
            />
          </div>
        </>
      )}
    </Section>
  );
}

function HistoryChart({
  history,
  title,
  unit,
  first,
  second,
  firstLabel,
  secondLabel,
}: {
  history: TelemetryHistory;
  title: string;
  unit: string;
  first: 'cpu' | 'ram' | 'temperature';
  second: 'cpu_reserved' | 'ram_used' | 'temperature_limit';
  firstLabel: string;
  secondLabel: string;
}) {
  const samples = history.samples;
  const values = samples.flatMap((sample) => [sample[first], sample[second]]);
  const lower =
    first === 'temperature' ? Math.floor(Math.min(...values) - 2) : 0;
  const upper = Math.max(
    lower + 1,
    Math.ceil(Math.max(...values) + (first === 'temperature' ? 2 : 0)),
  );
  const latest = samples[samples.length - 1];
  const segments: Sample[][] = [];
  for (const sample of samples) {
    const previous = segments[segments.length - 1];
    if (previous?.[0].segment === sample.segment) previous.push(sample);
    else segments.push([sample]);
  }
  const x = (sample: Sample) =>
    4 + ((sample.time - history.now + 120) / 120) * 592;
  const y = (value: number) => 106 - ((value - lower) / (upper - lower)) * 102;
  return (
    <div className="AiOS__historyChart">
      <strong>{title}</strong>
      <div className="AiOS__historyScale">
        <span>Диапазон</span>
        <span>
          {lower}–{upper} {unit}
        </span>
      </div>
      <svg
        viewBox="0 0 600 110"
        preserveAspectRatio="none"
        role="img"
        aria-label={`${title}: ${firstLabel} ${latest[first].toFixed(2)}, ${secondLabel} ${latest[second].toFixed(2)} ${unit}`}
      >
        <title>{`${title}. Пробелы означают отсутствие измерений.`}</title>
        {segments.map((segment) => (
          <g key={segment[0].segment}>
            {([first, second] as const).map((key, index) => (
              <g
                key={key}
                className={`AiOS__historyLine AiOS__historyLine--${index}`}
              >
                <polyline
                  points={segment
                    .map((sample) => `${x(sample)},${y(sample[key])}`)
                    .join(' ')}
                  vectorEffect="non-scaling-stroke"
                />
                {segment.length === 1 && (
                  <circle cx={x(segment[0])} cy={y(segment[0][key])} r="2" />
                )}
              </g>
            ))}
          </g>
        ))}
      </svg>
      <div className="AiOS__historyTimes">
        <span>−120 с</span>
        <span>сейчас</span>
      </div>
      <div className="AiOS__historyLegend">
        <span>
          {firstLabel}:{' '}
          <strong>
            {latest[first].toFixed(2)} {unit}
          </strong>
        </span>
        <span>
          {secondLabel}:{' '}
          <strong>
            {latest[second].toFixed(2)} {unit}
          </strong>
        </span>
      </div>
      {first === 'cpu' && latest.cpu_nominal !== undefined && (
        <Box color="label" mt={0.5}>
          Номинал личного назначения: {latest.cpu_nominal.toFixed(2)} ТГц.
          Разница с доступным CPU — тепловое ограничение серверов.
        </Box>
      )}
    </div>
  );
}
