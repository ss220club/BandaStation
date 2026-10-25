/// Both organic MMI variants must refuse an extracted incompatible brain without losing its personality.
/datum/unit_test/cybernetic_rejection_mmi/Run()
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human/consistent)
	donor.mind_initialize()
	var/datum/quirk/rejection = allocate(/datum/quirk/cybernetic_rejection)
	rejection.add_to_holder(donor)
	var/datum/mind/personality = donor.mind
	var/obj/item/organ/brain/brain = donor.get_organ_slot(ORGAN_SLOT_BRAIN)
	allocated += brain
	brain.Remove(donor)
	brain.forceMove(run_loc_floor_bottom_left)
	var/mob/living/brain/person = brain.brainmob
	TEST_ASSERT(HAS_TRAIT(brain, TRAIT_CYBERNETIC_REJECTION), "Extracting the brain lost its cybernetic incompatibility.")
	TEST_ASSERT_NOTNULL(person, "Extracting an incompatible brain lost its personality.")

	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human/consistent)
	surgeon.put_in_hands(brain)
	for(var/mmi_type in list(/obj/item/brain_processor/organic, /obj/item/brain_processor/organic/syndie))
		var/obj/item/brain_processor/organic/mmi = allocate(mmi_type)
		TEST_ASSERT_EQUAL(mmi.item_interaction(surgeon, brain), ITEM_INTERACT_BLOCKING, "[mmi_type] accepted an incompatible brain through item interaction.")
		TEST_ASSERT_EQUAL(brain.loc, surgeon, "[mmi_type] took an incompatible brain out of the surgeon's hands.")
		TEST_ASSERT(!mmi.insert_brain(brain), "[mmi_type] accepted an incompatible brain through direct insertion.")
		TEST_ASSERT_NULL(mmi.brain, "[mmi_type] retained an incompatible brain.")
		TEST_ASSERT_NULL(mmi.brainmob, "[mmi_type] took over the incompatible personality.")
		TEST_ASSERT_EQUAL(brain.brainmob, person, "[mmi_type] removed the rejected brain's personality.")
		TEST_ASSERT_EQUAL(personality.current, person, "[mmi_type] moved the rejected brain's mind.")

/// Compatibility is physiological and must be recorded even when a body has no mind.
/datum/unit_test/cybernetic_rejection_mindless_brain/Run()
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(donor, TRAIT_CYBERNETIC_REJECTION, TRAIT_GENERIC)
	var/obj/item/organ/brain/brain = donor.get_organ_slot(ORGAN_SLOT_BRAIN)
	allocated += brain
	brain.Remove(donor)
	brain.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(HAS_TRAIT(brain, TRAIT_CYBERNETIC_REJECTION), "A mindless brain lost its donor's cybernetic incompatibility.")
	var/obj/item/brain_processor/organic/mmi = allocate(/obj/item/brain_processor/organic)
	TEST_ASSERT(!mmi.insert_brain(brain), "An MMI accepted an incompatible mindless brain.")

	var/mob/living/carbon/human/recipient = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(brain.Insert(recipient, special = TRUE, movement_flags = DELETE_IF_REPLACED), "A compatible organic body rejected the organic donor brain.")
	brain.Remove(recipient)
	brain.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!HAS_TRAIT(brain, TRAIT_CYBERNETIC_REJECTION), "The extracted brain did not update compatibility for its new body.")
	TEST_ASSERT(mmi.insert_brain(brain), "An MMI rejected a brain from a compatible body.")

/// A working factory must gib incompatible victims, consume its cooldown and still convert compatible bodies.
/datum/unit_test/cybernetic_rejection_borg_factory/Run()
	var/obj/machinery/transformer/factory = allocate(/obj/machinery/transformer, get_step(run_loc_floor_bottom_left, EAST))
	factory.machine_stat = NONE
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent, get_turf(factory))
	victim.mind_initialize()
	var/datum/mind/rejected_personality = victim.mind
	ADD_TRAIT(victim, TRAIT_CYBERNETIC_REJECTION, TRAIT_GENERIC)
	factory.do_transform(victim)
	TEST_ASSERT(QDELETED(victim), "The robotic factory did not destroy an incompatible body.")
	TEST_ASSERT(factory.cooldown, "Destroying an incompatible body bypassed the factory cooldown.")
	TEST_ASSERT(!iscyborg(rejected_personality.current), "The robotic factory created a cyborg from an incompatible body.")

	factory.cooldown = FALSE
	factory.machine_stat = NONE
	var/mob/living/carbon/human/compatible_victim = allocate(/mob/living/carbon/human/consistent, get_turf(factory))
	compatible_victim.mind_initialize()
	var/datum/mind/compatible_personality = compatible_victim.mind
	factory.do_transform(compatible_victim)
	TEST_ASSERT(iscyborg(compatible_personality.current), "The robotic factory no longer converts compatible bodies.")
