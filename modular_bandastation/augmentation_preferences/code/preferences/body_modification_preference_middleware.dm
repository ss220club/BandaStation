/datum/preference_middleware/body_modifications
	action_delegations = list(
		"apply_body_modification" = PROC_REF(apply_body_modification),
		"remove_body_modification" = PROC_REF(remove_body_modification),
		"set_body_modification_manufacturer" = PROC_REF(set_body_modification_manufacturer),
	)

/// Append all of these into ui_data
/datum/preference_middleware/body_modifications/get_ui_data(mob/user)
	var/list/data = list()
	data["applied_body_modifications"] = get_applied_body_modifications()
	data["incompatible_body_modifications"] = get_incompatible_body_modifications(user)
	data["manufacturers"] = get_prosthesis_manufacturers()
	data["selected_manufacturer"] = get_current_manufacturers(user)
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
	for(var/body_modification_key in GLOB.body_modifications)
		if(GLOB.body_modifications[body_modification_key].can_be_applied(user))
			continue

		incompatible_body_modifications += body_modification_key

	return incompatible_body_modifications

/datum/preference_middleware/body_modifications/proc/get_prosthesis_manufacturers()
	PRIVATE_PROC(TRUE)

	var/list/manufacturers_map = list()
	for (var/key in GLOB.body_modifications)
		var/datum/body_modification/mod = GLOB.body_modifications[key]
		if (!istype(mod, /datum/body_modification/bodypart_prosthesis))
			continue

		var/datum/body_modification/bodypart_prosthesis/prosthesis_mod = mod

		manufacturers_map[key] = prosthesis_mod.manufacturers || list()

	return manufacturers_map

/datum/preference_middleware/body_modifications/proc/get_current_manufacturers(mob/user)
	PRIVATE_PROC(TRUE)

	var/list/current_brands = list()
	var/list/player_modifications = preferences.read_preference(/datum/preference/body_modifications)

	for (var/key in GLOB.body_modifications)
		var/datum/body_modification/mod = GLOB.body_modifications[key]

		if (!istype(mod, /datum/body_modification/bodypart_prosthesis))
			continue

		var/datum/body_modification/bodypart_prosthesis/prosthesis_mod = mod

		if (player_modifications && istype(player_modifications[key], /list) && player_modifications[key]["selected_manufacturer"])
			current_brands[key] = player_modifications[key]["selected_manufacturer"]
		else
			current_brands[key] = prosthesis_mod.selected_manufacturer
	return current_brands

/datum/preference_middleware/body_modifications/proc/apply_body_modification(list/params, mob/user)
	var/key = params["body_modification_key"]
	if (!key)
		return FALSE

	var/datum/body_modification/mod = GLOB.body_modifications[key]
	if (isnull(mod) || !mod.can_be_applied(user))
		return FALSE

	var/list/prefs = preferences.read_preference(/datum/preference/body_modifications)
	if (prefs[key])
		return FALSE

	if (istype(mod, /datum/body_modification/bodypart_prosthesis))
		var/datum/body_modification/bodypart_prosthesis/prosthesis = mod
		prefs[key] = list("selected_manufacturer" = prosthesis.selected_manufacturer)
	else
		prefs[key] = TRUE

	preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], prefs)
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
	user.update_body()
	return TRUE

/datum/preference_middleware/body_modifications/proc/set_body_modification_manufacturer(list/params, mob/user)
	var/key = params["body_modification_key"]
	var/brand = params["manufacturer"]

	if (!key || !brand)
		return FALSE

	var/list/prefs = preferences.read_preference(/datum/preference/body_modifications)
	if (!prefs[key])
		return FALSE

	var/datum/body_modification/mod = GLOB.body_modifications[key]
	if (!istype(mod, /datum/body_modification/bodypart_prosthesis))
		return FALSE

	var/datum/body_modification/bodypart_prosthesis/prosthesis = mod
	if (!(brand in prosthesis.manufacturers))
		return FALSE

	if (!islist(prefs[key]))
		prefs[key] = list()
	prefs[key]["selected_manufacturer"] = brand

	preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], prefs)

	if (istype(user, /mob/living/carbon/human))
		GLOB.body_modifications[key].apply_to_human(user)

	return TRUE

