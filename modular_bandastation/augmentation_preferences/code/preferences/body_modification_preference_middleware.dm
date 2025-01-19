/datum/preference_middleware/body_modifications
	action_delegations = list(
		"apply_body_modification" = PROC_REF(apply_body_modification),
		"remove_body_modification" = PROC_REF(remove_body_modification),
	)

/// Append all of these into ui_data
/datum/preference_middleware/body_modifications/get_ui_data(mob/user)
	var/list/data = list()
	data["applied_body_modifications"] = get_applied_body_modifications()
	data["incomptable_body_modifications"] = get_incomptable_body_modifications(user)
	return data

/// Append all of these into ui_static_data
/datum/preference_middleware/body_modifications/get_constant_data(mob/user)
	var/list/data = list()
	for(var/body_modification_key in GLOB.body_modifications)
		var/datum/body_modification/body_modification = GLOB.body_modifications[body_modification_key]
		data += list(
			list(
				"key" = body_modification.key,
				"name" = body_modification.name,
				"description" = body_modification.get_description(),
				"cost" = body_modification.cost
			)
		)

	return data

/datum/preference_middleware/body_modifications/proc/get_applied_body_modifications()
	PRIVATE_PROC(TRUE)

	var/list/applied_body_modifications = preferences.read_preference(/datum/preference/body_modifications)
	var/list/modifications = list()
	for(var/body_modification_key in applied_body_modifications)
		modifications += body_modification_key

	return modifications

/datum/preference_middleware/body_modifications/proc/get_incomptable_body_modifications(mob/user)
	PRIVATE_PROC(TRUE)

	var/list/incompatible_body_modifications = list()
	for(var/body_modification_key in GLOB.body_modifications)
		if(GLOB.body_modifications[body_modification_key].can_be_applied(user))
			continue

		incompatible_body_modifications += body_modification_key

	return incompatible_body_modifications

/datum/preference_middleware/body_modifications/proc/apply_body_modification(list/params, mob/user)
	var/body_modification_key = params["body_modification_key"]
	if(!body_modification_key)
		return FALSE

	var/datum/body_modification/body_modification_prototype = GLOB.body_modifications[body_modification_key]
	if(isnull(body_modification_prototype) || !body_modification_prototype.can_be_applied(user))
		return FALSE

	var/list/body_modifications = preferences.read_preference(/datum/preference/body_modifications)
	if(body_modifications[body_modification_key])
		return FALSE

	body_modifications[body_modification_key] = TRUE
	preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], body_modifications)
	return TRUE

/datum/preference_middleware/body_modifications/proc/remove_body_modification(list/params, mob/user)
	var/body_modification_key = params["body_modification_key"]
	if(!body_modification_key)
		return FALSE

	var/list/body_modifications = preferences.read_preference(/datum/preference/body_modifications)
	if(!body_modifications[body_modification_key])
		return FALSE

	body_modifications -= body_modification_key
	preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], body_modifications)
	return TRUE
