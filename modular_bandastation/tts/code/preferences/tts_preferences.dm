/datum/preference/text/tts_seed
	savefile_key = "tts_seed"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/text/tts_seed/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/tts_seed/seed = SStts220.tts_seeds[value]
	if(!seed)
		seed = SStts220.tts_seeds[SStts220.get_random_seed(target)]

	target.AddComponent(/datum/component/tts_component, seed)
	target.dna.tts_seed_dna = seed
	GLOB.human_to_tts["[target.real_name]"] = seed

/datum/preference/numeric/volume/sound_tts_volume_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume_radio"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/datum/preference/numeric/volume/sound_tts_volume_radio/apply_to_client_updated(client/client, value)
	client.mob.set_sound_channel_volume(CHANNEL_TTS_RADIO, value)

/datum/preference/numeric/volume/sound_tts_volume_radio/create_default_value()
	return maximum / 2

/datum/preference/numeric/volume/sound_tts_volume_announcement
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume_announcement"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/datum/preference/numeric/volume/sound_tts_volume_announcement/apply_to_client_updated(client/client, value)
	client.mob.set_sound_channel_volume(CHANNEL_TTS_ANNOUNCEMENT, value)

/datum/preference/numeric/volume/sound_tts_volume_announcement/create_default_value()
	return maximum / 2

/mob/living/carbon/human/randomize_human_appearance(randomize_flags)
	. = ..()
	var/datum/component/tts_component/tts_component = GetComponent(/datum/component/tts_component)
	tts_component.tts_seed = tts_component.get_random_tts_seed_by_gender()
