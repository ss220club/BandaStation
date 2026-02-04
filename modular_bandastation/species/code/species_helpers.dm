/// Returns the species' evil laugh sound
/datum/species/proc/get_evil_laugh_sound(mob/living/carbon/human/user)
	return

/datum/species/human/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/human/female/evil_laugh_female_1.ogg'
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_2.ogg',
	)

/datum/species/jelly/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/human/female/evil_laugh_female_1.ogg'
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_2.ogg',
	)

/datum/species/pod/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/human/female/evil_laugh_female_1.ogg'
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_2.ogg',
	)

/datum/species/skrell/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/human/female/evil_laugh_female_1.ogg'
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_2.ogg',
	)

/datum/species/tajaran/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/human/female/evil_laugh_female_1.ogg'
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_2.ogg',
	)

/datum/species/vulpkanin/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/human/female/evil_laugh_female_1.ogg'
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/evil_laugh_male_2.ogg',
	)

/datum/species/lizard/get_evil_laugh_sound(mob/living/carbon/human/user)
	return 'sound/mobs/humanoids/lizard/lizard_laugh1.ogg'

/datum/species/moth/get_evil_laugh_sound(mob/living/carbon/human/user)
	return 'sound/mobs/humanoids/moth/moth_laugh1.ogg'
