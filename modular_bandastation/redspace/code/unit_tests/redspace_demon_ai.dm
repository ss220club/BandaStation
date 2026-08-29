#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_demon_ai

/datum/unit_test/redspace_demon_ai/Run()
	var/datum/ai_movement/basic_avoidance/redspace_demon/avoidance = SSai_movement.movement_types[/datum/ai_movement/basic_avoidance/redspace_demon]
	if(!avoidance || avoidance.max_pathing_attempts != 10 || !(avoidance.move_flags & MOVEMENT_LOOP_START_INSTANT))
		return Fail("Redspace demons must have an avoidance movement that starts instantly and tolerates a long parked hold")

	var/mob/living/basic/demon/redspace/test_mob = allocate(/mob/living/basic/demon/redspace, run_loc_floor_bottom_left)
	var/datum/ai_controller/basic_controller/simple/redspace_demon/melee/controller = test_mob.ai_controller
	if(!istype(controller))
		return Fail("The demon must use the redspace melee controller")

	var/datum/bt_node/ai_behavior/move_to_target/redspace_demon/approach_node = new
	approach_node.target_key = BB_CURRENT_TARGET
	if(approach_node.approach_range <= approach_node.required_dist || approach_node.approach_movement != /datum/ai_movement/basic_avoidance/redspace_demon)
		return Fail("The demon approach node must use direct avoidance movement within melee reach")
	approach_node.on_movement_failed(null)
	if(approach_node.movement_failed)
		return Fail("A failed route must not abort the demon's attack branch")

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
	if(approach_node.get_desired_movement(controller, far_target) != /datum/ai_movement/jps)
		return Fail("A target beyond the approach range must keep JPS pathfinding")

	var/turf/obstruction_turf = get_step(test_turf, NORTH)
	var/obj/structure/closet/crate/bin/test_bin = allocate(/obj/structure/closet/crate/bin, obstruction_turf)
	if(approach_node.get_desired_movement(controller, close_target) != /datum/ai_movement/jps)
		return Fail("A smashable obstruction in the approach path must keep JPS so the demon can break it")
	qdel(test_bin)

	var/wall_restore_type = obstruction_turf.type
	obstruction_turf.ChangeTurf(/turf/closed/wall)
	if(approach_node.get_desired_movement(controller, close_target) != /datum/ai_movement/jps)
		obstruction_turf.ChangeTurf(wall_restore_type)
		return Fail("A close target behind a wall must keep JPS so the demon can path around it")
	obstruction_turf.ChangeTurf(wall_restore_type)

	qdel(approach_node)

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
