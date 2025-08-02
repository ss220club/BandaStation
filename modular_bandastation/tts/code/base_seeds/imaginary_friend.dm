/mob/eye/imaginary_friend/add_tts_component()
	AddComponent(/datum/component/tts_component)

/mob/eye/imaginary_friend/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	. = ..()
	var/message_to_tts = LAZYACCESS(message_mods, MODE_TTS_MESSAGE_OVERRIDE) || raw_message
	speaker.cast_tts(src, message_to_tts, is_radio = !!radio_freq, tts_seed_override = LAZYACCESS(message_mods, MODE_TTS_SEED_OVERRIDE), channel_override = radio_freq ? CHANNEL_TTS_RADIO : null)

/mob/eye/imaginary_friend/setup_friend_from_prefs(datum/preferences/appearance_from_prefs)
	. = ..()
	AddComponent(/datum/component/tts_component, SStts220.tts_seeds[appearance_from_prefs.read_preference(/datum/preference/text/tts_seed)])

/mob/eye/imaginary_friend/Initialize(mapload)
	. = ..()
	GRANT_ACTION(/datum/action/innate/voice_change/genderless)
