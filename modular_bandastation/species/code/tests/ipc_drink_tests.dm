/// Reject the drinking action itself, before its signal, taste checks or reagent transfer.
/datum/unit_test/ipc_drink_rejection
	var/drink_events = 0

/datum/unit_test/ipc_drink_rejection/proc/on_drink()
	SIGNAL_HANDLER
	drink_events++

/datum/unit_test/ipc_drink_rejection/Run()
	var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent)
	drinker.set_species(/datum/species/ipc)
	for(var/cup_type in list(/obj/item/reagent_containers/cup/glass/drinkingglass, /obj/item/reagent_containers/cup/bottle, /obj/item/reagent_containers/cup/soda_cans/cola))
		var/obj/item/reagent_containers/cup/cup = allocate(cup_type)
		cup.reagents.clear_reagents()
		cup.reagents.add_reagent(/datum/reagent/water, 20)
		cup.add_container_flags(OPENCONTAINER)
		cup.last_check_time = -10 SECONDS
		var/original_taste_time = cup.last_check_time
		var/original_events = drink_events
		RegisterSignal(cup, COMSIG_GLASS_DRANK, TYPE_PROC_REF(/datum/unit_test/ipc_drink_rejection, on_drink))
		TEST_ASSERT_EQUAL(cup.interact_with_atom(drinker, drinker, list()), ITEM_INTERACT_BLOCKING, "An IPC could drink from [cup_type].")
		TEST_ASSERT_EQUAL(cup.try_drink(drinker, feeder), ITEM_INTERACT_BLOCKING, "Another person could give an IPC a drink from [cup_type].")
		TEST_ASSERT_EQUAL(cup.reagents.total_volume, 20, "Rejected IPC drinking consumed [cup_type]'s contents.")
		TEST_ASSERT_EQUAL(drink_events, original_events, "Rejected IPC drinking emitted COMSIG_GLASS_DRANK.")
		TEST_ASSERT_EQUAL(cup.last_check_time, original_taste_time, "Rejected IPC drinking ran a taste check.")
		TEST_ASSERT(!DOING_INTERACTION(feeder, drinker), "Giving an IPC a drink started a timed action.")

		drinker.set_species(/datum/species/human)
		var/obj/item/organ/stomach/stomach = drinker.get_organ_slot(ORGAN_SLOT_STOMACH)
		var/original_stomach_volume = stomach.reagents.total_volume
		TEST_ASSERT_EQUAL(cup.interact_with_atom(drinker, drinker, list()), ITEM_INTERACT_SUCCESS, "A human control could not drink from [cup_type].")
		TEST_ASSERT_EQUAL(cup.reagents.total_volume, 20 - cup.gulp_size, "A human drink consumed the wrong volume.")
		TEST_ASSERT_EQUAL(stomach.reagents.total_volume, original_stomach_volume + cup.gulp_size, "A human control did not swallow the drink.")
		TEST_ASSERT_EQUAL(drink_events, original_events + 1, "The human drink did not emit its drinking signal.")
		drinker.set_species(/datum/species/ipc)
		TEST_ASSERT_EQUAL(cup.try_drink(drinker, drinker), ITEM_INTERACT_BLOCKING, "Returning to IPC did not restore drinking rejection.")
		TEST_ASSERT_EQUAL(drink_events, original_events + 1, "A second IPC transformation allowed a drinking signal.")
		UnregisterSignal(cup, COMSIG_GLASS_DRANK)

	var/obj/item/reagent_containers/condiment/condiment = allocate(/obj/item/reagent_containers/condiment)
	condiment.reagents.add_reagent(/datum/reagent/water, 20)
	TEST_ASSERT_EQUAL(condiment.try_eat(drinker, drinker), ITEM_INTERACT_BLOCKING, "An IPC could swallow liquid from a condiment bottle.")
	TEST_ASSERT_EQUAL(condiment.try_eat(drinker, feeder), ITEM_INTERACT_BLOCKING, "Another person could feed an IPC liquid condiments.")
	TEST_ASSERT_EQUAL(condiment.reagents.total_volume, 20, "Rejected IPC condiment consumption emptied the bottle.")
	drinker.set_species(/datum/species/human)
	TEST_ASSERT_EQUAL(condiment.try_eat(drinker, drinker), ITEM_INTERACT_SUCCESS, "A human control could not consume a liquid condiment.")
	TEST_ASSERT_EQUAL(condiment.reagents.total_volume, 10, "The human condiment control did not consume its dose.")

/// Becoming an IPC during another person's timed feeding must cancel the eventual gulp.
/datum/unit_test/ipc_drink_forced_after_delay
	parent_type = /datum/unit_test/ipc_drink_rejection

/datum/unit_test/ipc_drink_forced_after_delay/Run()
	var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent/slow)
	// Keep a real delay even after the dummy receives its mood speed bonus.
	feeder.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/cup = allocate(/obj/item/reagent_containers/cup/glass/drinkingglass)
	cup.reagents.add_reagent(/datum/reagent/water, 20)
	cup.last_check_time = -10 SECONDS
	var/original_taste_time = cup.last_check_time
	RegisterSignal(cup, COMSIG_GLASS_DRANK, TYPE_PROC_REF(/datum/unit_test/ipc_drink_rejection, on_drink))
	addtimer(CALLBACK(drinker, TYPE_PROC_REF(/mob, set_species), /datum/species/ipc), 1)
	TEST_ASSERT_EQUAL(cup.try_drink(drinker, feeder), ITEM_INTERACT_BLOCKING, "A forced drink completed after the recipient became an IPC.")
	TEST_ASSERT(is_species(drinker, /datum/species/ipc), "The forced-drinking fixture did not change species during the delay.")
	TEST_ASSERT_EQUAL(cup.reagents.total_volume, 20, "A forced drink consumed its contents after an IPC transformation.")
	TEST_ASSERT_EQUAL(drink_events, 0, "A forced drink emitted its completion signal after an IPC transformation.")
	TEST_ASSERT_EQUAL(cup.last_check_time, original_taste_time, "A forced drink ran a taste check after an IPC transformation.")
	TEST_ASSERT(!DOING_INTERACTION(feeder, drinker), "Rejected forced drinking left a timed interaction behind.")
	UnregisterSignal(cup, COMSIG_GLASS_DRANK)

	drinker.set_species(/datum/species/human)
	var/obj/item/reagent_containers/condiment/condiment = allocate(/obj/item/reagent_containers/condiment)
	condiment.reagents.add_reagent(/datum/reagent/water, 20)
	addtimer(CALLBACK(drinker, TYPE_PROC_REF(/mob, set_species), /datum/species/ipc), 1)
	TEST_ASSERT_EQUAL(condiment.try_eat(drinker, feeder), ITEM_INTERACT_BLOCKING, "Forced condiment consumption completed after an IPC transformation.")
	TEST_ASSERT(is_species(drinker, /datum/species/ipc), "The condiment fixture did not change species during the delay.")
	TEST_ASSERT_EQUAL(condiment.reagents.total_volume, 20, "Forced condiment consumption emptied its bottle after an IPC transformation.")

/// Repeated self-drinking also waits before a gulp, so its permission must be checked again.
/datum/unit_test/ipc_drink_loop_after_delay
	parent_type = /datum/unit_test/ipc_drink_rejection

/datum/unit_test/ipc_drink_loop_after_delay/Run()
	var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human/consistent/slow)
	drinker.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/cup = allocate(/obj/item/reagent_containers/cup/glass/drinkingglass)
	cup.reagents.add_reagent(/datum/reagent/water, 20)
	cup.loop_drink = TRUE
	cup.last_check_time = -10 SECONDS
	var/original_taste_time = cup.last_check_time
	RegisterSignal(cup, COMSIG_GLASS_DRANK, TYPE_PROC_REF(/datum/unit_test/ipc_drink_rejection, on_drink))
	addtimer(CALLBACK(drinker, TYPE_PROC_REF(/mob, set_species), /datum/species/ipc), 1)
	TEST_ASSERT_EQUAL(cup.try_drink(drinker, drinker), ITEM_INTERACT_BLOCKING, "A looping drink completed after its user became an IPC.")
	TEST_ASSERT(is_species(drinker, /datum/species/ipc), "The looping-drink fixture did not change species during the delay.")
	TEST_ASSERT_EQUAL(cup.reagents.total_volume, 20, "A looping drink consumed its contents after an IPC transformation.")
	TEST_ASSERT_EQUAL(drink_events, 0, "A looping drink emitted its completion signal after an IPC transformation.")
	TEST_ASSERT_EQUAL(cup.last_check_time, original_taste_time, "A looping drink ran a taste check after an IPC transformation.")
	TEST_ASSERT(!DOING_INTERACTION(drinker, drinker), "Rejected looping drinking left a timed interaction behind.")
	UnregisterSignal(cup, COMSIG_GLASS_DRANK)
