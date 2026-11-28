/// Shared body ownership for the Devourer and its transformed demons.
/mob/living/basic/demon/redspace
	var/mob/living/carbon/human/stored_victim

/// Containment owns only this stasis source; unrelated stasis remains untouched.
/mob/living/basic/demon/redspace/proc/contain_victim(mob/living/carbon/human/victim)
	if(stored_victim || QDELETED(victim))
		return FALSE
	stored_victim = victim
	RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_stored_victim_deleted))
	victim.apply_status_effect(/datum/status_effect/grouped/stasis, REDSPACE_DEVOURER_STASIS)
	if(!victim.forceMove(src) || QDELETED(victim) || victim.loc != src)
		detach_stored_victim()
		return FALSE
	return TRUE

/// Transfer can retain stasis while changing its owner. All other exits end it.
/mob/living/basic/demon/redspace/proc/detach_stored_victim(keep_stasis = FALSE)
	var/mob/living/carbon/human/victim = stored_victim
	stored_victim = null
	if(!victim)
		return
	UnregisterSignal(victim, COMSIG_QDELETING)
	if(!QDELETED(victim) && !keep_stasis)
		victim.remove_status_effect(/datum/status_effect/grouped/stasis, REDSPACE_DEVOURER_STASIS)
	return victim

/mob/living/basic/demon/redspace/proc/release_stored_victim()
	var/mob/living/carbon/human/victim = detach_stored_victim()
	if(!QDELETED(victim) && victim.loc == src)
		victim.forceMove(get_turf(src))

/mob/living/basic/demon/redspace/proc/transfer_stored_victim(mob/living/basic/demon/redspace/new_owner)
	var/mob/living/carbon/human/victim = detach_stored_victim(keep_stasis = TRUE)
	if(QDELETED(victim))
		return
	if(victim.loc == src && new_owner.contain_victim(victim))
		return
	victim.remove_status_effect(/datum/status_effect/grouped/stasis, REDSPACE_DEVOURER_STASIS)
	if(victim.loc == src)
		victim.forceMove(get_turf(src))

/mob/living/basic/demon/redspace/proc/on_stored_victim_deleted(mob/living/carbon/human/victim)
	SIGNAL_HANDLER
	if(victim == stored_victim)
		detach_stored_victim()

/mob/living/basic/demon/redspace/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == stored_victim)
		detach_stored_victim()

/mob/living/basic/demon/redspace/Destroy()
	release_stored_victim()
	return ..()
