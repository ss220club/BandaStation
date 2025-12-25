/datum/species/kidan/get_scream_sound(mob/living/carbon/human/kidan)
	if(kidan.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/kidan/scream_kidan.ogg'
	return 'modular_bandastation/emote_panel/audio/kidan/scream_kidan.ogg'

/datum/species/kidan/get_sigh_sound(mob/living/carbon/human/kidan)
	if(kidan.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/kidan/sigh_kidan_1.ogg',
			'modular_bandastation/emote_panel/audio/kidan/sigh_kidan_2.ogg',
		)
	return pick(
		'modular_bandastation/emote_panel/audio/kidan/sigh_kidan_1.ogg',
		'modular_bandastation/emote_panel/audio/kidan/sigh_kidan_2.ogg',
	)

/datum/species/kidan/get_cough_sound(mob/living/carbon/human/kidan)
	if(kidan.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/kidan/cough_kidan.ogg',
		)
	return pick(
		'modular_bandastation/emote_panel/audio/kidan/cough_kidan.ogg',
	)

/datum/species/kidan/get_cry_sound(mob/living/carbon/human/kidan)
	if(kidan.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/kidan/cry_kidan_1.ogg',
			'modular_bandastation/emote_panel/audio/kidan/cry_kidan_2.ogg',
		)
	return pick(
			'modular_bandastation/emote_panel/audio/kidan/cry_kidan_1.ogg',
			'modular_bandastation/emote_panel/audio/kidan/cry_kidan_2.ogg',
	)

/datum/species/kidan/get_sneeze_sound(mob/living/carbon/human/kidan)
	if(kidan.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/kidan/sneeze_kidan_2.ogg',
			'modular_bandastation/emote_panel/audio/kidan/sneeze_kidan_3.ogg',
		)
	return 'modular_bandastation/emote_panel/audio/kidan/sneeze_kidan_1.ogg'

/datum/species/kidan/get_laugh_sound(mob/living/carbon/human/kidan)
	if(!ishuman(kidan))
		return
	if(kidan.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/kidan/laugh_kidan_1.ogg',
			'modular_bandastation/emote_panel/audio/kidan/laugh_kidan_2.ogg',
		)
	return pick(
		'modular_bandastation/emote_panel/audio/kidan/laugh_kidan_3.ogg',
		'modular_bandastation/emote_panel/audio/kidan/laugh_kidan_4.ogg',
	)

// MARK: Emotes
/datum/emote/living/carbon/human/kidan
	species_type_whitelist_typecache = list(/datum/species/kidan)

/datum/emote/living/carbon/human/kidan/emote_clicks
	name = "Кликает"
	key = "clicks"
	key_third_person = "clickeds"
	message = "кликает."
	message_mime = "бесшумно кликает."
	message_param = "кликает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/kidan/Kidanclack.ogg'

/datum/emote/living/carbon/human/kidan/emote_rustles
	name = "Шелест усиками"
	key = "rustles"
	key_third_person = "rustlesed"
	message = "шелестит усиками."
	message_mime = "бесшумно шелестит."
	message_param = "шелестит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/kidan/waves_kidan_1.ogg'
