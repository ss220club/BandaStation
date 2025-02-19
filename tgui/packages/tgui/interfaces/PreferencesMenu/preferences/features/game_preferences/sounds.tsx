import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureSliderInput,
  FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const sound_ambience_volume: Feature<number> = {
  name: 'Громкость окружения',
  category: 'ЗВУК',
  description: `Различные звуки оружения, играющие по ситуации.`,
  component: FeatureSliderInput,
};

export const sound_breathing: FeatureToggle = {
  name: 'Включить звук дыхания',
  category: 'ЗВУК',
  description: 'Слышать звук дыхания, когда подключен баллон.',
  component: CheckboxInput,
};

export const sound_announcements: FeatureToggle = {
  name: 'Включить звук анонсов',
  category: 'ЗВУК',
  description: 'Играть звук при оповещениях с ЦК, уведомлений и тд.',
  component: CheckboxInput,
};

export const sound_combatmode: FeatureToggle = {
  name: 'Включить звук режима боя',
  category: 'ЗВУК',
  description: 'Играть звук при переключении режима боя.',
  component: CheckboxInput,
};

export const sound_endofround: FeatureToggle = {
  name: 'Включить звук конца раунда',
  category: 'ЗВУК',
  description: 'Играть звук, когда сервер начинает перезапуск.',
  component: CheckboxInput,
};

export const sound_instruments: FeatureToggle = {
  name: 'Включить звук музыкальных инструментов',
  category: 'ЗВУК',
  description: 'Играть звук музыкальных инструментов.',
  component: CheckboxInput,
};

export const sound_tts: FeatureChoiced = {
  name: 'TTS - включить',
  category: 'ЗВУК',
  description: `
    Играть звук text-to-speech.
    Функция "Blips" не работает.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_volume: Feature<number> = {
  name: 'TTS - громкость',
  category: 'ЗВУК',
  description: 'Громкость text-to-speech.',
  component: FeatureSliderInput,
};

export const sound_jukebox: FeatureToggle = {
  name: 'Включить звук музыкальных автоматов',
  category: 'ЗВУК',
  description: 'Играть звук музыкальных автоматов, диско-машин и тд.',
  component: CheckboxInput,
};

export const sound_lobby_volume: Feature<number> = {
  name: 'Громкость музыки в лобби',
  category: 'ЗВУК',
  component: FeatureSliderInput,
};

export const sound_midi: FeatureToggle = {
  name: 'Включить звук админской музыки',
  category: 'ЗВУК',
  description: 'Играть звук музыки, запускаемой администрацией.',
  component: CheckboxInput,
};

export const sound_ship_ambience_volume: Feature<number> = {
  name: 'Громкость звуков корабля',
  category: 'ЗВУК',
  description: `Зацикленный звук окружения корабля (низкий гул).`,
  component: FeatureSliderInput,
};

export const sound_elevator: FeatureToggle = {
  name: 'Включить музыку в лифтах',
  category: 'ЗВУК',
  component: CheckboxInput,
};

export const sound_achievement: FeatureChoiced = {
  name: 'Звук при получении достижений',
  category: 'ЗВУК',
  description: `
    Выбор звука, который будет играть при получении достижения.
    При отключении звука не будет.
  `,
  component: FeatureDropdownInput,
};

export const sound_radio_noise: Feature<number> = {
  name: 'Громкость оповещения рации',
  category: 'ЗВУК',
  description: `Громкость оповещений, когда в рацию кто-то говорит.`,
  component: FeatureSliderInput,
};

export const sound_ai_vox: FeatureToggle = {
  name: 'Включить звук VOX ИИ',
  category: 'ЗВУК',
  description:
    'Слышать краткие озвученные сообщения от ИИ (также известные, как "VOX").',
  component: CheckboxInput,
};
