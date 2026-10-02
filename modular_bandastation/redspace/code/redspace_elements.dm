/// Per-host listener used by redspace threshold elements.
/// Elements are shared by DCS, so the field subsystem must receive a unique listener datum for every host.
/datum/redspace_threshold_listener
	var/datum/element/redspace_threshold/owner
	var/atom/target
	var/turf/listener_turf
	var/waiting_for_redspace = FALSE

/datum/redspace_threshold_listener/New(datum/element/redspace_threshold/new_owner, atom/new_target)
	. = ..()
	owner = new_owner
	target = new_target
	RegisterSignal(src, COMSIG_REDSPACE_FIELD_CHANGED, PROC_REF(on_redspace_changed))
	if(ismovable(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_moved))
	else if(isturf(target))
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleting))

/datum/redspace_threshold_listener/proc/update_registration()
	if(QDELETED(src) || !owner || !target || QDELETED(target))
		return

	if(listener_turf)
		if(SSredspace?.initialized)
			SSredspace.unregister_field_listener(src)
		UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
		listener_turf = null

	if(!SSredspace)
		return
	if(!SSredspace.initialized)
		if(!waiting_for_redspace)
			RegisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_redspace_initialized))
			waiting_for_redspace = TRUE
		return
	if(waiting_for_redspace)
		UnregisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
		waiting_for_redspace = FALSE

	var/turf/new_turf = get_turf(target)
	if(!new_turf || !SSredspace.is_supported_z(new_turf.z))
		return

	listener_turf = new_turf
	RegisterSignal(listener_turf, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	if(!SSredspace.register_field_listener(src, listener_turf))
		UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
		listener_turf = null
		return

	var/current_value = SSredspace.get_value(listener_turf)
	if(!isnull(current_value) && current_value < owner.threshold)
		owner.on_threshold_reached(target, src)

/datum/redspace_threshold_listener/proc/on_redspace_initialized(datum/source)
	SIGNAL_HANDLER
	if(source != SSredspace)
		return
	update_registration()

/datum/redspace_threshold_listener/proc/on_redspace_changed(datum/source, datum/redspace_field_cell/cell, old_value, new_value, old_state, new_state, reason)
	SIGNAL_HANDLER
	if(!owner || !target || QDELETED(target) || isnull(new_value))
		return
	if(new_value < owner.threshold)
		owner.on_threshold_reached(target, src)

/datum/redspace_threshold_listener/proc/on_target_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(source != target)
		return
	update_registration()

/datum/redspace_threshold_listener/proc/on_target_deleting(turf/source)
	SIGNAL_HANDLER
	if(source != target || source.changing_turf)
		return
	owner.Detach(source)

/datum/redspace_threshold_listener/proc/on_turf_change(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	if(changed != listener_turf)
		return
	post_change_callbacks += CALLBACK(src, PROC_REF(on_turf_replaced))

/datum/redspace_threshold_listener/proc/on_turf_replaced(turf/new_turf)
	if(QDELETED(src) || !new_turf)
		return
	if(isturf(target))
		target = new_turf
	update_registration()

/datum/redspace_threshold_listener/Destroy()
	if(SSredspace?.initialized)
		SSredspace.unregister_field_listener(src)
	if(listener_turf)
		UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
	if(ismovable(target))
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	else if(isturf(target))
		UnregisterSignal(target, COMSIG_QDELETING)
	UnregisterSignal(src, COMSIG_REDSPACE_FIELD_CHANGED)
	if(waiting_for_redspace && SSredspace)
		UnregisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	waiting_for_redspace = FALSE
	owner = null
	target = null
	listener_turf = null
	return ..()

/// Shared redspace threshold logic. One DCS element can serve many hosts through per-host listeners.
/datum/element/redspace_threshold
	abstract_type = /datum/element/redspace_threshold
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/threshold
	var/list/target_listeners = list()

/datum/element/redspace_threshold/Attach(atom/target, threshold)
	if(!isatom(target) || isarea(target) || !isnum(threshold))
		return ELEMENT_INCOMPATIBLE
	if(find_target_listener(target))
		return
	. = ..()
	src.threshold = threshold
	var/datum/redspace_threshold_listener/listener = new(src, target)
	target_listeners += listener
	listener.update_registration()

/datum/element/redspace_threshold/proc/find_target_listener(atom/target) as /datum/redspace_threshold_listener
	for(var/datum/redspace_threshold_listener/listener as anything in target_listeners)
		if(listener?.target == target)
			return listener

/datum/element/redspace_threshold/Detach(atom/source, ...)
	var/datum/redspace_threshold_listener/listener = find_target_listener(source)
	if(listener)
		target_listeners -= listener
		qdel(listener)
	return ..()

/datum/element/redspace_threshold/proc/on_threshold_reached(atom/target, datum/redspace_threshold_listener/listener)
	return

/datum/element/redspace_threshold/Destroy(force)
	if(!force)
		return ..()
	for(var/datum/redspace_threshold_listener/listener as anything in target_listeners.Copy())
		qdel(listener)
	target_listeners.Cut()
	return ..()

/// Deletes a movable atom once its current turf falls below the configured value.
/datum/element/redspace_threshold/delete_below
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2

/datum/element/redspace_threshold/delete_below/Attach(atom/movable/target, threshold)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	return ..()

/datum/element/redspace_threshold/delete_below/on_threshold_reached(atom/target, datum/redspace_threshold_listener/listener)
	if(target && !QDELETED(target))
		qdel(target)

/// Restores a turf type when its current redspace value falls below the configured value.
/// The previous type must be captured before the spawning event changes the turf.
/datum/element/redspace_threshold/revert_turf_below
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/turf/restore_turf_type
	var/list/restore_baseturfs

/datum/element/redspace_threshold/revert_turf_below/Attach(turf/target, threshold, turf/restore_turf_type, list/restore_baseturfs = null)
	if(!isturf(target) || !isnum(threshold) || !ispath(restore_turf_type, /turf))
		return ELEMENT_INCOMPATIBLE
	src.restore_turf_type = restore_turf_type
	src.restore_baseturfs = restore_baseturfs
	return ..()

/datum/element/redspace_threshold/revert_turf_below/on_threshold_reached(turf/target, datum/redspace_threshold_listener/listener)
	if(!target || QDELETED(target) || !restore_turf_type || target.type == restore_turf_type)
		return

	if(restore_baseturfs)
		target.RemoveElement(type, threshold, restore_turf_type, restore_baseturfs)
	else
		target.RemoveElement(type, threshold, restore_turf_type)
	target.ChangeTurf(restore_turf_type, restore_baseturfs ? restore_baseturfs.Copy() : null, CHANGETURF_FORCEOP)
