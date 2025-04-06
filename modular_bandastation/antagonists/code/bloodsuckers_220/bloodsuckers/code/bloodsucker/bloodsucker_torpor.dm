/**
 * # Torpor
 *
 * Torpor is what deals with the Bloodsucker falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Being in a Coffin while Sol is on, dealt with by Sol
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [bloodsucker_coffin.dm]
 * - Death, dealt with by /handle_death()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [bloodsucker_daylight.dm]
*/

/atom/movable/screen/alert/status_effect/torpor
	name = "Torpor"
	desc = "You have returned to the precipice of oblivion once more. Through this you shall recover at the expense of being immensely vulnerable."
	icon = 'modular_bandastation/antagonists/code/bloodsuckers_220/icons/bloodsuckers/bloodsucker_status_effects.dmi'
	icon_state = "torpor"
	alerttooltipstyle = "alien"

/datum/status_effect/torpor
	id = "Torpor"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/torpor
	/// Our Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum
	/// Traits applied during Torpor.
	var/static/list/torpor_traits = list(
		TRAIT_DEATHCOMA,
		TRAIT_FAKEDEATH,
		TRAIT_NODEATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)


/datum/status_effect/torpor/on_apply()
	. = ..()
	var/mob/living/carbon/human/user = owner
	bloodsuckerdatum = IS_BLOODSUCKER(user)

	to_chat(owner, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))
	// Force them to go to sleep
	REMOVE_TRAIT(owner, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	// Without this, you'll just keep dying while you recover.
	owner.add_traits(torpor_traits, TORPOR_TRAIT)
	owner.set_timed_status_effect(0 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	// Disable ALL Powers
	bloodsuckerdatum.DisableAllPowers()

/datum/status_effect/torpor/on_remove()
	owner.remove_status_effect(/datum/status_effect/bloodsucker_sol)
	owner.grab_ghost()
	to_chat(owner, span_warning("You have recovered from Torpor."))
	owner.remove_traits(torpor_traits, TORPOR_TRAIT)
	if(!HAS_TRAIT(owner, TRAIT_MASQUERADE))
		ADD_TRAIT(owner, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	bloodsuckerdatum.heal_vampire_organs()
	owner.update_stat()
	SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_EXIT_TORPOR)

/datum/antagonist/bloodsucker/proc/check_begin_torpor(SkipChecks = FALSE)
	var/mob/living/carbon/user = owner.current
	/// Prevent Torpor whilst frenzied.
	if(frenzied || (IS_DEAD_OR_INCAP(user) && bloodsucker_blood_volume == 0))
		to_chat(user, span_userdanger("Your frenzy prevents you from entering torpor!"))
		return
	/// Are we entering Torpor via Sol/Death? Then entering it isnt optional!
	if(SkipChecks)
		to_chat(user, span_userdanger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
		owner.current.apply_status_effect(/datum/status_effect/torpor)
		return
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!SSsunlight.sunlight_active && (total_damage >= 10 || typecached_item_in_list(user.organs, yucky_organ_typecache)) && !is_in_torpor())
		owner.current.apply_status_effect(/datum/status_effect/torpor)

/datum/antagonist/bloodsucker/proc/check_end_torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	if(total_burn >= 199)
		return FALSE
	if(SSsunlight.sunlight_active)
		return FALSE
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(total_damage <= 10)
			owner.current.remove_status_effect(/datum/status_effect/torpor)
	else
		if(total_brute <= 10)
			owner.current.remove_status_effect(/datum/status_effect/torpor)

/datum/antagonist/bloodsucker/proc/is_in_torpor()
	if(QDELETED(owner.current))
		return FALSE
	return HAS_TRAIT_FROM(owner.current, TRAIT_NODEATH, TORPOR_TRAIT)

/datum/status_effect/bloodsucker_sol
	id = "bloodsucker_sol"
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/bloodsucker_sol
	var/list/datum/action/cooldown/bloodsucker/burdened_actions
	var/static/list/sol_traits = list(
		TRAIT_EASILY_WOUNDED,
	)

/datum/status_effect/bloodsucker_sol/on_apply()
	if(!SSsunlight.sunlight_active || istype(owner.loc, /obj/structure/closet/crate/coffin))
		return FALSE
	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	owner.add_traits(sol_traits, id)
	owner.remove_filter(id)
	owner.add_filter(id, 2, drop_shadow_filter(x = 0, y = 0, size = 3, offset = 1.5, color = "#ee7440"))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/bloodsucker_sol)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_sol)
	to_chat(owner, span_userdanger("Sol has risen! Your powers are suppressed, your body is burdened, and you will not heal outside of a coffin!"), type = MESSAGE_TYPE_INFO)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology?.damage_resistance -= 50
	for(var/datum/action/cooldown/bloodsucker/power in owner.actions)
		if(power.sol_multiplier)
			power.bloodcost *= power.sol_multiplier
			power.constant_bloodcost *= power.sol_multiplier
			if(power.active)
				to_chat(owner, span_warning("[power.name] is harder to upkeep during Sol, now requiring [power.constant_bloodcost] blood while the solar flares last!"), type = MESSAGE_TYPE_INFO)
			LAZYSET(burdened_actions, power, TRUE)
		power.update_desc(rebuild = FALSE)
		power.build_all_button_icons(UPDATE_BUTTON_NAME | UPDATE_BUTTON_STATUS)
	return TRUE

/datum/status_effect/bloodsucker_sol/on_remove()
	UnregisterSignal(SSsunlight, COMSIG_SOL_END)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.remove_traits(sol_traits, id)
	owner.remove_filter(id)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/bloodsucker_sol)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_sol)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology?.damage_resistance += 50
	for(var/datum/action/cooldown/bloodsucker/power in owner.actions)
		if(LAZYACCESS(burdened_actions, power))
			power.bloodcost /= power.sol_multiplier
			power.constant_bloodcost /= power.sol_multiplier
		power.update_desc(rebuild = FALSE)
		power.build_all_button_icons(UPDATE_BUTTON_NAME | UPDATE_BUTTON_STATUS)
	LAZYNULL(burdened_actions)

/datum/status_effect/bloodsucker_sol/get_examine_text()
	return span_warning("[owner.p_They()] seem[owner.p_s()] sickly and painfully overburned!")

/datum/status_effect/bloodsucker_sol/proc/on_sol_end()
	SIGNAL_HANDLER
	if(!QDELING(src))
		to_chat(owner, span_big(span_boldnotice("Sol has ended, your vampiric powers are no longer strained!")), type = MESSAGE_TYPE_INFO)
		qdel(src)

/datum/status_effect/bloodsucker_sol/proc/on_owner_moved()
	SIGNAL_HANDLER
	if(istype(owner.loc, /obj/structure/closet/crate/coffin))
		qdel(src)

/atom/movable/screen/alert/status_effect/bloodsucker_sol
	name = "Solar Flares"
	desc = "Solar flares bombard the station, heavily weakening your vampiric abilities and burdening your body!\nSleep in a coffin to avoid the effects of the solar flare!"
	icon = 'modular_bandastation/antagonists/code/bloodsuckers_220/icons/bloodsuckers/actions_bloodsucker.dmi'
	icon_state = "sol_alert"

/datum/actionspeed_modifier/bloodsucker_sol
	multiplicative_slowdown = 1
	id = ACTIONSPEED_ID_BLOODSUCKER_SOL

/datum/movespeed_modifier/bloodsucker_sol
	multiplicative_slowdown = 0.45
	id = ACTIONSPEED_ID_BLOODSUCKER_SOL
