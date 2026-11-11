#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_review
	parent_type = /datum/unit_test/redspace_observers
	abstract_type = /datum/unit_test/redspace_review

/datum/unit_test/redspace_review/provider_cache

/datum/unit_test/redspace_review/provider_cache/Run()
	var/list/coordinates = redspace_hex_coordinates(start_turf)
	if(SSredspace.context.get_zone_coefficient(start_turf.z, coordinates[1], coordinates[2]) != 1)
		return Fail("The empty context must start with its default coefficient")
	var/datum/redspace_context_provider/test_stub/provider = new
	provider.coefficient_target_key = redspace_hex_key(start_turf.z, coordinates[1], coordinates[2])
	SSredspace.context.add_provider(provider)
	if(SSredspace.context.get_zone_coefficient(start_turf.z, coordinates[1], coordinates[2]) != 0.5)
		return Fail("Adding a provider must invalidate an already sampled hex")

/datum/unit_test/redspace_review/energy_stasis

/datum/unit_test/redspace_review/energy_stasis/Run()
	var/mob/living/basic/demon/redspace/demon = allocate(/mob/living/basic/demon/redspace)
	var/datum/component/redspace_energy/energy = demon.GetComponent(/datum/component/redspace_energy)
	energy.field_observer.listener_turf = get_turf(demon)
	ADD_TRAIT(demon, TRAIT_STASIS, REF(src))
	for(var/value in list(3, 7))
		energy.update_environment(value, FALSE)
		energy.current_energy = 50
		energy.on_life(demon, 1)
		if(energy.current_energy != 50)
			return Fail("Stasis must pause energy drain and recovery")
	energy.current_energy = 0
	energy.update_environment(3, FALSE)
	var/health_before = demon.health
	energy.on_life(demon, 1)
	if(demon.health != health_before)
		return Fail("Stasis must also pause starvation damage")

/datum/unit_test/redspace_review/energy_partial_tick

/datum/unit_test/redspace_review/energy_partial_tick/Run()
	var/mob/living/basic/demon/redspace/demon = allocate(/mob/living/basic/demon/redspace)
	var/datum/component/redspace_energy/energy = demon.GetComponent(/datum/component/redspace_energy)
	energy.field_observer.listener_turf = get_turf(demon)
	energy.update_environment(3, FALSE)
	energy.current_energy = 5
	var/health_before = demon.health
	energy.on_life(demon, 1)
	if(abs(health_before - demon.health - 2.625) > 0.001 || energy.current_energy != 0)
		return Fail("Five energy at ten per second must cause only half a second of starvation damage")

/datum/unit_test/redspace_review/wave_reposition

/datum/unit_test/redspace_review/wave_reposition/Run()
	var/datum/redspace_field_source/wave/wave = allocate(/datum/redspace_field_source/wave, 0, start_turf, 4, 2, REDSPACE_PROFILE_DEBUG, 1 MINUTES, "test", 1, 0)
	wave.created_at = world.time - 10 SECONDS
	wave.get_current_center()
	var/expires_at = wave.expires_at
	var/turf/destination = get_step(start_turf, NORTH)
	if(!wave.set_position(destination))
		return Fail("The wave must accept a different origin")
	var/list/center = wave.get_current_center()
	if(center[1] != destination.x || center[2] != destination.y || wave.expires_at != expires_at)
		return Fail("Moving a wave must reset its displacement without extending its lifetime")

/datum/unit_test/redspace_review/sensor_position

/datum/unit_test/redspace_review/sensor_position/Run()
	var/obj/item/redspace_sensor/sensor = allocate(/obj/item/redspace_sensor)
	var/datum/redspace_sensor_record/record = allocate(/datum/redspace_sensor_record, "test")
	record.bind_sensor(sensor)
	record.record_sample(3, world.time)
	var/turf/destination = get_step(start_turf, NORTH)
	sensor.forceMove(destination)
	record.record_sample(3, world.time)
	if(record.last_x != destination.x || record.last_y != destination.y || record.last_z != destination.z)
		return Fail("An unchanged sample in the same tick must still update sensor coordinates")

/datum/unit_test/redspace_review/stabilizer_reposition

/datum/unit_test/redspace_review/stabilizer_reposition/Run()
	var/obj/machinery/redspace_stabilizer/stabilizer = allocate(/obj/machinery/redspace_stabilizer)
	if(!stabilizer.activate_stabilization(null))
		return Fail("The stabilizer fixture must activate")
	SSredspace.update_source_strength(stabilizer.field_source.source_id, -3)
	stabilizer.deactivate_stabilization(null)
	var/turf/destination = get_step(start_turf, NORTH)
	stabilizer.forceMove(destination)
	if(!stabilizer.activate_stabilization(null))
		return Fail("A relocated stabilizer must reactivate before its source finishes fading")
	if(stabilizer.field_source.origin_x != destination.x || stabilizer.field_source.origin_y != destination.y || stabilizer.field_source.z_level != destination.z)
		return Fail("A reused stabilizer source must follow the machine's new position")

/datum/unit_test/redspace_review/stabilizer_overlap

/datum/unit_test/redspace_review/stabilizer_overlap/Run()
	SSredspace.context.background_value = 10
	allocated += SSredspace.register_stabilizer_source(start_turf, -5, 3)
	allocated += SSredspace.register_stabilizer_source(start_turf, -5, 3)
	if(SSredspace.calculate_value(start_turf, SSredspace.get_cell(start_turf, TRUE)) != 2)
		return Fail("Overlapping stabilizers must sum their contributions and cap the combined correction at minus eight")

/datum/unit_test/redspace_review/sealer_acquisition

/datum/unit_test/redspace_review/sealer_acquisition/Run()
	var/obj/machinery/redspace_rift_sealer/sealer = allocate(/obj/machinery/redspace_rift_sealer)
	sealer.active = TRUE
	GLOB.redspace_active_rift_sealers |= sealer
	var/mob/living/basic/demon/redspace/demon = allocate(/mob/living/basic/demon/redspace)
	demon.ai_controller.force_ai_off()
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/redspace_demon)
	var/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/redspace_demon/behavior = allocate(/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/redspace_demon)
	behavior.target_key = BB_CURRENT_TARGET
	behavior.find_and_set_target(demon.ai_controller, strategy, behavior.get_target_priority_strategy(demon.ai_controller), 9)
	if(demon.ai_controller.blackboard[BB_CURRENT_TARGET] != sealer)
		return Fail("An active sealer must pass the real AI acquisition filter")

#endif
