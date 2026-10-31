export type FeedbackLevel = 0 | 1 | 2 | 3;

export type DisplayTelemetry = {
  cpuReserved?: number;
  cpuScope?: 'projects' | 'network';
  memoryUsed?: number;
  memoryCapacity?: number;
  integrityPercent?: number;
  temperatures?: { value: number; limit: number }[];
};

export type DisplayFeedback = { level: FeedbackLevel; reason: string };

const finite = (value: number | undefined): value is number =>
  typeof value === 'number' && Number.isFinite(value);

export function displayFeedback(data: DisplayTelemetry = {}): DisplayFeedback {
  let result: DisplayFeedback = { level: 0, reason: 'ЛОКАЛЬНЫЙ ЭКРАН' };
  const observe = (level: FeedbackLevel, reason: string) => {
    if (level > 0 && level >= result.level) result = { level, reason };
  };
  if (finite(data.cpuReserved) && data.cpuReserved >= 0) {
    const share = data.cpuReserved;
    const level = share > 1.001 ? 3 : share >= 0.9 ? 2 : share >= 0.75 ? 1 : 0;
    observe(
      data.cpuScope === 'projects' && share >= 0.98 ? 3 : level,
      `${data.cpuScope === 'projects' ? 'ПРОЕКТЫ:' : 'СЕТЬ:'} CPU ВЫДЕЛЕН`,
    );
  }
  if (
    finite(data.memoryUsed) &&
    finite(data.memoryCapacity) &&
    data.memoryUsed >= 0 &&
    data.memoryCapacity >= 0
  ) {
    const used = data.memoryUsed;
    const capacity = data.memoryCapacity;
    observe(
      used > capacity + 0.001
        ? 3
        : capacity > 0 && used >= capacity
          ? 2
          : capacity > 0 && used / capacity >= 0.9
            ? 1
            : 0,
      'ПАМЯТЬ ЗАРЕЗЕРВИРОВАНА',
    );
  }
  for (const { value, limit } of data.temperatures || []) {
    if (!finite(value) || !finite(limit) || value <= 0 || limit <= 0) continue;
    const margin = limit - value;
    observe(
      margin <= 0 ? 3 : margin <= 3 ? 2 : margin <= 10 ? 1 : 0,
      'ТЕМПЕРАТУРА ЯДРА',
    );
  }
  if (finite(data.integrityPercent)) {
    observe(
      data.integrityPercent <= 35
        ? 3
        : data.integrityPercent < 70
          ? 2
          : data.integrityPercent < 90
            ? 1
            : 0,
      'ЦЕЛОСТНОСТЬ ЯДРА',
    );
  }
  return result;
}
