/datum/preference_middleware/body_modifications
	action_delegations = list(
		"apply_body_modification" = PROC_REF(apply_body_modification),
		"remove_body_modification" = PROC_REF(remove_body_modification),
		"set_body_modification_manufacturer" = PROC_REF(set_body_modification_manufacturer),
	)

/datum/preference_middleware/body_modifications/get_ui_data(mob/user)
	var/list/data = list()
	data["applied_body_modifications"] = get_applied_body_modifications()
	data["incompatible_body_modifications"] = get_incompatible_body_modifications(user)
	data["manufacturers"] = get_prosthesis_manufacturers()
	data["selected_manufacturer"] = get_selected_manufacturers(user)
	return data

/datum/preference_middleware/body_modifications/get_constant_data(mob/user)
	var/list/data = list()
	for(var/body_modification_key in GLOB.body_modifications)
		var/datum/body_modification/body_modification = GLOB.body_modifications[body_modification_key]
		data += list(
			list(
				"key" = body_modification.key,
				"name" = body_modification.name,
				"description" = body_modification.get_description(),
				"cost" = body_modification.cost,
				"category" = body_modification.category
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

/datum/preference_middleware/body_modifications/proc/get_incompatible_body_modifications(mob/user)
	PRIVATE_PROC(TRUE)

	var/list/incompatible_body_modifications = list()
	var/list/applied = preferences.read_preference(/datum/preference/body_modifications)

	for(var/body_modification_key in GLOB.body_modifications)
		var/datum/body_modification/M = GLOB.body_modifications[body_modification_key]
		if(!LAZYLEN(M.incompatible_body_modifications & applied))
			continue
		incompatible_body_modifications += body_modification_key

	return incompatible_body_modifications

/datum/preference_middleware/body_modifications/proc/get_prosthesis_manufacturers()
	PRIVATE_PROC(TRUE)

	var/list/manufacturers_map = list()
	for (var/key in GLOB.body_modifications)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification, /datum/body_modification/bodypart_prosthesis))
			continue

		var/datum/body_modification/bodypart_prosthesis/prosthesis = modification

		manufacturers_map[key] = prosthesis.manufacturers || list()

	return manufacturers_map

/datum/preference_middleware/body_modifications/proc/get_selected_manufacturers(mob/user)
	PRIVATE_PROC(TRUE)

	var/list/current_brands = list()
	var/list/player_modifications = preferences.read_preference(/datum/preference/body_modifications)

	for (var/key in GLOB.body_modifications)
		var/datum/body_modification/modification = GLOB.body_modifications[key]

		if(!istype(modification, /datum/body_modification/bodypart_prosthesis))
			continue

		var/datum/body_modification/bodypart_prosthesis/prosthesis = modification
		current_brands[key] = player_modifications[key]?["selected_manufacturer"] || prosthesis.get_default_manufacturer()

	return current_brands

/datum/preference_middleware/body_modifications/proc/apply_body_modification(list/params, mob/user)
	var/key = params["body_modification_key"]
	if(!key)
		return FALSE

	var/datum/body_modification/modification = GLOB.body_modifications[key]
	if(!istype(modification) || !modification.can_be_applied(user))
		return FALSE

	var/list/updated_preference = preferences.read_preference(/datum/preference/body_modifications)
	if(!isnull(updated_preference[key]))
		return FALSE

	if(modification.ui_params_valid(params))
		updated_preference[key] = modification.handle_ui_params(params)
	else
		updated_preference[key] = modification.default_preference_value(params)

	return preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], updated_preference)

/datum/preference_middleware/body_modifications/proc/remove_body_modification(list/params, mob/user)
	var/body_modification_key = params["body_modification_key"]
	if(!body_modification_key)
		return FALSE

	var/list/body_modifications = preferences.read_preference(/datum/preference/body_modifications)
	if(isnull(body_modifications[body_modification_key]))
		return FALSE

	body_modifications -= body_modification_key
	return preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], body_modifications)

/datum/preference_middleware/body_modifications/proc/set_body_modification_manufacturer(list/params, mob/user)
	var/key = params["body_modification_key"]
	if(!key)
		return FALSE

	var/list/updated_preference = preferences.read_preference(/datum/preference/body_modifications)
	if(!islist(updated_preference[key]))
		return FALSE

	var/datum/body_modification/modification = GLOB.body_modifications[key]
	if(!modification.ui_params_valid(params))
		return FALSE

	updated_preference[key] = modification.handle_ui_params(params)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], updated_preference)

	return TRUE
