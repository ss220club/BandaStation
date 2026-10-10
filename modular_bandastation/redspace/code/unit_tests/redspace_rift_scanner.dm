#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_rift_scanner

/datum/unit_test/redspace_rift_scanner/Run()
	if(!SSredspace?.initialized)
		return Fail("The redspace subsystem must be available for rift scanner tests")

	var/turf/test_turf = run_loc_floor_bottom_left
	if(!SSredspace.is_supported_z(test_turf.z))
		test_turf = locate(1, 1, SSredspace.station_z_levels[1])
	if(!test_turf)
		return Fail("The rift scanner test requires an available station turf")

	var/baseline = SSredspace.get_active_hotspot_count()
	var/datum/redspace_field_source/hotspot/active_hotspot = SSredspace.register_hotspot(test_turf, 4, 2, REDSPACE_PROFILE_DEBUG, "unit test")
	var/datum/redspace_field_source/hotspot/inactive_hotspot = SSredspace.register_hotspot(test_turf, 0, 2, REDSPACE_PROFILE_DEBUG, "unit test")
	var/datum/redspace_field_source/stabilizer/stabilizer_source = SSredspace.register_stabilizer_source(test_turf, -2, 2, "unit test")
	var/datum/redspace_field_source/wave/wave_source = SSredspace.register_wave_source(test_turf, 4, 2, 1, 0, 10 MINUTES, REDSPACE_PROFILE_DEBUG, "unit test")
	var/obj/structure/redspace/demonic_beacon/beacon = allocate(/obj/structure/redspace/demonic_beacon, test_turf)

	var/count_correct = active_hotspot && inactive_hotspot && stabilizer_source && wave_source && beacon?.field_source && !beacon.field_source.counts_as_active_hotspot && SSredspace.get_active_hotspot_count() == baseline + 1
	if(active_hotspot)
		SSredspace.remove_source(active_hotspot.source_id, "unit test cleanup")
	if(inactive_hotspot)
		SSredspace.remove_source(inactive_hotspot.source_id, "unit test cleanup")
	if(stabilizer_source)
		SSredspace.remove_source(stabilizer_source.source_id, "unit test cleanup")
	if(wave_source)
		SSredspace.remove_source(wave_source.source_id, "unit test cleanup")
	if(beacon)
		qdel(beacon)
	if(!count_correct)
		return Fail("The rift scanner must count only positive active hotspots and exclude beacons, stabilizers, and waves")

	var/obj/machinery/redspace_rift_scanner/scanner = allocate(/obj/machinery/redspace_rift_scanner, test_turf)
	var/construction_started_at = world.time
	scanner.on_construction()
	if(scanner.next_scan_at < construction_started_at + REDSPACE_RIFT_SCANNER_SCAN_INTERVAL)
		return Fail("The rift scanner must start its cooldown when construction finishes")

	scanner.on_power_changed(scanner)
	if(scanner.next_scan_at < world.time + REDSPACE_RIFT_SCANNER_SCAN_INTERVAL)
		return Fail("Power changes must restart the rift scanner cooldown")

	var/datum/design/board/redspace_rift_scanner/scanner_design = new
	if(scanner_design.build_path != /obj/item/circuitboard/machine/redspace_rift_scanner || scanner_design.materials[SSmaterials.get_material(/datum/material/bluespace)] != HALF_SHEET_MATERIAL_AMOUNT)
		qdel(scanner_design)
		return Fail("The rift scanner must have a circuit board design with bluespace material")
	qdel(scanner_design)

#endif
