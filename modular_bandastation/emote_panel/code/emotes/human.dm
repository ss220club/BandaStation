/datum/emote/living/sniffle
	key = "sniffle"
	key_third_person = "sniffles"
	name = "нюхать"
	message = "нюхает."
	message_mime = "бесшумно нюхает."
	message_param = "нюхает %t."

/datum/emote/living/sniffle/get_sound(mob/living/user)
	if(user.gender == FEMALE)
		return 'modular_bandastation/emote_panel/audio/female/sniff_female.ogg'
	else
		return 'modular_bandastation/emote_panel/audio/male/sniff_male.ogg'

/datum/emote/living/carbon/scratch/New()
	mob_type_allowed_typecache += list(/mob/living/carbon/human)
	. = ..()
