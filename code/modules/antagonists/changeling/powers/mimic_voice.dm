/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "Мы формируем наши голосовые железы так, чтобы они звучали желаемым голосом. Поддержание этой силы замедляет выработку химических веществ."
	button_icon_state = "mimic_voice"
	helptext = "Превратит ваш голос в имя, которое вы введете. Мы должны постоянно расходовать химические вещества, чтобы поддерживать такую форму."
	chemical_cost = 0//constant chemical drain hardcoded
	dna_cost = 1
	req_human = TRUE
	var/datum/tts_seed/mimic_tts_seed

// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(user.override_voice)
		changeling.chem_recharge_slowdown -= 0.25
		user.override_voice = ""
		to_chat(user, span_notice("Мы возвращаем наши голосовые железы в исходное положение."))
		UnregisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS) // BANDASTATION EDIT - TTS
		mimic_tts_seed = null // BANDASTATION EDIT - TTS
		return

	var/mimic_voice = sanitize_name(tgui_input_text(user, "Enter a name to mimic", "Mimic Voice", max_length = MAX_NAME_LEN))
	if(!mimic_voice)
		return
	..()
	changeling.chem_recharge_slowdown += 0.25
	user.override_voice = mimic_voice
	to_chat(user, span_notice("Мы формируем наши железы так, чтобы они издавали голос <b>[mimic_voice]</b>, Это замедлит регенерацию химических веществ во время активной деятельности."))
	to_chat(user, span_notice("Используйте эту силу снова, чтобы вернуть наш прежний голос и вернуть производство химикатов к нормальному уровню."))
	RegisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS, PROC_REF(replace_tts_seed)) // BANDASTATION EDIT - TTS
	return TRUE

/datum/action/changeling/mimicvoice/Remove(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(user.override_voice)
		changeling?.chem_recharge_slowdown = max(0, changeling.chem_recharge_slowdown - 0.25)
		user.override_voice = ""
		to_chat(user, span_notice("Наши голосовые железы возвращаются в исходное положение."))
		UnregisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS) // BANDASTATION EDIT - TTS
		mimic_tts_seed = null // BANDASTATION EDIT - TTS
	. = ..()

// BANDASTATION EDIT START - TTS
/datum/action/changeling/mimicvoice/proc/replace_tts_seed(mob/user, list/tts_args)
	SIGNAL_HANDLER
	if(tts_args[TTS_PRIORITY] < TTS_PRIORITY_MIMIC)
		tts_args[TTS_CAST_SEED] = mimic_tts_seed || tts_args[TTS_CAST_SEED]
// BANDASTATION EDIT END
