/** Window sizes in pixels */
export enum WindowSize {
  Small = 30,
  Medium = 50,
  Large = 70,
  Width = 231,
}

/** Line lengths for autoexpand */
export enum LineLength {
  Small = 20,
  Medium = 40,
}

/**
 * Radio prefixes.
 * Displays the name in the left button, tags a css class.
 */
export const RADIO_PREFIXES = {
  ':a ': 'Hive',
  ':b ': 'io',
  ':c ': 'Cmd',
  ':e ': 'Engi',
  ':g ': 'Cling',
  ':m ': 'Med',
  ':n ': 'Sci',
  ':o ': 'AI',
  ':p ': 'Ent',
  ':s ': 'Sec',
  ':t ': 'Synd',
  ':u ': 'Supp',
  ':v ': 'Svc',
  ':y ': 'CCom',
  // BANDASTATION ADDITION START
  ':ф ': 'Рой',
  ':и ': 'вв',
  ':с ': 'Ком',
  ':у ': 'Инж',
  ':п ': 'Ген',
  ':ь ': 'Мед',
  ':т ': 'Иссл',
  ':щ ': 'ИИ',
  ':з ': 'Разв',
  ':ы ': 'Без',
  ':д ': 'Юр',
  ':е ': 'Синд',
  ':г ': 'Снаб',
  ':м ': 'Обсл',
  ':н ': 'ЦК',
  // BANDASTATION EDIT END
} as const;
