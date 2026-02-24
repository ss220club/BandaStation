// ============================================
// IPC OS STYLE SYSTEM
// ============================================
// Каждый бренд шасси имеет свою визуальную философию.
// От корпоративного минимализма до киберпанк-неона.
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
  /** Паттерн фона: 'stripes' = предупреждающие полосы, 'grid' = сетка-лоскут */
  bgPattern?: 'stripes' | 'grid';
  /**
   * Цвет базового текста.
   * Применяется на уровне контент-контейнера — перекрывает дефолтный белый.
   * Ключевая фича для Unbranded (фосфорный зелёный) и других.
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
    morpheus: '#4a90d9',
    etamin: '#d94a4a',
    bishop: '#4ad9a5',
    hesphiastos: '#d98f4a',
    ward_takahashi: '#8f4ad9',
    xion: '#4ad9d9',
    zeng_hu: '#a5d94a',
    shellguard: '#7a7a7a',
    cybersun: '#d94a8f',
    unbranded: '#5aff5a',
    hef: '#8a8a5a',
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
    hef: 'PatchworkOS',
  };
  return names[brand_key] ?? 'GenericOS';
}

/**
 * Возвращает визуальный профиль ОС для конкретного бренда.
 *
 * Философия каждого бренда:
 * - Morpheus:     корпоративный профессионализм, синий, чистота
 * - Etamin:       военный HUD, красно-чёрный, monospace, [[CAPS]]
 * - Bishop:       медицинская стерильность, холодный белый, максимум пространства
 * - Hesphiastos:  тяжёлая индустрия, янтарный, толстые рамки, warning stripes
 * - Ward-Takahashi: японский корпоративный минимализм, глубокий фиолет
 * - Xion:         базовый утилитаризм, нейтральный голубой
 * - Zeng-Hu:      органическая бионика, зелёный, максимум скруглений
 * - Shellguard:   утилитарная броня, серый, ноль украшений
 * - Cybersun:     cyberpunk неон, маджента+фиолет, максимальное свечение
 * - Unbranded:    ретро-терминал, фосфорный зелёный, CRT, monospace
 * - HEF:          лоскутная сборка, смешанный, сетка
 */
export function getOsStyle(brand_key: string): OsStyleConfig {
  switch (brand_key) {
    // ─────────────────────────────────────────────────────────────────
    // Morpheus Cyberkinetics — Corporate
    // Чистый корпоративный стиль. Синий центральный блик, округлые
    // углы, сдержанное свечение. «Профессионально и надёжно.»
    // ─────────────────────────────────────────────────────────────────
    case 'morpheus':
      return {
        borderRadius: '6px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.55,
        panelBgOpacity: 0.1,
        panelBorderOpacity: 0.38,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#d8eeff',
        bgStyle:
          'radial-gradient(ellipse at 50% -10%, rgba(74,144,217,0.32) 0%, rgba(0,0,0,0.97) 55%)',
        styleDesc: 'Corporate',
      };

    // ─────────────────────────────────────────────────────────────────
    // Etamin Industry — Military HUD
    // Тактический боевой интерфейс. Красно-чёрный градиент снизу,
    // сканлайны, monospace, острые края, [[ ЗАГОЛОВОК CAPS ]].
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
    // Bishop Cybernetics — Medical
    // Медицинский минимализм. Стерильная тьма с мягким бирюзовым
    // снизу. Максимальные скругления, тонкие линии, много воздуха.
    // «Точность. Чистота. Жизнь.»
    // ─────────────────────────────────────────────────────────────────
    case 'bishop':
      return {
        borderRadius: '10px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.2,
        panelBgOpacity: 0.05,
        panelBorderOpacity: 0.22,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#e8fff8',
        bgStyle:
          'linear-gradient(175deg, rgba(0,8,6,0.98) 0%, rgba(50,180,130,0.12) 100%)',
        styleDesc: 'Medical',
      };

    // ─────────────────────────────────────────────────────────────────
    // Hesphiastos Industries — Industrial
    // Тяжёлый индустриальный интерфейс. Янтарно-оранжевый накал,
    // толстые рамки, предупреждающие полосы. Броня и огонь.
    // ─────────────────────────────────────────────────────────────────
    case 'hesphiastos':
      return {
        borderRadius: '2px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.6,
        panelBgOpacity: 0.2,
        panelBorderOpacity: 0.7,
        borderWidth: '3px',
        textTransform: 'uppercase',
        textColor: '#ffe0b0',
        bgStyle:
          'linear-gradient(155deg, rgba(30,10,0,0.99) 0%, rgba(200,120,40,0.22) 55%, rgba(12,4,0,0.99) 100%)',
        bgPattern: 'stripes',
        styleDesc: 'Industrial',
      };

    // ─────────────────────────────────────────────────────────────────
    // Ward-Takahashi — Elegant Minimal
    // Японский корпоративный минимализм. Глубокий фиолет, тончайшие
    // линии, утончённость без излишеств. «Меньше — больше.»
    // ─────────────────────────────────────────────────────────────────
    case 'ward_takahashi':
      return {
        borderRadius: '4px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.55,
        panelBgOpacity: 0.05,
        panelBorderOpacity: 0.18,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#ecdeff',
        bgStyle:
          'linear-gradient(145deg, rgba(4,0,14,0.98) 0%, rgba(120,60,220,0.2) 55%, rgba(0,0,8,0.99) 100%)',
        styleDesc: 'Elegant Minimal',
      };

    // ─────────────────────────────────────────────────────────────────
    // Xion Manufacturing — Standard
    // Нейтральный функциональный интерфейс. Бюджетная бирюза без
    // украшений. Просто работает.
    // ─────────────────────────────────────────────────────────────────
    case 'xion':
      return {
        borderRadius: '3px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.28,
        panelBgOpacity: 0.08,
        panelBorderOpacity: 0.28,
        borderWidth: '1px',
        textTransform: 'none',
        bgStyle:
          'linear-gradient(135deg, rgba(0,0,0,0.97) 0%, rgba(60,200,200,0.09) 50%, rgba(0,0,0,0.97) 100%)',
        styleDesc: 'Standard',
      };

    // ─────────────────────────────────────────────────────────────────
    // Zeng-Hu Pharmaceuticals — Organic / Bio
    // Органическая бионика. Радиальный жёлто-зелёный сверху,
    // максимально скруглённые края, мягкая зелень. «Живой интерфейс.»
    // ─────────────────────────────────────────────────────────────────
    case 'zeng_hu':
      return {
        borderRadius: '14px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.45,
        panelBgOpacity: 0.1,
        panelBorderOpacity: 0.28,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#edffd8',
        bgStyle:
          'radial-gradient(ellipse at 50% -5%, rgba(150,220,60,0.28) 0%, rgba(0,4,0,0.97) 58%)',
        styleDesc: 'Organic / Bio',
      };

    // ─────────────────────────────────────────────────────────────────
    // Shellguard Munitions — Utilitarian
    // Абсолютный утилитаризм. Чистый серый без единого украшения.
    // Ноль свечения. «Работает — значит достаточно.»
    // ─────────────────────────────────────────────────────────────────
    case 'shellguard':
      return {
        borderRadius: '0px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.04,
        panelBgOpacity: 0.16,
        panelBorderOpacity: 0.75,
        borderWidth: '2px',
        textTransform: 'uppercase',
        textColor: '#cccccc',
        bgStyle:
          'linear-gradient(180deg, rgba(18,18,18,0.99) 0%, rgba(12,12,12,1) 100%)',
        styleDesc: 'Utilitarian',
      };

    // ─────────────────────────────────────────────────────────────────
    // Cybersun Industries — Cyberpunk Neon
    // Максимальный киберпанк. Два мощных радиальных источника неона
    // (маджента + фиолет), сканлайны, максимальное свечение.
    // «Ночь — это наш день.»
    // ─────────────────────────────────────────────────────────────────
    case 'cybersun':
      return {
        borderRadius: '2px',
        fontFamily: 'inherit',
        scanlines: true,
        scanlinesOpacity: 0.09,
        glowIntensity: 1.0,
        panelBgOpacity: 0.12,
        panelBorderOpacity: 0.65,
        borderWidth: '1px',
        textTransform: 'none',
        textColor: '#ffd8f0',
        bgStyle:
          'radial-gradient(ellipse at 25% 20%, rgba(220,70,150,0.42) 0%, transparent 48%), ' +
          'radial-gradient(ellipse at 75% 80%, rgba(130,0,255,0.28) 0%, transparent 45%), ' +
          'rgba(2,0,6,0.98)',
        styleDesc: 'Cyberpunk Neon',
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
    // HEF — Patchwork
    // Лоскутный эклектизм. Несимметричный оливковый градиент,
    // сетка-оверлей. Собрано из того, что было.
    // ─────────────────────────────────────────────────────────────────
    case 'hef':
      return {
        borderRadius: '4px',
        fontFamily: 'inherit',
        scanlines: false,
        scanlinesOpacity: 0,
        glowIntensity: 0.3,
        panelBgOpacity: 0.09,
        panelBorderOpacity: 0.28,
        borderWidth: '1px',
        textTransform: 'none',
        bgStyle:
          'linear-gradient(110deg, rgba(0,0,0,0.97) 0%, rgba(130,130,80,0.16) 33%, rgba(0,0,0,0.97) 62%, rgba(130,130,80,0.11) 100%)',
        bgPattern: 'grid',
        styleDesc: 'Patchwork',
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
