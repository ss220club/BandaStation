/**
 *	# Assigning Sol
 *
 *	Sol is the sunlight, during this period, all Bloodsuckers must be in their coffin, else they burn.
 */

/// Start Sol, called when someone is assigned Bloodsucker
/datum/antagonist/bloodsucker/proc/check_start_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("New Sol has been created due to Bloodsucker assignment.")
		SSsunlight.can_fire = TRUE

/// End Sol, if you're the last Bloodsucker
/datum/antagonist/bloodsucker/proc/check_cancel_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("Sol has been deleted due to the lack of Bloodsuckers")
		SSsunlight.can_fire = FALSE

///Ranks the Bloodsucker up, called by Sol.
/datum/antagonist/bloodsucker/proc/sol_rank_up(atom/source)
	SIGNAL_HANDLER
	if(bloodsucker_level < 3)
		INVOKE_ASYNC(src, PROC_REF(RankUp))
	else
		to_chat(owner.current, span_announce("You have already got as powerful as you can through surviving Sol."))

///Called when Sol is near starting.
/datum/antagonist/bloodsucker/proc/sol_near_start(atom/source)
	SIGNAL_HANDLER
	if(bloodsucker_lair_area && !(locate(/datum/action/cooldown/bloodsucker/gohome) in powers))
		BuyPower(new /datum/action/cooldown/bloodsucker/gohome)

///Called when Sol first ends.
/datum/antagonist/bloodsucker/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	check_end_torpor()
	for(var/datum/action/cooldown/bloodsucker/gohome/power in powers)
		RemovePower(power)
	if(altar_uses)
		to_chat(owner, span_boldnotice("Your Altar uses have been reset!"))
		altar_uses = 0

/// Cycle through all vamp antags and check if they're inside a closet.
/datum/antagonist/bloodsucker/proc/handle_sol()
	SIGNAL_HANDLER
	if(!owner?.current)
		return

	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		owner.current.apply_status_effect(/datum/status_effect/bloodsucker_sol)
		return

	owner.current.remove_status_effect(/datum/status_effect/bloodsucker_sol)
	if(owner.current.am_staked() && COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
		to_chat(owner.current, span_userdanger("You are staked! Remove the offending weapon from your heart before sleeping."))
		COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
	if(!is_in_torpor())
		check_begin_torpor(TRUE)
		owner.current.add_mood_event("vampsleep", /datum/mood_event/coffinsleep)

///Makes the area the bloodsucker is currently in dirty with cobweb and dirt.
/datum/antagonist/bloodsucker/proc/dirty_area()
	var/list/turf/area_turfs = get_area_turfs(get_area(owner.current))
	var/turf/turf_to_be_dirtied = pick(area_turfs)
	if(turf_to_be_dirtied && !turf_to_be_dirtied.density)
		var/turf/north_turf = get_step(turf_to_be_dirtied, NORTH)
		if(istype(north_turf, /turf/closed/wall))
			var/turf/west_turf = get_step(turf_to_be_dirtied, WEST)
			if(istype(west_turf, /turf/closed/wall))
				new /obj/effect/decal/cleanable/cobweb(turf_to_be_dirtied)
			var/turf/east_turf = get_step(turf_to_be_dirtied, EAST)
			if(istype(east_turf, /turf/closed/wall))
				new /obj/effect/decal/cleanable/cobweb/cobweb2(turf_to_be_dirtied)
		new /obj/effect/decal/cleanable/dirt(turf_to_be_dirtied)

/datum/antagonist/bloodsucker/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(!owner)
		return
	to_chat(owner, vampire_warning_message)

	switch(danger_level)
		if(DANGER_LEVEL_FIRST_WARNING)
			owner.current.playsound_local(null, 'modular_bandastation/antagonists/code/bloodsuckers_220/bloodsuckers/sounds/griffin_3.ogg', vol = 50, vary = TRUE)
		if(DANGER_LEVEL_SECOND_WARNING)
			owner.current.playsound_local(null, 'modular_bandastation/antagonists/code/bloodsuckers_220/bloodsuckers/sounds/griffin_5.ogg', vol = 50, vary = TRUE)
		if(DANGER_LEVEL_THIRD_WARNING)
			owner.current.playsound_local(null, 'sound/effects/alert.ogg', vol = 75, vary = TRUE)
		if(DANGER_LEVEL_SOL_ROSE)
			owner.current.playsound_local(null, 'sound/ambience/misc/ambimystery.ogg', vol = 75, vary = TRUE)
		if(DANGER_LEVEL_SOL_ENDED)
			owner.current.playsound_local(null, 'sound/music/antag/bloodcult/ghosty_wind.ogg', vol = 90, vary = TRUE)

