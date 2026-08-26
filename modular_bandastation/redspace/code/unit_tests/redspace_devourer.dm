#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_devourer

/datum/unit_test/redspace_devourer/Run()
	var/mob/living/basic/demon/redspace/devourer/devourer = allocate(/mob/living/basic/demon/redspace/devourer)
	if(devourer.name != "redspace devourer" || devourer.icon != 'modular_bandastation/redspace/icons/mob/demonic/moderate_demons/64x64.dmi' || devourer.icon_state != "Devourer" || devourer.icon_dead != "Devourer-closed")
		return Fail("The Devourer must use its dedicated sprite and localized English name key")
	if(devourer.speed != 2 || devourer.move_force != MOVE_FORCE_OVERPOWERING || devourer.move_resist != INFINITY || devourer.pull_force != MOVE_FORCE_OVERPOWERING || devourer.can_be_pulled(null, INFINITY))
		return Fail("The Devourer must be slow and immune to normal pushing and pulling")
	if(devourer.devour_delay != 5 SECONDS || devourer.transformation_delay != 2 MINUTES)
		return Fail("The Devourer must expose the configured devour and transformation delays")
	if(!istype(devourer.ai_controller, /datum/ai_controller/basic_controller/simple/redspace_demon/melee/devourer))
		return Fail("The Devourer must use the specialized redspace melee controller")
	if(devourer.ai_controller.blackboard[BB_TARGETING_STRATEGY] != /datum/targeting_strategy/basic/redspace_demon/devourer || devourer.ai_controller.blackboard[BB_TARGET_PRIORITY_STRATEGY] != /datum/target_priority_strategy/nearest)
		return Fail("The Devourer AI must search for nearby targets with its restricted targeting strategy")

	var/mob/living/carbon/human/incapacitated = allocate(/mob/living/carbon/human)
	incapacitated.mind_initialize()
	ADD_TRAIT(incapacitated, TRAIT_INCAPACITATED, REF(src))
	var/datum/targeting_strategy/basic/redspace_demon/devourer/targeting = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/redspace_demon/devourer)
	if(!targeting.is_valid_target(devourer, incapacitated, 9) || !targeting.can_keep_target(devourer, incapacitated, 16))
		return Fail("The Devourer must accept living minded incapacitated humans and retain them through cover")

	var/mob/living/carbon/human/conscious = allocate(/mob/living/carbon/human)
	conscious.mind_initialize()
	if(targeting.is_valid_target(devourer, conscious, 9) || redspace_devourer_can_consume(conscious))
		return Fail("The Devourer must not target conscious humans")

	var/mob/living/carbon/human/mindless = allocate(/mob/living/carbon/human)
	ADD_TRAIT(mindless, TRAIT_INCAPACITATED, REF(src))
	if(redspace_devourer_can_consume(mindless))
		return Fail("The Devourer must not target incapacitated humans without a mind")

	var/mob/living/carbon/human/dead = allocate(/mob/living/carbon/human)
	dead.mind_initialize()
	dead.stat = DEAD
	ADD_TRAIT(dead, TRAIT_INCAPACITATED, REF(src))
	if(redspace_devourer_can_consume(dead))
		return Fail("The Devourer must not target dead humans")

	var/mob/living/basic/demon/redspace/devourer/capture_devourer = allocate(/mob/living/basic/demon/redspace/devourer)
	var/mob/living/carbon/human/capture_victim = allocate(/mob/living/carbon/human)
	capture_victim.mind_initialize()
	ADD_TRAIT(capture_victim, TRAIT_INCAPACITATED, REF(src))
	if(!capture_devourer.capture_victim(capture_victim) || capture_victim.loc != capture_devourer || capture_devourer.stored_victim != capture_victim || !HAS_TRAIT(capture_victim, TRAIT_STASIS))
		return Fail("A successful capture must move the victim into stasis inside the Devourer")
	capture_devourer.release_victim()
	if(capture_devourer.stored_victim || capture_victim.loc == capture_devourer || HAS_TRAIT(capture_victim, TRAIT_STASIS))
		return Fail("Releasing a captured victim must clear containment and stasis")

	var/mob/living/basic/demon/redspace/devourer/transform_devourer = allocate(/mob/living/basic/demon/redspace/devourer)
	var/mob/living/carbon/human/transform_victim = allocate(/mob/living/carbon/human)
	transform_victim.mind_initialize()
	ADD_TRAIT(transform_victim, TRAIT_INCAPACITATED, REF(src))
	var/datum/mind/victim_mind = transform_victim.mind
	if(!transform_devourer.capture_victim(transform_victim))
		return Fail("The Devourer must be able to capture a valid transformation victim")
	var/mob/living/basic/demon/redspace/moderate/minotaur/transformed = transform_devourer.transform_with_victim()
	if(!transformed || QDELETED(transformed) || transformed.mind != victim_mind || victim_mind.current != transformed)
		if(transformed)
			qdel(transformed)
		return Fail("Transformation must create a minotaur controlled by the victim's mind")
	qdel(transformed)

	var/datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer/devourer_event = new
	if(devourer_event.event_id != "demonic_devourer" || devourer_event.profile_id != REDSPACE_PROFILE_DEMONIC || devourer_event.spawn_type != /mob/living/basic/demon/redspace/devourer || !devourer_event.automatic || devourer_event.weight != 1 || devourer_event.get_spawn_budget_cost() != 3 || devourer_event.spawn_policy_id != "demonic_devourer")
		return Fail("The Devourer must expose the configured automatic spawn event metadata")
	if(!SSredspace || SSredspace.event_registry["demonic_devourer"] != /datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer)
		return Fail("The Devourer spawn must be registered in SSredspace")
	var/datum/redspace_profile/demonic/profile = new
	if(!profile.is_event_allowed("demonic_devourer") || profile.get_event_profile(REDSPACE_STATE_STORM).get_event_weight("demonic_devourer") != 1)
		return Fail("The demonic profile must expose the Devourer in its storm event pool")
	qdel(profile)
	qdel(devourer_event)

#endif
