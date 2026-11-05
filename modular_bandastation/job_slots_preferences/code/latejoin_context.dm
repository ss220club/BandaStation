/// Routing settings that must stay unchanged while a latejoin menu or request yields.
/// This deliberately does not freeze the contents of a saved or edited character profile.
/datum/latejoin_profile_snapshot
	var/datum/preferences/preferences
	var/editing_slot
	var/list/assigned_slots
	var/use_current_slot
	/// Only UI rendering freezes character contents; spawn requests recheck their selected body.
	var/character_revision

/// Capture one job, or the whole menu, without retaining the mutable assignment map.
/datum/preferences/proc/capture_latejoin_profile(job_title = null)
	var/datum/latejoin_profile_snapshot/context = new
	context.preferences = src
	context.editing_slot = default_slot
	context.assigned_slots = list()
	if(istext(job_title))
		context.assigned_slots[job_title] = pref_job_slots?[job_title]
	else if(islist(pref_job_slots))
		context.assigned_slots = pref_job_slots.Copy()
	context.use_current_slot = read_preference(/datum/preference/toggle/late_join_always_current_slot)
	return context

/// A selected job depends on its own assignment; menu rows depend on every assignment.
/datum/preferences/proc/is_latejoin_profile_current(job_title, datum/latejoin_profile_snapshot/context)
	if(!istype(context) || QDELETED(context) || context.preferences != src || context.editing_slot != default_slot)
		return FALSE
	if(context.use_current_slot != read_preference(/datum/preference/toggle/late_join_always_current_slot))
		return FALSE
	if(!isnull(context.character_revision) && context.character_revision != character_preferences_revision)
		return FALSE
	if(context.use_current_slot)
		return TRUE
	var/list/assigned_slots = context.assigned_slots
	if(!islist(assigned_slots))
		return FALSE
	var/list/current_slots = islist(pref_job_slots) ? pref_job_slots : list()
	if(istext(job_title))
		return assigned_slots[job_title] == current_slots[job_title]
	if(length(assigned_slots) != length(current_slots))
		return FALSE
	for(var/title in assigned_slots)
		if(!(title in current_slots) || assigned_slots[title] != current_slots[title])
			return FALSE
	return TRUE
