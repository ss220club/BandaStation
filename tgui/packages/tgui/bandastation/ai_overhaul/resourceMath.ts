export function resourceAvailability(
  totalCpu: number,
  assignedCpu: number,
  totalRam: number,
  assignedRam: number,
) {
  const cpuFraction = Math.max(0, Math.min(1, 1 - assignedCpu));
  return {
    cpuFraction,
    cpuThz: Math.max(0, totalCpu) * cpuFraction,
    ram: Math.max(0, totalRam - assignedRam),
  };
}

export function safeRatio(value: number, capacity: number) {
  return capacity > 0 ? Math.max(0, Math.min(1, value / capacity)) : 0;
}
