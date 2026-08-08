/datum/emote/living/ussp_rage
	key = "ussprage"
	message = "разражается потоком неорусских ругательств!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/ussp_rage/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/ussp_rage/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_negative1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_negative2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_negative3.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_negative4.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_negative5.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_negative6.ogg'
	))

/datum/emote/living/ussp_good
	key = "usspgood"
	message = "одобряет по-неорусски."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/ussp_good/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/ussp_good/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_good.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_good1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_good2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_good3.ogg'
	))

/datum/emote/living/ussp_together
	key = "ussptogether"
	message = "предлагает объединиться по-неорусски."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/ussp_together/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/ussp_together/get_sound(mob/living/user)
	return sound('modular_bandastation/voyaker_events/sounds/emotes/ussp_toghether.ogg')

/datum/emote/living/ussp_contact
	key = "usspcontact"
	message = "замечает противника!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/ussp_contact/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/ussp_contact/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_contact.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_contact1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_contact2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_contact3.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_contact4.ogg'
	))

/datum/emote/living/ussp_regroup
	key = "usspregroup"
	message = "предлагает отступить!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/ussp_regroup/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/ussp_regroup/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_regroup.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_regroup1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_regroup2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_regroup3.ogg'
	))

/datum/emote/living/ussp_forward
	key = "usspforward"
	message = "предлагает наступать!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 7 SECONDS

/datum/emote/living/ussp_forward/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak()

/datum/emote/living/ussp_forward/get_sound(mob/living/user)
	return pick(list(
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_forward.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_forward1.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_forward2.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_forward3.ogg',
		'modular_bandastation/voyaker_events/sounds/emotes/ussp_forward4.ogg'
	))


