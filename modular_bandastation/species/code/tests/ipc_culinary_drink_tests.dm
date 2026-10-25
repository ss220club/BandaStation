/// A culinary processor must retain the real gulp, taste, drink signals and source consumption without chemistry.
/datum/unit_test/ipc_culinary_drinking
	parent_type = /datum/unit_test/ipc_drink_rejection

/datum/unit_test/ipc_culinary_drinking/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	var/obj/item/organ/stomach/ipc_culinary/culinary = allocate(__IMPLIED_TYPE__)
	culinary.Insert(human)
	human.set_nutrition(100, forced = TRUE)
	for(var/cup_type in list(/obj/item/reagent_containers/cup/glass/drinkingglass, /obj/item/reagent_containers/cup/bottle, /obj/item/reagent_containers/cup/soda_cans/cola))
		var/obj/item/reagent_containers/cup/cup = allocate(cup_type)
		cup.reagents.clear_reagents()
		cup.reagents.add_reagent(/datum/reagent/consumable/nutriment, 10, list("donut" = 1))
		cup.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 10)
		cup.add_container_flags(OPENCONTAINER)
		cup.last_check_time = -10 SECONDS
		human.last_taste_time = -10 SECONDS
		var/original_events = drink_events
		RegisterSignal(cup, COMSIG_GLASS_DRANK, TYPE_PROC_REF(/datum/unit_test/ipc_drink_rejection, on_drink))
		TEST_ASSERT_EQUAL(cup.try_drink(human, human), ITEM_INTERACT_SUCCESS, "A functional culinary processor could not drink from [cup_type].")
		TEST_ASSERT_EQUAL(cup.reagents.total_volume, max(20 - cup.gulp_size, 0), "An IPC gulp consumed an incorrect volume from [cup_type].")
		TEST_ASSERT_EQUAL(drink_events, original_events + 1, "An accepted IPC drink did not emit exactly one drink signal.")
		TEST_ASSERT_EQUAL(human.last_taste_time, world.time, "An accepted drink did not produce flavor feedback.")
		if(cup.reagents.total_volume)
			var/before_feed = cup.reagents.total_volume
			TEST_ASSERT_EQUAL(cup.try_drink(human, feeder), ITEM_INTERACT_SUCCESS, "A working culinary processor rejected another person's drink.")
			TEST_ASSERT_EQUAL(cup.reagents.total_volume, max(before_feed - cup.gulp_size, 0), "Forced drinking consumed the wrong portion.")
		TEST_ASSERT_EQUAL(human.nutrition, 100, "An accepted drink charged the IPC battery.")
		TEST_ASSERT_EQUAL(human.reagents.total_volume, 0, "A drink entered the IPC's bloodstream.")
		TEST_ASSERT_EQUAL(culinary.reagents.total_volume, 0, "A drink accumulated in the culinary processor.")
		TEST_ASSERT_EQUAL(human.stat, STABLE, "Drink sedatives affected a chemically immune IPC.")
		UnregisterSignal(cup, COMSIG_GLASS_DRANK)

	// A drinking glass derives drink_type from its contents; an arbitrary mixture cannot be labeled liked by hand.
	var/mob/living/carbon/human/organic = allocate(/mob/living/carbon/human/consistent)
	for(var/mob/living/carbon/human/drinker as anything in list(human, organic))
		var/obj/item/reagent_containers/cup/glass/bottle/rootbeer/rootbeer = allocate(__IMPLIED_TYPE__)
		rootbeer.add_container_flags(OPENCONTAINER)
		rootbeer.last_check_time = -10 SECONDS
		TEST_ASSERT_EQUAL(drinker.get_food_taste_reaction(rootbeer, rootbeer.drink_type), FOOD_LIKED, "The actual root-beer fixture is not a liked drink.")
		TEST_ASSERT_EQUAL(rootbeer.try_drink(drinker, drinker), ITEM_INTERACT_SUCCESS, "The actual root-beer drinking fixture failed.")
		TEST_ASSERT_NOTNULL(drinker.mob_mood.mood_events["fav_food"], "A real liked drink did not produce its usual food mood event for [drinker.dna.species.type].")
		TEST_ASSERT_EQUAL(rootbeer.reagents.total_volume, 30 - rootbeer.gulp_size, "The liked-drink mood control consumed an incorrect portion.")
	TEST_ASSERT_EQUAL(human.nutrition, 100, "A liked drink charged the IPC battery.")

/// Both forcefeeding and a repeated self-gulp must revalidate a processor removed or damaged during the delay.
/datum/unit_test/ipc_culinary_drinking_after_delay
	parent_type = /datum/unit_test/ipc_drink_rejection

/datum/unit_test/ipc_culinary_drinking_after_delay/Run()
	for(var/force_feed in list(TRUE, FALSE))
		for(var/remove_processor in list(TRUE, FALSE))
			var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent/slow)
			var/mob/living/carbon/human/feeder = force_feed ? allocate(/mob/living/carbon/human/consistent/slow) : human
			human.set_species(/datum/species/ipc)
			human.set_nutrition(100, forced = TRUE)
			feeder.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
			var/obj/item/organ/stomach/ipc_culinary/culinary = allocate(__IMPLIED_TYPE__)
			culinary.Insert(human)
			var/obj/item/reagent_containers/cup/glass/drinkingglass/cup = allocate(__IMPLIED_TYPE__)
			cup.reagents.add_reagent(/datum/reagent/water, 20)
			cup.loop_drink = !force_feed
			cup.last_check_time = -10 SECONDS
			var/original_events = drink_events
			var/original_taste_time = human.last_taste_time
			RegisterSignal(cup, COMSIG_GLASS_DRANK, TYPE_PROC_REF(/datum/unit_test/ipc_drink_rejection, on_drink))
			if(remove_processor)
				addtimer(CALLBACK(culinary, TYPE_PROC_REF(/obj/item/organ, Remove), human, TRUE), 1)
			else
				addtimer(CALLBACK(culinary, TYPE_PROC_REF(/obj/item/organ, set_organ_damage), culinary.maxHealth), 1)
			TEST_ASSERT_EQUAL(cup.try_drink(human, feeder), ITEM_INTERACT_BLOCKING, "A delayed drink completed after its processor was removed or failed.")
			TEST_ASSERT(!culinary.is_operational(), "The delayed-drinking fixture did not remove or break the processor.")
			TEST_ASSERT_EQUAL(cup.reagents.total_volume, 20, "Rejected delayed drinking consumed its source.")
			TEST_ASSERT_EQUAL(drink_events, original_events, "Rejected delayed drinking emitted a drink signal.")
			TEST_ASSERT_EQUAL(human.last_taste_time, original_taste_time, "Rejected delayed drinking produced taste feedback.")
			TEST_ASSERT_EQUAL(cup.last_check_time, -10 SECONDS, "Rejected delayed drinking ran the drink's taste checks.")
			TEST_ASSERT(!DOING_INTERACTION(feeder, human), "Rejected delayed drinking retained a timed action.")
			UnregisterSignal(cup, COMSIG_GLASS_DRANK)

/// Synchronous drink callbacks can also invalidate the processor before the source is consumed.
/datum/unit_test/ipc_culinary_drink_callback
	var/obj/item/organ/stomach/ipc_culinary/processor

/datum/unit_test/ipc_culinary_drink_callback/proc/on_drink(datum/source, mob/living/carbon/eater)
	SIGNAL_HANDLER
	processor.Remove(eater, special = TRUE)

/datum/unit_test/ipc_culinary_drink_callback/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	processor = allocate(/obj/item/organ/stomach/ipc_culinary)
	processor.Insert(human)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/cup = allocate(__IMPLIED_TYPE__)
	cup.reagents.add_reagent(/datum/reagent/water, 20)
	var/original_taste_time = human.last_taste_time
	RegisterSignal(cup, COMSIG_GLASS_DRANK, PROC_REF(on_drink))
	TEST_ASSERT_EQUAL(cup.try_drink(human, human), ITEM_INTERACT_BLOCKING, "A drink callback bypassed processor revalidation.")
	TEST_ASSERT_EQUAL(cup.reagents.total_volume, 20, "A drink callback caused consumption after the processor was removed.")
	TEST_ASSERT_EQUAL(human.last_taste_time, original_taste_time, "A rejected callback-invalidated drink generated flavor feedback.")
	UnregisterSignal(cup, COMSIG_GLASS_DRANK)
	processor = null

/// Liquid food must consume a clamped portion while preserving immunity; pills remain incompatible.
/datum/unit_test/ipc_culinary_condiments/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	human.set_nutrition(100, forced = TRUE)
	var/obj/item/organ/stomach/ipc_culinary/culinary = allocate(__IMPLIED_TYPE__)
	culinary.Insert(human)
	var/obj/item/reagent_containers/condiment/condiment = allocate(__IMPLIED_TYPE__)
	condiment.reagents.add_reagent(/datum/reagent/consumable/nutriment, 8, list("donut" = 1))
	condiment.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 5)
	human.last_taste_time = -10 SECONDS
	TEST_ASSERT_EQUAL(condiment.try_eat(human, human), ITEM_INTERACT_SUCCESS, "A culinary processor could not consume liquid food.")
	TEST_ASSERT_EQUAL(condiment.reagents.total_volume, 3, "Liquid food did not consume its native 10-unit portion.")
	TEST_ASSERT_EQUAL(human.last_taste_time, world.time, "Liquid food did not produce flavor feedback.")
	TEST_ASSERT_EQUAL(condiment.try_eat(human, feeder), ITEM_INTERACT_SUCCESS, "A culinary processor could not receive liquid food from another person.")
	TEST_ASSERT_EQUAL(condiment.reagents.total_volume, 0, "A final liquid food portion was not clamped to its actual contents.")
	TEST_ASSERT_EQUAL(condiment.try_eat(human, human), ITEM_INTERACT_BLOCKING, "An empty condiment bottle allowed infinite consumption.")
	TEST_ASSERT_EQUAL(human.nutrition, 100, "Liquid food charged the IPC battery.")
	TEST_ASSERT_EQUAL(human.reagents.total_volume, 0, "Liquid food introduced chemicals into an IPC.")
	TEST_ASSERT_EQUAL(culinary.reagents.total_volume, 0, "Liquid food introduced chemicals into the culinary processor.")
	var/obj/item/reagent_containers/applicator/pill/pill = allocate(__IMPLIED_TYPE__)
	pill.reagents.add_reagent(/datum/reagent/medicine/stimulants, 10)
	TEST_ASSERT_EQUAL(pill.interact_with_atom(human, human, list()), ITEM_INTERACT_BLOCKING, "A culinary processor allowed a medicinal applicator through chemical immunity.")
	TEST_ASSERT_EQUAL(pill.reagents.total_volume, 10, "A rejected pill lost its contents.")

/// A delayed condiment gulp has the same processor revalidation as a cup.
/datum/unit_test/ipc_culinary_condiments_after_delay/Run()
	for(var/remove_processor in list(TRUE, FALSE))
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
		var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent/slow)
		human.set_species(/datum/species/ipc)
		feeder.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
		var/obj/item/organ/stomach/ipc_culinary/culinary = allocate(__IMPLIED_TYPE__)
		culinary.Insert(human)
		var/obj/item/reagent_containers/condiment/condiment = allocate(__IMPLIED_TYPE__)
		condiment.reagents.add_reagent(/datum/reagent/water, 20)
		var/original_taste_time = human.last_taste_time
		if(remove_processor)
			addtimer(CALLBACK(culinary, TYPE_PROC_REF(/obj/item/organ, Remove), human, TRUE), 1)
		else
			addtimer(CALLBACK(culinary, TYPE_PROC_REF(/obj/item/organ, set_organ_damage), culinary.maxHealth), 1)
		TEST_ASSERT_EQUAL(condiment.try_eat(human, feeder), ITEM_INTERACT_BLOCKING, "A delayed condiment gulp bypassed a removed or failed processor.")
		TEST_ASSERT(!culinary.is_operational(), "The forced-condiment fixture left its processor operational.")
		TEST_ASSERT_EQUAL(condiment.reagents.total_volume, 20, "A rejected delayed condiment gulp consumed its source.")
		TEST_ASSERT_EQUAL(human.last_taste_time, original_taste_time, "A rejected delayed condiment gulp generated flavor feedback.")

/// Real loaded cutlery must consume its portion and give flavor without introducing chemicals into a chassis.
/datum/unit_test/ipc_culinary_utensils/Run()
	for(var/self_feeding in list(TRUE, FALSE))
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
		var/mob/living/carbon/human/feeder = self_feeding ? human : allocate(/mob/living/carbon/human/consistent)
		human.set_species(/datum/species/ipc)
		human.set_nutrition(100, forced = TRUE)
		var/obj/item/organ/stomach/ipc_culinary/culinary = allocate(__IMPLIED_TYPE__)
		TEST_ASSERT(culinary.Insert(human), "The cutlery fixture rejected its culinary processor.")
		var/obj/item/food/omelette/food = allocate(/obj/item/food/omelette)
		food.reagents.clear_reagents()
		food.reagents.add_reagent(/datum/reagent/consumable/nutriment, 6, list("omelette" = 1))
		var/obj/item/kitchen/fork/fork = allocate(/obj/item/kitchen/fork)
		TEST_ASSERT_EQUAL(food.item_interaction(feeder, fork, list()), ITEM_INTERACT_SUCCESS, "Could not load the culinary test fork.")
		TEST_ASSERT_EQUAL(food.reagents.total_volume, 5, "Loading a fork did not spend its one-unit portion.")
		human.last_taste_time = -10 SECONDS
		fork.attack(human, feeder)
		TEST_ASSERT_NULL(fork.forkload, "Culinary feeding left a reusable forkful.")
		TEST_ASSERT_EQUAL(fork.icon_state, "fork", "The consumed fork retained its loaded appearance.")
		TEST_ASSERT_EQUAL(food.reagents.total_volume, 5, "Swallowing a forkful consumed food a second time.")
		TEST_ASSERT_EQUAL(human.last_taste_time, world.time, "A culinary forkful did not produce flavor feedback.")

		for(var/spoon_type in list(/obj/item/kitchen/spoon, /obj/item/kitchen/spoon/soup_ladle))
			var/obj/item/kitchen/spoon/spoon = allocate(spoon_type)
			spoon.reagents.add_reagent(/datum/reagent/consumable/nutriment, 3, list("soup" = 1))
			spoon.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 2)
			human.last_taste_time = -10 SECONDS
			spoon.attack(human, feeder, list(), list())
			TEST_ASSERT_EQUAL(spoon.reagents.total_volume, max(5 - spoon.spoon_sip_size, 0), "Culinary spoon feeding consumed an incorrect portion.")
			TEST_ASSERT_EQUAL(human.last_taste_time, world.time, "A culinary spoonful did not produce flavor feedback.")
			if(spoon.reagents.total_volume)
				spoon.attack(human, feeder, list(), list())
			TEST_ASSERT_EQUAL(spoon.reagents.total_volume, 0, "A culinary spoon retained its final partial portion.")
		TEST_ASSERT_EQUAL(human.nutrition, 100, "Food from culinary cutlery charged the IPC battery.")
		TEST_ASSERT_EQUAL(human.reagents.total_volume, 0, "Culinary cutlery introduced chemicals into the bloodstream.")
		TEST_ASSERT_EQUAL(culinary.reagents.total_volume, 0, "Culinary cutlery introduced chemicals into the processor.")
		human.reagents.metabolize(human, 2)
		TEST_ASSERT_EQUAL(human.stat, STABLE, "A spoon's sedative affected an immune IPC.")

/// Spoon feeding must keep its contents when its processor is removed or fails during the actual do_after.
/datum/unit_test/ipc_culinary_utensils_after_delay/Run()
	for(var/remove_processor in list(TRUE, FALSE))
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
		var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent/slow)
		human.set_species(/datum/species/ipc)
		human.set_nutrition(100, forced = TRUE)
		feeder.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
		var/obj/item/organ/stomach/ipc_culinary/culinary = allocate(__IMPLIED_TYPE__)
		TEST_ASSERT(culinary.Insert(human), "The delayed spoon fixture rejected its culinary processor.")
		var/obj/item/kitchen/spoon/spoon = allocate(/obj/item/kitchen/spoon)
		spoon.reagents.add_reagent(/datum/reagent/consumable/nutriment, 5)
		var/original_taste_time = human.last_taste_time
		if(remove_processor)
			addtimer(CALLBACK(culinary, TYPE_PROC_REF(/obj/item/organ, Remove), human, TRUE), 1)
		else
			addtimer(CALLBACK(culinary, TYPE_PROC_REF(/obj/item/organ, set_organ_damage), culinary.maxHealth), 1)
		spoon.attack(human, feeder, list(), list())
		TEST_ASSERT(!culinary.is_operational(), "The delayed spoon fixture left its culinary processor operational.")
		TEST_ASSERT_EQUAL(spoon.reagents.total_volume, 5, "A rejected delayed spoonful consumed its source.")
		TEST_ASSERT_EQUAL(human.last_taste_time, original_taste_time, "A rejected delayed spoonful generated flavor feedback.")
		TEST_ASSERT_EQUAL(human.nutrition, 100, "A rejected delayed spoonful changed battery charge.")
		TEST_ASSERT_EQUAL(human.reagents.total_volume, 0, "A rejected delayed spoonful introduced chemicals.")
