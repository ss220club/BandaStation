#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_summon

/datum/unit_test/redspace_summon/Run()
	var/mob/living/basic/demon/redspace/moderate/ravager/ravager = allocate(/mob/living/basic/demon/redspace/moderate/ravager, run_loc_floor_bottom_left)
	var/datum/action/cooldown/mob_cooldown/redspace_summon/summon_action = locate(/datum/action/cooldown/mob_cooldown/redspace_summon) in ravager.actions
	if(!summon_action)
		return Fail("The Ravager must receive the summon lesser demon ability")
	if(summon_action.button_icon_state != "lesser_demon_conjure" || summon_action.cooldown_time < 60 SECONDS)
		return Fail("The summon ability must use the conjure sprite and a long cooldown")
	var/list/expected_limits = list(
		/mob/living/basic/demon/redspace = 3,
		/mob/living/basic/demon/redspace/ranged = 2,
		/mob/living/basic/demon/redspace/soldier = 1,
		/mob/living/basic/demon/redspace/devourer = 1,
	)
	for(var/summon_path in expected_limits)
		if(!summon_action.summon_options[summon_path] || summon_action.summon_options[summon_path][1] != expected_limits[summon_path])
			return Fail("The summon menu must expose the configured demon limits")

	summon_action.summon_type = /mob/living/basic/demon/redspace
	var/mob/living/basic/demon/redspace/summoned_demon = summon_action.spawn_summoned_demon(get_turf(ravager))
	if(!summoned_demon || QDELETED(summoned_demon) || !(summoned_demon in summon_action.summoned_demons) || summon_action.get_summoned_count(/mob/living/basic/demon/redspace) != 1)
		return Fail("Summoning must spawn the selected demon type and track it for the limits")
	summoned_demon.death()
	if(summon_action.get_summoned_count(/mob/living/basic/demon/redspace) != 0 || (summoned_demon in summon_action.summoned_demons))
		return Fail("A dead summoned demon must free its summon slot")
	qdel(summoned_demon)

	summon_action.summon_type = /mob/living/basic/demon/redspace/soldier
	var/mob/living/basic/demon/redspace/soldier/summoned_soldier = summon_action.spawn_summoned_demon(get_turf(ravager))
	if(!summoned_soldier || QDELETED(summoned_soldier) || summon_action.get_summoned_count(/mob/living/basic/demon/redspace) != 0 || summon_action.get_summoned_count(/mob/living/basic/demon/redspace/soldier) != 1)
		qdel(summoned_soldier)
		return Fail("Soldier summons must only count toward the soldier limit")
	qdel(summoned_soldier)

#endif
