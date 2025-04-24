/mob/show_message(msg, type, alt_msg, alt_type, avoid_highlighting)
	if(!client)
		return FALSE
	msg = replacetext_char(msg, "+", null)
	. = ..()

/datum/chatmessage/New(text, atom/target, mob/owner, datum/language/language, list/extra_classes, lifespan)
	text = replacetext_char(text, "+", null)
	. = ..()

/mob/dead/observer/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	. = ..()
	if(!. || (length(message_mods) && message_mods[MODE_CUSTOM_SAY_EMOTE] && message_mods[MODE_CUSTOM_SAY_ERASE_INPUT]))
		return
	if(radio_freq == FREQ_ENTERTAINMENT)
		return
	var/message_to_tts = LAZYACCESS(message_mods, MODE_TTS_MESSAGE_OVERRIDE) || raw_message
	speaker.cast_tts(src, message_to_tts, is_radio = !!radio_freq, tts_seed_override = LAZYACCESS(message_mods, MODE_TTS_SEED_OVERRIDE), channel_override = radio_freq ? CHANNEL_TTS_RADIO : null)

/atom/movable/virtualspeaker/cast_tts(mob/listener, message, atom/location, is_local, is_radio, list/effects, traits, preSFX, postSFX, tts_seed_override, channel_override)
	SEND_SIGNAL(source, COMSIG_ATOM_TTS_CAST, listener, message, location, is_local, is_radio, effects, traits, preSFX, postSFX, tts_seed_override, channel_override)
