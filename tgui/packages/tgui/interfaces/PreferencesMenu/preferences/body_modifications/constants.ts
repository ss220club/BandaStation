export const MANUFACTURER_COLORS: Record<string, string> = {
  none: '#666666',
  general: '#888888',
  bishop: '#5b9bd5',
  'bishop mk2': '#4a87c5',
  'bishop nano': '#7ab5e5',
  'etamin industry': '#c8a100',
  'etamin industry lumineux': '#f0c060',
  gromtech: '#6899c4',
  hephaestus: '#3a6e3a',
  'hephaestus titan': '#2d5a2d',
  interdyne: '#00acc1',
  morpheus: '#424242',
  shellguard: '#c62828',
  wardtakahashi: '#9e9e9e',
  'wardtakahashi pro': '#757575',
  xion: '#e65c00',
  'xion light': '#ff9433',
  'zeng-hu': '#ff9800',
};

export const MANUFACTURER_DESCRIPTIONS: Record<string, string> = {
  none: 'Без протеза. Чистый органический вид.',
  general: 'Стандартный протез без выраженной фирменной стилистики.',
  bishop: 'Базовая линейка Bishop с надежной, проверенной электроникой.',
  'bishop mk2':
    'Второе поколение Bishop: лучше сенсорика и стабильнее нейроинтерфейс.',
  'bishop nano': 'Компактная серия Bishop с акцентом на легкость и скрытность.',
  'etamin industry':
    'Индустриальная линейка Etamin: прочные узлы и утилитарный дизайн.',
  'etamin industry lumineux':
    'Серия Lumineux от Etamin с более выразительной визуальной отделкой.',
  gromtech:
    'Тяжелые протезы GromTech для высоких нагрузок и грубой эксплуатации.',
  hephaestus: 'Классическая инженерная линейка Hephaestus Industries.',
  'hephaestus titan':
    'Усиленная серия Titan: повышенная прочность и износостойкость.',
  interdyne:
    'Высокоточная биомех-линейка Interdyne с упором на чувствительность.',
  morpheus: 'Нейроориентированные решения Morpheus Cyberkinetics.',
  shellguard: 'Защищенная платформа Shellguard с упором на боевую выживаемость.',
  wardtakahashi: 'Элегантная линейка WardTakahashi для повседневного использования.',
  'wardtakahashi pro':
    'Премиум-серия WardTakahashi с улучшенной кинематикой.',
  xion: 'Экспериментальная платформа Xion: агрессивный дизайн и гибкая настройка.',
  'xion light': 'Облегченная серия Xion с минимальным весом.',
  'zeng-hu': 'Биомедицинская линейка Zeng-Hu с тонкой настройкой интерфейсов.',
};

export const getManufacturerColor = (name: string): string => {
  const lowerName = name.toLowerCase();
  return MANUFACTURER_COLORS[lowerName] || '#888888';
};

export const CATEGORY_CONFIG: Record<
  string,
  { icon: string; colorClass: string; order: number; color: string }
> = {
  Протезы: {
    icon: 'hand-paper',
    colorClass: 'prosthetics',
    order: 1,
    color: '#ffc800',
  },
  Prosthetics: {
    icon: 'hand-paper',
    colorClass: 'prosthetics',
    order: 1,
    color: '#ffc800',
  },
  Импланты: {
    icon: 'microchip',
    colorClass: 'implants',
    order: 2,
    color: '#ff2a6d',
  },
  Implants: {
    icon: 'microchip',
    colorClass: 'implants',
    order: 2,
    color: '#ff2a6d',
  },
  Органы: { icon: 'heart', colorClass: 'organs', order: 3, color: '#ff3333' },
  Organs: { icon: 'heart', colorClass: 'organs', order: 3, color: '#ff3333' },
  Ампутации: {
    icon: 'cut',
    colorClass: 'prosthetics',
    order: 4,
    color: '#ffc800',
  },
  Amputations: {
    icon: 'cut',
    colorClass: 'prosthetics',
    order: 4,
    color: '#ffc800',
  },
  Роботизация: {
    icon: 'robot',
    colorClass: 'chassis',
    order: 5,
    color: '#0080ff',
  },
  Robotic: {
    icon: 'robot',
    colorClass: 'chassis',
    order: 5,
    color: '#0080ff',
  },
};

export const DEFAULT_CATEGORY_CONFIG = {
  icon: 'cog',
  colorClass: 'implants',
  order: 99,
  color: '#00f0ff',
};
