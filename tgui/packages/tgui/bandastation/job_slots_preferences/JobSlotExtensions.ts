export function extendJobSlotOptions(
  options: { value: number; displayText: string }[],
) {
  options.push({
    value: -1,
    displayText: 'Случайное имя и внешность активного персонажа',
  });
}

export function jobSlotIconProps(slot: number) {
  return slot === -1 ? { icon: 'dice' } : {};
}
