/// The real arm action and APC interaction must consume energy, clamp the final interval and reject parallel draws.
/datum/unit_test/ipc_apc_charging/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	human.set_nutrition(NUTRITION_LEVEL_WELL_FED - 10, forced = TRUE)
	var/obj/item/organ/cyberimp/arm/power_cord/ipc/adapter = human.get_organ_by_type(/obj/item/organ/cyberimp/arm/power_cord/ipc)
	adapter.ui_action_click()
	var/obj/item/ipc_power_cord/cord = adapter.active_item
	TEST_ASSERT(istype(cord) && human.is_holding(cord), "The IPC arm action did not extend a charging cable.")
	var/obj/machinery/power/apc/apc = allocate(/obj/machinery/power/apc)
	apc.chargemode = FALSE
	apc.cell = allocate(/obj/item/stock_parts/power_store/cell, apc)
	var/initial_energy = apc.cell.charge()
	TEST_ASSERT_EQUAL(cord.interact_with_atom(apc, human), ITEM_INTERACT_SUCCESS, "A held connector refused a working APC cell.")
	TEST_ASSERT_EQUAL(cord.interact_with_atom(apc, human), ITEM_INTERACT_BLOCKING, "A second click started a parallel charging operation.")
	var/deadline = world.time + 5 SECONDS
	while(cord.drawing_power && world.time < deadline)
		sleep(1)
	TEST_ASSERT(!cord.drawing_power, "APC charging did not finish after the battery reached its limit.")
	TEST_ASSERT_EQUAL(human.nutrition, NUTRITION_LEVEL_WELL_FED, "The final APC charging interval exceeded or failed to reach the charging limit.")
	TEST_ASSERT_EQUAL(initial_energy - apc.cell.charge(), STANDARD_CELL_CHARGE * 0.1, "APC charge spent did not match the accepted 10 nutrition.")

	human.set_nutrition(200, forced = TRUE)
	var/obj/item/stock_parts/power_store/cell/source_cell = apc.cell
	apc.cell = null
	TEST_ASSERT(!cord.can_charge(apc, human), "An APC without a power cell was accepted.")
	apc.cell = source_cell
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	allocated += battery
	battery.Remove(human, special = TRUE)
	TEST_ASSERT(!cord.can_charge(apc, human), "A body without a microbattery could draw power.")
	battery.Insert(human, special = TRUE)
	battery.set_organ_damage(battery.maxHealth)
	TEST_ASSERT(!cord.can_charge(apc, human), "A failed microbattery could draw power.")
	battery.set_organ_damage(0)
	adapter.Retract()
	TEST_ASSERT(!cord.can_charge(apc, human), "A retracted connector could still draw power.")

/// Exercises the actual charger callback and its energy conversion across tick lengths and organ removal.
/datum/unit_test/ipc_borg_charging/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	var/obj/machinery/recharge_station/charger = allocate(/obj/machinery/recharge_station)
	TEST_ASSERT(charger.is_operational, "The test area's charging station has no power.")
	charger.recharge_speed = STANDARD_CELL_CHARGE * 0.1
	charger.close_machine(human)
	TEST_ASSERT_EQUAL(charger.occupant, human, "The charging station rejected an IPC occupant.")
	human.set_nutrition(200, forced = TRUE)
	charger.process(1)
	TEST_ASSERT_EQUAL(human.nutrition, 210, "The charging station did not transfer its actual supplied energy to the microbattery.")
	human.set_nutrition(200, forced = TRUE)
	charger.process(0.5)
	charger.process(0.5)
	TEST_ASSERT_EQUAL(human.nutrition, 210, "Charging speed changed when a one-second interval was split into two ticks.")
	human.set_nutrition(NUTRITION_LEVEL_FULL - 5, forced = TRUE)
	charger.process(1)
	TEST_ASSERT_EQUAL(human.nutrition, NUTRITION_LEVEL_FULL, "The station overcharged the microbattery.")
	TEST_ASSERT_EQUAL(battery.charging_buffer.charge(), 0, "The charger adapter retained a second stored charge balance.")

	human.set_nutrition(200, forced = TRUE)
	battery.set_organ_damage(battery.maxHealth)
	charger.process(1)
	TEST_ASSERT_EQUAL(human.nutrition, 200, "The station charged a failed microbattery.")
	battery.set_organ_damage(0)
	allocated += battery
	battery.Remove(human, special = TRUE)
	charger.process(1)
	TEST_ASSERT_EQUAL(human.nutrition, 200, "The removed microbattery retained its charger signal subscription.")
	TEST_ASSERT_NULL(human.alerts["ipc_charge"], "Removing the microbattery left its HUD charge indicator behind.")

/// Power failures must not damage disconnected players; EMP damage must still shut down an adapter.
/datum/unit_test/ipc_power_failure/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	human.set_nutrition(0, forced = TRUE)
	battery.on_life(60)
	TEST_ASSERT_EQUAL(battery.damage, 0, "A disconnected IPC's battery was damaged by starvation.")
	TEST_ASSERT_NOTEQUAL(human.stat, DEAD, "A disconnected IPC was killed by an empty battery.")
	var/obj/item/organ/cyberimp/arm/power_cord/ipc/adapter = human.get_organ_by_type(/obj/item/organ/cyberimp/arm/power_cord/ipc)
	adapter.ui_action_click()
	adapter.emp_act(EMP_HEAVY)
	TEST_ASSERT(adapter.organ_flags & ORGAN_FAILING, "An unshielded charging adapter remained functional after an EMP.")
	TEST_ASSERT_NULL(adapter.active_item, "The damaged adapter left a usable charging cable extended.")
	allocated += adapter
	adapter.Remove(human, special = TRUE)
	adapter.forceMove(get_turf(human))
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver)
	human.put_in_hands(screwdriver)
	TEST_ASSERT_EQUAL(adapter.screwdriver_act(human, screwdriver), ITEM_INTERACT_SUCCESS, "An extracted charging adapter could not be repaired with a screwdriver.")
	TEST_ASSERT(!(adapter.organ_flags & ORGAN_FAILING), "Repair left the charging adapter failed.")

/// Extraction keeps a single conscious personality; transplanting the organ transfers that same mind.
/datum/unit_test/ipc_positronic_transplant/Run()
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human/consistent)
	donor.set_species(/datum/species/ipc)
	donor.mind_initialize()
	var/datum/mind/personality = donor.mind
	var/obj/item/organ/brain/ipc/core = donor.get_organ_slot(ORGAN_SLOT_BRAIN)
	allocated += core
	core.Remove(donor)
	core.forceMove(get_turf(donor))
	var/mob/living/brain/person = core.brainmob
	TEST_ASSERT_NOTNULL(person, "Extracting the positronic core lost its personality.")
	TEST_ASSERT_NOTNULL(core.personal_processor, "The extracted core has no autonomous processor.")
	TEST_ASSERT_EQUAL(personality.current, person, "The mind did not move into the extracted core.")
	TEST_ASSERT_EQUAL(core.personal_processor.brainmob, person, "The internal processor created a second personality.")
	TEST_ASSERT_EQUAL(person.container, core.personal_processor, "The extracted brainmob has the wrong speech container.")
	TEST_ASSERT(core.personal_processor.contains(person), "The processor does not physically contain its brainmob.")
	TEST_ASSERT(person.can_speak(), "The extracted positronic core cannot speak.")
	TEST_ASSERT_NOTEQUAL(person.stat, DEAD, "A healthy extracted core is not conscious.")
	var/obj/item/brain_processor/ipc_core/old_processor = core.personal_processor
	var/mob/living/carbon/human/recipient = allocate(/mob/living/carbon/human/consistent)
	recipient.set_species(/datum/species/ipc)
	core.Insert(recipient, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	TEST_ASSERT_EQUAL(recipient.mind, personality, "Transplanting the core did not transfer its original mind.")
	TEST_ASSERT_EQUAL(personality.current, recipient, "The original mind remained in a detached brainmob.")
	TEST_ASSERT_NULL(core.brainmob, "The transplanted core kept a duplicate detached brainmob.")
	TEST_ASSERT_NULL(core.personal_processor, "The transplanted core retained its detached processor.")
	TEST_ASSERT(QDELETED(old_processor), "The detached processor leaked after transplantation.")

/// Native TG MMI insertion and removal must hand off the existing personality without losing or duplicating it.
/datum/unit_test/ipc_positronic_mmi/Run()
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human/consistent)
	donor.set_species(/datum/species/ipc)
	donor.mind_initialize()
	var/datum/mind/personality = donor.mind
	var/obj/item/organ/brain/ipc/core = donor.get_organ_slot(ORGAN_SLOT_BRAIN)
	allocated += core
	core.Remove(donor)
	core.forceMove(get_turf(donor))
	var/mob/living/brain/person = core.brainmob
	TEST_ASSERT_NOTNULL(person, "Extracting the positronic core lost its personality.")
	var/turf/floor = get_turf(core)
	core.moveToNullspace()
	core.forceMove(floor)
	TEST_ASSERT_EQUAL(personality.current, person, "Moving the core through nullspace changed its personality.")
	TEST_ASSERT_EQUAL(person.container, core.personal_processor, "Moving the core through nullspace lost its processor.")
	var/obj/item/brain_processor/organic/mmi = allocate(/obj/item/brain_processor/organic)
	mmi.insert_brain(core)
	TEST_ASSERT_EQUAL(mmi.brainmob, person, "The MMI failed to take over the original personality.")
	TEST_ASSERT_EQUAL(person.container, mmi, "The internal processor overwrote the MMI's brain container.")
	TEST_ASSERT_NULL(core.personal_processor, "An IPC core retained its internal processor while inside an MMI.")
	TEST_ASSERT_NULL(core.brainmob, "An MMI and core both retained a brainmob reference.")
	mmi.moveToNullspace()
	mmi.forceMove(floor)
	TEST_ASSERT_EQUAL(personality.current, person, "Moving the MMI through nullspace changed its personality.")
	TEST_ASSERT_EQUAL(person.container, mmi, "Moving the MMI through nullspace lost its brain container.")
	mmi.remove_brain()
	TEST_ASSERT_NULL(mmi.brainmob, "The emptied MMI still owns the positronic personality.")
	TEST_ASSERT_EQUAL(core.brainmob, person, "Removing the core from an MMI lost or replaced its personality.")
	TEST_ASSERT_EQUAL(personality.current, person, "The personality's mind changed during the MMI round trip.")
	TEST_ASSERT_EQUAL(person.container, core.personal_processor, "The autonomous processor was not restored after MMI removal.")
	TEST_ASSERT(person.can_speak(), "The core cannot speak after removal from an MMI.")
	var/obj/item/brain_processor/ipc_core/processor = core.personal_processor
	qdel(core)
	TEST_ASSERT(QDELETED(processor), "Deleting a positronic core leaked its processor.")
	TEST_ASSERT(QDELETED(person), "Deleting a positronic core leaked its brainmob.")

/*
 * Manual checks requiring an attached player client:
 * - Set charge to 200; compare ten seconds of normal processing with changed SSmobs tick rate.
 *   Drain remains 0.5 nutrition total; the battery percentage changes when crossing a percent boundary.
 * - At charge below 100, confirm intermittent controller damage, shutdowns and slowed movement.
 * - While charging at an APC, remove its cell, step away, retract the cable or remove the arm.
 *   Every case stops charging before another transfer; a damaged or emagged APC burns the chassis once.
 */
