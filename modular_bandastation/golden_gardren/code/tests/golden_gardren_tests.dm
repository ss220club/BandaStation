/// Combining the pair seats each pilot by the half they came from, docks both halves without copies, and the halves do not outlive the frame.
/datum/unit_test/golden_gardren_assemble

/datum/unit_test/golden_gardren_assemble/Run()
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/obj/vehicle/sealed/mecha/golden/golden = allocate(/obj/vehicle/sealed/mecha/golden)
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	golden.mob_enter(gunner, silent = TRUE)
	gardren.mob_enter(main_pilot, silent = TRUE)
	var/obj/item/stock_parts/power_store/gardren_cell = gardren.cell
	var/expected_max_integrity = golden.max_integrity + gardren.max_integrity

	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren, null, TRUE)
	TEST_ASSERT(combined.assemble(golden, gardren, gunner, main_pilot), "Assembly failed with both pilots in place")

	TEST_ASSERT_EQUAL(gunner.loc, combined, "The Golden pilot was not moved into the frame")
	TEST_ASSERT_EQUAL(main_pilot.loc, combined, "The Gardren pilot was not moved into the frame")
	TEST_ASSERT(!golden.is_occupant(gunner), "The Golden pilot is still listed as an occupant of the docked Golden")
	TEST_ASSERT(!gardren.is_occupant(main_pilot), "The Gardren pilot is still listed as an occupant of the docked Gardren")
	TEST_ASSERT(combined.is_driver(main_pilot), "The Gardren pilot did not get the main seat")
	TEST_ASSERT(!combined.is_driver(gunner), "The Golden pilot got control over movement")
	TEST_ASSERT(combined.occupants[gunner] & VEHICLE_CONTROL_EQUIPMENT, "The Golden pilot did not get the weapons seat")

	TEST_ASSERT_EQUAL(golden.loc, combined, "The Golden was not docked into the frame")
	TEST_ASSERT_EQUAL(gardren.loc, combined, "The Gardren was not docked into the frame")
	TEST_ASSERT_EQUAL(combined.cell, gardren_cell, "The frame does not run on the Gardren's cell")
	TEST_ASSERT_NULL(gardren.cell, "The Gardren kept a reference to the cell it handed over")
	TEST_ASSERT_EQUAL(combined.max_integrity, expected_max_integrity, "The frame's integrity is not the sum of both halves")

	qdel(combined)
	TEST_ASSERT(QDELETED(golden), "Destroying the frame left a free Golden behind")
	TEST_ASSERT(QDELETED(gardren), "Destroying the frame left a free Gardren behind")
	TEST_ASSERT(!QDELETED(main_pilot) && isturf(main_pilot.loc), "The Gardren pilot was not ejected when the frame was destroyed")
	TEST_ASSERT(!QDELETED(gunner) && isturf(gunner.loc), "The Golden pilot was not ejected when the frame was destroyed")

/// A lone Golden pilot keeps the weapons seat even though they enter the empty frame first.
/datum/unit_test/golden_gardren_assemble_one_pilot

/datum/unit_test/golden_gardren_assemble_one_pilot/Run()
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	var/obj/vehicle/sealed/mecha/golden/golden = allocate(/obj/vehicle/sealed/mecha/golden)
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	golden.mob_enter(gunner, silent = TRUE)

	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren, null, TRUE)
	TEST_ASSERT(combined.assemble(golden, gardren, gunner, null), "Assembly failed with only the Golden pilot")
	TEST_ASSERT_EQUAL(gunner.loc, combined, "The Golden pilot was not moved into the frame")
	TEST_ASSERT(!combined.is_driver(gunner), "The Golden pilot took the main seat")
	TEST_ASSERT(combined.occupants[gunner] & VEHICLE_CONTROL_EQUIPMENT, "The Golden pilot did not get the weapons seat")

/// The main seat punches with the mech's fists, the weapons seat cannot.
/datum/unit_test/golden_gardren_melee_seat

/datum/unit_test/golden_gardren_melee_seat/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	combined.mob_enter(main_pilot, silent = TRUE)
	combined.mob_enter(gunner, silent = TRUE)
	TEST_ASSERT(combined.is_driver(main_pilot), "The first pilot in did not take the main seat")
	combined.setDir(EAST)
	main_pilot.set_combat_mode(TRUE)
	gunner.set_combat_mode(TRUE)

	click_wrapper(gunner, target)
	TEST_ASSERT_EQUAL(target.get_brute_loss(), 0, "The weapons seat punched with the mech's fists")

	click_wrapper(main_pilot, target)
	TEST_ASSERT(target.get_brute_loss() > 0, "The main seat could not punch with the mech's fists")

/// The shield soaks damage from its own charge, collapses when emptied, cannot be raised right away, and drops without an operator.
/datum/unit_test/golden_gardren_shield

/datum/unit_test/golden_gardren_shield/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/operator = allocate(/mob/living/carbon/human/consistent)
	var/start_integrity = combined.get_integrity()

	TEST_ASSERT(combined.toggle_shield(operator), "The shield could not be raised on a charged mech")
	combined.take_damage(100, BRUTE)
	TEST_ASSERT_EQUAL(combined.get_integrity(), start_integrity, "Damage within the shield charge reached the hull")
	TEST_ASSERT_EQUAL(combined.shield_charge, combined.shield_max_charge - 100, "The shield did not spend its charge on the absorbed damage")

	combined.take_damage(combined.shield_charge + 50, BRUTE)
	TEST_ASSERT(!combined.shield_active, "The shield stayed up after its charge ran out")
	TEST_ASSERT_EQUAL(combined.get_integrity(), start_integrity - 50, "Damage beyond the shield charge did not reach the hull")
	TEST_ASSERT(!combined.toggle_shield(operator), "The shield was raised again right after collapsing")

	var/obj/vehicle/sealed/mecha/golden_gardren/manned = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	manned.mob_enter(main_pilot, silent = TRUE)
	manned.mob_enter(gunner, silent = TRUE)
	TEST_ASSERT(manned.toggle_shield(gunner), "The operator could not raise the shield")
	manned.mob_exit(gunner, silent = TRUE)
	TEST_ASSERT(!manned.shield_active, "The shield stayed up after the weapons operator left")
