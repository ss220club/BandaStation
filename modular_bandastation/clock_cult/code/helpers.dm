///Returns whether the given mob can be converted to the clock cult
/proc/is_convertable_to_clock_cult(mob/living/target)
	if(!istype(target))
		return FALSE
	if(isnull(target.mind))
		return FALSE
#ifndef TESTING
	if(!GET_CLIENT(target))
		return FALSE
#endif
	if(isbot(target))
		return FALSE
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE))
		return FALSE
	if(ishuman(target) && target.mind.holy_role)
		return FALSE
	if(IS_HERETIC_OR_MONSTER(target))
		return FALSE
	return TRUE

///check if an atom is on the reebe z level, will also return FALSE if the atom has no z level
/proc/on_reebe(atom/checked_atom)
	var/turf/checked_turf = get_turf(checked_atom)
	if(!checked_turf?.z || !is_reebe_level(checked_turf.z))
		return FALSE
	return TRUE

/proc/gods_battle()
	if(GLOB.cult_narsie && GLOB.cult_ratvar)
		var/datum/component/singularity/narsie_singularity_component = GLOB.cult_narsie.singularity?.resolve()
		var/datum/component/singularity/ratvar_singularity_component = GLOB.cult_ratvar.singularity?.resolve()
		if(!narsie_singularity_component || !ratvar_singularity_component)
			message_admins("gods_battle() called without a singularity component on of of the 2 main gods.")
			return FALSE

		narsie_singularity_component.target = GLOB.cult_ratvar
		ratvar_singularity_component.target = GLOB.cult_narsie
		return TRUE
	return FALSE

#ifdef TESTING
///Debug proc: give a clockwork slab max cogs and set cult power/vitality to max for testing
/proc/clock_testing_godmode()
	GLOB.clock_vitality = MAX_CLOCK_VITALITY
	SSthe_ark.clock_power = SSthe_ark.max_clock_power
	SSthe_ark.max_clock_power = STANDARD_CELL_CHARGE * 100
	SSthe_ark.clock_power = SSthe_ark.max_clock_power
	for(var/obj/item/clockwork_slab/slab in GLOB.clockwork_slabs)
		slab.cogs = 9999
		GLOB.clock_installed_cogs = 9999
	message_admins("Clock cult godmode activated.")
#endif

/proc/try_servant_warp(mob/living/servant, turf/target_turf)
	var/mob/living/pulled = servant.pulling
	playsound(servant, 'sound/magic/magic_missile.ogg', 50, TRUE) //doing this manually for sound volume reasons
	playsound(target_turf, 'sound/magic/magic_missile.ogg', 50, TRUE)
	do_sparks(3, TRUE, servant)
	do_sparks(3, TRUE, target_turf)
	do_teleport(servant, target_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	to_chat(servant, "You warp to [get_area(target_turf)].")
	if(!IS_CLOCK(servant) || !on_reebe(servant))
		servant.apply_status_effect(/datum/status_effect/clock_warp_sickness, 15 SECONDS)

	if(ishuman(servant)) //looks weird on non-humanoids
		new /obj/effect/temp_visual/ratvar/warp(target_turf)

	if(istype(pulled))
		do_teleport(pulled, target_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
		if(!IS_CLOCK(pulled))
			pulled.Paralyze(3 SECONDS)
			to_chat(pulled, span_warning("You feel sick and confused."))
			pulled.apply_status_effect(/datum/status_effect/clock_warp_sickness, 15 SECONDS)
		else if(!on_reebe(pulled))
			pulled.apply_status_effect(/datum/status_effect/clock_warp_sickness, 15 SECONDS)
