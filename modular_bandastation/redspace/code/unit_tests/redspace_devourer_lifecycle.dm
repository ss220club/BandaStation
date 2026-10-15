#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Synchronous hooks exercise continuations after the poll or retreat changes state.
/mob/living/basic/demon/redspace/devourer/unit_test_lifecycle
	var/datum/callback/continuation_hook
	var/mob/dead/observer/poll_candidate
	var/poll_calls = 0

/mob/living/basic/demon/redspace/devourer/unit_test_lifecycle/choose_ravager_ghost()
	poll_calls++
	continuation_hook?.Invoke()
	return poll_candidate

/mob/living/basic/demon/redspace/devourer/unit_test_lifecycle/devourer_retreat_step(turf/destination, list/visited, turf/previous_turf)
	if(continuation_hook)
		continuation_hook.Invoke()
		return TRUE
	return ..()

/datum/unit_test/redspace_devourer_lifecycle
	abstract_type = /datum/unit_test/redspace_devourer_lifecycle
	var/mob/living/basic/demon/redspace/devourer/unit_test_lifecycle/devourer
	var/mob/living/carbon/human/victim
	var/mob/living/carbon/human/new_victim

/datum/unit_test/redspace_devourer_lifecycle/New()
	. = ..()
	devourer = allocate(/mob/living/basic/demon/redspace/devourer/unit_test_lifecycle)
	victim = allocate(/mob/living/carbon/human)
	victim.stat = HARD_CRIT

/datum/unit_test/redspace_devourer_lifecycle/Destroy()
	// A possessed replacement may survive a failed assertion; never retain a test key.
	for(var/mob/test_mob in allocated)
		test_mob.ckey = null
	return ..()

/datum/unit_test/redspace_devourer_lifecycle/proc/recapture()
	devourer.release_victim()
	new_victim = allocate(/mob/living/carbon/human)
	new_victim.stat = HARD_CRIT
	if(!devourer.capture_victim(new_victim))
		Fail("A newer operation must capture its own body")
	devourer.start_transformation_countdown()

/datum/unit_test/redspace_devourer_lifecycle/stages

/datum/unit_test/redspace_devourer_lifecycle/stages/Run()
	devourer.set_devour_stage(REDSPACE_DEVOURER_DEVOURING)
	var/capture_operation = devourer.devour_operation_id
	if(!devourer.can_finish_devour(victim, capture_operation) || !devourer.capture_victim(victim))
		return Fail("The active capture operation must accept its adjacent victim")
	if(devourer.devour_stage != REDSPACE_DEVOURER_CAPTURED || !devourer.can_transform() || devourer.capture_victim(victim) || devourer.can_finish_devour(victim, capture_operation))
		return Fail("Successful capture must commit once and invalidate the devour continuation")
	var/datum/component/redspace_energy/energy = devourer.GetComponent(/datum/component/redspace_energy)
	if(!HAS_TRAIT(devourer, TRAIT_IMMOBILIZED) || energy.zero_energy_damage_percent || devourer.icon_state != "Devourer-closed")
		return Fail("Committed stages must retain their immobilization, sprite and starvation protection")
	devourer.start_transformation_countdown()
	var/old_operation = devourer.devour_operation_id
	var/old_timer = devourer.transformation_timer_id
	devourer.start_transformation_countdown()
	var/current_timer = devourer.transformation_timer_id
	devourer.begin_transformation(old_operation)
	if(devourer.devour_stage != REDSPACE_DEVOURER_WAITING || !current_timer || current_timer == old_timer || devourer.transformation_timer_id != current_timer || devourer.poll_calls)
		return Fail("Replacing the countdown must cancel the old timer and reject its callback")
	devourer.release_victim()
	devourer.begin_transformation(old_operation)
	if(devourer.devour_stage != REDSPACE_DEVOURER_IDLE || devourer.transformation_timer_id || devourer.transformation_target || devourer.can_transform() || HAS_TRAIT(devourer, TRAIT_IMMOBILIZED) || HAS_TRAIT(victim, TRAIT_STASIS) || victim.loc != run_loc_floor_bottom_left || energy.zero_energy_damage_percent != devourer.redspace_zero_energy_damage_percent || devourer.icon_state != devourer.icon_living)
		return Fail("Release must reset the operation, timer, body and stage effects")

/datum/unit_test/redspace_devourer_lifecycle/poll_no_volunteer

/datum/unit_test/redspace_devourer_lifecycle/poll_no_volunteer/Run()
	if(!devourer.capture_victim(victim))
		return Fail("The poll test must capture its victim")
	devourer.set_devour_stage(REDSPACE_DEVOURER_POLLING)
	var/mob/living/basic/demon/redspace/moderate/transformed = devourer.poll_for_ravager(devourer.devour_operation_id)
	if(transformed)
		allocated += transformed
	if(!istype(transformed, /mob/living/basic/demon/redspace/moderate/minotaur) || !QDELETED(devourer) || devourer.poll_calls != 1 || transformed.stored_victim != victim || victim.loc != transformed || !HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("A completed poll without a volunteer must produce one Minotaur carrying the body")

/datum/unit_test/redspace_devourer_lifecycle/poll_volunteer

/datum/unit_test/redspace_devourer_lifecycle/poll_volunteer/Run()
	if(!devourer.capture_victim(victim))
		return Fail("The volunteer test must capture its victim")
	devourer.poll_candidate = allocate(/mob/dead/observer)
	devourer.poll_candidate.key = "redspace_lifecycle_volunteer"
	devourer.set_devour_stage(REDSPACE_DEVOURER_POLLING)
	var/mob/living/basic/demon/redspace/moderate/transformed = devourer.poll_for_ravager(devourer.devour_operation_id)
	if(transformed)
		allocated += transformed
	if(!istype(transformed, /mob/living/basic/demon/redspace/moderate/ravager) || transformed.ckey != ckey("redspace_lifecycle_volunteer") || transformed.stored_victim != victim || !QDELETED(devourer))
		return Fail("The current volunteer must control the Ravager and retain the captured body")
	transformed.ckey = null

/datum/unit_test/redspace_devourer_lifecycle/stale_poll

/datum/unit_test/redspace_devourer_lifecycle/stale_poll/Run()
	if(!devourer.capture_victim(victim))
		return Fail("The stale poll test must capture its first victim")
	devourer.set_devour_stage(REDSPACE_DEVOURER_POLLING)
	var/old_operation = devourer.devour_operation_id
	devourer.continuation_hook = CALLBACK(src, PROC_REF(recapture))
	if(devourer.poll_for_ravager(old_operation) || QDELETED(devourer) || devourer.devour_stage != REDSPACE_DEVOURER_WAITING || devourer.stored_victim != new_victim || !devourer.transformation_timer_id || HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("A poll result must not transform or release a newer capture")
	devourer.poll_for_ravager(old_operation)
	if(devourer.poll_calls != 1)
		return Fail("An obsolete queued poll must not start another ghost query")

/datum/unit_test/redspace_devourer_lifecycle/stale_retreat

/datum/unit_test/redspace_devourer_lifecycle/stale_retreat/Run()
	if(!devourer.capture_victim(victim))
		return Fail("The stale retreat test must capture its first victim")
	devourer.continuation_hook = CALLBACK(src, PROC_REF(recapture))
	devourer.walk_direct_to_transformation_site(run_loc_floor_top_right)
	if(devourer.devour_stage != REDSPACE_DEVOURER_WAITING || devourer.stored_victim != new_victim || devourer.transformation_target || !devourer.transformation_timer_id || HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("An interrupted retreat must leave the newer operation and its countdown intact")

/datum/unit_test/redspace_devourer_lifecycle/retreat_complete

/datum/unit_test/redspace_devourer_lifecycle/retreat_complete/Run()
	if(!devourer.capture_victim(victim))
		return Fail("Retreat must begin with a captured body")
	devourer.walk_direct_to_transformation_site(run_loc_floor_bottom_left)
	if(devourer.devour_stage != REDSPACE_DEVOURER_WAITING || !devourer.transformation_timer_id || devourer.transformation_target || HAS_TRAIT(devourer, TRAIT_IMMOBILIZED) || !HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("Completed retreat must start one countdown and preserve its existing movement policy")

/datum/unit_test/redspace_devourer_lifecycle/body_exits

/datum/unit_test/redspace_devourer_lifecycle/body_exits/Run()
	if(!devourer.capture_victim(victim))
		return Fail("The external move test must capture its victim")
	devourer.start_transformation_countdown()
	var/operation_id = devourer.devour_operation_id
	victim.forceMove(run_loc_floor_top_right)
	if(devourer.stored_victim || HAS_TRAIT(victim, TRAIT_STASIS) || HAS_TRAIT(devourer, TRAIT_IMMOBILIZED) || !devourer.can_transform() || devourer.devour_operation_id != operation_id || !devourer.transformation_timer_id)
		return Fail("External body movement must end containment without cancelling a committed transformation")
	var/mob/living/basic/demon/redspace/moderate/transformed = devourer.transform_with_minotaur()
	if(transformed)
		allocated += transformed
	if(!transformed || transformed.stored_victim || victim.loc != run_loc_floor_top_right || !QDELETED(devourer) || devourer.transformation_timer_id)
		return Fail("A transformation without its moved body must not reclaim or immobilize that body")

/datum/unit_test/redspace_devourer_lifecycle/cleanup

/datum/unit_test/redspace_devourer_lifecycle/cleanup/Run()
	for(var/delete_demon in list(FALSE, TRUE))
		var/mob/living/basic/demon/redspace/devourer/subject = allocate(/mob/living/basic/demon/redspace/devourer)
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
		body.stat = HARD_CRIT
		if(!subject.capture_victim(body))
			return Fail("Cleanup must begin with a contained body")
		subject.start_transformation_countdown()
		if(delete_demon)
			qdel(subject)
		else
			subject.death()
		if(subject.transformation_timer_id || subject.transformation_target || subject.can_transform() || subject.stored_victim || HAS_TRAIT(body, TRAIT_STASIS) || body.loc != run_loc_floor_bottom_left)
			return Fail("Death and deletion during the countdown must cancel work and release the body")

/datum/unit_test/redspace_devourer_lifecycle/stasis_ownership

/datum/unit_test/redspace_devourer_lifecycle/stasis_ownership/Run()
	victim.apply_status_effect(/datum/status_effect/grouped/stasis, "unrelated_unit_test_stasis")
	if(!devourer.capture_victim(victim))
		return Fail("Containment must accept a victim with an unrelated stasis source")
	var/mob/living/basic/demon/redspace/moderate/transformed = devourer.transform_with_minotaur()
	if(transformed)
		allocated += transformed
	if(!transformed || victim.loc != transformed || !HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("Body transfer must preserve stasis while changing its owner")
	victim.forceMove(run_loc_floor_top_right)
	if(transformed.stored_victim || !HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("A transformed demon must detach a moved body without removing unrelated stasis")
	victim.remove_status_effect(/datum/status_effect/grouped/stasis, "unrelated_unit_test_stasis")
	if(HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("External movement must remove the containment stasis source")

/datum/unit_test/redspace_devourer_lifecycle/poll_cancelled
	var/delete_demon = FALSE

/datum/unit_test/redspace_devourer_lifecycle/poll_cancelled/proc/cancel_poll()
	if(delete_demon)
		qdel(devourer)
	else
		devourer.death()

/datum/unit_test/redspace_devourer_lifecycle/poll_cancelled/Run()
	if(!devourer.capture_victim(victim))
		return Fail("The cancelled poll must begin with a captured body")
	devourer.set_devour_stage(REDSPACE_DEVOURER_POLLING)
	devourer.continuation_hook = CALLBACK(src, PROC_REF(cancel_poll))
	if(devourer.poll_for_ravager(devourer.devour_operation_id) || devourer.can_transform() || devourer.transformation_timer_id || devourer.stored_victim || HAS_TRAIT(victim, TRAIT_STASIS) || victim.loc != run_loc_floor_bottom_left)
		return Fail("Death or deletion during a poll must release the body and reject the returned result")

/datum/unit_test/redspace_devourer_lifecycle/poll_cancelled/deleted
	delete_demon = TRUE

/datum/unit_test/redspace_devourer_lifecycle/retry

/datum/unit_test/redspace_devourer_lifecycle/retry/Run()
	if(!devourer.capture_victim(victim))
		return Fail("The retry test must capture its victim")
	devourer.start_transformation_countdown()
	var/old_operation = devourer.devour_operation_id
	devourer.moveToNullspace()
	if(devourer.transform_with_minotaur() || devourer.devour_stage != REDSPACE_DEVOURER_WAITING || !devourer.transformation_timer_id || devourer.stored_victim != victim || !HAS_TRAIT(victim, TRAIT_STASIS))
		return Fail("A missing transformation turf must replace the old countdown with one retry and keep the body")
	var/retry_operation = devourer.devour_operation_id
	devourer.forceMove(run_loc_floor_bottom_left)
	devourer.begin_transformation(old_operation)
	if(devourer.devour_operation_id != retry_operation || devourer.poll_calls)
		return Fail("The old deadline must not start the retry's poll")
	var/mob/living/basic/demon/redspace/moderate/transformed = devourer.transform_with_minotaur()
	if(transformed)
		allocated += transformed
	if(!transformed || transformed.stored_victim != victim || !QDELETED(devourer) || devourer.transformation_timer_id)
		return Fail("The retry must transform normally after returning to a turf")

#endif
