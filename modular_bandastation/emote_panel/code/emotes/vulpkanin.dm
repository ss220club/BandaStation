/datum/species/vulpkanin/get_scream_sound(mob/living/carbon/human/human)
	if(human.physique == MALE)
		return pick(
			'sound/mobs/humanoids/human/scream/malescream_1.ogg',
			'sound/mobs/humanoids/human/scream/malescream_2.ogg',
			'sound/mobs/humanoids/human/scream/malescream_3.ogg',
			'sound/mobs/humanoids/human/scream/malescream_4.ogg',
			'sound/mobs/humanoids/human/scream/malescream_5.ogg',
			'sound/mobs/humanoids/human/scream/malescream_6.ogg',
		)

	return pick(
		'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
	)

/datum/species/vulpkanin/get_cough_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)

/datum/species/vulpkanin/get_cry_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/vulpkanin/get_sneeze_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/vulpkanin/get_laugh_sound(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	if(human.physique == FEMALE)
		return 'sound/mobs/humanoids/human/laugh/womanlaugh.ogg'
	return pick(
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
	)

// MARK: Emotes
/datum/emote/living/carbon/human/vulpkanin
	species_type_whitelist_typecache = /datum/species/vulpkanin

/datum/emote/living/carbon/human/vulpkanin/howl
	name = "Выть"
	key = "howl"
	key_third_person = "howls"
	message = "воет."
	message_mime = "делает вид, что воет."
	message_param = "воет на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 6 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/vulpkanin/howl.ogg'

/datum/emote/living/carbon/human/vulpkanin/growl
	name = "Рычать"
	key = "growl"
	key_third_person = "growls"
	message = "рычит."
	message_mime = "бусшумно рычит."
	message_param = "рычит на %t."
	cooldown = 2 SECONDS
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/vulpkanin/growl/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/vulpkanin/growl1.ogg',
		'modular_bandastation/emote_panel/audio/vulpkanin/growl2.ogg',
		'modular_bandastation/emote_panel/audio/vulpkanin/growl3.ogg',
	)

/datum/emote/living/carbon/human/vulpkanin/purr
	name = "Урчать"
	key = "purr"
	key_third_person = "purrs"
	message = "урчит."
	message_param = "урчит на %t."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	cooldown = 2 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/vulpkanin/purr.ogg'

/datum/emote/living/carbon/human/vulpkanin/bark
	name = "Гавкнуть"
	key = "bark"
	key_third_person = "bark"
	message = "гавкает."
	message_param = "гавкает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 2 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/vulpkanin/bark.ogg'

/datum/emote/living/carbon/human/vulpkanin/wbark
	name = "Гавкнуть дважды"
	key = "wbark"
	key_third_person = "wbark"
	message = "дважды гавкает."
	message_param = "дважды гавкает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 2 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/vulpkanin/wbark.ogg'
