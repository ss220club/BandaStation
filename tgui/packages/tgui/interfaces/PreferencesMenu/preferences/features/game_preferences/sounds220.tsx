import { Feature, FeatureSliderInput } from '../base';

// BANDASTATION SOUND PREFS

export const sound_tts_volume_radio: Feature<number> = {
  name: 'TTS - громкость рации',
  category: 'ЗВУК',
  description: 'Громкость text-to-speech для рации.',
  component: FeatureSliderInput,
};

export const sound_tts_volume_announcement: Feature<number> = {
  name: 'TTS - громкость оповещений',
  category: 'ЗВУК',
  description: 'Громкость text-to-speech для оповещений.',
  component: FeatureSliderInput,
};
