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

// MARK: Vulpkanin emotes
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
	sound = 'modular_bandastation/emote_panel/audio/howl.ogg'

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
		'modular_bandastation/emote_panel/audio/growl1.ogg',
		'modular_bandastation/emote_panel/audio/growl2.ogg',
		'modular_bandastation/emote_panel/audio/growl3.ogg',
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
	sound = 'modular_bandastation/emote_panel/audio/purr.ogg'

/datum/emote/living/carbon/human/vulpkanin/bark
	name = "Гавкнуть"
	key = "bark"
	key_third_person = "bark"
	message = "гавкает."
	message_param = "гавкает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 2 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/bark.ogg'

/datum/emote/living/carbon/human/vulpkanin/wbark
	name = "Гавкнуть дважды"
	key = "wbark"
	key_third_person = "wbark"
	message = "дважды гавкает."
	message_param = "дважды гавкает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 2 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/wbark.ogg'

// MARK: Tajaran emotes
/datum/emote/living/carbon/human/tajaran
	species_type_whitelist_typecache = /datum/species/tajaran

/datum/emote/living/carbon/human/tajaran/emote_meow
	name = "Мяукнуть"
	key = "meow_t"
	key_third_person = "meows"
	message = "мяукает."
	message_mime = "бесшумно мяукает."
	message_param = "мяукает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_meow.ogg'

/datum/emote/living/carbon/human/tajaran/emote_mow
	name = "Мяукнуть раздражённо"
	key = "mow"
	key_third_person = "mows"
	message = "раздражённо мяукает."
	message_mime = "бесшумно раздражённо мяукает."
	message_param = "раздражённо мяукает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_annoyed_meow.ogg'

/datum/emote/living/carbon/human/tajaran/emote_purr
	name = "Мурчать"
	key = "purr_t"
	key_third_person = "purrs"
	message = "мурчит."
	message_mime = "бесшумно мурчит."
	message_param = "мурчит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_purr.ogg'

/datum/emote/living/carbon/human/tajaran/emote_pur
	name = "Мурчать кратко"
	key = "pur"
	key_third_person = "purs"
	message = "кратко мурчит."
	message_mime = "бесшумно кратко мурчит."
	message_param = "кратко мурчит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_purr_short.ogg'

/datum/emote/living/carbon/human/tajaran/emote_purrr
	name = "Мурчать дольше"
	key = "purrr"
	key_third_person = "purrrs"
	message = "длительно мурчит."
	message_mime = "бесшумно длительно мурчит."
	message_param = "длительно мурчит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_purr_long.ogg'

/datum/emote/living/carbon/human/tajaran/emote_hiss_t
	name = "Шипеть"
	key = "hiss_t"
	key_third_person = "hisses"
	message = "шипит."
	message_mime = "бесшумно шипит."
	message_param = "шипит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_hiss.ogg'

// MARK: Skrell emotes
/datum/emote/living/carbon/human/skrell
	species_type_whitelist_typecache = /datum/species/skrell

/datum/emote/living/carbon/human/screll/warble
	name = "Трелить"
	key = "warble"
	key_third_person = "warbles"
	message = "трелит."
	message_param = "трелит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	species_type_whitelist_typecache = list(/datum/species/skrell)

/datum/emote/living/carbon/human/screll/warble/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/skrell/warble_1.ogg',
		'modular_bandastation/emote_panel/audio/skrell/warble_2.ogg',
	)

/datum/emote/living/carbon/human/screll/croak
	name = "Квакать"
	key = "croak"
	key_third_person = "croak"
	message = "квакает."
	message_param = "квакает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	species_type_whitelist_typecache = list(/datum/species/skrell)

/datum/emote/living/carbon/human/screll/croak/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/skrell/croak_1.ogg',
		'modular_bandastation/emote_panel/audio/skrell/croak_2.ogg',
		'modular_bandastation/emote_panel/audio/skrell/croak_3.ogg',
	)

/datum/emote/living/carbon/human/screll/croak/anger
	name = "Гневно квакать"
	key = "croak_anger"
	key_third_person = "croak_anger"
	message = "гневно квакает!"
	message_param = "гневно квакает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	species_type_whitelist_typecache = list(/datum/species/skrell)

/datum/emote/living/carbon/human/croak/anger/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/skrell/anger_1.ogg',
		'modular_bandastation/emote_panel/audio/skrell/anger_2.ogg',
	)
