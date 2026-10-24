/// Different blood colors must not change the appearance another wearer needs to remove when washing.
/datum/unit_test/ipc_barefoot_blood_cleaning/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/consistent)
	ipc.set_species(/datum/species/ipc)
	ipc.dna.features[FEATURE_IPC_CHASSIS_COLOR] = "#337799"
	for(var/obj/item/bodypart/limb as anything in ipc.get_bodyparts())
		limb.update_limb(is_creating = TRUE)
	ipc.update_body_parts()
	var/mob/living/carbon/human/organic = allocate(/mob/living/carbon/human/consistent)
	var/clean_ipc_icon = icon2base64(getFlatIcon(ipc, no_anim = TRUE))
	var/clean_organic_icon = icon2base64(getFlatIcon(organic, no_anim = TRUE))
	ipc.forceMove(run_loc_floor_top_right)
	organic.forceMove(get_step(run_loc_floor_top_right, SOUTH))
	var/obj/effect/decal/cleanable/blood/red_pool = allocate(/obj/effect/decal/cleanable/blood)
	red_pool.bloodiness = BLOOD_POOL_MAX
	ipc.forceMove(run_loc_floor_bottom_left)
	var/datum/component/bloodysoles/feet/ipc_feet = ipc.GetComponent(/datum/component/bloodysoles/feet)
	TEST_ASSERT(ipc_feet.total_bloodiness > 0, "Walking through blood did not stain an IPC's bare feet.")
	var/mutable_appearance/ipc_feet_overlay = ipc.overlays_standing[SHOES_LAYER]
	TEST_ASSERT_NOTNULL(ipc_feet_overlay, "Bloody IPC feet had no shoe-layer overlay.")
	var/red_appearance = ipc_feet_overlay.appearance
	var/red_color = ipc_feet_overlay.color

	var/obj/effect/decal/cleanable/blood/xeno/green_pool = allocate(/obj/effect/decal/cleanable/blood/xeno, run_loc_floor_top_right)
	green_pool.bloodiness = BLOOD_POOL_MAX
	organic.forceMove(run_loc_floor_top_right)
	var/datum/component/bloodysoles/feet/organic_feet = organic.GetComponent(/datum/component/bloodysoles/feet)
	TEST_ASSERT(organic_feet.total_bloodiness > 0, "The organic control's feet did not pick up alien blood.")
	var/mutable_appearance/organic_feet_overlay = organic.overlays_standing[SHOES_LAYER]
	TEST_ASSERT_NOTNULL(organic_feet_overlay, "The organic control had no bloody feet overlay.")
	TEST_ASSERT_NOTEQUAL(red_color, organic_feet_overlay.color, "The regression fixture did not create two different blood colors.")
	var/green_appearance = organic_feet_overlay.appearance
	TEST_ASSERT(red_appearance in ipc.overlays, "The IPC lost its visible blood before washing.")

	ipc.wash(CLEAN_WASH)
	TEST_ASSERT_EQUAL(ipc_feet.total_bloodiness, 0, "Washing left blood on an IPC's feet.")
	TEST_ASSERT_NULL(ipc.overlays_standing[SHOES_LAYER], "Washing left a cached bloody feet overlay on an IPC.")
	TEST_ASSERT(!(red_appearance in ipc.overlays), "Another wearer's blood color prevented washing the IPC's old blood sprite off.")
	ipc.regenerate_icons()
	TEST_ASSERT_EQUAL(icon2base64(getFlatIcon(ipc, no_anim = TRUE)), clean_ipc_icon, "Washing and rebuilding the IPC icon did not restore its clean, colored chassis and head.")

	// Showers use turf.wash(..., TRUE), which must also remove the actual mob overlay.
	var/turf/shower_turf = get_turf(organic)
	shower_turf.wash(CLEAN_WASH, TRUE)
	TEST_ASSERT_EQUAL(organic_feet.total_bloodiness, 0, "Shower washing left blood on the organic control's feet.")
	TEST_ASSERT(!(green_appearance in organic.overlays), "Shower washing left the organic control's blood sprite behind.")
	TEST_ASSERT_EQUAL(icon2base64(getFlatIcon(organic, no_anim = TRUE)), clean_organic_icon, "Washing changed the organic control's clean appearance.")

/// Cleaner sprays may wash an immune chassis, but must not apply any other chemical effect.
/datum/unit_test/ipc_cleaner_reagent_immunity/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/consistent)
	ipc.set_species(/datum/species/ipc)
	var/datum/component/bloodysoles/feet/feet = ipc.GetComponent(/datum/component/bloodysoles/feet)
	var/obj/effect/decal/cleanable/blood/pool = allocate(/obj/effect/decal/cleanable/blood, run_loc_floor_top_right)
	var/obj/item/reagent_containers/cup/beaker/source = allocate(/obj/item/reagent_containers/cup/beaker)
	source.reagents.add_reagent(/datum/reagent/space_cleaner, 10)
	pool.bloodiness = BLOOD_POOL_MAX
	SEND_SIGNAL(ipc, COMSIG_STEP_ON_BLOOD, pool)
	TEST_ASSERT(feet.total_bloodiness > 0, "The cleaner exposure fixture had no bloody feet.")
	for(var/method in list(INGEST, INJECT, INHALE, PATCH))
		source.reagents.expose(ipc, method)
		TEST_ASSERT(feet.total_bloodiness > 0, "Internal exposure method [method] washed an IPC's feet.")
	var/datum/reagent/space_cleaner/cleaner = source.reagents.has_reagent(/datum/reagent/space_cleaner)
	for(var/amount in list(0, -1))
		var/list/dose = list()
		dose[cleaner] = amount
		ipc.expose_reagents(dose, source.reagents, TOUCH)
		TEST_ASSERT(feet.total_bloodiness > 0, "A nonpositive cleaner dose of [amount] washed an IPC's feet.")

	for(var/method in list(TOUCH, VAPOR))
		for(var/cleaner_first in list(TRUE, FALSE))
			source.reagents.clear_reagents()
			for(var/reagent_type in (cleaner_first ? list(/datum/reagent/space_cleaner/ez_clean, /datum/reagent/water) : list(/datum/reagent/water, /datum/reagent/space_cleaner/ez_clean)))
				source.reagents.add_reagent(reagent_type, 10, no_react = TRUE)
			source.reagents.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10, no_react = TRUE)
			pool.bloodiness = BLOOD_POOL_MAX
			SEND_SIGNAL(ipc, COMSIG_STEP_ON_BLOOD, pool)
			TEST_ASSERT(feet.total_bloodiness > 0, "The mixed cleaner spray fixture had no bloody feet.")
			var/mutable_appearance/feet_overlay = ipc.overlays_standing[SHOES_LAYER]
			var/blood_appearance = feet_overlay.appearance
			var/original_health = ipc.health
			ipc.Sleeping(30 SECONDS)
			var/original_sleep = ipc.AmountSleeping()
			ipc.set_fire_stacks(5)
			TEST_ASSERT(ipc.ignite_mob(silent = TRUE), "The mixed cleaner spray fixture did not catch fire.")
			source.reagents.expose(ipc, method)
			TEST_ASSERT_EQUAL(feet.total_bloodiness, 0, "External cleaner method [method] could not wash an IPC's feet.")
			TEST_ASSERT(!(blood_appearance in ipc.overlays), "Cleaner spray left the blood sprite on an IPC's feet.")
			TEST_ASSERT_EQUAL(ipc.health, original_health, "EZ Clean applied its damaging chemical callback to an IPC.")
			TEST_ASSERT_EQUAL(ipc.reagents.total_volume, 0, "Cleaning let spray chemicals enter an IPC's body.")
			TEST_ASSERT(!ipc.IsKnockdown(), "Cleaning applied pepper spray's chemical callback to an IPC.")
			TEST_ASSERT_EQUAL(ipc.AmountSleeping(), original_sleep, "Cleaning ran water's unrelated wake-up effect.")
			if(method == TOUCH)
				TEST_ASSERT(!ipc.on_fire, "The mixed spray stopped extinguishing when its reagent order changed.")
			ipc.extinguish_mob()
