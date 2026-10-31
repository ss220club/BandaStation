/// Shared turf subscription lifecycle. The caller chooses the turf (including
/// whether a contained item can observe) and handles movement/gameplay effects.
/// The callback asks the caller to resample after initialization or ChangeTurf;
/// it receives the replacement turf, or null after subsystem initialization.
/datum/redspace_field_observer
	var/datum/listener
	var/datum/callback/resample_callback
	var/turf/listener_turf
	var/waiting_for_redspace = FALSE

/datum/redspace_field_observer/New(datum/new_listener, datum/callback/new_callback)
	. = ..()
	listener = new_listener
	resample_callback = new_callback

/datum/redspace_field_observer/Destroy()
	clear_registration()
	if(waiting_for_redspace && SSredspace)
		UnregisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	waiting_for_redspace = FALSE
	listener = null
	resample_callback = null
	return ..()

/datum/redspace_field_observer/proc/clear_registration()
	if(SSredspace)
		SSredspace.unregister_field_listener(listener)
	if(listener_turf)
		UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
	listener_turf = null

/// Returns whether the listener is registered at this exact point.
/datum/redspace_field_observer/proc/update_registration(turf/new_turf)
	if(!listener || QDELETED(listener) || !SSredspace)
		clear_registration()
		return FALSE
	if(!SSredspace.initialized)
		clear_registration()
		if(!waiting_for_redspace)
			RegisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_redspace_initialized))
			waiting_for_redspace = TRUE
		return FALSE
	if(waiting_for_redspace)
		UnregisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
		waiting_for_redspace = FALSE
	if(!SSredspace.move_field_listener(listener, new_turf))
		clear_registration()
		return FALSE
	if(listener_turf != new_turf)
		if(listener_turf)
			UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
		listener_turf = new_turf
		RegisterSignal(listener_turf, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	return TRUE

/datum/redspace_field_observer/proc/on_redspace_initialized(datum/source)
	SIGNAL_HANDLER
	if(source == SSredspace && listener && !QDELETED(listener))
		resample_callback.Invoke(null)

/datum/redspace_field_observer/proc/on_turf_change(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	if(changed == listener_turf)
		post_change_callbacks += CALLBACK(src, PROC_REF(on_turf_replaced))

/datum/redspace_field_observer/proc/on_turf_replaced(turf/new_turf)
	if(!QDELETED(src) && listener && !QDELETED(listener) && new_turf)
		resample_callback.Invoke(new_turf)
