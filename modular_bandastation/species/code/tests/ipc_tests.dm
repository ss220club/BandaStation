/// Transformations must replace IPC organs, traits, actions and limbs in both directions.
/datum/unit_test/ipc_species_roundtrip/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/ipc), "IPC did not receive a positronic brain.")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_HEART), /obj/item/organ/heart/ipc), "IPC did not receive a battery.")
	TEST_ASSERT_NOTNULL(human.get_organ_by_type(/obj/item/organ/cyberimp/arm/power_cord/ipc), "IPC did not receive its charging cable.")
	TEST_ASSERT_NULL(human.get_organ_slot(ORGAN_SLOT_STOMACH), "IPC retained its organic stomach.")
	TEST_ASSERT_NULL(human.get_organ_slot(ORGAN_SLOT_LUNGS), "IPC retained its lungs.")
	TEST_ASSERT_NULL(human.get_organ_slot(ORGAN_SLOT_LIVER), "IPC retained its liver.")
	TEST_ASSERT(HAS_TRAIT(human, TRAIT_NOBREATH), "IPC still needs to breathe.")
	TEST_ASSERT(HAS_TRAIT(human, TRAIT_NOHUNGER), "IPC uses organic hunger instead of battery discharge.")
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_RESISTHEAT), "IPC inherited android heat immunity.")
	for(var/obj/item/bodypart/limb as anything in human.get_bodyparts())
		TEST_ASSERT(limb.bodytype & BODYTYPE_ROBOTIC, "IPC has an organic [limb.body_zone].")

	human.set_species(/datum/species/human)
	var/obj/item/organ/brain/organic_brain = human.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/organic_heart = human.get_organ_slot(ORGAN_SLOT_HEART)
	TEST_ASSERT_EQUAL(organic_brain?.type, /obj/item/organ/brain, "IPC brain survived an organic species transformation.")
	TEST_ASSERT_EQUAL(organic_heart?.type, /obj/item/organ/heart, "IPC battery survived an organic species transformation.")
	TEST_ASSERT_NOTNULL(human.get_organ_slot(ORGAN_SLOT_STOMACH), "Human stomach was not restored.")
	TEST_ASSERT_NULL(human.get_organ_by_type(/obj/item/organ/cyberimp/arm/power_cord/ipc), "Charging cable survived a species transformation.")
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_NOBREATH), "IPC breathing trait leaked after transformation.")
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_NOHUNGER), "IPC battery trait leaked after transformation.")
	for(var/datum/action/innate/ipc_display/display in human.actions)
		TEST_FAIL("IPC display action survived a species transformation.")
	for(var/obj/item/bodypart/limb as anything in human.get_bodyparts())
		TEST_ASSERT(limb.bodytype & BODYTYPE_ORGANIC, "IPC [limb.body_zone] survived an organic species transformation.")

/// Disconnecting a head must leave the positronic brain in the chest.
/datum/unit_test/ipc_headless/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	var/obj/item/organ/brain/brain = human.get_organ_slot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT_EQUAL(brain.zone, BODY_ZONE_CHEST, "IPC brain is not installed in the chest.")
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)
	head.drop_limb()
	TEST_ASSERT_EQUAL(human.get_organ_slot(ORGAN_SLOT_BRAIN), brain, "Decapitation removed the positronic brain.")
	TEST_ASSERT_NOTEQUAL(human.stat, DEAD, "Removing an IPC head killed its positronic brain.")

/// Real shocks charge the battery; insulation and phantom shocks must not create power.
/datum/unit_test/ipc_electrical_charging/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	human.set_nutrition(200, forced = TRUE)
	human.electrocute_act(25, "unit test", flags = SHOCK_SUPPRESS_MESSAGE)
	TEST_ASSERT_EQUAL(human.nutrition, 225, "Electrical shock did not charge the IPC battery.")
	TEST_ASSERT_EQUAL(human.get_fire_loss(), 0, "Normal electrical shock burned an IPC.")

	var/obj/item/clothing/gloves/color/yellow/gloves = allocate(/obj/item/clothing/gloves/color/yellow)
	human.equip_to_slot_or_del(gloves, ITEM_SLOT_GLOVES)
	TEST_ASSERT_EQUAL(human.gloves, gloves, "Test could not equip insulated gloves.")
	human.electrocute_act(25, "unit test", flags = SHOCK_SUPPRESS_MESSAGE)
	TEST_ASSERT_EQUAL(human.nutrition, 225, "Insulated gloves allowed free charging.")
	human.dropItemToGround(gloves)
	human.electrocute_act(25, "unit test", flags = SHOCK_ILLUSION | SHOCK_SUPPRESS_MESSAGE)
	TEST_ASSERT_EQUAL(human.nutrition, 225, "An imaginary shock charged a real battery.")

	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	battery.adjust_charge(NUTRITION_LEVEL_FULL * 2)
	TEST_ASSERT_EQUAL(human.nutrition, NUTRITION_LEVEL_FULL, "Battery charge exceeded its capacity.")
	battery.adjust_charge(-NUTRITION_LEVEL_FULL * 2)
	TEST_ASSERT_EQUAL(human.nutrition, 0, "Battery charge became negative.")

/// Repairing a dead chassis must not bypass failed components or a voluntary death.
/datum/unit_test/ipc_reboot/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	var/datum/species/ipc/species = human.dna.species
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	human.death()
	human.set_nutrition(0, forced = TRUE)
	TEST_ASSERT(!species.try_restart(human), "An empty battery booted a dead IPC.")
	human.set_nutrition(NUTRITION_LEVEL_WELL_FED, forced = TRUE)
	battery.set_organ_damage(battery.maxHealth)
	TEST_ASSERT(!species.try_restart(human), "A failed battery booted a dead IPC.")
	battery.set_organ_damage(0)
	var/obj/item/organ/brain/brain = human.get_organ_slot(ORGAN_SLOT_BRAIN)
	brain.organ_flags |= ORGAN_FAILING
	TEST_ASSERT(!species.try_restart(human), "A failed positronic brain booted a dead IPC.")
	brain.organ_flags &= ~ORGAN_FAILING
	brain.organ_flags |= ORGAN_EMP
	TEST_ASSERT(!species.try_restart(human), "An EMP-disabled positronic brain booted a dead IPC.")
	brain.organ_flags &= ~ORGAN_EMP
	human.set_suicide(TRUE)
	TEST_ASSERT(!species.try_restart(human), "Automatic reboot bypassed the suicide flag.")
	human.set_suicide(FALSE)
	TEST_ASSERT(species.try_restart(human), "A repaired, charged IPC did not reboot.")
	TEST_ASSERT_NOTEQUAL(human.stat, DEAD, "Reboot left the IPC dead.")

/// EMP must be safe even after the brain has been extracted during repairs.
/datum/unit_test/ipc_extracted_brain_emp/Run()
	var/obj/item/organ/brain/ipc/brain = allocate(/obj/item/organ/brain/ipc)
	brain.emp_act(EMP_HEAVY)
	TEST_ASSERT(brain.damage > 0, "An unshielded positronic brain ignored an EMP.")

/// Diagnostic goggles need live HUD images through repeated transformations.
/datum/unit_test/ipc_diagnostic_hud/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left, /datum/species/ipc)
	for(var/hud_type in list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD))
		TEST_ASSERT_NOTNULL(human.hud_list[hud_type], "IPC spawned without [hud_type] image.")
		TEST_ASSERT_NOTNULL(human.active_hud_list[hud_type], "IPC spawned with inactive [hud_type].")
	var/image/battery_image = human.hud_list[DIAG_BATT_HUD]
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	battery.Remove(human, special = TRUE)
	TEST_ASSERT_EQUAL(battery_image.icon_state, "hudnobatt", "Removing the battery did not immediately update diagnostics.")
	battery.Insert(human, special = TRUE)
	TEST_ASSERT_NOTEQUAL(battery_image.icon_state, "hudnobatt", "Installing a battery left the missing-battery icon.")
	var/image/status_image = human.hud_list[DIAG_STAT_HUD]
	human.Unconscious(5 SECONDS)
	TEST_ASSERT_EQUAL(status_image.icon_state, "hudoffline", "Non-damaging unconsciousness did not update diagnostics.")
	human.SetUnconscious(0)
	TEST_ASSERT_EQUAL(status_image.icon_state, "hudstat", "Waking up left the offline diagnostic icon.")
	human.set_species(/datum/species/human)
	for(var/hud_type in list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD))
		TEST_ASSERT_NULL(human.active_hud_list[hud_type], "Organic human retained [hud_type] diagnostic image.")
	human.set_species(/datum/species/ipc)
	for(var/hud_type in list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD))
		TEST_ASSERT_NOTNULL(human.active_hud_list[hud_type], "Second IPC transformation did not reactivate [hud_type].")

/// Bloodless chassis cannot use defibrillation to bypass the battery requirement.
/datum/unit_test/ipc_no_battery_defib/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	battery.Remove(human)
	TEST_ASSERT_EQUAL(human.can_defib(), DEFIB_FAIL_BLACKLISTED, "Defibrillation can boot a chassis without its battery.")

/// Six TG limbs must retain the source's total EMP damage without robotic limb paralysis.
/datum/unit_test/ipc_chassis_emp/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/ipc)
	var/total_burn = 0
	for(var/obj/item/bodypart/limb as anything in human.get_bodyparts())
		limb.emp_act(EMP_HEAVY)
		total_burn += limb.burn_dam
		TEST_ASSERT(!HAS_TRAIT(limb, TRAIT_PARALYSIS), "EMP applied ordinary augmented-limb paralysis to an IPC.")
	TEST_ASSERT(abs(total_burn - 64.9) <= DAMAGE_PRECISION * 6, "Heavy EMP chassis damage differed from the source's 64.9 total beyond per-limb rounding: [total_burn].")

/// Guaranteed maintenance follows the patient's species, never the surgeon's.
/datum/unit_test/ipc_surgery_failure_chance/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/screwdriver/tool = allocate(/obj/item/screwdriver)
	var/datum/surgery_operation/limb/mechanical_incision/incision = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	var/list/operation_args = list(OPERATION_SPEED = 10)
	var/original_chance = incision.get_modified_failure_chance(incision.time, patient, surgeon, tool, operation_args)
	TEST_ASSERT(original_chance > 0, "Control patient has no surgical failure risk under adverse conditions.")

	patient.set_species(/datum/species/ipc)
	TEST_ASSERT_EQUAL(patient.stat, STABLE, "IPC patient must be awake for the maintenance check.")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_ANALGESIA), "IPC patient must not be anesthetized for the maintenance check.")
	TEST_ASSERT_EQUAL(incision.get_modified_failure_chance(incision.time, patient, surgeon, tool, operation_args), 0, "Awake IPC maintenance can randomly fail under adverse conditions.")
	var/datum/surgery_operation/limb/mechanical_open/open_hatch = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT_EQUAL(open_hatch.get_modified_failure_chance(open_hatch.time, patient, surgeon, IMPLEMENT_HAND, operation_args), 0, "Opening an IPC hatch by hand can randomly fail.")
	var/datum/surgery_operation/organ/repair/brain/mechanic/brain_repair = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT_EQUAL(brain_repair.get_modified_failure_chance(brain_repair.time, patient, surgeon, tool, operation_args), 0, "IPC internal maintenance can randomly fail.")

	patient.set_species(/datum/species/human)
	TEST_ASSERT_EQUAL(incision.get_modified_failure_chance(incision.time, patient, surgeon, tool, operation_args), original_chance, "Guaranteed maintenance leaked after changing away from IPC.")
	surgeon.set_species(/datum/species/ipc)
	TEST_ASSERT_EQUAL(incision.get_modified_failure_chance(incision.time, patient, surgeon, tool, operation_args), original_chance, "An IPC surgeon changed an organic patient's surgical failure risk.")

/// Real operations still require a suitable tool and an uninterrupted action.
/datum/unit_test/ipc_surgery_steps/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.set_species(/datum/species/ipc)
	patient.set_resting(TRUE)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	ADD_TRAIT(patient, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human/consistent/slow)
	var/obj/item/screwdriver/tool = allocate(/obj/item/screwdriver)
	var/obj/item/crowbar/wrong_tool = allocate(/obj/item/crowbar)
	var/datum/surgery_operation/limb/mechanical_incision/incision = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	var/list/operation_args = list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST)

	surgeon.put_in_active_hand(wrong_tool)
	TEST_ASSERT_EQUAL(incision.try_perform(chest, surgeon, wrong_tool, operation_args), ITEM_INTERACT_BLOCKING, "IPC surgery accepted an unsuitable tool.")
	TEST_ASSERT(!LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_CUT), "An invalid tool opened the IPC chassis.")
	surgeon.dropItemToGround(wrong_tool)
	surgeon.put_in_active_hand(tool)
	addtimer(CALLBACK(surgeon, TYPE_PROC_REF(/mob, dropItemToGround), tool), 1)
	TEST_ASSERT_EQUAL(incision.try_perform(chest, surgeon, tool, operation_args), ITEM_INTERACT_BLOCKING, "Dropping the tool did not interrupt IPC surgery.")
	TEST_ASSERT(!LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_CUT), "Interrupted maintenance opened the IPC chassis.")

	surgeon.put_in_active_hand(tool)
	TEST_ASSERT_EQUAL(incision.try_perform(chest, surgeon, tool, operation_args), ITEM_INTERACT_SUCCESS, "Valid IPC incision did not succeed.")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_CUT), "Successful maintenance did not unscrew the IPC chassis.")
	surgeon.dropItemToGround(tool)
	var/datum/surgery_operation/limb/mechanical_open/open_hatch = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT_EQUAL(open_hatch.try_perform(chest, surgeon, IMPLEMENT_HAND, operation_args), ITEM_INTERACT_SUCCESS, "Opening an IPC hatch by hand did not succeed.")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_OPEN), "Successful maintenance did not open the IPC hatch.")

/// Food cannot be consumed by an IPC, including direct bites and another person's feeding attempt.
/datum/unit_test/ipc_food_rejection/Run()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/food/cracker/food = allocate(/obj/item/food/cracker)
	var/datum/component/edible/edible = food.GetComponent(/datum/component/edible)
	var/initial_food_volume = food.reagents.total_volume
	eater.set_species(/datum/species/ipc)
	eater.set_nutrition(200, forced = TRUE)
	var/initial_reagent_volume = eater.reagents.total_volume
	var/initial_satiety = eater.satiety

	edible.TryToEat(eater, eater)
	edible.TryToEat(eater, feeder)
	TEST_ASSERT(!edible.TakeBite(eater, feeder), "A direct bite bypassed IPC food rejection.")
	TEST_ASSERT_EQUAL(food.reagents.total_volume, initial_food_volume, "Rejected IPC feeding consumed food.")
	TEST_ASSERT_EQUAL(edible.bitecount, 0, "Rejected IPC feeding counted as a bite.")
	TEST_ASSERT_EQUAL(eater.reagents.total_volume, initial_reagent_volume, "Rejected IPC feeding transferred reagents.")
	TEST_ASSERT_EQUAL(eater.nutrition, 200, "Rejected food changed IPC battery charge.")
	TEST_ASSERT_EQUAL(eater.satiety, initial_satiety, "Rejected food changed IPC satiety.")
	TEST_ASSERT(!DOING_INTERACTION(feeder, eater), "Feeding an IPC started a timed feeding action.")

	eater.set_species(/datum/species/human)
	TEST_ASSERT(edible.TakeBite(eater, eater), "Changing away from IPC did not restore eating.")
	TEST_ASSERT(food.reagents.total_volume < initial_food_volume, "A human control did not consume food.")
	var/remaining_food_volume = food.reagents.total_volume
	eater.set_species(/datum/species/ipc)
	TEST_ASSERT(!edible.TakeBite(eater, eater), "A second transformation into IPC did not restore food rejection.")
	TEST_ASSERT_EQUAL(food.reagents.total_volume, remaining_food_volume, "A second IPC transformation allowed food consumption.")
	eater.set_species(/datum/species/human)
	TEST_ASSERT(edible.CanConsume(eater, feeder), "IPC food rejection survived a second transformation into a human.")

/// Loaded utensils must retain their contents when the receiver is an IPC.
/datum/unit_test/ipc_utensil_food_rejection/Run()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/food/omelette/food = allocate(/obj/item/food/omelette)
	var/obj/item/kitchen/fork/fork = allocate(/obj/item/kitchen/fork)
	var/obj/item/kitchen/spoon/spoon = allocate(/obj/item/kitchen/spoon)
	TEST_ASSERT_EQUAL(food.item_interaction(feeder, fork, list()), ITEM_INTERACT_SUCCESS, "Could not load an omelette onto the test fork.")
	var/datum/reagent/forkful = fork.forkload
	TEST_ASSERT_NOTNULL(forkful, "The test fork has no food.")
	spoon.reagents.add_reagent(/datum/reagent/consumable/nutriment, spoon.reagents.maximum_volume)
	var/spoonful_volume = spoon.reagents.total_volume
	eater.set_species(/datum/species/ipc)
	eater.set_nutrition(200, forced = TRUE)
	var/initial_reagent_volume = eater.reagents.total_volume

	fork.attack(eater, eater)
	fork.attack(eater, feeder)
	spoon.attack(eater, eater, list(), list())
	spoon.attack(eater, feeder, list(), list())
	TEST_ASSERT_EQUAL(fork.forkload, forkful, "An IPC consumed the food on a fork.")
	TEST_ASSERT_EQUAL(spoon.reagents.total_volume, spoonful_volume, "An IPC consumed a spoonful.")
	TEST_ASSERT_EQUAL(eater.reagents.total_volume, initial_reagent_volume, "An IPC received food reagents from cutlery.")
	TEST_ASSERT_EQUAL(eater.nutrition, 200, "Food from cutlery changed IPC battery charge.")

	eater.set_species(/datum/species/human)
	fork.attack(eater, eater)
	TEST_ASSERT_NULL(fork.forkload, "A human control could not eat food from a fork.")
	spoon.attack(eater, feeder, list(), list())
	TEST_ASSERT_EQUAL(spoon.reagents.total_volume, 0, "A human control could not be fed using a spoon.")

/// Species changes during forcefeeding must be checked again before food leaves its source.
/datum/unit_test/ipc_food_rejection_after_delay/Run()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human/consistent/slow)
	// The mood speed bonus can cancel a slow dummy's 0.1 base after its first action.
	feeder.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/base, multiplicative_slowdown = 1)
	var/obj/item/food/cracker/food = allocate(/obj/item/food/cracker)
	var/datum/component/edible/edible = food.GetComponent(/datum/component/edible)
	var/initial_food_volume = food.reagents.total_volume

	edible.TryToEat(eater, feeder)
	TEST_ASSERT(DOING_INTERACTION(feeder, eater), "The food control did not start a delayed feeding action.")
	addtimer(CALLBACK(eater, TYPE_PROC_REF(/mob, set_species), /datum/species/ipc), 1)
	var/deadline = world.time + 10 SECONDS
	while(DOING_INTERACTION(feeder, eater) && world.time < deadline)
		stoplag()
	TEST_ASSERT(!DOING_INTERACTION(feeder, eater), "Timed out while waiting for the feeding action.")
	TEST_ASSERT(is_species(eater, /datum/species/ipc), "The receiver did not become an IPC during forcefeeding.")
	TEST_ASSERT_EQUAL(food.reagents.total_volume, initial_food_volume, "A species change during forcefeeding allowed food consumption.")
	TEST_ASSERT_EQUAL(edible.bitecount, 0, "A species change during forcefeeding still counted a bite.")

	eater.set_species(/datum/species/human)
	var/obj/item/kitchen/spoon/spoon = allocate(/obj/item/kitchen/spoon)
	spoon.reagents.add_reagent(/datum/reagent/consumable/nutriment, spoon.reagents.maximum_volume)
	var/spoonful_volume = spoon.reagents.total_volume
	addtimer(CALLBACK(eater, TYPE_PROC_REF(/mob, set_species), /datum/species/ipc), 1)
	spoon.attack(eater, feeder, list(), list())
	TEST_ASSERT(is_species(eater, /datum/species/ipc), "The receiver did not become an IPC during spoon feeding.")
	TEST_ASSERT_EQUAL(spoon.reagents.total_volume, spoonful_volume, "A species change during spoon feeding allowed food consumption.")

/// Positronic cores reject ordinary neurological injuries without preventing damage or persistent special effects.
/datum/unit_test/ipc_brain_trauma_rejection/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/consistent)
	ipc.set_species(/datum/species/ipc)
	var/obj/item/organ/brain/ipc/core = ipc.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/mob/living/carbon/human/organic = allocate(/mob/living/carbon/human/consistent)
	var/list/ordinary_traumas = list(
		/datum/brain_trauma/severe/pacifism,
		/datum/brain_trauma/severe/monophobia,
		/datum/brain_trauma/severe/hypnotic_stupor,
		/datum/brain_trauma/severe/blindness,
		/datum/brain_trauma/severe/mute,
	)
	for(var/trauma_type in ordinary_traumas)
		TEST_ASSERT_NOTNULL(organic.gain_trauma(trauma_type, TRAUMA_RESILIENCE_LOBOTOMY), "The organic control could not receive [trauma_type].")
		organic.cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
		TEST_ASSERT_NULL(ipc.gain_trauma(trauma_type), "An IPC received ordinary [trauma_type].")
		TEST_ASSERT_NULL(ipc.gain_trauma(trauma_type, TRAUMA_RESILIENCE_LOBOTOMY), "An IPC received deep-rooted [trauma_type].")
	TEST_ASSERT_EQUAL(length(core.traumas), 0, "Rejected neurological injuries were retained on the positronic core.")
	core.apply_organ_damage(20)
	TEST_ASSERT(core.damage > 0, "Brain trauma protection also blocked ordinary core damage.")

	// Wizard cheese and similar effects pass an existing datum with its own resilience.
	var/datum/brain_trauma/special/godwoken/magic_trauma = allocate(/datum/brain_trauma/special/godwoken)
	magic_trauma.resilience = TRAUMA_RESILIENCE_MAGIC
	TEST_ASSERT_NULL(ipc.gain_trauma(magic_trauma, TRAUMA_RESILIENCE_LOBOTOMY), "An explicit ordinary resilience was ignored for an existing trauma datum.")
	TEST_ASSERT_EQUAL(ipc.gain_trauma(magic_trauma), magic_trauma, "An IPC rejected a trauma datum with magical resilience.")
	var/datum/brain_trauma/magic/lumiphobia/permanent_trauma = allocate(/datum/brain_trauma/magic/lumiphobia)
	permanent_trauma.resilience = TRAUMA_RESILIENCE_ABSOLUTE
	TEST_ASSERT_EQUAL(ipc.gain_trauma(permanent_trauma), permanent_trauma, "An IPC rejected a trauma datum with permanent resilience.")
	TEST_ASSERT_EQUAL(length(core.traumas), 2, "Persistent special traumas were not retained on the positronic core.")

/// Replacing an organic brain with a core must clean transferred injuries and their active symptoms.
/datum/unit_test/ipc_brain_trauma_species_change/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT_NOTNULL(human.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY), "Could not give the human control traumatic pacifism.")
	TEST_ASSERT_NOTNULL(human.gain_trauma(/datum/brain_trauma/severe/mute, TRAUMA_RESILIENCE_LOBOTOMY), "Could not give the human control traumatic muteness.")
	TEST_ASSERT(HAS_TRAIT(human, TRAIT_PACIFISM), "The control trauma did not apply pacifism.")
	TEST_ASSERT(HAS_TRAIT(human, TRAIT_MUTE), "The control trauma did not apply muteness.")
	var/datum/brain_trauma/persistent = human.gain_trauma(/datum/brain_trauma/special/godwoken, TRAUMA_RESILIENCE_MAGIC)
	TEST_ASSERT_NOTNULL(persistent, "Could not seed a persistent special trauma before changing species.")

	human.set_species(/datum/species/ipc)
	TEST_ASSERT(!human.has_trauma_type(/datum/brain_trauma/severe/pacifism), "An organic pacifism trauma survived conversion into an IPC.")
	TEST_ASSERT(!human.has_trauma_type(/datum/brain_trauma/severe/mute), "An organic muteness trauma survived conversion into an IPC.")
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_PACIFISM), "Organic traumatic pacifism remained active after conversion into an IPC.")
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_MUTE), "Organic traumatic muteness remained active after conversion into an IPC.")
	TEST_ASSERT(persistent in human.get_traumas(), "Conversion into an IPC erased a persistent special trauma.")

	human.set_species(/datum/species/human)
	TEST_ASSERT_NOTNULL(human.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY), "IPC brain trauma protection leaked after changing back into a human.")
	TEST_ASSERT(HAS_TRAIT(human, TRAIT_PACIFISM), "Traumatic pacifism no longer affected the restored human.")

/// Neural debugging clears legacy deep-rooted IPC errors while preserving stronger effects and other cyberbrains.
/datum/unit_test/ipc_brain_trauma_repair/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/consistent)
	ipc.set_species(/datum/species/ipc)
	var/obj/item/organ/brain/ipc/core = ipc.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/multitool/tool = allocate(/obj/item/multitool)
	var/datum/surgery_operation/organ/repair/brain/mechanic/operation = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	var/datum/brain_trauma/legacy = ipc.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_MAGIC)
	TEST_ASSERT_NOTNULL(legacy, "Could not seed the legacy trauma fixture.")
	// Older installed cores could already carry this tier; seed it through the normal on_gain path.
	legacy.resilience = TRAUMA_RESILIENCE_LOBOTOMY
	var/datum/brain_trauma/persistent = ipc.gain_trauma(/datum/brain_trauma/special/godwoken, TRAUMA_RESILIENCE_MAGIC)
	TEST_ASSERT_NOTNULL(persistent, "Could not seed a persistent special trauma for the repair control.")
	TEST_ASSERT(HAS_TRAIT(ipc, TRAIT_PACIFISM), "The legacy fixture did not apply traumatic pacifism.")
	core.set_organ_damage(20)

	UNLINT(operation.success(core, surgeon, tool, list()))
	TEST_ASSERT(!ipc.has_trauma_type(/datum/brain_trauma/severe/pacifism), "Neural debugging left a legacy deep-rooted IPC trauma.")
	TEST_ASSERT(!HAS_TRAIT(ipc, TRAIT_PACIFISM), "Neural debugging left the legacy trauma's pacifism effect active.")
	TEST_ASSERT(persistent in core.traumas, "Neural debugging erased a persistent special effect.")
	TEST_ASSERT(core.damage < 20, "Neural debugging stopped repairing physical core damage.")

	var/mob/living/carbon/human/android = allocate(/mob/living/carbon/human/consistent)
	android.set_species(/datum/species/android)
	var/obj/item/organ/brain/cybernetic/ordinary_brain = android.get_organ_slot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT_EQUAL(ordinary_brain.type, /obj/item/organ/brain/cybernetic, "The control did not receive an ordinary cybernetic brain.")
	TEST_ASSERT_NOTNULL(android.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY), "An ordinary cybernetic brain inherited IPC trauma protection.")
	UNLINT(operation.success(ordinary_brain, surgeon, tool, list()))
	TEST_ASSERT(android.has_trauma_type(/datum/brain_trauma/severe/pacifism), "IPC neural debugging changed deep-rooted trauma treatment for ordinary cybernetic brains.")
