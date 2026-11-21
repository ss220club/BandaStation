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

/// A lone pilot cannot combine, and two pilots cannot combine without confirming.
/datum/unit_test/golden_gardren_combine_requires_crew

/datum/unit_test/golden_gardren_combine_requires_crew/Run()
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/driver = allocate(/mob/living/carbon/human/consistent)
	var/obj/vehicle/sealed/mecha/golden/golden = allocate(/obj/vehicle/sealed/mecha/golden)
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren, get_step(golden, EAST))
	golden.mob_enter(gunner, silent = TRUE)

	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren, null, TRUE)
	TEST_ASSERT_NOTNULL(golden_gardren_combine_blocker(golden, gardren), "A lone pilot was offered the combination")
	TEST_ASSERT(!combined.assemble(golden, gardren, gunner, null), "Assembly succeeded with only one pilot")
	gardren.mob_enter(driver, silent = TRUE)
	TEST_ASSERT_NULL(golden_gardren_combine_blocker(golden, gardren), "The pair with two ready pilots cannot request a combination")
	golden_gardren_try_combine(golden, gunner)
	TEST_ASSERT_EQUAL(gunner.loc, golden, "The halves combined without a confirmation")
	TEST_ASSERT(!(golden in GLOB.golden_gardren_busy) && !(gardren in GLOB.golden_gardren_busy), "The cancelled request left the pair busy")

/// Aiming the weapons seat's strike must not intercept the main pilot's punches or fire the arm weapon.
/datum/unit_test/golden_gardren_melee_seat

/datum/unit_test/golden_gardren_melee_seat/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	combined.mob_enter(main_pilot, silent = TRUE)
	TEST_ASSERT(combined.mob_try_enter(gunner), "The second pilot could not board the mech")
	TEST_ASSERT(combined.is_driver(main_pilot), "The first pilot in did not take the main seat")
	var/strike_type = /datum/action/vehicle/sealed/mecha/ivanov_strike/golden_gardren
	TEST_ASSERT_NULL(LAZYACCESSASSOC(combined.occupant_actions, main_pilot, strike_type), "The main seat received the missile strike")
	var/datum/action/vehicle/sealed/mecha/ivanov_strike/strike = LAZYACCESSASSOC(combined.occupant_actions, gunner, strike_type)
	TEST_ASSERT_NOTNULL(strike, "The second pilot did not receive the missile strike")
	combined.setDir(EAST)
	main_pilot.set_combat_mode(TRUE)
	gunner.set_combat_mode(TRUE)
	strike.Trigger(gunner)
	TEST_ASSERT(strike.aiming_missile, "The gunner could not start targeting")

	click_wrapper(gunner, target)
	TEST_ASSERT_EQUAL(target.get_brute_loss(), 0, "The weapons seat punched with the mech's fists")

	click_wrapper(main_pilot, target)
	TEST_ASSERT(target.get_brute_loss() > 0, "The main seat could not punch with the mech's fists")
	TEST_ASSERT_EQUAL(strike.rockets_left, 3, "The main pilot's click spent a missile strike")

	var/turf/strike_target = get_step(target, EAST)
	var/charge_before = combined.get_charge()
	click_wrapper(gunner, strike_target, list(RIGHT_CLICK = 1, BUTTON = RIGHT_CLICK))
	var/obj/effect/pod_landingzone/zone = locate() in strike_target
	if(zone?.pod)
		allocated += zone.pod
	TEST_ASSERT(istype(zone?.pod, /obj/structure/closet/supplypod/podspawn/golden_gardren_missile), "The gunner did not target a Golden-Gardren missile")
	TEST_ASSERT_EQUAL(strike.rockets_left, 2, "The gunner's click did not spend a missile strike")
	TEST_ASSERT_EQUAL(combined.get_charge(), charge_before, "The arm laser fired simultaneously with the strike")
	combined.mob_exit(gunner, silent = TRUE, forced = TRUE)
	TEST_ASSERT(QDELETED(strike), "The absent gunner's targeting action was not cleaned up")

/// The shield soaks damage from its own charge, collapses when emptied and cannot be raised right away.
/datum/unit_test/golden_gardren_shield

/datum/unit_test/golden_gardren_shield/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/operator = allocate(/mob/living/carbon/human/consistent)
	var/datum/component/golden_gardren_shield/shield = combined.GetComponent(/datum/component/golden_gardren_shield)
	var/start_integrity = combined.get_integrity()

	TEST_ASSERT(shield.toggle(operator), "The shield could not be raised on a charged mech")
	combined.take_damage(100, BRUTE)
	TEST_ASSERT_EQUAL(combined.get_integrity(), start_integrity, "Damage within the shield charge reached the hull")
	TEST_ASSERT_EQUAL(shield.charge, shield.max_charge - 100, "The shield did not spend its charge on the absorbed damage")

	combined.take_damage(shield.charge + 50, BRUTE)
	TEST_ASSERT(!shield.active, "The shield stayed up after its charge ran out")
	TEST_ASSERT_EQUAL(combined.get_integrity(), start_integrity - 50, "Damage beyond the shield charge did not reach the hull")
	TEST_ASSERT(!shield.toggle(operator), "The shield was raised again right after collapsing")

/// The gunner of the combined mech and the pilot of the lone Golden raise the shield from their button, and it drops once they leave.
/datum/unit_test/golden_gardren_shield_operators

/datum/unit_test/golden_gardren_shield_operators/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	combined.mob_enter(main_pilot, silent = TRUE)
	combined.mob_enter(gunner, silent = TRUE)
	TEST_ASSERT_NULL(LAZYACCESSASSOC(combined.occupant_actions, main_pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_shield), "The main seat got the shield button")

	var/obj/vehicle/sealed/mecha/golden/golden = allocate(/obj/vehicle/sealed/mecha/golden)
	var/mob/living/carbon/human/consistent/golden_pilot = allocate(/mob/living/carbon/human/consistent)
	golden.mob_enter(golden_pilot, silent = TRUE)

	for(var/obj/vehicle/sealed/mecha/mech as anything in list(combined, golden))
		var/mob/living/operator = mech == combined ? gunner : golden_pilot
		var/datum/component/golden_gardren_shield/shield = mech.GetComponent(/datum/component/golden_gardren_shield)
		var/datum/action/shield_button = LAZYACCESSASSOC(mech.occupant_actions, operator, /datum/action/vehicle/sealed/mecha/golden_gardren_shield)
		TEST_ASSERT_NOTNULL(shield_button, "[mech] gave its operator no shield button")
		shield_button.Trigger()
		TEST_ASSERT(shield.active, "The operator of [mech] could not raise the shield from the button")
		mech.mob_exit(operator, silent = TRUE)
		TEST_ASSERT(!shield.active, "The shield of [mech] stayed up after its operator left")

/// Changing seats counts as leaving the old one: a shield left without a gunner comes down.
/datum/unit_test/golden_gardren_seat_swap_drops_shield

/datum/unit_test/golden_gardren_seat_swap_drops_shield/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/pilot = allocate(/mob/living/carbon/human/consistent)
	combined.mob_enter(pilot, silent = TRUE)
	var/datum/component/golden_gardren_shield/shield = combined.GetComponent(/datum/component/golden_gardren_shield)

	combined.assign_seat(pilot, main_seat = FALSE)
	TEST_ASSERT(shield.toggle(pilot), "The gunner could not raise the shield")
	combined.assign_seat(pilot, main_seat = TRUE)
	TEST_ASSERT(!shield.active, "The shield stayed up after its only operator moved to the main seat")

/// Separation gives back the same halves with their pilots and parts, spreads the damage and leaves no frame behind.
/datum/unit_test/golden_gardren_separate

/datum/unit_test/golden_gardren_separate/Run()
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/obj/vehicle/sealed/mecha/golden/golden = allocate(/obj/vehicle/sealed/mecha/golden)
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	golden.mob_enter(gunner, silent = TRUE)
	gardren.mob_enter(main_pilot, silent = TRUE)
	var/obj/item/stock_parts/power_store/gardren_cell = gardren.cell
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren, null, TRUE)
	TEST_ASSERT(combined.assemble(golden, gardren, gunner, main_pilot), "Assembly failed with both pilots in place")

	combined.take_damage(combined.max_integrity / 2, BRUTE)
	TEST_ASSERT(combined.use_energy(gardren_cell.maxcharge / 4), "The combined frame could not use the Gardren's battery")
	combined.mob_exit(gunner, silent = TRUE, forced = TRUE)
	TEST_ASSERT_NOTNULL(combined.separate_blocker(), "A single occupant was offered a separation")
	TEST_ASSERT(!combined.disassemble(), "The frame separated with only one pilot")
	combined.mob_enter(gunner, silent = TRUE)
	golden_gardren_try_separate(combined, gunner)
	TEST_ASSERT(!QDELETED(combined), "The frame separated without a confirmation")
	TEST_ASSERT(!(combined in GLOB.golden_gardren_busy), "The cancelled request left the frame busy")
	TEST_ASSERT_NULL(combined.separate_blocker(), "A combined frame with room around it refused to separate")
	TEST_ASSERT(combined.disassemble(), "Separation failed with room around the frame")

	TEST_ASSERT(QDELETED(combined), "The frame was left behind after separation")
	TEST_ASSERT(!QDELETED(golden) && isturf(golden.loc), "The Golden did not come back onto the map")
	TEST_ASSERT(!QDELETED(gardren) && isturf(gardren.loc), "The Gardren did not come back onto the map")
	TEST_ASSERT(golden.loc != gardren.loc, "Both halves landed on the same turf")
	TEST_ASSERT_EQUAL(main_pilot.loc, gardren, "The main seat pilot did not go back into the Gardren")
	TEST_ASSERT_EQUAL(gunner.loc, golden, "The weapons seat pilot did not go back into the Golden")
	TEST_ASSERT_EQUAL(gardren.cell, gardren_cell, "The Gardren did not get its cell back")
	TEST_ASSERT_EQUAL(gardren_cell.percent(), 75, "Separation changed the remaining battery charge")
	TEST_ASSERT(!golden.completely_disabled && !gardren.completely_disabled, "A half stayed switched off after separation")
	TEST_ASSERT_EQUAL(gardren.get_integrity(), round(gardren.max_integrity / 2), "The Gardren did not take its share of the damage")
	TEST_ASSERT_EQUAL(golden.get_integrity(), round(golden.max_integrity / 2), "The Golden did not take its share of the damage")

/// A frame that was not formed from the pair has no halves to give back.
/datum/unit_test/golden_gardren_separate_spawned_frame

/datum/unit_test/golden_gardren_separate_spawned_frame/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	TEST_ASSERT(istype(combined.cell, /obj/item/stock_parts/power_store/cell/bluespace), "The admin-spawned frame has no bluespace battery")
	for(var/slot in list(MECHA_L_ARM, MECHA_R_ARM))
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy/golden_gardren/laser = combined.equip_by_category[slot]
		TEST_ASSERT(istype(laser), "An arm of the combined frame has no heavy laser")
		TEST_ASSERT_EQUAL(laser.equip_cooldown, 1.2 SECONDS, "The heavy laser does not use its shorter firing cooldown")
		var/charge_before = combined.get_charge()
		TEST_ASSERT(combined.use_energy(laser.energy_drain), "The battery could not power the laser")
		TEST_ASSERT_EQUAL(combined.get_charge(), charge_before - laser.energy_drain, "The laser drained the wrong amount of charge")
	TEST_ASSERT_NOTNULL(combined.separate_blocker(), "An admin-spawned frame offered to separate into free halves")
	TEST_ASSERT(!combined.disassemble(), "An admin-spawned frame separated into free halves")
	TEST_ASSERT(!QDELETED(combined), "A failed separation deleted the frame")

/// Returns the turf a rescue capsule carrying [pilot] is going to land on, or null if the pilot is not in a capsule.
/// Waits out the burning countdown of a mech that took a lethal blow, up to a little longer than the countdown itself.
/datum/unit_test/proc/golden_gardren_wait_for_blow_up(obj/vehicle/sealed/mecha/mech)
	for(var/waited in 1 to 80)
		if(QDELETED(mech))
			return
		sleep(1)

/datum/unit_test/proc/golden_gardren_capsule_target(mob/living/pilot, atom/mech_turf)
	if(!istype(pilot.loc, /obj/structure/closet/supplypod))
		return null
	for(var/obj/effect/pod_landingzone/zone in range(6, mech_turf))
		if(zone.pod == pilot.loc)
			return get_turf(zone)
	return null

/// Without a chosen spot the ejection fires both pilots in capsules onto separate free turfs right next to the mech, and knocks them down.
/datum/unit_test/golden_gardren_emergency_eject

/datum/unit_test/golden_gardren_emergency_eject/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	combined.mob_enter(main_pilot, silent = TRUE)
	combined.mob_enter(gunner, silent = TRUE)
	var/datum/component/golden_gardren_ejection/ejection = combined.GetComponent(/datum/component/golden_gardren_ejection)

	TEST_ASSERT(ejection.start(main_pilot), "The ejection countdown did not start")
	var/launch_delay = timeleft(ejection.timer)
	ejection.eject()
	var/list/landings = list()
	for(var/mob/living/carbon/human/pilot as anything in list(main_pilot, gunner))
		TEST_ASSERT(!combined.is_occupant(pilot), "A pilot stayed inside after the emergency ejection")
		var/obj/structure/closet/supplypod/capsule = pilot.loc
		TEST_ASSERT(istype(capsule), "A pilot was not put into a rescue capsule")
		var/opening_delay = launch_delay + capsule.delays[POD_TRANSIT] + capsule.delays[POD_FALLING] + capsule.delays[POD_OPENING]
		TEST_ASSERT(opening_delay >= (6.8 SECONDS) && opening_delay <= (7 SECONDS), "The capsule should open about 6.9 seconds after starting the countdown")
		var/turf/landing = golden_gardren_capsule_target(pilot, combined.loc)
		TEST_ASSERT_NOTNULL(landing, "A pilot was not put into a rescue capsule")
		TEST_ASSERT(landing != combined.loc, "A capsule was sent onto the mech itself despite free turfs around it")
		TEST_ASSERT(get_dist(landing, combined) <= 1, "A capsule without a chosen spot was sent further than the neighbouring turfs")
		TEST_ASSERT(pilot.IsKnockdown(), "A pilot was not knocked down by the emergency ejection")
		landings += landing
	TEST_ASSERT(landings[1] != landings[2], "Both capsules were sent onto the same turf")

/// A pilot can only pick a free, safe landing spot within range, and the capsule goes exactly there.
/datum/unit_test/golden_gardren_eject_landing_choice

/datum/unit_test/golden_gardren_eject_landing_choice/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	combined.mob_enter(main_pilot, silent = TRUE)
	var/turf/frame_turf = combined.loc
	// Two tiles away inside the test room, so the spot is in range and in sight.
	var/turf/picked = locate(min(frame_turf.x + 2, run_loc_floor_top_right.x), frame_turf.y, frame_turf.z)
	var/turf/far_away = locate(frame_turf.x + 10, frame_turf.y, frame_turf.z)
	var/datum/component/golden_gardren_ejection/ejection = combined.GetComponent(/datum/component/golden_gardren_ejection)

	TEST_ASSERT(!ejection.choose_landing(main_pilot, picked), "A landing spot was accepted before the ejection countdown started")
	TEST_ASSERT(ejection.start(main_pilot), "The ejection countdown did not start")
	TEST_ASSERT(!ejection.choose_landing(main_pilot, frame_turf), "The mech's own turf was accepted as a landing spot")
	TEST_ASSERT(!ejection.choose_landing(main_pilot, far_away), "A landing spot out of range was accepted")
	// Some test maps keep the test room airless; there the same free floor must be refused as unsafe instead.
	if(!is_safe_turf(picked, extended_safety_checks = TRUE))
		TEST_ASSERT(!ejection.choose_landing(main_pilot, picked), "An unsafe landing spot was accepted")
		ejection.eject()
		TEST_ASSERT(golden_gardren_capsule_target(main_pilot, frame_turf) != picked, "A capsule was sent to an unsafe spot")
		return
	TEST_ASSERT_NULL(ejection.landing_blocker(picked), "A free safe floor two tiles away is refused as a landing spot")
	TEST_ASSERT(ejection.choose_landing(main_pilot, picked), "A free landing spot in range was refused")

	ejection.eject()
	TEST_ASSERT_EQUAL(golden_gardren_capsule_target(main_pilot, frame_turf), picked, "The capsule was not sent to the chosen spot")
	TEST_ASSERT(!LAZYLEN(ejection.landings), "The landing choice outlived the ejection")

/// A lethal blow sets the manned frame burning instead of destroying it at once; when it blows up, the pilots are fired clear instead of being deleted with it.
/datum/unit_test/golden_gardren_destruction_ejects
	priority = TEST_LONGER

/datum/unit_test/golden_gardren_destruction_ejects/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	combined.mob_enter(main_pilot, silent = TRUE)
	combined.mob_enter(gunner, silent = TRUE)
	var/turf/frame_turf = combined.loc

	combined.take_damage(combined.get_integrity() + 10, BRUTE)
	TEST_ASSERT(!QDELETED(combined), "The manned frame blew up at once, leaving the pilots no time to aim their capsules")
	TEST_ASSERT(golden_gardren_is_ejecting(combined), "A lethal blow did not start the ejection countdown")
	TEST_ASSERT(combined.is_occupant(main_pilot) && combined.is_occupant(gunner), "The pilots were thrown out before the countdown ran out")
	golden_gardren_wait_for_blow_up(combined)
	TEST_ASSERT(QDELETED(combined), "The burning frame did not blow up when the countdown ran out")
	for(var/mob/living/carbon/human/pilot as anything in list(main_pilot, gunner))
		TEST_ASSERT(!QDELETED(pilot), "A pilot was deleted together with the frame")
		var/turf/landing = golden_gardren_capsule_target(pilot, frame_turf)
		TEST_ASSERT_NOTNULL(landing, "A pilot was not fired clear of the destroyed frame in a capsule")
		TEST_ASSERT(landing != frame_turf, "A pilot was sent under the wreck despite free turfs around it")
	var/obj/structure/mecha_wreckage/golden_gardren/wreck = locate() in frame_turf
	TEST_ASSERT_NOTNULL(wreck, "The destroyed frame left no wreck")
	qdel(wreck)

/// The lone Golden and Gardren carry the same capsules: the pilot gets the button, and a destroyed half fires its pilot clear.
/datum/unit_test/golden_gardren_halves_eject
	priority = TEST_LONGER

/datum/unit_test/golden_gardren_halves_eject/Run()
	for(var/half_type in list(/obj/vehicle/sealed/mecha/golden, /obj/vehicle/sealed/mecha/gardren))
		var/obj/vehicle/sealed/mecha/half = allocate(half_type)
		var/mob/living/carbon/human/consistent/pilot = allocate(/mob/living/carbon/human/consistent)
		half.mob_enter(pilot, silent = TRUE)
		var/turf/half_turf = half.loc
		TEST_ASSERT(istype(half.cell, /obj/item/stock_parts/power_store/cell/bluespace), "[half] has no bluespace battery")
		var/expected_utility_slots = half_type == /obj/vehicle/sealed/mecha/gardren ? 2 : 3
		TEST_ASSERT_EQUAL(half.max_equip_by_category[MECHA_UTILITY], expected_utility_slots, "[half] lost its chassis-specific slot limit")
		for(var/slot in list(MECHA_L_ARM, MECHA_R_ARM))
			var/obj/item/mecha_parts/mecha_equipment/weapon/laser = half.equip_by_category[slot]
			TEST_ASSERT_EQUAL(laser?.type, /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser, "[half] does not have standard lasers in both arms")
		TEST_ASSERT_NOTNULL(LAZYACCESSASSOC(half.occupant_actions, pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject), "The pilot of [half] got no ejection button")

		half.take_damage(half.get_integrity() + 10, BRUTE)
		TEST_ASSERT(!QDELETED(half) && golden_gardren_is_ejecting(half), "[half_type] blew up at once instead of burning through the ejection countdown")
		golden_gardren_wait_for_blow_up(half)
		TEST_ASSERT(QDELETED(half), "[half_type] did not blow up when the countdown ran out")
		TEST_ASSERT(!QDELETED(pilot), "The pilot of [half_type] was deleted together with it")
		var/turf/landing = golden_gardren_capsule_target(pilot, half_turf)
		TEST_ASSERT_NOTNULL(landing, "The pilot of [half_type] was not fired clear in a capsule")
		TEST_ASSERT(landing != half_turf, "The pilot of [half_type] was sent under the wreck despite free turfs around it")
		for(var/obj/structure/mecha_wreckage/wreck in half_turf)
			qdel(wreck)

/// The cockpit panel only runs each seat's own commands, whatever the client sends.
/datum/unit_test/golden_gardren_cockpit_permissions

/datum/unit_test/golden_gardren_cockpit_permissions/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	combined.mob_enter(main_pilot, silent = TRUE)
	combined.mob_enter(gunner, silent = TRUE)
	var/datum/golden_gardren_cockpit/cockpit = allocate(/datum/golden_gardren_cockpit, combined)
	var/datum/tgui/main_ui = allocate(/datum/tgui, main_pilot, cockpit, "GoldenGardrenCockpit")
	var/datum/tgui/gunner_ui = allocate(/datum/tgui, gunner, cockpit, "GoldenGardrenCockpit")
	var/datum/component/golden_gardren_shield/shield = combined.GetComponent(/datum/component/golden_gardren_shield)

	cockpit.ui_act("toggle_shield", list(), main_ui, main_ui.state)
	TEST_ASSERT(!shield.active, "The main seat raised the shield")
	cockpit.ui_act("toggle_shield", list(), gunner_ui, gunner_ui.state)
	TEST_ASSERT(shield.active, "The weapons seat could not raise the shield")

	var/strafe_before = combined.strafe
	cockpit.ui_act("toggle_strafe", list(), gunner_ui, gunner_ui.state)
	TEST_ASSERT_EQUAL(combined.strafe, strafe_before, "The weapons seat toggled strafing")
	cockpit.ui_act("toggle_strafe", list(), main_ui, main_ui.state)
	TEST_ASSERT(combined.strafe != strafe_before, "The main seat could not toggle strafing")

	TEST_ASSERT(combined.use_energy(combined.cell.maxcharge / 2), "The mech could not use its battery")
	var/list/main_data = cockpit.ui_data(main_pilot)
	TEST_ASSERT(isnull(main_data["weapons"]), "The main seat was sent the weapons seat data")
	TEST_ASSERT_EQUAL(main_data["charge_percent"], 50, "The cockpit did not show the remaining battery charge")
	var/list/gunner_data = cockpit.ui_data(gunner)
	TEST_ASSERT(isnull(gunner_data["strafe"]), "The weapons seat was sent the main seat data")
	TEST_ASSERT(length(gunner_data["weapons"]), "The weapons seat got no weapon data")

/// Activated inside a mech of the pair the summon implant binds to it; a docked half answers through its frame.
/datum/unit_test/golden_gardren_summon_link

/datum/unit_test/golden_gardren_summon_link/Run()
	var/mob/living/carbon/human/consistent/pilot = allocate(/mob/living/carbon/human/consistent)
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	var/obj/item/implant/golden_gardren_summon/implant = allocate(/obj/item/implant/golden_gardren_summon)
	TEST_ASSERT(implant.implant(pilot, null, silent = TRUE, force = TRUE), "The summon implant could not be implanted")

	gardren.mob_enter(pilot, silent = TRUE)
	implant.activate("action_button")
	TEST_ASSERT_EQUAL(implant.get_linked_mech(), gardren, "Activating the implant inside the Gardren did not bind it")

	var/obj/vehicle/sealed/mecha/golden_gardren/frame = allocate(/obj/vehicle/sealed/mecha/golden_gardren, null, TRUE)
	gardren.forceMove(frame)
	TEST_ASSERT_EQUAL(implant.get_linked_mech(), frame, "A docked half did not answer the summon through its frame")

/// The summon refuses an occupied mech, and an empty one is dropped in a pod next to the summoner, never onto them.
/datum/unit_test/golden_gardren_summon_drop
	priority = TEST_LONGER
	normal_floor_required = TRUE

/datum/unit_test/golden_gardren_summon_drop/Run()
	var/mob/living/carbon/human/consistent/summoner = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/stowaway = allocate(/mob/living/carbon/human/consistent)
	var/obj/vehicle/sealed/mecha/golden/golden = allocate(/obj/vehicle/sealed/mecha/golden, run_loc_floor_top_right)
	var/obj/item/implant/golden_gardren_summon/implant = allocate(/obj/item/implant/golden_gardren_summon)
	TEST_ASSERT(implant.implant(summoner, null, silent = TRUE, force = TRUE), "The summon implant could not be implanted")

	var/turf/open/floor/landing = implant.find_landing(summoner)
	TEST_ASSERT_NOTNULL(landing, "No landing spot was found around the summoner in the test room")
	TEST_ASSERT(landing != get_turf(summoner), "The mech was going to land on the summoner")
	TEST_ASSERT(get_dist(landing, summoner) <= 2, "The landing spot is too far from the summoner")

	golden.mob_enter(stowaway, silent = TRUE)
	TEST_ASSERT_NOTNULL(implant.summon_blocker(golden, summoner, landing, check_cooldown = TRUE), "An occupied mech was allowed to be summoned")
	golden.mob_exit(stowaway, silent = TRUE)
	TEST_ASSERT_NULL(implant.summon_blocker(golden, summoner, landing, check_cooldown = TRUE), "An empty mech with a free landing spot was refused")

	implant.drop_mech(golden, landing)
	TEST_ASSERT(istype(golden.loc, /obj/structure/closet/supplypod), "The summoned mech was not put into the drop pod")
	var/obj/effect/pod_landingzone/zone = locate() in landing
	TEST_ASSERT_NOTNULL(zone, "The drop pod was not sent to the landing spot")
	TEST_ASSERT_EQUAL(zone.pod, golden.loc, "The landing spot belongs to a different pod")
	stowaway.forceMove(landing)
	var/landing_type = landing.type
	var/stowaway_health = stowaway.get_brute_loss()
	var/summoner_health = summoner.get_brute_loss()
	for(var/waited in 1 to 45)
		if(golden.loc == landing)
			break
		sleep(1)
	TEST_ASSERT_EQUAL(golden.loc, landing, "The mech did not land on the marked tile")
	TEST_ASSERT_EQUAL(landing.type, landing_type, "The impact changed the turf type")
	TEST_ASSERT(landing.broken, "The impact did not crack the floor tile")
	TEST_ASSERT_EQUAL(stowaway.get_brute_loss() - stowaway_health, 10, "The impact dealt the wrong amount of damage")
	TEST_ASSERT_EQUAL(summoner.get_brute_loss(), summoner_health, "The impact harmed someone on a neighbouring tile")

/// The phase shift belongs to the pilot: it carries the mech through obstacles at an energy cost and keeps the hands idle while on.
/datum/unit_test/golden_gardren_phasing

/datum/unit_test/golden_gardren_phasing/Run()
	var/obj/vehicle/sealed/mecha/golden_gardren/combined = allocate(/obj/vehicle/sealed/mecha/golden_gardren)
	var/mob/living/carbon/human/consistent/main_pilot = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/gunner = allocate(/mob/living/carbon/human/consistent)
	combined.mob_enter(main_pilot, silent = TRUE)
	combined.mob_enter(gunner, silent = TRUE)
	TEST_ASSERT_NULL(LAZYACCESSASSOC(combined.occupant_actions, gunner, /datum/action/vehicle/sealed/mecha/golden_gardren_phasing), "The weapons seat got the phase shift button")

	var/turf/start = combined.loc
	var/turf/blocked = get_step(start, EAST)
	var/turf/beyond = get_step(blocked, EAST)
	allocate(/obj/structure/girder, blocked)
	TEST_ASSERT(!combined.Move(blocked, EAST), "The mech walked into an obstacle without the phase shift")

	var/datum/action/phasing_button = LAZYACCESSASSOC(combined.occupant_actions, main_pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_phasing)
	TEST_ASSERT_NOTNULL(phasing_button, "The main seat got no phase shift button")
	phasing_button.Trigger()
	var/datum/component/golden_gardren_phasing/phasing = combined.GetComponent(/datum/component/golden_gardren_phasing)
	TEST_ASSERT(phasing.active, "The phase shift did not turn on from the pilot's button")
	TEST_ASSERT_NOTNULL(combined.get_filter("golden_gardren_phasing"), "The phasing mech is not blurred")

	var/charge_before = combined.get_charge()
	TEST_ASSERT(combined.Move(blocked, EAST), "The phasing mech could not pass through an obstacle")
	TEST_ASSERT(combined.get_charge() < charge_before, "Phasing through an obstacle cost no energy")

	var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent, beyond)
	main_pilot.set_combat_mode(TRUE)
	click_wrapper(main_pilot, target)
	TEST_ASSERT_EQUAL(target.get_brute_loss(), 0, "The mech punched while phasing")

	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	var/mob/living/carbon/human/consistent/gardren_pilot = allocate(/mob/living/carbon/human/consistent)
	gardren.mob_enter(gardren_pilot, silent = TRUE)
	TEST_ASSERT_NOTNULL(LAZYACCESSASSOC(gardren.occupant_actions, gardren_pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_phasing), "The Gardren pilot got no phase shift button")

/// The fist seizes an adjacent target that rides along; squeezing chokes and then breaks bones; a click throws the target; a plain resist does not free it.
/datum/unit_test/golden_gardren_fist
	priority = TEST_LONGER

/datum/unit_test/golden_gardren_fist/Run()
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	var/mob/living/carbon/human/consistent/pilot = allocate(/mob/living/carbon/human/consistent)
	var/turf/target_turf = get_step(gardren.loc, EAST)
	var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent, target_turf)
	// Consistent dummies act instantly; the grab and the escape are timed actions, so both use the live game's timing.
	for(var/mob/living/carbon/human/consistent/actor as anything in list(pilot, target))
		actor.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	gardren.mob_enter(pilot, silent = TRUE)
	gardren.setDir(EAST)
	pilot.set_combat_mode(TRUE)
	var/datum/component/golden_gardren_fist/fist = gardren.GetComponent(/datum/component/golden_gardren_fist)

	var/datum/action/fist_button = LAZYACCESSASSOC(gardren.occupant_actions, pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_fist)
	var/datum/action/squeeze_button = LAZYACCESSASSOC(gardren.occupant_actions, pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze)
	TEST_ASSERT_NOTNULL(fist_button, "The pilot got no fist button")
	TEST_ASSERT_NOTNULL(squeeze_button, "The pilot got no squeeze button")
	fist_button.Trigger()
	TEST_ASSERT(fist.grab_mode, "The fist button did not switch the hand to grabbing")

	click_wrapper(pilot, target)
	TEST_ASSERT_EQUAL(target.get_brute_loss(), 0, "The pilot punched the target in grab mode")
	TEST_ASSERT_NULL(fist.held, "The fist closed without its wind-up")
	sleep(1.5 SECONDS)
	TEST_ASSERT_EQUAL(fist.held, target, "The fist did not seize the adjacent target")
	TEST_ASSERT_EQUAL(target.buckled, gardren, "The seized target is not held by the mech")
	TEST_ASSERT(HAS_TRAIT(target, TRAIT_HANDS_BLOCKED), "The seized target can still use its hands")

	var/datum/action/phasing_button = LAZYACCESSASSOC(gardren.occupant_actions, pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_phasing)
	phasing_button.Trigger()
	var/datum/component/golden_gardren_phasing/phasing = gardren.GetComponent(/datum/component/golden_gardren_phasing)
	TEST_ASSERT(!phasing.active, "The phase shift turned on with a target in the fist")

	TEST_ASSERT_EQUAL(target.loc, gardren.loc, "The seized target was not lifted onto the mech")
	TEST_ASSERT(gardren.Move(target_turf, EAST), "The mech could not step forward with a target in the fist")
	TEST_ASSERT_EQUAL(target.loc, gardren.loc, "The seized target did not ride along with the mech")

	target.resist_buckle()
	TEST_ASSERT_EQUAL(target.buckled, gardren, "A plain resist got the target out of the fist at once")

	// The squeeze is driven by its processing tick; the test steps it second by second instead of waiting.
	squeeze_button.Trigger()
	TEST_ASSERT(fist.squeezing, "The squeeze button did not start squeezing the held target")
	TEST_ASSERT(HAS_TRAIT(target, TRAIT_MUTE), "The squeezed target can still speak")
	fist.process(1)
	TEST_ASSERT(target.get_oxy_loss() > 0, "The squeeze did not choke the target")
	TEST_ASSERT_EQUAL(target.get_brute_loss(), 0, "The squeeze crushed the target before it had been held long enough")
	for(var/second in 1 to 9)
		fist.process(1)
	TEST_ASSERT(target.get_brute_loss() > 0, "A long squeeze did not crush the target")
	var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_NOTNULL(locate(/datum/wound/blunt/bone) in chest.wounds, "A long squeeze did not break any bones")

	var/turf/aim = locate(min(gardren.x + 3, run_loc_floor_top_right.x), gardren.y, gardren.z)
	var/brute_before = target.get_brute_loss()
	click_wrapper(pilot, aim)
	TEST_ASSERT_NULL(fist.held, "A click with a target in the fist did not throw it")
	TEST_ASSERT_NULL(target.buckled, "The thrown target is still held by the mech")
	TEST_ASSERT(!fist.squeezing, "The squeeze went on after the target was thrown")
	TEST_ASSERT(!HAS_TRAIT(target, TRAIT_MUTE) && !HAS_TRAIT(target, TRAIT_HANDS_BLOCKED), "The thrown target kept the fist's restraints")
	TEST_ASSERT(target.get_brute_loss() > brute_before, "The throw did no damage")

/// When the pilot leaves, the fist opens and puts the held target down in front of the mech.
/datum/unit_test/golden_gardren_fist_release
	priority = TEST_LONGER

/datum/unit_test/golden_gardren_fist_release/Run()
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	var/mob/living/carbon/human/consistent/pilot = allocate(/mob/living/carbon/human/consistent)
	var/turf/target_turf = get_step(gardren.loc, EAST)
	var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent, target_turf)
	gardren.mob_enter(pilot, silent = TRUE)
	gardren.setDir(EAST)
	var/datum/component/golden_gardren_fist/fist = gardren.GetComponent(/datum/component/golden_gardren_fist)
	var/datum/action/fist_button = LAZYACCESSASSOC(gardren.occupant_actions, pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_fist)
	fist_button.Trigger()
	click_wrapper(pilot, target)
	// Consistent dummies close the fist at once.
	TEST_ASSERT_EQUAL(fist.held, target, "The fist did not seize the adjacent target")
	var/datum/action/squeeze_button = LAZYACCESSASSOC(gardren.occupant_actions, pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze)
	squeeze_button.Trigger()

	gardren.mob_exit(pilot, silent = TRUE)
	TEST_ASSERT_NULL(target.buckled, "The fist kept the target after its pilot left")
	TEST_ASSERT_NULL(fist.held, "The fist still references the target it let go of")
	TEST_ASSERT(!fist.squeezing, "The fist kept squeezing after its pilot left")
	TEST_ASSERT(!HAS_TRAIT(target, TRAIT_HANDS_BLOCKED) && !HAS_TRAIT(target, TRAIT_MUTE), "The released target kept the fist's restraints")
	TEST_ASSERT_EQUAL(target.loc, target_turf, "The released target was not put down in front of the mech")

/// The fist takes furniture, carries it in front of the mech and throws it, but leaves items and building parts alone.
/datum/unit_test/golden_gardren_fist_objects

/datum/unit_test/golden_gardren_fist_objects/Run()
	var/obj/vehicle/sealed/mecha/gardren/gardren = allocate(/obj/vehicle/sealed/mecha/gardren)
	var/mob/living/carbon/human/consistent/pilot = allocate(/mob/living/carbon/human/consistent)
	var/turf/front_turf = get_step(gardren.loc, EAST)
	gardren.mob_enter(pilot, silent = TRUE)
	gardren.setDir(EAST)
	pilot.set_combat_mode(TRUE)
	var/datum/component/golden_gardren_fist/fist = gardren.GetComponent(/datum/component/golden_gardren_fist)
	var/datum/action/fist_button = LAZYACCESSASSOC(gardren.occupant_actions, pilot, /datum/action/vehicle/sealed/mecha/golden_gardren_fist)
	fist_button.Trigger()

	// Consistent dummies close the fist at once.
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, front_turf)
	click_wrapper(pilot, wrench)
	TEST_ASSERT_NULL(fist.held, "The fist took an ordinary item")
	var/obj/structure/girder/girder = allocate(/obj/structure/girder, front_turf)
	click_wrapper(pilot, girder)
	TEST_ASSERT_NULL(fist.held, "The fist took a building part")
	qdel(girder)

	var/obj/structure/table/table = allocate(/obj/structure/table, front_turf)
	var/table_pixel_w = table.pixel_w
	click_wrapper(pilot, table)
	TEST_ASSERT_EQUAL(fist.held, table, "The fist did not take a table")
	TEST_ASSERT(!table.anchored, "The table stayed bolted down in the fist")
	TEST_ASSERT_EQUAL(table.loc, gardren.loc, "The held table was not lifted onto the mech")
	TEST_ASSERT(table.pixel_w > table_pixel_w, "The held table is not drawn in front of a mech facing east")

	var/turf/next = get_step(gardren.loc, NORTH)
	TEST_ASSERT(gardren.Move(next, NORTH), "The mech could not step with a table in the fist")
	TEST_ASSERT_EQUAL(table.loc, gardren.loc, "The held table did not ride along with the mech")
	TEST_ASSERT_EQUAL(table.pixel_w, table_pixel_w, "The held table was not moved in front of the mech when it turned")

	var/turf/aim = locate(gardren.x, min(gardren.y + 3, run_loc_floor_top_right.y), gardren.z)
	click_wrapper(pilot, aim)
	TEST_ASSERT_NULL(fist.held, "A click with a table in the fist did not throw it")
	TEST_ASSERT(table.throwing || table.loc != gardren.loc, "The table was not thrown")
	TEST_ASSERT_EQUAL(table.pixel_w, table_pixel_w, "The thrown table kept the fist's offset")
