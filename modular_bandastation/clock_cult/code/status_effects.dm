// Clock cult speech slurring (used by Kindle scripture); reuses cult text file
/datum/status_effect/speech/slurring/clock
	id = "clock_slurring"
	common_prob = 50
	uncommon_prob = 25
	replacement_prob = 33
	doubletext_prob = 0
	text_modification_file = "slurring_cult_text.json"

// Warp sickness inflicted on non-cultists who are teleported by cult abilities
/datum/status_effect/clock_warp_sickness
	id = "clock_warp_sickness"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/clock_warp_sickness/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(.)
		to_chat(new_owner, span_warning("The sudden teleportation leaves you disoriented and nauseous!"))

/datum/status_effect/clock_warp_sickness/tick()
	owner.adjust_confusion(1 SECONDS)
	owner.adjust_tox_loss(0.5)

/datum/status_effect/interdiction
	id = "interdicted"
	duration = 2.5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 0.2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/interdiction
	/// If we kicked the owner out of running mode
	var/running_toggled = FALSE

/datum/status_effect/interdiction/tick()
	if(owner.move_intent != MOVE_INTENT_WALK)
		owner.move_intent = MOVE_INTENT_WALK
		owner.adjust_confusion_up_to(1 SECONDS, 1 SECONDS)
		running_toggled = TRUE
		to_chat(owner, span_warning("You know you shouldn't be running here."))

	owner.add_movespeed_modifier(/datum/movespeed_modifier/clock_interdiction)

/datum/status_effect/interdiction/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/clock_interdiction)

	if(running_toggled && owner.move_intent == MOVE_INTENT_WALK)
		owner.move_intent = MOVE_INTENT_RUN

/atom/movable/screen/alert/status_effect/interdiction
	name = "Interdicted"
	desc = "I don't think I am meant to go this way."
	icon = 'modular_bandastation/clock_cult/icons/hud/screen_alert.dmi'
	icon_state = "belligerent"

/datum/movespeed_modifier/clock_interdiction
	multiplicative_slowdown = 1.5
