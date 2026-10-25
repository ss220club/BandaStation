/// Transforming in both directions must replace organs, bodyparts and the electronics interaction.
/datum/unit_test/vox_species_roundtrip/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/cybernetic/vox), "Vox did not receive its cortical stack.")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_LUNGS), /obj/item/organ/lungs/vox), "Vox retained oxygen-breathing lungs.")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/vox), "Vox did not receive its tongue.")
	TEST_ASSERT_NOTNULL(human.get_organ_by_type(/obj/item/organ/quills/vox), "Vox did not receive its quills.")
	TEST_ASSERT_NOTNULL(human.get_organ_by_type(/obj/item/organ/tail/vox), "Vox did not receive its tail.")
	TEST_ASSERT_EQUAL(human.dna.species.get_breath_type(), GAS_N2, "Vox species reports the wrong breathing gas.")
	TEST_ASSERT_EQUAL(length(human.get_bodyparts()), 6, "Vox did not retain six native bodyparts.")
	for(var/obj/item/bodypart/bodypart as anything in human.get_bodyparts())
		TEST_ASSERT(bodypart.bodytype & BODYTYPE_ORGANIC, "Vox received a robotic bodypart.")

	human.set_species(/datum/species/human)
	var/obj/item/organ/brain/brain = human.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/lungs/lungs = human.get_organ_slot(ORGAN_SLOT_LUNGS)
	TEST_ASSERT_EQUAL(brain?.type, /obj/item/organ/brain, "Human retained a vox cortical stack.")
	TEST_ASSERT_EQUAL(lungs?.type, /obj/item/organ/lungs, "Human retained vox lungs.")
	TEST_ASSERT_NULL(human.get_organ_by_type(/obj/item/organ/quills/vox), "Human retained vox quills.")
	TEST_ASSERT_NULL(human.get_organ_by_type(/obj/item/organ/tail/vox), "Human retained a vox tail.")

/// Exercise the real gas exchange, suffocation alerts and oxygen toxicity code.
/datum/unit_test/vox_breathing
	parent_type = /datum/unit_test/lungs

/datum/unit_test/vox_breathing/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	var/obj/item/organ/lungs/vox/lungs = human.get_organ_slot(ORGAN_SLOT_LUNGS)
	lungs_test_check_breath("pure nitrogen", human, lungs, create_nitrogen_mix())
	TEST_ASSERT_EQUAL(human.get_tox_loss(), 0, "Pure nitrogen poisoned a vox.")
	lungs_test_check_breath("station atmosphere", human, lungs, create_standard_mix())
	TEST_ASSERT(human.get_tox_loss() > 0, "Station oxygen did not poison a vox.")
	TEST_ASSERT(human.has_alert(ALERT_TOO_MUCH_OXYGEN), "Vox was not warned about oxygen toxicity.")
	lungs_test_check_breath("nitrogen after oxygen exposure", human, lungs, create_nitrogen_mix())
	TEST_ASSERT(!human.has_alert(ALERT_TOO_MUCH_OXYGEN), "Oxygen warning remained after returning to nitrogen.")
	lungs_test_check_breath("vacuum", human, lungs, null, expect_failure = TRUE)
	TEST_ASSERT(human.get_oxy_loss() > 0, "Vox did not suffocate in vacuum.")
	lungs_test_check_breath("nitrogen after suffocation", human, lungs, create_nitrogen_mix())
	TEST_ASSERT(!human.has_alert(ALERT_NOT_ENOUGH_NITRO), "Nitrogen warning remained after breathing nitrogen.")

/// The inherited cyberbrain must take EMP damage both inside and outside a body.
/datum/unit_test/vox_brain_emp/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	var/obj/item/organ/brain/cybernetic/vox/brain = human.get_organ_slot(ORGAN_SLOT_BRAIN)
	brain.emp_act(EMP_HEAVY)
	TEST_ASSERT(brain.damage > 0, "An implanted vox cortical stack ignored EMP.")
	TEST_ASSERT(human.IsParalyzed(), "Heavy EMP did not interrupt the vox cortical stack.")
	var/obj/item/organ/brain/cybernetic/vox/extracted = allocate(/obj/item/organ/brain/cybernetic/vox)
	extracted.emp_act(EMP_LIGHT)
	TEST_ASSERT(extracted.damage > 0, "An extracted vox cortical stack ignored EMP.")

/// Real spawning needs working internals, while preferences previews must not spawn life support.
/datum/unit_test/vox_life_support/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	var/datum/species/vox/species = human.dna.species
	species.pre_equip_species_outfit(null, human, visuals_only = TRUE)
	TEST_ASSERT_NULL(human.wear_mask, "Preferences preview spawned a real vox breath mask.")
	TEST_ASSERT_NULL(human.is_holding_item_of_type(/obj/item/tank/internals), "Preferences preview spawned a real nitrogen tank.")
	species.pre_equip_species_outfit(null, human)
	TEST_ASSERT(istype(human.wear_mask, /obj/item/clothing/mask/breath/vox), "Vox did not spawn with its breath mask.")
	TEST_ASSERT(istype(human.internal, /obj/item/tank/internals/nitrogen), "Vox did not enable nitrogen internals.")
	TEST_ASSERT(human.internal.air_contents.moles[/datum/gas/nitrogen] > 0, "Spawn nitrogen tank is empty.")
	TEST_ASSERT(!human.internal.air_contents.moles[/datum/gas/oxygen], "Spawn nitrogen tank contains oxygen.")
	TEST_ASSERT_EQUAL(species.survival_box_overrides[SURVIVAL_MASK_TYPE], /obj/item/clothing/mask/breath/vox, "Emergency box has the wrong mask for a vox.")
	TEST_ASSERT_EQUAL(species.survival_box_overrides[SURVIVAL_INTERNALS_TYPE], /obj/item/tank/internals/nitrogen/belt, "Emergency box gives a vox an oxygen tank.")

/// Professional outfits run after species life support and must not replace it with unsafe equipment.
/datum/unit_test/vox_job_life_support/Run()
	for(var/job_type in list(/datum/job/assistant, /datum/job/clown, /datum/job/mime, /datum/job/station_engineer))
		var/datum/job/job = SSjob.get_job_type(job_type)
		TEST_ASSERT_NOTNULL(job, "Test could not retrieve [job_type].")
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
		human.set_species(/datum/species/vox)
		human.job = job
		human.dress_up_as_job(job, consistent = TRUE)
		TEST_ASSERT(istype(human.wear_mask, /obj/item/clothing/mask/breath/vox), "[job_type] replaced the vox's life-support mask.")
		TEST_ASSERT(istype(human.internal, /obj/item/tank/internals/nitrogen), "[job_type] disabled the vox's nitrogen internals.")
		TEST_ASSERT(human.is_holding(human.internal), "[job_type] removed the active nitrogen tank from the vox's hands.")
		TEST_ASSERT(human.internal.air_contents.moles[/datum/gas/nitrogen] > 0, "[job_type] gave a vox an empty nitrogen tank.")
		TEST_ASSERT(!human.internal.air_contents.moles[/datum/gas/oxygen], "[job_type] gave a vox oxygen in its active nitrogen tank.")

/// Every imported electronics class must be edible without changing its native durability.
/datum/unit_test/vox_electronics_bites/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	var/list/item_types = list(
		/obj/item/circuitboard/machine/autolathe,
		/obj/item/flashlight,
		/obj/item/modular_computer/pda,
		/obj/item/gps,
		/obj/item/radio,
		/obj/item/electronics/airlock,
	)
	var/obj/item/organ/stomach/stomach = human.get_organ_slot(ORGAN_SLOT_STOMACH)
	for(var/item_type in item_types)
		var/obj/item/item = allocate(item_type)
		var/initial_integrity = item.get_integrity()
		human.put_in_active_hand(item)
		var/datum/component/vox_food/food = item.AddComponent(/datum/component/vox_food)
		food.create_snack()
		TEST_ASSERT_EQUAL(item.get_integrity(), initial_integrity, "Preparing [item_type] as vox food damaged it before a bite.")
		var/datum/component/edible/vox/edible = food.snack.GetComponent(/datum/component/edible/vox)
		TEST_ASSERT(edible.TakeBite(human, human), "Vox could not bite [item_type].")
		TEST_ASSERT(item.get_integrity() < initial_integrity, "Biting [item_type] did not damage the device.")
		TEST_ASSERT(human.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) > 0 || stomach.reagents.total_volume > 0, "Biting electronics did not provide food.")
		human.dropItemToGround(item)

/// An unfinished meal must retain the device's original deconstruction behaviour.
/datum/unit_test/vox_electronics_debris_flags/Run()
	var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	for(var/already_suppressed in list(FALSE, TRUE))
		var/obj/item/flashlight/item = allocate(/obj/item/flashlight)
		if(already_suppressed)
			item.obj_flags |= NO_DEBRIS_AFTER_DECONSTRUCTION
		vox.put_in_active_hand(item)
		var/datum/component/vox_food/food = item.AddComponent(/datum/component/vox_food)
		food.create_snack()
		var/datum/component/edible/vox/edible = food.snack.GetComponent(/datum/component/edible/vox)
		TEST_ASSERT(edible.TakeBite(vox, vox), "Vox could not take an intermediate device bite.")
		TEST_ASSERT(!QDELETED(item), "An intermediate bite destroyed the device.")
		TEST_ASSERT_EQUAL(!!(item.obj_flags & NO_DEBRIS_AFTER_DECONSTRUCTION), already_suppressed, "An unfinished Vox meal changed the device's original debris flag.")
		vox.dropItemToGround(item)

/// Medical stock must guarantee compatible blood without relying on random packs.
/datum/unit_test/vox_blood_stock/Run()
	var/datum/supply_pack/medical/bloodpacks/pack = allocate(/datum/supply_pack/medical/bloodpacks)
	TEST_ASSERT(/obj/item/reagent_containers/blood/vox in pack.contains, "Cargo blood supplies have no guaranteed Vox pack.")
	var/obj/structure/closet/crate/cargo = pack.generate(run_loc_floor_bottom_left)
	allocated += cargo
	var/obj/item/reagent_containers/blood/vox/cargo_blood = locate() in cargo
	TEST_ASSERT_NOTNULL(cargo_blood, "Generating a medical supply crate did not supply Vox blood.")
	var/obj/structure/closet/crate/freezer/blood/freezer = allocate(/obj/structure/closet/crate/freezer/blood)
	freezer.PopulateContents()
	var/obj/item/reagent_containers/blood/vox/freezer_blood = locate() in freezer
	TEST_ASSERT_NOTNULL(freezer_blood, "A stocked blood freezer has no Vox blood pack.")

/// A meal proxy cannot be used by humans, feed humans, or eat a dropped item.
/datum/unit_test/vox_electronics_restrictions/Run()
	var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/flashlight/item = allocate(/obj/item/flashlight)
	vox.put_in_active_hand(item)
	var/datum/component/vox_food/food = item.AddComponent(/datum/component/vox_food)
	food.create_snack()
	var/datum/component/edible/vox/edible = food.snack.GetComponent(/datum/component/edible/vox)
	var/initial_integrity = item.get_integrity()
	TEST_ASSERT(!edible.TakeBite(human, vox), "A vox could feed electronics to a human.")
	TEST_ASSERT(!edible.TakeBite(vox, human), "A human could feed vox electronics through a stale proxy.")
	item.resistance_flags |= INDESTRUCTIBLE
	TEST_ASSERT(!edible.TakeBite(vox, vox), "Indestructible electronics provided an infinite food source.")
	item.resistance_flags &= ~INDESTRUCTIBLE
	item.flags_1 |= HOLOGRAM_1
	TEST_ASSERT(!edible.TakeBite(vox, vox), "Holographic electronics provided real food.")
	item.flags_1 &= ~HOLOGRAM_1
	item.set_armor_rating(CONSUME, 100)
	TEST_ASSERT(!edible.TakeBite(vox, vox), "Consumption-proof electronics provided an infinite food source.")
	item.set_armor_rating(CONSUME, 0)
	vox.dropItemToGround(item)
	TEST_ASSERT(!edible.TakeBite(vox, vox), "Vox could eat a dropped device through its meal proxy.")
	TEST_ASSERT_EQUAL(item.get_integrity(), initial_integrity, "A rejected bite damaged electronics.")

/// Finishing a meal must remove both the real item and the owned proxy after the expected bite count.
/datum/unit_test/vox_electronics_consumption/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	var/list/bite_counts = list(
		/obj/item/circuitboard/machine/autolathe = 4,
		/obj/item/flashlight = 3,
		/obj/item/radio = 2,
		/obj/item/gps = 3,
		/obj/item/electronics/airlock = 4,
		/obj/item/modular_computer/pda = 7,
	)
	for(var/item_type in bite_counts)
		var/obj/item/item = allocate(item_type)
		human.put_in_active_hand(item)
		var/datum/component/vox_food/food = item.AddComponent(/datum/component/vox_food)
		food.create_snack()
		var/obj/item/food/vox_snack/snack = food.snack
		var/datum/component/edible/vox/edible = snack.GetComponent(/datum/component/edible/vox)
		for(var/bite in 1 to bite_counts[item_type])
			TEST_ASSERT(!QDELETED(item), "[item_type] was consumed before its expected last bite.")
			TEST_ASSERT(edible.TakeBite(human, human), "Vox could not finish eating [item_type].")
		TEST_ASSERT(QDELETED(item), "A fully eaten [item_type] survived its last bite.")
		TEST_ASSERT(QDELETED(snack), "A fully eaten [item_type] left its proxy behind.")

/// Detached mutant organs must survive a transplant to another species and release their previous owner.
/datum/unit_test/vox_tail_transplant/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	var/obj/item/organ/tail/vox/tail = human.get_organ_by_type(/obj/item/organ/tail/vox)
	allocated += tail
	tail.Remove(human, special = TRUE)
	var/mob/living/carbon/human/species/monkey/monkey = allocate(/mob/living/carbon/human/species/monkey)
	TEST_ASSERT(tail.Insert(monkey, special = TRUE), "An extracted vox tail could not be transplanted into a monkey.")
	TEST_ASSERT_EQUAL(tail.owner, monkey, "Tail transplant did not transfer its owner.")
	tail.Remove(monkey, special = TRUE)
	TEST_ASSERT_NULL(tail.owner, "Removing a transplanted vox tail kept the monkey reference.")

/// Stealing the actual item during do_after must cancel its pending bite.
/datum/unit_test/vox_electronics_stolen_during_bite/Run()
	var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	vox.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	var/mob/living/carbon/human/thief = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/flashlight/item = allocate(/obj/item/flashlight)
	vox.put_in_active_hand(item)
	var/datum/component/vox_food/food = item.AddComponent(/datum/component/vox_food)
	food.create_snack()
	var/datum/component/edible/vox/edible = food.snack.GetComponent(/datum/component/edible/vox)
	var/initial_integrity = item.get_integrity()
	edible.TryToEat(vox, vox)
	vox.dropItemToGround(item)
	thief.put_in_active_hand(item)
	sleep(1.2 SECONDS)
	TEST_ASSERT_EQUAL(item.get_integrity(), initial_integrity, "A pending bite damaged an item after it was stolen.")
	TEST_ASSERT_EQUAL(edible.bitecount, 0, "Vox received a bite of a stolen item.")

/// Repeated clicks must reuse the meal instead of deleting the first click's pending action.
/datum/unit_test/vox_electronics_repeated_click/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	// Consistent dummies override the normal base; exercise the live game's one-second action.
	human.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	TEST_ASSERT_EQUAL(human.cached_multiplicative_actions_slowdown, 1, "Test actor does not use normal action timing.")
	var/obj/item/flashlight/item = allocate(/obj/item/flashlight)
	human.put_in_active_hand(item)
	TEST_ASSERT(item.pre_attack(human, human, list(), list()), "Vox click did not enter the electronics eating interaction.")
	var/datum/component/vox_food/food = item.GetComponent(/datum/component/vox_food)
	TEST_ASSERT_NOTNULL(food, "Vox click did not add the electronics food component.")
	var/obj/item/food/vox_snack/snack = food.snack
	TEST_ASSERT_EQUAL(LAZYACCESS(human.do_afters, human), 1, "The first click did not start exactly one pending bite.")
	TEST_ASSERT(item.pre_attack(human, human, list(), list()), "Repeated vox click did not enter the electronics eating interaction.")
	TEST_ASSERT_EQUAL(LAZYACCESS(human.do_afters, human), 1, "Repeated clicks started parallel pending bites.")
	TEST_ASSERT_EQUAL(item.GetComponent(/datum/component/vox_food), food, "Repeated click replaced the owned food component.")
	TEST_ASSERT_EQUAL(food.snack, snack, "Repeated click replaced its pending meal proxy.")
	TEST_ASSERT(!QDELETED(snack), "Repeated click deleted a pending meal proxy.")
	var/datum/component/edible/vox/edible = snack.GetComponent(/datum/component/edible/vox)
	TEST_ASSERT_EQUAL(edible.eat_time, 1 SECONDS, "Vox food does not use the normal one-second bite delay.")
	sleep(1.2 SECONDS)
	TEST_ASSERT_EQUAL(edible.bitecount, 1, "Repeated clicks cancelled or duplicated the first delayed bite.")
	human.dropItemToGround(item)
	sleep(1.2 SECONDS)
	TEST_ASSERT_EQUAL(edible.bitecount, 1, "Automatic eating continued after dropping the device.")

/// A food-attempt callback must not be able to move the real device after its final ownership check.
/datum/unit_test/vox_electronics_food_signal
	var/obj/item/device
	var/attempts = 0

/datum/unit_test/vox_electronics_food_signal/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	device = allocate(/obj/item/flashlight)
	human.put_in_active_hand(device)
	var/datum/component/vox_food/food = device.AddComponent(/datum/component/vox_food)
	food.create_snack()
	var/datum/component/edible/vox/edible = food.snack.GetComponent(/datum/component/edible/vox)
	RegisterSignal(food.snack, COMSIG_FOOD_ATTEMPT_EAT, PROC_REF(move_device))
	var/initial_integrity = device.get_integrity()
	TEST_ASSERT(!edible.TakeBite(human, human), "A food signal moved electronics after the last ownership check.")
	TEST_ASSERT_EQUAL(device.get_integrity(), initial_integrity, "A food signal allowed damage to a device no longer held.")
	TEST_ASSERT_EQUAL(edible.bitecount, 0, "A food signal allowed a bite of an unavailable device.")
	device = null

/datum/unit_test/vox_electronics_food_signal/proc/move_device(datum/source, mob/living/eater, mob/living/feeder)
	SIGNAL_HANDLER
	attempts++
	if(attempts == 2)
		feeder.dropItemToGround(device)

/// Item teardown owns the proxy, including while a delayed bite is pending.
/datum/unit_test/vox_electronics_deleted_during_bite/Run()
	var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	vox.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	var/obj/item/flashlight/item = allocate(/obj/item/flashlight)
	vox.put_in_active_hand(item)
	var/datum/component/vox_food/food = item.AddComponent(/datum/component/vox_food)
	food.create_snack()
	var/obj/item/food/vox_snack/snack = food.snack
	var/datum/component/edible/vox/edible = snack.GetComponent(/datum/component/edible/vox)
	edible.TryToEat(vox, vox)
	qdel(item)
	TEST_ASSERT(QDELETED(snack), "Deleting electronics leaked its meal proxy.")
	sleep(1.2 SECONDS)

/// Species changes during the real eating delay must invalidate its pending bite.
/datum/unit_test/vox_electronics_transformation/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/vox)
	human.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	var/obj/item/flashlight/item = allocate(/obj/item/flashlight)
	human.put_in_active_hand(item)
	var/datum/component/vox_food/food = item.AddComponent(/datum/component/vox_food)
	food.create_snack()
	var/datum/component/edible/vox/edible = food.snack.GetComponent(/datum/component/edible/vox)
	var/initial_integrity = item.get_integrity()
	edible.TryToEat(human, human)
	human.set_species(/datum/species/human)
	sleep(1.2 SECONDS)
	TEST_ASSERT_EQUAL(edible.bitecount, 0, "A transformed human retained a pending vox meal.")
	TEST_ASSERT_EQUAL(item.get_integrity(), initial_integrity, "A transformed human still damaged electronics with a bite.")
	TEST_ASSERT(!item.pre_attack(human, human, list(), list()), "A human retained the vox electronics interaction.")

/// Normal item damage must continue to work for vox and other species.
/datum/unit_test/vox_item_attack_regression/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/crowbar/weapon = allocate(/obj/item/crowbar)
	attacker.set_species(/datum/species/vox)
	attacker.set_combat_mode(TRUE)
	weapon.attack(target, attacker, list(), list())
	TEST_ASSERT(target.get_brute_loss() > 0, "The vox electronics interaction disabled ordinary item attacks.")
