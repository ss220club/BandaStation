#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_energy

/datum/unit_test/redspace_energy/Run()
	var/mob/living/basic/demon/redspace/test_mob = allocate(/mob/living/basic/demon/redspace, run_loc_floor_bottom_left)
	var/datum/component/redspace_energy/energy = test_mob.GetComponent(/datum/component/redspace_energy)
	if(!energy)
		return Fail("Redspace demons must receive the redspace energy component")
	if(test_mob.icon != 'modular_bandastation/redspace/icons/mob/demonic/lesser_demons.dmi' || test_mob.icon_state != "demon_melee")
		return Fail("Redspace demons must use the lesser demon sprite")
	if(!istype(test_mob.ai_controller, /datum/ai_controller/basic_controller/simple/simple_hostile))
		return Fail("Redspace demons must use the active hostile AI controller")
	if(!(FACTION_HELL in test_mob.faction))
		return Fail("Redspace demons must retain the inherited Hell faction")
	if(energy.max_energy != 100 || energy.current_energy != 100)
		return Fail("Redspace demons must start with a full configurable energy reserve")

	if(!energy.consume_energy(25) || energy.current_energy != 75)
		return Fail("Redspace energy must be consumed as a percentage of maximum energy")
	energy.listener_turf = get_turf(test_mob)
	energy.update_environment(REDSPACE_DISTURBANCE_ENTER_VALUE, FALSE)
	energy.current_energy = 0
	energy.on_life(test_mob, 1)
	if(energy.current_energy <= 0)
		return Fail("Redspace energy must recover in a high-disturbance zone")

	energy.update_environment(REDSPACE_DISTURBANCE_EXIT_VALUE, FALSE)
	energy.current_energy = 0
	var/health_before = test_mob.health
	energy.on_life(test_mob, 1)
	if(test_mob.health >= health_before)
		return Fail("Redspace demons must take damage while empty in a drain zone")

#endif
