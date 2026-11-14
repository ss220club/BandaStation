/// Combining the pair moves both pilots into their seats, docks both halves without copies, and the halves do not outlive the frame.
/datum/unit_test/golden_gardren_assemble

/datum/unit_test/golden_gardren_assemble/Run()
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	var/obj/vehicle/sealed/mecha/golden/golden = allocate(/obj/vehicle/sealed/mecha/golden)
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	golden.mob_enter(main_pilot, silent = TRUE)
	gardren.mob_enter(gunner, silent = TRUE)
	var/obj/item/stock_parts/power_store/golden_cell = golden.cell
	var/expected_max_integrity = golden.max_integrity + gardren.max_integrity

	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren, null, TRUE)
	TEST_ASSERT(combined.assemble(golden, gardren, main_pilot, gunner), "Assembly failed with both pilots in place")

	TEST_ASSERT_EQUAL(main_pilot.loc, combined, "The Golden pilot was not moved into the frame")
	TEST_ASSERT_EQUAL(gunner.loc, combined, "The Gardren pilot was not moved into the frame")
	TEST_ASSERT(!golden.is_occupant(main_pilot), "The Golden pilot is still listed as an occupant of the docked Golden")
	TEST_ASSERT(!gardren.is_occupant(gunner), "The Gardren pilot is still listed as an occupant of the docked Gardren")
	TEST_ASSERT(combined.is_driver(main_pilot), "The Golden pilot did not get the main seat")
	TEST_ASSERT(!combined.is_driver(gunner), "The Gardren pilot got control over movement")
	TEST_ASSERT(combined.occupants[gunner] & VEHICLE_CONTROL_EQUIPMENT, "The Gardren pilot did not get the weapons seat")

	TEST_ASSERT_EQUAL(golden.loc, combined, "The Golden was not docked into the frame")
	TEST_ASSERT_EQUAL(gardren.loc, combined, "The Gardren was not docked into the frame")
	TEST_ASSERT_EQUAL(combined.cell, golden_cell, "The frame does not run on the Golden's cell")
	TEST_ASSERT_NULL(golden.cell, "The Golden kept a reference to the cell it handed over")
	TEST_ASSERT_EQUAL(combined.max_integrity, expected_max_integrity, "The frame's integrity is not the sum of both halves")

	qdel(combined)
	TEST_ASSERT(QDELETED(golden), "Destroying the frame left a free Golden behind")
	TEST_ASSERT(QDELETED(gardren), "Destroying the frame left a free Gardren behind")
	TEST_ASSERT(!QDELETED(main_pilot) && isturf(main_pilot.loc), "The Golden pilot was not ejected when the frame was destroyed")
	TEST_ASSERT(!QDELETED(gunner) && isturf(gunner.loc), "The Gardren pilot was not ejected when the frame was destroyed")
