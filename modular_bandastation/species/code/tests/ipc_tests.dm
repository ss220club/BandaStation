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
	TEST_ASSERT_EQUAL(human.get_organ_slot(ORGAN_SLOT_BRAIN).type, /obj/item/organ/brain, "IPC brain survived an organic species transformation.")
	TEST_ASSERT_EQUAL(human.get_organ_slot(ORGAN_SLOT_HEART).type, /obj/item/organ/heart, "IPC battery survived an organic species transformation.")
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
