#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_devourer

/datum/unit_test/redspace_devourer/Run()
	var/mob/living/basic/demon/redspace/devourer/devourer = allocate(/mob/living/basic/demon/redspace/devourer)
	if(devourer.name != "demonic devourer" || devourer.icon != 'modular_bandastation/redspace/icons/mob/demonic/moderate_demons/64x64.dmi' || devourer.icon_state != "Devourer" || devourer.icon_dead != "Devourer-closed" || devourer.base_pixel_x != -16 || devourer.base_pixel_y != -10 || devourer.pixel_x != -16 || devourer.pixel_y != -10)
		return Fail("The Devourer must use its dedicated sprite and SET_BASE_PIXEL offsets")
	if(devourer.speed != 2 || devourer.move_force != MOVE_FORCE_OVERPOWERING || devourer.move_resist != INFINITY || devourer.pull_force != MOVE_FORCE_OVERPOWERING || devourer.can_be_pulled(null, INFINITY))
		return Fail("The Devourer must be slow and immune to normal pushing and pulling")
	if(devourer.obj_damage < 200 || devourer.environment_smash < ENVIRONMENT_SMASH_WALLS)
		return Fail("The Devourer must tear through doors and walls quickly during its retreat")
	if(devourer.devour_delay != 5 SECONDS || devourer.transformation_delay != 2 MINUTES)
		return Fail("The Devourer must expose the configured devour and transformation delays")
	if(!istype(devourer.ai_controller, /datum/ai_controller/basic_controller/simple/redspace_demon/melee/devourer))
		return Fail("The Devourer must use the specialized redspace melee controller")
	if(devourer.ai_controller.blackboard[BB_TARGETING_STRATEGY] != /datum/targeting_strategy/basic/redspace_demon/devourer || devourer.ai_controller.blackboard[BB_TARGET_PRIORITY_STRATEGY] != /datum/target_priority_strategy/nearest/redspace_demon || devourer.ai_controller.blackboard[BB_TARGET_MINIMUM_STAT] != HARD_CRIT)
		return Fail("The Devourer AI must search for nearby targets with its restricted targeting strategy and keep living crit victims valid so it can consume them")

	var/turf/ravager_turf = get_safe_random_station_turf_equal_weight()
	if(!ravager_turf)
		return Fail("The Ravager test requires an available station turf")
	var/mob/living/basic/demon/redspace/moderate/ravager/ravager = allocate(/mob/living/basic/demon/redspace/moderate/ravager, ravager_turf)
	var/datum/action/cooldown/mob_cooldown/redspace_beacon/beacon_action = locate(/datum/action/cooldown/mob_cooldown/redspace_beacon) in ravager.actions
	if(ravager.name != "ravager" || ravager.icon != 'modular_bandastation/redspace/icons/mob/demonic/moderate_demons/32x64.dmi' || ravager.icon_state != "ravager" || !beacon_action)
		return Fail("The Ravager must use the supplied sprite and receive the beacon ability")
	if(beacon_action.button_icon_state != "demonic_beacon" || beacon_action.cooldown_time < 60 SECONDS)
		return Fail("The beacon ability must use the beacon sprite and a long cooldown")
	if(!beacon_action.Activate(ravager) || length(beacon_action.beacons) != 1 || !beacon_action.beacons[1]?.field_source)
		return Fail("The Ravager must be able to create a demonic beacon")
	var/obj/structure/redspace/demonic_beacon/first_beacon = beacon_action.beacons[1]
	var/source_id = first_beacon.field_source.source_id
	if(first_beacon.field_source.strength != 7 || first_beacon.field_source.radius != REDSPACE_HEX_RADIUS || SSredspace.field_sources["[source_id]"] != first_beacon.field_source)
		return Fail("The demonic beacon must register a seven-point one-hex hotspot")
	if(first_beacon.icon_state != "demonic_beacon")
		return Fail("The demonic beacon must use the beacon sprite")
	beacon_action.next_use_time = 0
	if(!beacon_action.Activate(ravager) || length(beacon_action.beacons) != 2)
		return Fail("The Ravager must be able to place multiple demonic beacons")
	qdel(beacon_action.beacons[2])
	if(length(beacon_action.beacons) != 1)
		return Fail("Destroying one beacon must leave the rest tracked")
	qdel(first_beacon)
	if(length(beacon_action.beacons) || SSredspace.field_sources["[source_id]"])
		return Fail("Destroying the demonic beacon must remove its redspace hotspot")

	var/mob/living/carbon/human/incapacitated = allocate(/mob/living/carbon/human)
	incapacitated.mind_initialize()
	incapacitated.stat = SOFT_CRIT
	ADD_TRAIT(incapacitated, TRAIT_INCAPACITATED, REF(src))
	var/datum/targeting_strategy/basic/redspace_demon/devourer/targeting = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/redspace_demon/devourer)
	if(!targeting.is_valid_target(devourer, incapacitated, 9) || !targeting.can_keep_target(devourer, incapacitated, 16))
		return Fail("The Devourer must accept living minded incapacitated humans and retain them through cover")
	if(redspace_devourer_can_consume(incapacitated))
		return Fail("The Devourer must finish soft-crit victims before starting to consume them")

	var/mob/living/carbon/human/conscious = allocate(/mob/living/carbon/human)
	conscious.mind_initialize()
	if(!targeting.is_valid_target(devourer, conscious, 9) || redspace_devourer_can_consume(conscious))
		return Fail("The Devourer must target conscious humans but only consume incapacitated ones")

	var/mob/living/carbon/human/hard_crit = allocate(/mob/living/carbon/human)
	hard_crit.mind_initialize()
	hard_crit.stat = HARD_CRIT
	if(!targeting.is_valid_target(devourer, hard_crit, 9) || !targeting.can_keep_target(devourer, hard_crit, 16) || !redspace_devourer_can_consume(hard_crit))
		return Fail("The Devourer must keep and consume living hard-crit humans so a failed devour attempt can be retried")

	var/mob/living/carbon/human/mindless = allocate(/mob/living/carbon/human)
	mindless.stat = HARD_CRIT
	if(!targeting.is_valid_target(devourer, mindless, 9) || !redspace_devourer_can_consume(mindless))
		return Fail("The Devourer must devour every humanoid, including those without a mind")

	var/mob/living/carbon/human/dead = allocate(/mob/living/carbon/human)
	dead.mind_initialize()
	dead.stat = DEAD
	ADD_TRAIT(dead, TRAIT_INCAPACITATED, REF(src))
	if(redspace_devourer_can_consume(dead))
		return Fail("The Devourer must not target dead humans")

	var/turf/source_turf = get_safe_random_station_turf_equal_weight()
	var/turf/outside_turf
	for(var/attempt in 1 to 20)
		var/turf/candidate_turf = get_safe_random_station_turf_equal_weight()
		if(candidate_turf && candidate_turf.z == source_turf?.z && get_dist(candidate_turf, source_turf) > 5)
			outside_turf = candidate_turf
			break
	if(!source_turf || !outside_turf)
		return Fail("The Devourer epicenter fallback test requires two distant station turfs")
	var/list/saved_field_sources = SSredspace.field_sources
	var/list/saved_field_cells = SSredspace.field_cells
	var/datum/redspace_field_source/hotspot/test_source = new(0, source_turf, 4.5, 2, REDSPACE_PROFILE_DEMONIC, null, "unit test")
	SSredspace.field_sources = list("unit_test" = test_source)
	SSredspace.field_cells = list()
	var/turf/selected_epicenter = redspace_devourer_get_hottest_turf(outside_turf)
	SSredspace.field_sources = saved_field_sources
	SSredspace.field_cells = saved_field_cells
	qdel(test_source)
	if(selected_epicenter != source_turf)
		return Fail("A Devourer that eats outside the disturbance must still select the source epicenter")

	var/mob/living/basic/demon/redspace/devourer/capture_devourer = allocate(/mob/living/basic/demon/redspace/devourer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/capture_victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	capture_victim.mind_initialize()
	capture_victim.stat = HARD_CRIT
	ADD_TRAIT(capture_victim, TRAIT_INCAPACITATED, REF(src))
	if(!capture_devourer.capture_victim(capture_victim) || !capture_devourer.transformation_committed || capture_victim.loc != capture_devourer || capture_devourer.stored_victim != capture_victim || !HAS_TRAIT(capture_victim, TRAIT_STASIS))
		return Fail("A successful capture must move the victim into stasis inside the Devourer")
	var/datum/component/redspace_energy/capture_energy = capture_devourer.GetComponent(/datum/component/redspace_energy)
	if(!capture_energy || capture_energy.zero_energy_damage_percent)
		return Fail("A captured victim must prevent redspace starvation from killing the Devourer before transformation")
	capture_energy.update_environment(REDSPACE_DISTURBANCE_EXIT_VALUE, FALSE)
	capture_energy.current_energy = 0
	var/capture_health = capture_devourer.health
	capture_energy.on_life(capture_devourer, 1)
	if(capture_devourer.stat == DEAD || capture_devourer.health != capture_health)
		return Fail("A captured Devourer must survive an empty redspace energy reserve until transformation")
	var/turf/door_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/door_target_turf = get_step(door_turf, EAST)
	var/obj/machinery/door/airlock/instant/test_door = allocate(/obj/machinery/door/airlock/instant, door_turf)
	test_door.close(TRUE)
	capture_devourer.forceMove(run_loc_floor_bottom_left)
	capture_devourer.next_move = 0
	var/door_integrity = test_door.atom_integrity
	if(!redspace_demon_has_obstruction(capture_devourer, door_target_turf) || !redspace_demon_attack_obstruction(capture_devourer, door_target_turf) || (!QDELETED(test_door) && test_door.atom_integrity >= door_integrity))
		return Fail("A Devourer carrying a victim must be able to break a closed airlock blocking its path")
	capture_devourer.release_victim()
	if(capture_devourer.stored_victim || capture_devourer.transformation_committed || capture_victim.loc == capture_devourer || HAS_TRAIT(capture_victim, TRAIT_STASIS) || capture_energy.zero_energy_damage_percent != capture_devourer.redspace_zero_energy_damage_percent)
		return Fail("Releasing a captured victim must clear containment and stasis")

	var/mob/living/basic/demon/redspace/devourer/retreat_devourer = allocate(/mob/living/basic/demon/redspace/devourer, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/retreat_victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	retreat_victim.mind_initialize()
	retreat_victim.stat = HARD_CRIT
	ADD_TRAIT(retreat_victim, TRAIT_INCAPACITATED, REF(src))
	if(!retreat_devourer.capture_victim(retreat_victim))
		return Fail("The retreat regression test requires a captured victim")
	var/datum/ai_controller/basic_controller/simple/redspace_demon/melee/devourer/retreat_controller = retreat_devourer.ai_controller
	retreat_controller.force_ai_off()
	REMOVE_TRAIT(retreat_devourer, TRAIT_IMMOBILIZED, "redspace_devourer_stasis")

	// A closed airlock in the way must take damage while the controller is forced off.
	var/turf/retreat_door_turf = get_step(get_turf(retreat_devourer), EAST)
	var/turf/retreat_destination = get_step(get_step(retreat_door_turf, EAST), EAST)
	var/obj/machinery/door/airlock/instant/retreat_door = allocate(/obj/machinery/door/airlock/instant, retreat_door_turf)
	retreat_door.close(TRUE)
	retreat_devourer.next_move = 0
	var/retreat_door_integrity = retreat_door.atom_integrity
	var/retreat_step_result = retreat_devourer.devourer_retreat_step(retreat_destination)
	var/retreat_door_damaged = QDELETED(retreat_door) || retreat_door.atom_integrity < retreat_door_integrity
	if(!retreat_step_result || !retreat_door_damaged)
		retreat_controller.clear_forced_off()
		retreat_devourer.release_victim()
		return Fail("A retreating devourer with the controller forced off must smash a door blocking its route")

	// A wall in the way must be dismantled, and an open path must be stepped through.
	var/turf/retreat_wall_turf = get_step(get_turf(retreat_devourer), WEST)
	var/retreat_wall_restore_type = retreat_wall_turf?.type
	var/retreat_wall_x = retreat_wall_turf?.x
	var/retreat_wall_y = retreat_wall_turf?.y
	var/retreat_wall_z = retreat_wall_turf?.z
	if(!retreat_wall_turf)
		retreat_controller.clear_forced_off()
		retreat_devourer.release_victim()
		return Fail("The retreat wall regression test could not allocate a route")
	retreat_wall_turf.ChangeTurf(/turf/closed/wall)
	retreat_devourer.next_move = 0
	var/wall_step_result = retreat_devourer.devourer_retreat_step(get_step(retreat_wall_turf, WEST))
	var/turf/retreat_wall_result = locate(retreat_wall_x, retreat_wall_y, retreat_wall_z)
	var/retreat_wall_remains = iswallturf(retreat_wall_result)
	retreat_wall_result?.ChangeTurf(retreat_wall_restore_type)
	if(!wall_step_result || retreat_wall_remains)
		retreat_controller.clear_forced_off()
		retreat_devourer.release_victim()
		return Fail("A retreating devourer must dismantle a wall blocking its route")

	retreat_devourer.next_move = 0
	var/turf/open_step_turf = get_step(get_turf(retreat_devourer), NORTH)
	if(!open_step_turf || !retreat_devourer.devourer_retreat_step(open_step_turf) || get_turf(retreat_devourer) != open_step_turf)
		retreat_controller.clear_forced_off()
		retreat_devourer.release_victim()
		return Fail("A retreating devourer must step through an open path")
	retreat_controller.clear_forced_off()
	retreat_devourer.release_victim()

	// A reinforced wall on the direct line must not stall the retreat when a breakable
	// airlock sits next to it: the step must smash the airlock instead of pushing against
	// the unbreakable wall. The side walls also prove the devourer refuses to cut diagonally
	// through a corner sealed by a reinforced wall.
	var/turf/detour_start_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/mob/living/basic/demon/redspace/devourer/detour_devourer = allocate(/mob/living/basic/demon/redspace/devourer, detour_start_turf)
	var/mob/living/carbon/human/detour_victim = allocate(/mob/living/carbon/human, detour_start_turf)
	detour_victim.mind_initialize()
	detour_victim.stat = HARD_CRIT
	ADD_TRAIT(detour_victim, TRAIT_INCAPACITATED, REF(src))
	if(!detour_devourer.capture_victim(detour_victim))
		return Fail("The detour regression test requires a captured victim")
	detour_devourer.ai_controller.force_ai_off()
	REMOVE_TRAIT(detour_devourer, TRAIT_IMMOBILIZED, "redspace_devourer_stasis")
	var/turf/detour_wall_turf = get_step(detour_start_turf, EAST)
	var/turf/detour_south_wall_turf = get_step(detour_start_turf, SOUTH)
	var/turf/detour_door_turf = get_step(detour_start_turf, NORTH)
	var/detour_wall_restore_type = detour_wall_turf?.type
	var/detour_south_wall_restore_type = detour_south_wall_turf?.type
	if(!detour_wall_turf || !detour_south_wall_turf || !detour_door_turf)
		detour_devourer.ai_controller.clear_forced_off()
		detour_devourer.release_victim()
		return Fail("The detour regression test could not allocate a route")
	detour_wall_turf.ChangeTurf(/turf/closed/wall/r_wall)
	detour_south_wall_turf.ChangeTurf(/turf/closed/wall/r_wall)
	var/obj/machinery/door/airlock/instant/detour_door = allocate(/obj/machinery/door/airlock/instant, detour_door_turf)
	detour_door.close(TRUE)
	detour_devourer.next_move = 0
	var/detour_door_integrity = detour_door.atom_integrity
	var/turf/detour_destination = get_step(detour_wall_turf, EAST)
	var/detour_step_result = detour_devourer.devourer_retreat_step(detour_destination, list(detour_start_turf), null)
	var/detour_door_damaged = QDELETED(detour_door) || detour_door.atom_integrity < detour_door_integrity
	detour_wall_turf.ChangeTurf(detour_wall_restore_type)
	detour_south_wall_turf.ChangeTurf(detour_south_wall_restore_type)
	detour_devourer.ai_controller.clear_forced_off()
	detour_devourer.release_victim()
	if(!detour_step_result || !detour_door_damaged)
		return Fail("A retreating devourer must smash a breakable airlock next to an unbreakable wall instead of stalling against it")

	// Sealed in by reinforced walls on every side (with the room border walls behind),
	// a single step must be reported as blocked so the retreat gives up and transforms in
	// place. The devourer sits in the bottom-right corner of the room: east and south are
	// the room border, north and west are sealed off with reinforced walls.
	var/turf/sealed_start_turf = locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/mob/living/basic/demon/redspace/devourer/sealed_devourer = allocate(/mob/living/basic/demon/redspace/devourer, sealed_start_turf)
	var/mob/living/carbon/human/sealed_victim = allocate(/mob/living/carbon/human, sealed_start_turf)
	sealed_victim.mind_initialize()
	sealed_victim.stat = HARD_CRIT
	ADD_TRAIT(sealed_victim, TRAIT_INCAPACITATED, REF(src))
	if(!sealed_devourer.capture_victim(sealed_victim))
		return Fail("The sealed regression test requires a captured victim")
	sealed_devourer.ai_controller.force_ai_off()
	REMOVE_TRAIT(sealed_devourer, TRAIT_IMMOBILIZED, "redspace_devourer_stasis")
	var/turf/sealed_north_wall_turf = get_step(sealed_start_turf, NORTH)
	var/turf/sealed_west_wall_turf = get_step(sealed_start_turf, WEST)
	var/sealed_north_restore_type = sealed_north_wall_turf?.type
	var/sealed_west_restore_type = sealed_west_wall_turf?.type
	if(!sealed_north_wall_turf || !sealed_west_wall_turf)
		sealed_devourer.ai_controller.clear_forced_off()
		sealed_devourer.release_victim()
		return Fail("The sealed regression test could not allocate a route")
	sealed_north_wall_turf.ChangeTurf(/turf/closed/wall/r_wall)
	sealed_west_wall_turf.ChangeTurf(/turf/closed/wall/r_wall)
	sealed_devourer.next_move = 0
	var/sealed_step_result = sealed_devourer.devourer_retreat_step(get_step(sealed_start_turf, EAST), list(sealed_start_turf), null)
	sealed_north_wall_turf.ChangeTurf(sealed_north_restore_type)
	sealed_west_wall_turf.ChangeTurf(sealed_west_restore_type)
	sealed_devourer.ai_controller.clear_forced_off()
	sealed_devourer.release_victim()
	if(sealed_step_result)
		return Fail("A retreating devourer sealed in by reinforced walls must report a blocked step")

	// An epicenter sealed by an unbreakable wall is unreachable, while an open or
	// breakable one must be stepped into.
	var/turf/epicenter_start_turf = locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/mob/living/basic/demon/redspace/devourer/epicenter_devourer = allocate(/mob/living/basic/demon/redspace/devourer, epicenter_start_turf)
	var/turf/epicenter_turf = get_step(epicenter_start_turf, NORTH)
	var/epicenter_restore_type = epicenter_turf?.type
	if(!epicenter_turf)
		return Fail("The epicenter regression test could not allocate a destination")
	if(epicenter_devourer.devourer_epicenter_unreachable(epicenter_turf))
		return Fail("An open epicenter must be enterable")
	epicenter_turf.ChangeTurf(/turf/closed/wall/r_wall)
	if(!epicenter_devourer.devourer_epicenter_unreachable(epicenter_turf))
		epicenter_turf.ChangeTurf(epicenter_restore_type)
		return Fail("An epicenter sealed by a reinforced wall must count as unreachable")
	epicenter_turf.ChangeTurf(epicenter_restore_type)
	epicenter_turf.ChangeTurf(/turf/closed/wall)
	if(epicenter_devourer.devourer_epicenter_unreachable(epicenter_turf))
		epicenter_turf.ChangeTurf(epicenter_restore_type)
		return Fail("An epicenter sealed by a breakable wall must remain smashable")
	epicenter_turf.ChangeTurf(epicenter_restore_type)

	var/mob/living/basic/demon/redspace/devourer/transform_devourer = allocate(/mob/living/basic/demon/redspace/devourer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/transform_victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	transform_victim.mind_initialize()
	transform_victim.stat = HARD_CRIT
	ADD_TRAIT(transform_victim, TRAIT_INCAPACITATED, REF(src))
	if(!transform_devourer.capture_victim(transform_victim))
		return Fail("The Devourer must be able to capture a valid transformation victim")
	var/mob/living/basic/demon/redspace/moderate/ravager/transformed = transform_devourer.transform_with_victim("redspace_test")
	if(!transformed || QDELETED(transformed) || transformed.ckey != ckey("redspace_test") || transformed.icon_state != "ravager")
		if(transformed)
			transformed.ckey = null
			qdel(transformed)
		return Fail("Transformation must create a Ravager controlled by the selected ghost")
	if(QDELETED(transform_victim) || transform_victim.loc != transformed || transformed.stored_victim != transform_victim || !HAS_TRAIT(transform_victim, TRAIT_STASIS))
		transformed.ckey = null
		qdel(transformed)
		return Fail("Transformation must carry the victim inside the new demon instead of deleting it")
	var/turf/ravager_death_turf = get_turf(transformed)
	transformed.ckey = null
	transformed.death()
	if(QDELETED(transform_victim) || transform_victim.loc != ravager_death_turf || HAS_TRAIT(transform_victim, TRAIT_STASIS))
		return Fail("A Ravager's contained victim must fall out and leave stasis when the Ravager dies")

	var/mob/living/basic/demon/redspace/devourer/minotaur_devourer = allocate(/mob/living/basic/demon/redspace/devourer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/minotaur_victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	minotaur_victim.mind_initialize()
	minotaur_victim.stat = HARD_CRIT
	ADD_TRAIT(minotaur_victim, TRAIT_INCAPACITATED, REF(src))
	if(!minotaur_devourer.capture_victim(minotaur_victim))
		return Fail("The Devourer must be able to capture a victim for minotaur transformation")
	var/mob/living/basic/demon/redspace/moderate/minotaur/minotaur_transformed = minotaur_devourer.transform_with_minotaur()
	if(!minotaur_transformed || QDELETED(minotaur_transformed) || minotaur_transformed.icon_state != "minotaur")
		if(minotaur_transformed)
			qdel(minotaur_transformed)
		return Fail("Transformation must create a Minotaur with AI when no player responds")
	if(QDELETED(minotaur_victim) || minotaur_victim.loc != minotaur_transformed || minotaur_transformed.stored_victim != minotaur_victim)
		qdel(minotaur_transformed)
		return Fail("Minotaur transformation must also carry the victim inside the new demon")
	var/turf/minotaur_death_turf = get_turf(minotaur_transformed)
	minotaur_transformed.death()
	if(QDELETED(minotaur_victim) || minotaur_victim.loc != minotaur_death_turf || HAS_TRAIT(minotaur_victim, TRAIT_STASIS))
		return Fail("A Minotaur's contained victim must fall out and leave stasis when the Minotaur dies")

	var/mob/living/basic/demon/redspace/devourer/dead_victim_devourer = allocate(/mob/living/basic/demon/redspace/devourer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/dead_after_capture_victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	dead_after_capture_victim.mind_initialize()
	dead_after_capture_victim.stat = HARD_CRIT
	ADD_TRAIT(dead_after_capture_victim, TRAIT_INCAPACITATED, REF(src))
	if(!dead_victim_devourer.capture_victim(dead_after_capture_victim))
		return Fail("The Devourer must commit to transformation as soon as it captures a victim")
	dead_after_capture_victim.death()
	var/mob/living/basic/demon/redspace/moderate/minotaur/dead_victim_transformed = dead_victim_devourer.transform_with_minotaur()
	if(!dead_victim_transformed || QDELETED(dead_victim_transformed) || dead_victim_transformed.stored_victim != dead_after_capture_victim || dead_after_capture_victim.loc != dead_victim_transformed)
		if(dead_victim_transformed)
			qdel(dead_victim_transformed)
		return Fail("A victim dying after capture must not cancel the Devourer's transformation")
	qdel(dead_victim_transformed)

	var/mob/living/basic/demon/redspace/devourer/deleted_victim_devourer = allocate(/mob/living/basic/demon/redspace/devourer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/deleted_after_capture_victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	deleted_after_capture_victim.stat = HARD_CRIT
	if(!deleted_victim_devourer.capture_victim(deleted_after_capture_victim))
		return Fail("The Devourer must accept a victim before testing deletion during transformation")
	qdel(deleted_after_capture_victim)
	var/mob/living/basic/demon/redspace/moderate/minotaur/deleted_victim_transformed = deleted_victim_devourer.transform_with_minotaur()
	if(!deleted_victim_transformed || QDELETED(deleted_victim_transformed))
		if(deleted_victim_transformed)
			qdel(deleted_victim_transformed)
		return Fail("Deleting a captured victim must not cancel the Devourer's committed transformation")
	qdel(deleted_victim_transformed)

	var/mob/living/basic/demon/redspace/devourer/player_devourer = allocate(/mob/living/basic/demon/redspace/devourer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/player_victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	player_victim.mind_initialize()
	player_victim.stat = HARD_CRIT
	ADD_TRAIT(player_victim, TRAIT_INCAPACITATED, REF(src))
	if(!player_devourer.capture_victim(player_victim))
		return Fail("The Devourer must be able to capture a victim before a player transformation")
	player_devourer.ckey = "redspace_test_player"
	var/turf/player_transform_turf = get_turf(player_devourer)
	player_devourer.begin_transformation()
	var/mob/living/basic/demon/redspace/moderate/ravager/player_ravager = locate(/mob/living/basic/demon/redspace/moderate/ravager) in player_transform_turf
	if(!player_ravager || QDELETED(player_ravager) || player_ravager.ckey != ckey("redspace_test_player") || player_ravager.stored_victim != player_victim)
		if(player_ravager && !QDELETED(player_ravager))
			player_ravager.ckey = null
			qdel(player_ravager)
		return Fail("A player-controlled Devourer must become the Ravager themselves")
	player_ravager.ckey = null
	qdel(player_ravager)

	var/datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer/devourer_event = new
	if(devourer_event.event_id != "demonic_devourer" || devourer_event.profile_id != REDSPACE_PROFILE_DEMONIC || devourer_event.spawn_type != /mob/living/basic/demon/redspace/devourer || !devourer_event.automatic || devourer_event.weight != 1 || devourer_event.get_spawn_budget_cost() != 3 || devourer_event.spawn_policy_id != "demonic_devourer")
		return Fail("The Devourer must expose the configured automatic spawn event metadata")
	if(!SSredspace || SSredspace.event_registry["demonic_devourer"] != /datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer)
		return Fail("The Devourer spawn must be registered in SSredspace")
	var/datum/redspace_profile/demonic/profile = new
	if(!profile.is_event_allowed("demonic_devourer") || profile.get_event_profile(REDSPACE_STATE_STORM).get_event_weight("demonic_devourer") != 1)
		return Fail("The demonic profile must expose the Devourer in its storm event pool")
	qdel(profile)
	qdel(devourer_event)

#endif
