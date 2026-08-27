#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_rift_sealer

/datum/unit_test/redspace_rift_sealer/Run()
	var/turf/test_turf = run_loc_floor_bottom_left
	var/datum/redspace_field_source/hotspot/hotspot = new(0, test_turf, 4, 6, REDSPACE_PROFILE_DEMONIC)
	hotspot.growth_last_update_at = world.time - (2 MINUTES)
	var/list/growth_update = hotspot.get_growth_update()
	if(!growth_update || abs(growth_update[1] - 4.4) > 0.01 || abs(growth_update[2] - 7) > 0.01)
		qdel(hotspot)
		return Fail("Hotspots must grow by 0.2 strength and 0.5 radius per minute")
	qdel(hotspot)

	var/datum/redspace_field_source/hotspot/fractional_radius_source = new(0, test_turf, 1, 1, REDSPACE_PROFILE_DEMONIC)
	if(!fractional_radius_source.set_radius(1.5, "unit test") || fractional_radius_source.radius != 1.5 || fractional_radius_source.radius_squared != 2.25)
		qdel(fractional_radius_source)
		return Fail("Redspace source radii must preserve fractional growth values")
	qdel(fractional_radius_source)

	if(!SSredspace)
		return Fail("The redspace subsystem must be available for rift sealer tests")

	var/turf/supported_turf = test_turf
	if(!SSredspace.is_supported_z(supported_turf.z))
		supported_turf = locate(1, 1, SSredspace.station_z_levels[1])
	var/datum/redspace_field_source/hotspot/registered_hotspot = SSredspace.register_hotspot(supported_turf, 4, 6.5)
	var/obj/machinery/redspace_rift_sealer/sealer = allocate(/obj/machinery/redspace_rift_sealer, supported_turf)
	if(!registered_hotspot || !sealer)
		if(registered_hotspot)
			SSredspace.remove_source(registered_hotspot.source_id, "unit test cleanup")
		if(sealer)
			qdel(sealer)
		return Fail("A nearby rift sealer must join a registered hotspot")
	if(registered_hotspot.radius_squared != registered_hotspot.radius * registered_hotspot.radius)
		SSredspace.remove_source(registered_hotspot.source_id, "unit test cleanup")
		qdel(sealer)
		return Fail("Registered hotspots must keep radius and radius_squared synchronized")
	sealer.anchored = TRUE
	if(!sealer.try_start_sealing())
		SSredspace.remove_source(registered_hotspot.source_id, "unit test cleanup")
		qdel(sealer)
		return Fail("A nearby rift sealer must join a registered hotspot")

	if(!registered_hotspot.sealing_active || registered_hotspot.strength != REDSPACE_RIFT_SEALING_TARGET_STRENGTH)
		SSredspace.remove_source(registered_hotspot.source_id, "unit test cleanup")
		qdel(sealer)
		return Fail("Starting a seal must raise the hotspot to the sealing strength")

	var/mob/living/basic/demon/redspace/test_demon = allocate(/mob/living/basic/demon/redspace, supported_turf)
	var/mob/living/carbon/human/human_target = allocate(/mob/living/carbon/human, supported_turf)
	human_target.mind_initialize()
	var/datum/target_source/hearers/redspace_demon/demon_target_source = GET_TARGET_SOURCE(/datum/target_source/hearers/redspace_demon)
	var/list/demon_candidates = demon_target_source.collect_candidates(test_demon, test_demon.ai_controller, 9)
	var/datum/targeting_strategy/basic/redspace_demon/demon_targeting = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/redspace_demon)
	var/datum/target_priority_strategy/nearest/redspace_demon/demon_priority = GET_TARGET_PRIORITY_STRATEGY(/datum/target_priority_strategy/nearest/redspace_demon)
	if(!(sealer in demon_candidates) || !demon_targeting.is_valid_target(test_demon, human_target, 9) || demon_priority.select_target(test_demon.ai_controller, list(sealer, human_target)) != sealer)
		sealer.stop_sealing("unit test cleanup")
		SSredspace.remove_source(registered_hotspot.source_id, "unit test cleanup")
		qdel(sealer)
		return Fail("Active rift sealers must be available to redspace demon target acquisition")

	SSredspace.processing_sources -= "[registered_hotspot.source_id]"
	sealer.stop_sealing("unit test interruption")
	if(registered_hotspot.sealing_active || registered_hotspot.strength != 4 || SSredspace.processing_sources["[registered_hotspot.source_id]"] != registered_hotspot)
		SSredspace.remove_source(registered_hotspot.source_id, "unit test cleanup")
		qdel(sealer)
		return Fail("Removing the last sealer must interrupt, restore, and resume hotspot processing")

	SSredspace.remove_source(registered_hotspot.source_id, "unit test cleanup")
	qdel(sealer)

#endif
