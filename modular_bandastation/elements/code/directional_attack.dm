/*!
 * This element allows the mob its attached to the ability to click an adjacent mob by clicking a distant atom
 * that is in the general direction relative to the parent.
 */
/datum/element/directional_attack/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignals(target, list(COMSIG_MOB_ATTACK_RANGED, COMSIG_MOB_ATTACK_RANGED_SECONDARY, COMSIG_MOB_RANGED_ITEM_INTERACTION, COMSIG_MOB_RANGED_ITEM_INTERACTION_SECONDARY), PROC_REF(on_ranged_attack))

/datum/element/directional_attack/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOB_ATTACK_RANGED, COMSIG_MOB_ATTACK_RANGED_SECONDARY, COMSIG_MOB_RANGED_ITEM_INTERACTION, COMSIG_MOB_RANGED_ITEM_INTERACTION_SECONDARY))

/**
 * This proc handles clicks on tiles that aren't adjacent to the source mob
 * In addition to clicking the distant tile, it checks the tile in the direction and clicks the mob in the tile if there is one
 *
 * Arguments:
 * * user - The mob clicking
 * * target - The atom being clicked (should be a distant one)
 * * modifiers - Miscellaneous click parameters, passed from Click itself
 */
/datum/element/directional_attack/proc/on_ranged_attack(mob/living/user, atom/target, list/modifiers)
	SIGNAL_HANDLER

	if(!user.combat_mode)
		return
	if(QDELETED(target))
		return

	var/turf/turf_to_check = get_step(user, angle2dir(get_angle(user, parse_caught_click_modifiers(modifiers, get_turf(user), user.client))))
	if(!turf_to_check?.IsReachableBy(user))
		return

	for(var/mob/living/target_mob in turf_to_check)
		if(target_mob.stat == DEAD)
			continue
		// This is here to undo the +1 click cooldown on ClickOn()
		user.next_click = world.time - 1
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, ClickOn), target_mob, list2params(modifiers))
		return COMPONENT_CANCEL_ATTACK_CHAIN
