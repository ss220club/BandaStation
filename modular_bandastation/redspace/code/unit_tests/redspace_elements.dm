#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_elements
	var/test_x
	var/test_y
	var/test_z
	var/restore_type
	var/list/restore_baseturfs

/datum/unit_test/redspace_elements/Run()
	var/obj/structure/redspace/demonic_crystal/crystal = new
	allocated += crystal
	if(crystal.icon != 'modular_bandastation/redspace/icons/obj/demon_objs.dmi' || crystal.icon_state != "demonic_crystal" || crystal.light_range != 3 || crystal.light_color != "#ff0000")
		return Fail("Demonic crystal must use its red glowing sprite")
	var/datum/element/redspace_threshold/delete_below/crystal_element = SSdcs.GetElement(list(/datum/element/redspace_threshold/delete_below, REDSPACE_DISTURBANCE_ENTER_VALUE), FALSE)
	if(!crystal_element?.find_target_listener(crystal))
		return Fail("Demonic crystal must attach the redspace deletion element")

	var/delete_threshold = -100000
	var/obj/item/delete_target = allocate(/obj/item, run_loc_floor_bottom_left)
	delete_target.AddElement(/datum/element/redspace_threshold/delete_below, delete_threshold)

	var/datum/element/redspace_threshold/delete_below/delete_element = SSdcs.GetElement(list(/datum/element/redspace_threshold/delete_below, delete_threshold), FALSE)
	var/datum/redspace_threshold_listener/delete_listener = delete_element?.find_target_listener(delete_target)
	if(!delete_listener)
		return Fail("Delete element must create a per-host redspace listener")

	SEND_SIGNAL(delete_listener, COMSIG_REDSPACE_FIELD_CHANGED, null, 0, delete_threshold - 1, REDSPACE_STATE_CALM, REDSPACE_STATE_EBB, "unit test")
	if(!QDELETED(delete_target))
		return Fail("Delete element must remove its host below the configured threshold")

	var/turf/original_turf = run_loc_floor_bottom_left
	restore_type = original_turf.type
	restore_baseturfs = islist(original_turf.baseturfs) ? original_turf.baseturfs.Copy() : original_turf.baseturfs ? list(original_turf.baseturfs) : list()
	test_x = original_turf.x
	test_y = original_turf.y
	test_z = original_turf.z

	var/turf/redspace_turf = original_turf.ChangeTurf(/turf/open/floor, restore_baseturfs.Copy(), CHANGETURF_FORCEOP)
	if(!redspace_turf || redspace_turf.type == restore_type)
		return Fail("Element test turf must be replaceable")

	var/revert_threshold = -100000
	redspace_turf.AddElement(/datum/element/redspace_threshold/revert_turf_below, revert_threshold, restore_type, restore_baseturfs)
	var/datum/element/redspace_threshold/revert_turf_below/revert_element = SSdcs.GetElement(list(/datum/element/redspace_threshold/revert_turf_below, revert_threshold, restore_type, restore_baseturfs), FALSE)
	var/datum/redspace_threshold_listener/revert_listener = revert_element?.find_target_listener(redspace_turf)
	if(!revert_listener)
		return Fail("Turf revert element must create a per-turf redspace listener")

	SEND_SIGNAL(revert_listener, COMSIG_REDSPACE_FIELD_CHANGED, null, 0, revert_threshold - 1, REDSPACE_STATE_CALM, REDSPACE_STATE_EBB, "unit test")
	var/turf/restored_turf = locate(test_x, test_y, test_z)
	if(!restored_turf || restored_turf.type != restore_type)
		return Fail("Turf revert element must restore the previous turf type")

/datum/unit_test/redspace_elements/Destroy()
	var/turf/current_turf = locate(test_x, test_y, test_z)
	if(current_turf && restore_type && current_turf.type != restore_type)
		current_turf.ChangeTurf(restore_type, restore_baseturfs?.Copy(), CHANGETURF_FORCEOP)
	return ..()

#endif
