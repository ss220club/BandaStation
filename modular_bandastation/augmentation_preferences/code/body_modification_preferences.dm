/datum/preference_middleware/body_modifications
	action_delegations = list(
		"apply_body_modification" = PROC_REF(apply_body_modification),
		"remove_body_modification" = PROC_REF(remove_body_modification),
	)

/// Append all of these into ui_data
/datum/preference_middleware/body_modifications/get_ui_data(mob/user)
	return preferences.body_modifications

/// Append all of these into ui_static_data
/datum/preference_middleware/body_modifications/get_ui_static_data(mob/user)
	var/list/body_modifications = get_all_body_modifications()
	var/list/data = list()
	for(var/body_modification_key in body_modifications)
		var/datum/body_modification/body_modification = body_modifications[body_modification_key]
		data += list(
			list(
				"key" = body_modification.key,
				"name" = body_modification.name,
				"description" = body_modification.get_description(),
				"cost" = body_modification.cost
			)
		)


	return data

/datum/preference_middleware/body_modifications/proc/apply_body_modification(list/params, mob/user)
	var/body_modification_key = params["body_modification_key"]
	if(!body_modification_key)
		return FALSE

	var/list/all_body_modifications = get_all_body_modifications()
	var/datum/body_modification/body_modification = all_body_modifications[body_modification_key]
	




/datum/preference_middleware/body_modifications/proc/remove_body_modification(list/params, mob/user)
	var/body_modification_key = params["body_modification_key"]
	if(!references.body_modifications[body_modification_key])
		return FALSE

	preferences.body_modifications -= body_modification_key
	return TRUE

// /// Called when a character is changed.
// /datum/preference_middleware/body_modifications/on_new_character(mob/user)
// 	return

/datum/preference_middleware/body_modifications/proc/get_all_body_modifications()
	var/static/list/body_modifications = null
	if(isnull(body_modifications))
		body_modifications = list()
		for(var/datum/body_modification/body_modification_type as anything in subtypesof(/datum/body_modification))
			if(body_modification_type == body_modification_type::abstract_type)
				continue

			var/datum/body_modification/body_modification_prototype = new body_modification_type()
			body_modifications[body_modification_prototype.key] = body_modification_prototype


	return body_modifications
