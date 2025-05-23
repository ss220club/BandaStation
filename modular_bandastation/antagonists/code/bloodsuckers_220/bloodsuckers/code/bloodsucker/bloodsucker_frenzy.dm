/**
 * # FrenzyGrab
 *
 * The martial art given to Bloodsuckers so they can instantly aggressively grab people.
 */
/datum/martial_art/frenzygrab
	name = "Frenzy Grab"
	id = MARTIALART_FRENZYGRAB

/datum/martial_art/frenzygrab/grab_act(mob/living/user, mob/living/target)
	if(user != target)
		target.grabbedby(user)
		target.grippedby(user, instant = TRUE)
		return TRUE
	return ..()





/**
 * # Status effects
 * This is the status effect given to Bloodsuckers in a Frenzy
 * This deals with everything entering/exiting Frenzy is meant to deal with.
 */

/atom/movable/screen/alert/status_effect/frenzy
	name = "Frenzy"
	desc = "You are in a frenzy! You are entirely feral and, depending on your clan, fighting for your life!"
	icon = 'modular_bandastation/antagonists/code/bloodsuckers_220/icons/bloodsuckers/bloodsucker_status_effects.dmi'
	icon_state = "frenzy"
	alerttooltipstyle = "cult"

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 1
	alert_type = /atom/movable/screen/alert/status_effect/frenzy
	/// The stored Bloodsucker antag datum
	var/datum/antagonist/bloodsucker/bloodsuckerdatum
	/// Traits applied during Frenzy.
	var/static/list/frenzy_traits = list(
		TRAIT_BATON_RESISTANCE,
		TRAIT_DEAF,
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_MUTE,
		TRAIT_PUSHIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
	)
	///Boolean indicating whether or not the owner is part of the Brujah clan
	///Used in passive burn damage calculation
	var/brujah = FALSE

/datum/status_effect/frenzy/get_examine_text()
	return span_warning("[owner.p_They()] seem[owner.p_s()] inhumane and feral!")

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	var/mob/living/carbon/human/user = owner
	bloodsuckerdatum = IS_BLOODSUCKER(user)

	if(QDELETED(bloodsuckerdatum) || !COOLDOWN_FINISHED(bloodsuckerdatum, bloodsucker_frenzy_cooldown))
		return FALSE

	// Disable ALL Powers and notify their entry
	bloodsuckerdatum.DisableAllPowers(forced = TRUE)
	to_chat(owner, span_userdanger("Blood! You need Blood, now! You enter a total Frenzy!"))
	to_chat(owner, span_announce("* Bloodsucker Tip: While in a frenzy, you instantly aggresively grab, have stun resistance, cannot speak, hear, or use any powers outside of Feed and Trespass (If you have it)."))
	owner.balloon_alert(owner, "you enter a frenzy!")
	SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_ENTERS_FRENZY)

	// Give the other Frenzy effects
	owner.add_traits(frenzy_traits, FRENZY_TRAIT)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/bloodsucker_frenzy)
	bloodsuckerdatum.frenzygrab = new(src)
	bloodsuckerdatum.frenzygrab.teach(user)
	bloodsuckerdatum.frenzygrab.locked_to_use = TRUE
	owner.add_client_colour(/datum/client_colour/manual_heart_blood, FRENZY_TRAIT)
	user.uncuff()
	bloodsuckerdatum.frenzied = TRUE

	// Determine if the owner is part of the Brujah clan
	if(istype(bloodsuckerdatum.my_clan, /datum/bloodsucker_clan/brujah))
		brujah = TRUE
	return ..()

/datum/status_effect/frenzy/on_remove()
	if(bloodsuckerdatum?.frenzied)
		owner.balloon_alert(owner, "you come back to your senses.")
		owner.remove_traits(frenzy_traits, FRENZY_TRAIT)
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/bloodsucker_frenzy)
		QDEL_NULL(bloodsuckerdatum.frenzygrab)
		owner.remove_client_colour(FRENZY_TRAIT)

		SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_EXITS_FRENZY)
		bloodsuckerdatum.frenzied = FALSE
		COOLDOWN_START(bloodsuckerdatum, bloodsucker_frenzy_cooldown, 30 SECONDS)


	SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_EXITS_FRENZY)
	bloodsuckerdatum.frenzied = FALSE
	return ..()

/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/human/user = owner
	if(!bloodsuckerdatum.frenzied)
		return
	//Passively accumulate burn damage (Bloodsuckers can't survive on low blood forever).
	//Humanity loss is supposed to be a bad thing for Bloodsuckers so it adds to this damage.
	//Brujah Bloodsuckers start with a lot of lost humanity so we give them a bit of leeway.
	if(!brujah)
		user.adjustFireLoss(1.5 + (bloodsuckerdatum.humanity_lost / 10))
	if(prob(30))
		user.do_jitter_animation(300)
		return
	if(prob(10))
		user.emote("tremble")
		return
	if(prob(5))
		user.emote("screech")
		return

/datum/movespeed_modifier/bloodsucker_frenzy
	multiplicative_slowdown = -0.4
