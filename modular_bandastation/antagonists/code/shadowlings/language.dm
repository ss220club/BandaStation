/datum/language/shadow_hive
	name = "Hive Mind"
	desc = "A shadow-linked mind channel."
	key = "8"

/obj/item/organ/tongue/shadow_hive
	name = "umbra nexus"
	desc = "A dark, whispering node that links its bearer to the Shadow Hive."
	icon_state = "tongueayylmao"
	say_mod = "whispers"
	sense_of_taste = FALSE
	modifies_speech = TRUE

/obj/item/organ/tongue/shadow_hive/modify_speech(datum/source, list/speech_args)
	var/mob/living/carbon/human/user = source
	if(!istype(user))
		return

	var/message = speech_args[SPEECH_MESSAGE]
	if(!length(message))
		return

	var/datum/language/lang = speech_args[SPEECH_LANGUAGE]
	if(!istype(lang, /datum/language/shadow_hive))
		return

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return

	var/rendered = "<span class='shadowradio'><b>[user.real_name]:</b> [message]</span>"
	user.log_talk(message, LOG_SAY, tag="SHADOW_HIVE")

	to_chat(user, rendered, type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)

	for(var/mob/living/carbon/human/L in hive.lings)
		if(QDELETED(L))
			continue
		if(L == user)
			continue
		to_chat(L, rendered, type = MESSAGE_TYPE_RADIO, avoid_highlighting = FALSE)

	for(var/mob/living/carbon/human/T in hive.thralls)
		if(QDELETED(T))
			continue
		if(T == user)
			continue
		to_chat(T, rendered, type = MESSAGE_TYPE_RADIO, avoid_highlighting = FALSE)

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]", type = MESSAGE_TYPE_RADIO)

	speech_args[SPEECH_MESSAGE] = ""
