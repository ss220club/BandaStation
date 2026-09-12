#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_demon_ai

/datum/unit_test/redspace_demon_ai/Run()
	var/datum/ai_movement/basic_avoidance/redspace_demon/avoidance = SSai_movement.movement_types[/datum/ai_movement/basic_avoidance/redspace_demon]
	if(!avoidance || avoidance.max_pathing_attempts != 10 || !(avoidance.move_flags & MOVEMENT_LOOP_START_INSTANT))
		return Fail("Redspace demons must have an avoidance movement that starts instantly and tolerates a long parked hold")
	var/datum/ai_movement/jps/redspace_demon/jps_movement = SSai_movement.movement_types[/datum/ai_movement/jps/redspace_demon]
	if(!jps_movement || jps_movement.max_pathing_attempts > 6)
		return Fail("Redspace demons must give up on an unroutable target quickly so the direct approach can take over")

	var/mob/living/basic/demon/redspace/test_mob = allocate(/mob/living/basic/demon/redspace, run_loc_floor_bottom_left)
	var/datum/ai_controller/basic_controller/simple/redspace_demon/melee/controller = test_mob.ai_controller
	if(!istype(controller))
		return Fail("The demon must use the redspace melee controller")
	var/mob/living/basic/demon/redspace/ranged/ranged_demon = allocate(/mob/living/basic/demon/redspace/ranged, run_loc_floor_bottom_left)
	if(!HAS_TRAIT_FROM(ranged_demon, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(/datum/element/simple_flying)))
		return Fail("Ranged redspace demons must be able to fly")
	var/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/redspace_demon/target_node = new
	if(target_node.vision_range != REDSPACE_DEMON_AGGRO_RANGE || target_node.target_loss_distance != REDSPACE_DEMON_TARGET_LOSS_DISTANCE)
		return Fail("Redspace demons must use the extended aggro and target retention ranges")
	qdel(target_node)

	var/datum/bt_node/ai_behavior/move_to_target/redspace_demon/approach_node = new
	approach_node.target_key = BB_CURRENT_TARGET
	if(approach_node.approach_range <= approach_node.required_dist || approach_node.approach_movement != /datum/ai_movement/basic_avoidance/redspace_demon)
		return Fail("The demon approach node must use direct avoidance movement within melee reach")
	approach_node.on_movement_failed(null)
	if(!approach_node.movement_failed)
		return Fail("An exhausted route must be reported so the demon can switch to a direct approach")

	var/turf/test_turf = get_turf(test_mob)
	var/turf/close_turf = get_step(get_step(test_turf, NORTH), NORTH)
	var/turf/far_turf = get_step(get_step(get_step(get_step(get_step(test_turf, NORTH), NORTH), NORTH), NORTH), NORTH)
	var/mob/living/carbon/human/close_target = allocate(/mob/living/carbon/human, close_turf)
	var/mob/living/carbon/human/far_target = allocate(/mob/living/carbon/human, far_turf)
	if(approach_node.get_desired_movement(controller, close_target) != /datum/ai_movement/basic_avoidance/redspace_demon)
		return Fail("A close visible target with a clear path must use direct avoidance movement")
	var/turf/boundary_turf = get_step(get_step(get_step(test_turf, NORTH), NORTH), NORTH)
	var/mob/living/carbon/human/boundary_target = allocate(/mob/living/carbon/human, boundary_turf)
	if(approach_node.get_desired_movement(controller, boundary_target) != /datum/ai_movement/basic_avoidance/redspace_demon)
		return Fail("A visible target at the edge of the approach range must still use direct avoidance movement")
	if(approach_node.get_desired_movement(controller, far_target) != /datum/ai_movement/jps/redspace_demon)
		return Fail("A target beyond the approach range must keep JPS pathfinding")

	var/turf/obstruction_turf = get_step(test_turf, NORTH)
	var/obj/structure/closet/crate/bin/test_bin = allocate(/obj/structure/closet/crate/bin, obstruction_turf)
	if(approach_node.get_desired_movement(controller, close_target) != /datum/ai_movement/jps/redspace_demon)
		return Fail("A smashable obstruction in the approach path must keep JPS so the demon can break it")
	test_mob.next_move = 0
	var/bin_integrity = test_bin.atom_integrity
	if(!redspace_demon_attack_obstruction(test_mob, close_target) || (!QDELETED(test_bin) && test_bin.atom_integrity >= bin_integrity))
		return Fail("A transformation movement must attack a smashable obstruction instead of stalling")
	qdel(test_bin)

	var/wall_restore_type = obstruction_turf.type
	obstruction_turf.ChangeTurf(/turf/closed/wall)
	if(approach_node.get_desired_movement(controller, close_target) != /datum/ai_movement/jps/redspace_demon)
		obstruction_turf.ChangeTurf(wall_restore_type)
		return Fail("A close target behind a wall must keep JPS so the demon can path around it")
	obstruction_turf.ChangeTurf(wall_restore_type)

	var/mob/living/carbon/human/failover_target = allocate(/mob/living/carbon/human, far_turf)
	failover_target.mind_initialize()
	controller.set_blackboard_key(BB_CURRENT_TARGET, failover_target)
	var/approach_result = approach_node.perform(0, controller)
	var/using_direct_approach = controller.ai_movement == SSai_movement.movement_types[/datum/ai_movement/basic_avoidance/redspace_demon]
	controller.ai_movement.stop_moving_towards(controller)
	controller.change_ai_movement_type(initial(controller.ai_movement))
	controller.clear_blackboard_key(BB_CURRENT_TARGET)
	if(approach_result & AI_BEHAVIOR_FAILED)
		return Fail("A failed route must not abort the demon's attack branch")
	if(!using_direct_approach)
		return Fail("A demon whose route failed must walk straight at its target instead of standing still")

	qdel(approach_node)

	var/list/wall_demons = list(
		allocate(/mob/living/basic/demon/redspace/devourer, get_step(test_turf, NORTHEAST)),
		allocate(/mob/living/basic/demon/redspace/moderate/minotaur, get_step(test_turf, NORTHWEST)),
		allocate(/mob/living/basic/demon/redspace/moderate/ravager, get_step(test_turf, SOUTHEAST)),
	)
	for(var/mob/living/basic/demon/redspace/wall_demon as anything in wall_demons)
		if(wall_demon.environment_smash != ENVIRONMENT_SMASH_RWALLS || wall_demon.obj_damage < 200)
			return Fail("Redspace demons that can reach the epicenter must smash walls quickly and tear through doors")
		var/turf/demon_turf = get_turf(wall_demon)
		var/turf/wall_turf = get_step(demon_turf, NORTH)
		if(!wall_turf)
			return Fail("Wall-breaking regression test could not allocate a two-tile route")
		var/turf/wall_target = get_step(wall_turf, NORTH)
		var/original_wall_type = wall_turf.type
		if(!wall_target)
			return Fail("Wall-breaking regression test could not allocate a two-tile route")
		var/wall_x = wall_turf.x
		var/wall_y = wall_turf.y
		var/wall_z = wall_turf.z
		wall_turf.ChangeTurf(/turf/closed/wall)
		wall_demon.next_move = 0
		var/has_obstruction = redspace_demon_has_obstruction(wall_demon, wall_target)
		var/attack_succeeded = redspace_demon_attack_obstruction(wall_demon, wall_target)
		var/turf/result_turf = locate(wall_x, wall_y, wall_z)
		var/wall_remains = iswallturf(result_turf)
		result_turf?.ChangeTurf(original_wall_type)
		if(!has_obstruction || !attack_succeeded || wall_remains)
			return Fail("Devourers, Minotaurs, and Ravagers must break a wall blocking their route")

		wall_turf = locate(wall_x, wall_y, wall_z)
		wall_turf.ChangeTurf(/turf/closed/wall/r_wall)
		for(var/impact in 1 to 5)
			wall_demon.next_move = 0
			if(!redspace_demon_attack_obstruction(wall_demon, wall_target))
				wall_turf = locate(wall_x, wall_y, wall_z)
				wall_turf?.ChangeTurf(original_wall_type)
				return Fail("A reinforced wall must accept repeated attacks from redspace demons")
			wall_turf = locate(wall_x, wall_y, wall_z)
			if(!istype(wall_turf, /turf/closed/wall/r_wall))
				wall_turf?.ChangeTurf(original_wall_type)
				return Fail("A reinforced wall must survive the first five redspace demon attacks")
		wall_demon.next_move = 0
		if(!redspace_demon_attack_obstruction(wall_demon, wall_target))
			wall_turf = locate(wall_x, wall_y, wall_z)
			wall_turf?.ChangeTurf(original_wall_type)
			return Fail("A reinforced wall must be breakable after repeated redspace demon attacks")
		wall_turf = locate(wall_x, wall_y, wall_z)
		var/reinforced_wall_remains = istype(wall_turf, /turf/closed/wall/r_wall)
		wall_turf?.ChangeTurf(original_wall_type)
		if(reinforced_wall_remains)
			return Fail("Six redspace demon attacks must break a reinforced wall")

	var/mob/living/basic/demon/redspace/far_wall_demon = wall_demons[1]
	var/turf/far_wall_demon_turf = get_turf(far_wall_demon)
	var/turf/far_wall_turf = get_step(far_wall_demon_turf, NORTH)
	var/turf/far_target_turf = get_step(get_step(get_step(get_step(get_step(far_wall_demon_turf, NORTH), NORTH), NORTH), NORTH), NORTH)
	var/obj/machinery/redspace_rift_sealer/far_wall_target = allocate(/obj/machinery/redspace_rift_sealer, far_target_turf)
	far_wall_target.active = TRUE
	var/datum/ai_controller/basic_controller/simple/redspace_demon/melee/far_wall_controller = far_wall_demon.ai_controller
	far_wall_controller.set_blackboard_key(BB_CURRENT_TARGET, far_wall_target)
	var/far_wall_restore_type = far_wall_turf?.type
	var/far_wall_x = far_wall_turf?.x
	var/far_wall_y = far_wall_turf?.y
	var/far_wall_z = far_wall_turf?.z
	if(!far_wall_turf || !far_target_turf)
		return Fail("The distant wall regression test could not allocate a route")
	far_wall_turf.ChangeTurf(/turf/closed/wall)
	far_wall_demon.next_move = 0
	far_wall_controller.SelectBehaviors(0)
	var/turf/far_result_turf = locate(far_wall_x, far_wall_y, far_wall_z)
	var/far_wall_remains = iswallturf(far_result_turf)
	far_result_turf?.ChangeTurf(far_wall_restore_type)
	if(far_wall_remains)
		return Fail("The obstruction behavior must break a wall before a demon reaches a distant target")

	var/turf/path_wall_turf = get_step(far_wall_demon_turf, EAST)
	var/path_wall_restore_type = path_wall_turf?.type
	var/path_wall_x = path_wall_turf?.x
	var/path_wall_y = path_wall_turf?.y
	var/path_wall_z = path_wall_turf?.z
	if(!path_wall_turf)
		return Fail("The JPS obstruction regression test could not allocate a route")
	path_wall_turf.ChangeTurf(/turf/closed/wall)
	var/datum/move_loop/has_target/jps/failure_loop = new(null, null, null, 0, 0, far_wall_controller)
	failure_loop.target = far_wall_target
	failure_loop.movement_path = list(path_wall_turf)
	far_wall_demon.next_move = 0
	redspace_demon_handle_failed_move(failure_loop)
	var/turf/path_result_turf = locate(path_wall_x, path_wall_y, path_wall_z)
	var/path_wall_remains = iswallturf(path_result_turf)
	path_result_turf?.ChangeTurf(path_wall_restore_type)
	qdel(failure_loop)
	if(path_wall_remains)
		return Fail("A failed JPS step must attack the blocker on its path, not only the direct target line")

	var/obj/machinery/redspace_rift_sealer/test_sealer = allocate(/obj/machinery/redspace_rift_sealer, test_turf)
	test_sealer.active = TRUE
	var/datum/targeting_strategy/basic/redspace_demon/sealer_strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/redspace_demon)
	if(!sealer_strategy.is_valid_target(test_mob, test_sealer, REDSPACE_DEMON_AGGRO_RANGE, controller))
		return Fail("An active sealer on the demon's z-level must be a valid target")
	controller.set_blackboard_key(BB_CURRENT_TARGET, test_sealer)
	test_sealer.active = FALSE
	if(!redspace_demon_discard_invalid_sealer_target(controller, test_sealer) || controller.blackboard[BB_CURRENT_TARGET])
		return Fail("Demons must immediately drop a sealer target after it becomes inactive")

	var/mob/living/basic/demon/redspace/hook_demon = allocate(/mob/living/basic/demon/redspace, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/hook_target = allocate(/mob/living/carbon/human, get_step(get_turf(hook_demon), NORTH))
	hook_target.mind_initialize()
	var/datum/ai_controller/basic_controller/simple/redspace_demon/melee/hook_controller = hook_demon.ai_controller
	if(!istype(hook_controller.ai_movement, /datum/ai_movement/jps/redspace_demon))
		return Fail("The demon must use the JPS subtype that swings on arrival")
	hook_controller.set_blackboard_key(BB_CURRENT_TARGET, hook_target)
	var/datum/move_loop/fake_loop = new(null, null, null, 0, 0, hook_controller)
	var/health_before = hook_target.health
	redspace_demon_post_move_attack(fake_loop, MOVELOOP_SUCCESS)
	if(hook_target.health >= health_before)
		return Fail("A successful step into melee range must immediately swing at the target")
	var/health_after_arrival = hook_target.health
	hook_demon.next_move = 0
	redspace_demon_try_immediate_attack(hook_controller, hook_target)
	if(hook_target.health >= health_after_arrival)
		return Fail("A demon already standing in melee range must swing without waiting for the attack behavior")
	qdel(fake_loop)

	var/mob/living/basic/demon/redspace/block_demon = allocate(/mob/living/basic/demon/redspace, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/block_target = allocate(/mob/living/carbon/human, get_step(get_turf(block_demon), NORTH))
	block_target.mind_initialize()
	block_target.AddComponent(/datum/component/regenerative_shield, number_of_hits = 1, damage_threshold = 100, regeneration_time = 1 MINUTES)
	var/datum/ai_controller/basic_controller/simple/redspace_demon/melee/block_controller = block_demon.ai_controller
	block_controller.set_blackboard_key(BB_CURRENT_TARGET, block_target)
	block_demon.next_move = 0
	var/block_health = block_target.health
	redspace_demon_try_immediate_attack(block_controller, block_target)
	if(block_target.health != block_health || block_demon.next_move <= world.time)
		return Fail("A blocked immediate attack must consume no health and still start the melee cooldown")
	redspace_demon_try_immediate_attack(block_controller, block_target)
	if(block_target.health != block_health)
		return Fail("A blocked immediate attack must not be retried before its cooldown expires")

#endif
