#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_energy

/datum/unit_test/redspace_energy/Run()
	var/mob/living/basic/demon/redspace/test_mob = allocate(/mob/living/basic/demon/redspace, run_loc_floor_bottom_left)
	var/datum/component/redspace_energy/energy = test_mob.GetComponent(/datum/component/redspace_energy)
	if(!energy)
		return Fail("Redspace demons must receive the redspace energy component")
	if(test_mob.icon != 'modular_bandastation/redspace/icons/mob/demonic/lesser_demons.dmi' || test_mob.icon_state != "demon_melee")
		return Fail("Redspace demons must use the lesser demon sprite")
	if(!istype(test_mob.ai_controller, /datum/ai_controller/basic_controller/simple/redspace_demon/melee))
		return Fail("Redspace demons must use the obstacle-breaking hostile AI controller")
	if(!istype(test_mob.ai_controller.ai_movement, /datum/ai_movement/jps))
		return Fail("Redspace demons must use JPS movement to route around obstacles")
	if(test_mob.ai_controller.blackboard[BB_TARGETING_STRATEGY] != /datum/targeting_strategy/basic/redspace_demon || test_mob.ai_controller.blackboard[BB_TARGET_PRIORITY_STRATEGY] != /datum/target_priority_strategy/nearest/redspace_demon || test_mob.ai_controller.blackboard[BB_TARGET_MINIMUM_STAT] != STABLE)
		return Fail("Redspace demons must remember acquired targets, prioritize closer enemies and disengage once a target enters crit so Devourers can consume it")
	var/turf/cardinal_obstacle = get_step(test_mob, NORTH)
	var/turf/cardinal_target = get_step(cardinal_obstacle, NORTH)
	var/mob/living/basic/demon/redspace/diagonal_test_mob = allocate(/mob/living/basic/demon/redspace, get_step(test_mob, EAST))
	var/turf/diagonal_obstacle = get_step(diagonal_test_mob, NORTHEAST)
	var/turf/diagonal_target = get_step(diagonal_obstacle, NORTHEAST)
	var/obj/structure/closet/crate/bin/test_bin = allocate(/obj/structure/closet/crate/bin, cardinal_obstacle)
	var/obj/structure/closet/crate/bin/diagonal_bin = allocate(/obj/structure/closet/crate/bin, diagonal_obstacle)
	if(!redspace_demon_has_obstruction(test_mob, cardinal_target) || !redspace_demon_has_obstruction(diagonal_test_mob, diagonal_target))
		return Fail("Redspace demon movement must detect dense objects on cardinal and diagonal approach tiles")
	var/bin_integrity_before = test_bin.atom_integrity
	test_mob.melee_attack(test_bin, ignore_cooldown = TRUE)
	if(test_bin.atom_integrity >= bin_integrity_before)
		return Fail("Redspace melee demons must be able to damage a trash bin blocking their target")
	var/diagonal_bin_integrity_before = diagonal_bin.atom_integrity
	diagonal_test_mob.melee_attack(diagonal_bin, ignore_cooldown = TRUE)
	if(diagonal_bin.atom_integrity >= diagonal_bin_integrity_before)
		return Fail("Redspace melee demons must be able to damage a diagonal trash bin blocking their target")
	if(!test_mob.has_faction(FACTION_HELL))
		return Fail("Redspace demons must retain the inherited Hell faction")
	if(energy.max_energy != 100 || energy.current_energy != 100)
		return Fail("Redspace demons must start with a full configurable energy reserve")

	var/mob/living/basic/demon/redspace/ranged/test_ranged = allocate(/mob/living/basic/demon/redspace/ranged, run_loc_floor_bottom_left)
	var/datum/component/ranged_attacks/ranged_attacks = test_ranged.GetComponent(/datum/component/ranged_attacks)
	if(test_ranged.icon_state != "demon_ranged" || test_ranged.maxHealth >= test_mob.maxHealth || !istype(test_ranged.ai_controller, /datum/ai_controller/basic_controller/simple/redspace_demon/ranged) || !istype(test_ranged.ai_controller.ai_movement, /datum/ai_movement/jps) || !ranged_attacks || ranged_attacks.projectile_type != /obj/projectile/magic/lesser_fireball)
		return Fail("Redspace ranged demons must use the ranged sprite, reduced health and fireball attack AI")
	var/datum/bt_node/ai_behavior/basic_ranged_attack/redspace_demon/ranged_attack = new
	var/datum/bt_node/ai_behavior/attack_obstructions/redspace_demon/ranged/ranged_obstructions = new
	if(ranged_attack.max_range != 9 || ranged_obstructions.max_attack_range != 9)
		return Fail("Redspace ranged demons must preserve their nine-tile firing radius")
	qdel(ranged_attack)
	qdel(ranged_obstructions)

	var/mob/living/basic/demon/redspace/moderate/beholder/test_beholder = allocate(/mob/living/basic/demon/redspace/moderate/beholder, run_loc_floor_bottom_left)
	var/datum/component/ranged_attacks/beholder_attacks = test_beholder.GetComponent(/datum/component/ranged_attacks)
	if(test_beholder.icon != 'modular_bandastation/redspace/icons/mob/demonic/moderate_demons/64x64.dmi' || test_beholder.icon_state != "mature_beholder" || test_beholder.base_pixel_x != -16 || test_beholder.base_pixel_y != -10)
		return Fail("The mature beholder must use its dedicated 64x64 sprite and offsets")
	if(!istype(test_beholder.ai_controller, /datum/ai_controller/basic_controller/simple/redspace_demon/ranged/beholder) || test_beholder.ai_controller.blackboard[BB_RANGED_SKIRMISH_MIN_DISTANCE] != 2)
		return Fail("The mature beholder must use the ranged demon AI with point-blank retreat range")
	if(!beholder_attacks || beholder_attacks.burst_shots != 4 || beholder_attacks.projectile_type != /obj/projectile/magic/lesser_fireball)
		return Fail("The mature beholder must fire four-fireball bursts")
	if(!HAS_TRAIT_FROM(test_beholder, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(/datum/element/simple_flying)))
		return Fail("The mature beholder must be able to fly")
	if(test_beholder.maxHealth <= test_ranged.maxHealth)
		return Fail("The mature beholder must be bulkier than a lesser ranged demon")

	var/datum/redspace_event/spawn/mob/demonic_lesser_demon/mature_beholder/beholder_event = new
	if(beholder_event.event_id != "demonic_mature_beholder" || beholder_event.profile_id != REDSPACE_PROFILE_DEMONIC || beholder_event.spawn_type != /mob/living/basic/demon/redspace/moderate/beholder || !beholder_event.automatic || beholder_event.weight != 1 || beholder_event.get_spawn_budget_cost() != 2 || beholder_event.spawn_policy_id != "demonic_mature_beholder")
		return Fail("The mature beholder must expose the configured automatic spawn event metadata")
	if(!SSredspace || SSredspace.event_registry["demonic_mature_beholder"] != /datum/redspace_event/spawn/mob/demonic_lesser_demon/mature_beholder)
		return Fail("The mature beholder spawn must be registered in SSredspace")
	var/datum/redspace_profile/demonic/beholder_profile = new
	if(!beholder_profile.is_event_allowed("demonic_mature_beholder") || beholder_profile.get_event_profile(REDSPACE_STATE_STORM).get_event_weight("demonic_mature_beholder") != 1)
		return Fail("The demonic profile must expose the mature beholder in its storm event pool")
	qdel(beholder_profile)
	qdel(beholder_event)

	var/obj/projectile/magic/lesser_fireball/test_fireball = new
	var/obj/projectile/magic/fireball/standard_fireball = new
	if(test_fireball.icon_state != standard_fireball.icon_state || test_fireball.damage != 20 || test_fireball.ignite_chance != 30 || test_fireball.fire_stacks != 2 || istype(test_fireball, /obj/projectile/magic/fireball))
		return Fail("Ranged fireballs must be direct projectiles with no explosion")
	qdel(test_fireball)
	qdel(standard_fireball)

	var/mob/living/basic/demon/redspace/soldier/test_soldier = allocate(/mob/living/basic/demon/redspace/soldier, run_loc_floor_bottom_left)
	if(test_soldier.icon_state != "demon_soldier" || test_soldier.maxHealth <= test_mob.maxHealth || test_soldier.melee_damage_lower <= test_mob.melee_damage_lower || test_soldier.melee_damage_upper <= test_mob.melee_damage_upper)
		return Fail("Redspace soldiers must be stronger than lesser demons")
	if(!istype(test_soldier.ai_controller, /datum/ai_controller/basic_controller/simple/redspace_demon/melee))
		return Fail("Redspace soldiers must inherit the obstacle-breaking hostile AI controller")

	var/mob/living/basic/demon/redspace/moderate/minotaur/test_minotaur = allocate(/mob/living/basic/demon/redspace/moderate/minotaur, run_loc_floor_bottom_left)
	var/datum/component/redspace_energy/minotaur_energy = test_minotaur.GetComponent(/datum/component/redspace_energy)
	var/datum/action/cooldown/mob_cooldown/ground_slam/redspace/ground_slam = test_minotaur.ai_controller.blackboard[BB_TARGETED_ACTION]
	if(!minotaur_energy || minotaur_energy.max_energy != 200 || minotaur_energy.drain_percent != 5 || minotaur_energy.zero_energy_damage_percent != 0.5 || !ground_slam || ground_slam.range != 2 || ground_slam.damage != 20 || ground_slam.knockdown_duration != 2 SECONDS)
		return Fail("Moderate demons must have a larger, slower-draining energy reserve and a ground slam ability")

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
