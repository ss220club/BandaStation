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

	var/mob/living/basic/demon/redspace/ranged/test_ranged = allocate(/mob/living/basic/demon/redspace/ranged, run_loc_floor_bottom_left)
	var/datum/component/ranged_attacks/ranged_attacks = test_ranged.GetComponent(/datum/component/ranged_attacks)
	if(test_ranged.icon_state != "demon_ranged" || test_ranged.maxHealth >= test_mob.maxHealth || !istype(test_ranged.ai_controller, /datum/ai_controller/basic_controller/simple/simple_ranged) || !ranged_attacks || ranged_attacks.projectile_type != /obj/projectile/magic/lesser_fireball)
		return Fail("Redspace ranged demons must use the ranged sprite, reduced health and fireball attack AI")

	var/obj/projectile/magic/lesser_fireball/test_fireball = new
	var/obj/projectile/magic/fireball/standard_fireball = new
	if(test_fireball.icon_state != standard_fireball.icon_state || test_fireball.damage != 14 || test_fireball.ignite_chance != 30 || test_fireball.fire_stacks != 2 || istype(test_fireball, /obj/projectile/magic/fireball))
		return Fail("Ranged fireballs must be direct projectiles with no explosion")
	qdel(test_fireball)
	qdel(standard_fireball)

	var/mob/living/basic/demon/redspace/soldier/test_soldier = allocate(/mob/living/basic/demon/redspace/soldier, run_loc_floor_bottom_left)
	if(test_soldier.icon_state != "demon_soldier" || test_soldier.maxHealth <= test_mob.maxHealth || test_soldier.melee_damage_lower <= test_mob.melee_damage_lower || test_soldier.melee_damage_upper <= test_mob.melee_damage_upper)
		return Fail("Redspace soldiers must be stronger than lesser demons")

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
