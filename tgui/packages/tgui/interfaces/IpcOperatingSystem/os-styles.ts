// ============================================
// IPC OS STYLE SYSTEM
// ============================================
// Каждый бренд шасси несёт свою корпоративную философию.
// Разные компании — разные ОС. Как настоящие.
// ============================================

/**
 * Визуальный профиль ОС — каждый бренд имеет свой стиль интерфейса.
 */
export type OsStyleConfig = {
  /** CSS border-radius для панелей и контейнеров */
  borderRadius: string;
  /** CSS font-family: 'monospace' для терминальных стилей, иначе 'inherit' */
  fontFamily: string;
  /** Показывать ли оверлей со сканлайнами (CRT-эффект) */
  scanlines: boolean;
  /** Непрозрачность сканлайн-оверлея (0–1) */
  scanlinesOpacity: number;
  /** Интенсивность свечения текста (0 = нет, 1 = максимум) */
  glowIntensity: number;
  /** Прозрачность фона панелей (0–1) */
  panelBgOpacity: number;
  /** Прозрачность рамок панелей (0–1) */
  panelBorderOpacity: number;
  /** Ширина рамок */
  borderWidth: string;
  /** Трансформация текста заголовков */
  textTransform: 'none' | 'uppercase';
  /** CSS background для Window.Content — уникальный фон бренда */
  bgStyle: string;
  /** Паттерн фона поверх bgStyle */
  bgPattern?: 'stripes' | 'grid';
  /**
   * Цвет паттерна (CSS rgba строка).
   * Если не указан — использует дефолт (оранжевый для stripes, оливковый для grid).
   */
  bgPatternColor?: string;
  /**
   * Цвет базового текста — перекрывает дефолтный белый на уровне контейнера.
   * Ключевая фича для Unbranded (зелёный), Etamin (красноватый) и т.д.
   */
  textColor?: string;
  /** Префикс заголовков приложений (напр. '[ ' для Etamin) */
  headerPrefix?: string;
  /** Суффикс заголовков приложений (напр. ' ]' для Etamin) */
  headerSuffix?: string;
  /** Описание стиля для дебаг-бара */
  styleDesc: string;
};

/** Полный список ключей брендов для цикличного переключения в дебаг-режиме */
export const ALL_BRAND_KEYS = [
  'morpheus',
  'etamin',
  'bishop',
  'hesphiastos',
  'ward_takahashi',
  'xion',
  'zeng_hu',
  'shellguard',
  'cybersun',
  'unbranded',
  'hef',
] as const;

export type BrandKey = (typeof ALL_BRAND_KEYS)[number];

/** Возвращает hex-цвет акцента темы по ключу бренда */
export function getOsBrandColor(brand_key: string): string {
  const colors: Record<string, string> = {
    morpheus: '#9b59d9',    // Фиолетовый корпоративный
    etamin: '#d94a4a',      // Красный военный
    bishop: '#4a8fd9',      // Стальной синий медицинский
    hesphiastos: '#4a8a3a', // Военный зелёный
    ward_takahashi: '#9a9aaa', // Серебристо-серый
    xion: '#d97820',        // Инженерный оранжевый
    zeng_hu: '#d4845a',     // Тёплый коралл
    shellguard: '#aa1111',  // Тёмно-красный
    cybersun: '#dd1133',    // Зловещий алый неон
    unbranded: '#5aff5a',   // Фосфорный зелёный
    hef: '#9060cc',         // Призрачный фиолет
  };
  return colors[brand_key] ?? '#6a6a6a';
}

/** Возвращает название ОС по ключу бренда */
export function getOsStyleName(brand_key: string): string {
  const names: Record<string, string> = {
    morpheus: 'MorphOS',
    etamin: 'EtaminOS',
    bishop: 'BishopNet',
    hesphiastos: 'HephForge',
    ward_takahashi: 'WardLink',
    xion: 'XionShell',
    zeng_hu: 'ZengMed',
    shellguard: 'ShellGuardOS',
    cybersun: 'NightSun',
    unbranded: 'FreeOS',
    hef: 'Yūrei OS',
  };
  return names[brand_key] ?? 'GenericOS';
}

/**
 * Возвращает визуальный профиль ОС для конкретного бренда.
 *
 * Философия каждого бренда:
 * - Morpheus:       корпоративный фиолет — чистота, профессионализм
 * - Etamin:         военный красно-чёрный HUD — тактика, monospace, [[CAPS]]
 * - Bishop:         медицинский стальной синий — холодная стерильность
 * - Hesphiastos:    военный зелёный — тяжёлая промышленность, warning stripes
 * - Ward-Takahashi: минималистичный серый — японский корпоративный дзен
 * - Xion:           инженерный оранжевый — функционально, без излишеств
 * - Zeng-Hu:        тёплый коралловый — органика, человечность
 * - Shellguard:     чёрный с тёмно-красным — броня, утилитаризм, ноль украшений
 * - Cybersun:       зловещий алый неон — кибerpunk мрак и угроза
 * - Unbranded:      фосфорный зелёный терминал — хакер, CRT, retro
 * - HEF (Yūrei OS): призрачный фиолет — лоскут, сетка, экзотика
 */
export function getOsStyle(brand_key: string): OsStyleConfig {
  switch (brand_key) {
    // ─────────────────────────────────────────────────────────────────
    // Morpheus Cyberkinetics — Corporate Purple
    // Корпоративная чистота с фиолетовым акцентом. Скруглённые углы,
    // тонкие рамки, мягкое свечение. «Профессионально. Надёжно.»
    // ─────────────────────────────────────────────────────────────────
    case 'morpheus':
      return {
        borderRadius: '6px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.6,
        panelBgOpacity: 0.1,
        panelBorderOpacity: 0.38,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#ecdeff',
        bgStyle:
          'radial-gradient(ellipse at 50% -8%, rgba(155,89,217,0.38) 0%, rgba(2,0,8,0.97) 55%)',
        styleDesc: 'Corporate Purple',
      };

    // ─────────────────────────────────────────────────────────────────
    // Etamin Industry — Military HUD
    // Тактический боевой интерфейс. Красно-чёрный градиент снизу,
    // сканлайны, monospace, острые края, [ ЗАГОЛОВОК CAPS ].
    // «Угроза нейтрализована.»
    // ─────────────────────────────────────────────────────────────────
    case 'etamin':
      return {
        borderRadius: '0px',
        fontFamily: 'monospace',
        scanlines: true,
        scanlinesOpacity: 0.1,
        glowIntensity: 0.45,
        panelBgOpacity: 0.18,
        panelBorderOpacity: 0.6,
        borderWidth: '2px',
        textTransform: 'uppercase',
        textColor: '#ffcccc',
        bgStyle:
          'linear-gradient(180deg, rgba(10,0,0,0.99) 0%, rgba(180,40,40,0.18) 55%, rgba(6,0,0,1) 100%)',
        headerPrefix: '[ ',
        headerSuffix: ' ]',
        styleDesc: 'Military HUD',
      };

    // ─────────────────────────────────────────────────────────────────
    // Bishop Cybernetics — Medical Steel
    // Медицинская стерильность. Холодный стальной синий снизу.
    // Максимальные скругления, тонкие линии, много воздуха.
    // «Точность. Чистота. Жизнь.»
    // ─────────────────────────────────────────────────────────────────
    case 'bishop':
      return {
        borderRadius: '10px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.22,
        panelBgOpacity: 0.05,
        panelBorderOpacity: 0.22,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#d8eeff',
        bgStyle:
          'linear-gradient(175deg, rgba(0,4,12,0.98) 0%, rgba(74,143,217,0.16) 100%)',
        styleDesc: 'Medical Steel',
      };

    // ─────────────────────────────────────────────────────────────────
    // Hesphiastos Industries — Military Green
    // Тяжёлый военно-промышленный интерфейс. Оливково-зелёный,
    // толстые рамки, предупреждающие зелёные полосы. Броня.
    // ─────────────────────────────────────────────────────────────────
    case 'hesphiastos':
      return {
        borderRadius: '2px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.55,
        panelBgOpacity: 0.2,
        panelBorderOpacity: 0.7,
        borderWidth: '3px',
        textTransform: 'uppercase',
        textColor: '#c8e8a8',
        bgStyle:
          'linear-gradient(155deg, rgba(0,12,0,0.99) 0%, rgba(74,138,58,0.22) 55%, rgba(0,8,0,0.99) 100%)',
        bgPattern: 'stripes',
        bgPatternColor: 'rgba(74,138,58,0.06)',
        styleDesc: 'Military Green',
      };

    // ─────────────────────────────────────────────────────────────────
    // Ward-Takahashi — Elegant Gray
    // Японский корпоративный минимализм. Холодный нейтральный серый,
    // тончайшие линии, без излишеств. «Меньше — больше.»
    // ─────────────────────────────────────────────────────────────────
    case 'ward_takahashi':
      return {
        borderRadius: '4px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.35,
        panelBgOpacity: 0.05,
        panelBorderOpacity: 0.2,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#d8d8e8',
        bgStyle:
          'linear-gradient(145deg, rgba(6,6,8,0.98) 0%, rgba(120,120,140,0.18) 55%, rgba(2,2,4,0.99) 100%)',
        styleDesc: 'Elegant Gray',
      };

    // ─────────────────────────────────────────────────────────────────
    // Xion Manufacturing Group — Engineering Orange
    // Инженерный функционализм. Оранжевый как знаки горных работ.
    // Просто работает. Без украшений.
    // ─────────────────────────────────────────────────────────────────
    case 'xion':
      return {
        borderRadius: '3px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.5,
        panelBgOpacity: 0.1,
        panelBorderOpacity: 0.45,
        borderWidth: '2px',
        textTransform: 'uppercase',
        textColor: '#ffe0b0',
        bgStyle:
          'radial-gradient(ellipse at 50% -5%, rgba(217,120,32,0.28) 0%, rgba(0,0,0,0.97) 55%)',
        styleDesc: 'Engineering Orange',
      };

    // ─────────────────────────────────────────────────────────────────
    // Zeng-Hu Pharmaceuticals — Human Warmth
    // Тёплый коралловый. Органические формы, максимальные скругления.
    // Похоже на что-то созданное для людей, а не машин.
    // ─────────────────────────────────────────────────────────────────
    case 'zeng_hu':
      return {
        borderRadius: '14px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.4,
        panelBgOpacity: 0.1,
        panelBorderOpacity: 0.28,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#ffeedd',
        bgStyle:
          'radial-gradient(ellipse at 50% -5%, rgba(212,132,90,0.3) 0%, rgba(4,2,0,0.97) 58%)',
        styleDesc: 'Human Warmth',
      };

    // ─────────────────────────────────────────────────────────────────
    // Shellguard Munitions — Black & Red
    // Абсолютный мрак с красным акцентом. Ноль украшений, ноль свечения.
    // Только броня и функция. «Цель нейтрализована.»
    // ─────────────────────────────────────────────────────────────────
    case 'shellguard':
      return {
        borderRadius: '0px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.04,
        panelBgOpacity: 0.18,
        panelBorderOpacity: 0.75,
        borderWidth: '2px',
        textTransform: 'uppercase',
        textColor: '#cc8888',
        bgStyle:
          'linear-gradient(180deg, rgba(5,0,0,0.99) 0%, rgba(10,0,0,1) 100%)',
        styleDesc: 'Black & Red',
      };

    // ─────────────────────────────────────────────────────────────────
    // Cybersun Industries — Crimson Neon
    // Зловещий алый киберпанк. Два мощных красных радиальных источника.
    // Сканлайны, максимальное свечение. «Ночь не безопасна.»
    // ─────────────────────────────────────────────────────────────────
    case 'cybersun':
      return {
        borderRadius: '2px',
        fontFamily: 'inherit',
        scanlines: true,
        scanlinesOpacity: 0.1,
        glowIntensity: 1.0,
        panelBgOpacity: 0.12,
        panelBorderOpacity: 0.65,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#ffaabb',
        bgStyle:
          'radial-gradient(ellipse at 25% 20%, rgba(220,20,50,0.48) 0%, transparent 48%), ' +
          'radial-gradient(ellipse at 75% 80%, rgba(160,0,20,0.32) 0%, transparent 45%), ' +
          'rgba(3,0,0,0.99)',
        styleDesc: 'Crimson Neon',
      };

    // ─────────────────────────────────────────────────────────────────
    // Unbranded / FreeOS — Retro Terminal
    // Хакерский ретро-терминал. Почти чёрный с фосфорным зелёным.
    // Monospace, тяжёлые сканлайны. «Root access granted.»
    // ─────────────────────────────────────────────────────────────────
    case 'unbranded':
      return {
        borderRadius: '0px',
        fontFamily: 'monospace',
        scanlines: true,
        scanlinesOpacity: 0.14,
        glowIntensity: 0.85,
        panelBgOpacity: 0.06,
        panelBorderOpacity: 0.4,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#5aff5a',
        bgStyle:
          'radial-gradient(ellipse at 50% 55%, rgba(80,130,80,0.18) 0%, rgba(0,3,0,0.99) 60%)',
        styleDesc: 'Retro Terminal',
      };

    // ─────────────────────────────────────────────────────────────────
    // HEF — Yūrei OS (Призрак ОС)
    // Лоскутный призрачный фиолет. Сетка-оверлей, эклектика.
    // Собрано из всего что было. 幽霊.
    // ─────────────────────────────────────────────────────────────────
    case 'hef':
      return {
        borderRadius: '4px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.45,
        panelBgOpacity: 0.09,
        panelBorderOpacity: 0.32,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#d8b8ff',
        bgStyle:
          'linear-gradient(110deg, rgba(2,0,6,0.97) 0%, rgba(100,60,180,0.18) 33%, rgba(2,0,6,0.97) 62%, rgba(100,60,180,0.12) 100%)',
        bgPattern: 'grid',
        bgPatternColor: 'rgba(144,96,204,0.06)',
        styleDesc: 'Yūrei — Призрак',
      };

    default:
      return {
        borderRadius: '4px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.4,
        panelBgOpacity: 0.08,
        panelBorderOpacity: 0.3,
        borderWidth: '1px',
        textTransform: 'none',
        bgStyle:
          'linear-gradient(135deg, rgba(0,0,0,0.95) 0%, rgba(106,106,106,0.1) 50%, rgba(0,0,0,0.95) 100%)',
        styleDesc: 'Standard',
      };
  }
}
