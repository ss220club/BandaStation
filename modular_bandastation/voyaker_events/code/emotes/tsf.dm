/datum/emote/living/tsf_rage
	key = "tsfrage"
	message = "разражается потоком ругательств на Соле!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/tsf_rage/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/tsf_rage/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative3.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative4.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative5.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative6.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative7.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_negative8.ogg'
	))

/datum/emote/living/tsf_good
	key = "tsfgood"
	message = "одобряет на Соле."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/tsf_good/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/tsf_good/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_good.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_good1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_good2.ogg'
	))

/datum/emote/living/tsf_together
	key = "tsftogether"
	message = "предлагает объединиться на Соле."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/tsf_together/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/tsf_together/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_together.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_together1.ogg'
	))

/datum/emote/living/tsf_contact
	key = "tsfcontact"
	message = "замечает противника!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/tsf_contact/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/tsf_contact/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_contact.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_contact1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_contact2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_contact3.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_contact4.ogg'
	))

/datum/emote/living/tsf_regroup
	key = "tsfregroup"
	message = "предлагает отступить!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/tsf_regroup/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/tsf_regroup/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_regroup.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_regroup1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_regroup2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_regroup3.ogg'
	))

/datum/emote/living/tsf_forward
	key = "tsfforward"
	message = "предлагает наступать!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/tsf_forward/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/tsf_forward/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_forward.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_forward1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_forward2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_forward3.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/tsf_forward4.ogg'
	))


