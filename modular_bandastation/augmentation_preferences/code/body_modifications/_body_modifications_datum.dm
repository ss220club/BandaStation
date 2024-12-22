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

/datum/body_modification/New()
	..()
	if(abstract_type == type)
		stack_trace("cannot create body modification [type] with abstract type [abstract_type]")
		qdel(src)

/// Apply this set of body modifications to the given mob
/datum/body_modification/proc/apply_to_carbon(mob/living/carbon/target)
	SHOULD_CALL_PARENT(TRUE)

	return can_be_applied()

/// Remove this set of body modifications from the given mob
/datum/body_modification/proc/remove_from_carbon(mob/living/carbon/target)
	return TRUE

/// Returns TRUE if the preview should be updated
/datum/body_modification/proc/should_update_preview(mob/living/carbon/target)
	return TRUE

/// Returns TRUE if this body modification can be applied
/datum/body_modification/proc/can_be_applied(mob/living/carbon/target)
	SHOULD_CALL_PARENT(TRUE)

	return !isnull(target) && length(incompatible_body_modifications && target.client?.prefs?.body_modifications)

/// Returns the list of body modifications incompatible with this body modification
/datum/body_modification/proc/get_conflicting_body_modifications(mob/living/carbon/target)
	return incompatible_body_modifications && target.client?.prefs?.body_modifications

/datum/body_modification/proc/get_description()
	return null
