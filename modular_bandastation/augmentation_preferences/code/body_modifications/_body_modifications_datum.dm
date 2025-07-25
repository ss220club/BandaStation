GLOBAL_LIST_INIT_TYPED(body_modifications, /datum/body_modification, init_body_modifications())

/datum/body_modification
	/// The abstract type of this body modification
	var/abstract_type = /datum/body_modification
	/// The key used to identify this body modification
	var/key = null
	/// The name of this body modification
	var/name = null
	/// Cost in quirk points of thisbody modification
	var/cost = 0
	/// The list of body modifications incompatible with this body modification
	var/list/incompatible_body_modifications = list()
	var/category = null

/datum/body_modification/New()
	..()
	if(isnull(key))
		stack_trace("body modification without key: [type]")

	if(abstract_type == type)
		stack_trace("abstract body modification attempted to be instantiated: [type]")
		qdel(src)

/// Apply this set of body modifications to the given mob
/datum/body_modification/proc/apply_to_human(mob/living/carbon/target)
	SHOULD_CALL_PARENT(TRUE)

	return can_be_applied(target)

/// Returns TRUE if this body modification can be applied
/datum/body_modification/proc/can_be_applied(mob/living/carbon/target)
	SHOULD_CALL_PARENT(TRUE)

	if(isnull(target))
		return FALSE

	var/list/applied_body_modifications = target.client?.prefs?.read_preference(/datum/preference/body_modifications)
	if(length(applied_body_modifications) == 0)
		return TRUE

	for(var/incompatible_body_modification in incompatible_body_modifications)
		if(incompatible_body_modification in applied_body_modifications)
			return FALSE

	return TRUE

/// Returns the list of body modifications incompatible with this body modification
/datum/body_modification/proc/get_conflicting_body_modifications(mob/living/carbon/target)
	return incompatible_body_modifications & target.client?.prefs?.read_preference(/datum/preference/body_modifications)

/datum/body_modification/proc/get_description()
	return "No description yet"

/proc/init_body_modifications()
	var/list/body_modifications = list()
	for(var/datum/body_modification/body_modification_type as anything in subtypesof(/datum/body_modification))
		if(body_modification_type == body_modification_type::abstract_type)
			continue

		body_modifications[body_modification_type::key] = new body_modification_type()

	return body_modifications
