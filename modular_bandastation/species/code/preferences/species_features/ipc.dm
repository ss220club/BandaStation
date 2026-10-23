/datum/preference/choiced/ipc
	abstract_type = /datum/preference/choiced/ipc
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	var/feature_key

/datum/preference/choiced/ipc/has_relevant_feature(datum/preferences/preferences)
	return current_species_has_savekey(preferences)

/datum/preference/choiced/ipc/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features[feature_key] = value

/datum/preference/choiced/ipc/chassis
	savefile_key = "ipc_chassis"
	feature_key = FEATURE_IPC_CHASSIS

/datum/preference/choiced/ipc/chassis/init_possible_values()
	var/list/choices = list()
	for(var/chassis_name in GLOB.ipc_chassis)
		var/datum/ipc_chassis/chassis = GLOB.ipc_chassis[chassis_name]
		if(chassis.has_body)
			choices += chassis_name
	return choices

/datum/preference/choiced/ipc/chassis/create_default_value()
	return /datum/ipc_chassis/morpheus::name

/datum/preference/choiced/ipc/head
	savefile_key = "ipc_head"
	feature_key = FEATURE_IPC_HEAD

/datum/preference/choiced/ipc/head/init_possible_values()
	var/list/choices = list()
	for(var/chassis_name in GLOB.ipc_chassis)
		var/datum/ipc_chassis/chassis = GLOB.ipc_chassis[chassis_name]
		if(chassis.has_head)
			choices += chassis_name
	return choices

/datum/preference/choiced/ipc/head/create_default_value()
	return /datum/ipc_chassis/morpheus::name

/datum/preference/choiced/ipc/head/post_write(value, datum/preferences/preferences)
	. = ..()
	// Re-read and validate the saved screen against the new head before the next preview.
	if(!isnull(preferences))
		preferences.value_cache -= /datum/preference/choiced/ipc/screen

/datum/preference/choiced/ipc/screen
	savefile_key = "ipc_screen"
	feature_key = FEATURE_IPC_SCREEN

/datum/preference/choiced/ipc/screen/init_possible_values()
	return assoc_to_keys(GLOB.ipc_displays)

/datum/preference/choiced/ipc/screen/create_default_value()
	return /datum/sprite_accessory/ipc_display/ipc_screen_blue::name

/datum/preference/choiced/ipc/screen/create_informed_default_value(datum/preferences/preferences)
	return get_default_ipc_display(preferences.read_preference(/datum/preference/choiced/ipc/head))

/datum/preference/choiced/ipc/screen/deserialize(input, datum/preferences/preferences)
	if(isnull(preferences))
		return ..()
	var/head_name = preferences.read_preference(/datum/preference/choiced/ipc/head)
	return sanitize_inlist(input, get_ipc_display_choices(head_name), get_default_ipc_display(head_name))

/datum/preference/choiced/ipc/screen/is_valid(value, datum/preferences/preferences)
	if(!..())
		return FALSE
	if(isnull(preferences))
		return TRUE
	return value in get_ipc_display_choices(preferences.read_preference(/datum/preference/choiced/ipc/head))

/datum/preference/choiced/ipc/screen/compile_constant_data()
	var/list/data = ..()
	var/list/choices_by_head = list()
	for(var/chassis_name in GLOB.ipc_chassis)
		var/datum/ipc_chassis/chassis = GLOB.ipc_chassis[chassis_name]
		if(chassis.has_head)
			choices_by_head[chassis_name] = get_ipc_display_choices(chassis_name)
	data["choices_by_head"] = choices_by_head
	return data

/datum/preference/choiced/ipc/antenna
	savefile_key = "ipc_antenna"
	feature_key = FEATURE_IPC_ANTENNA

/datum/preference/choiced/ipc/antenna/init_possible_values()
	return assoc_to_keys(GLOB.ipc_antennae)

/datum/preference/choiced/ipc/antenna/create_default_value()
	return /datum/sprite_accessory/ipc_antenna/none::name

/datum/preference/color/ipc
	abstract_type = /datum/preference/color/ipc
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	var/feature_key

/datum/preference/color/ipc/has_relevant_feature(datum/preferences/preferences)
	return current_species_has_savekey(preferences)

/datum/preference/color/ipc/create_default_value()
	return COLOR_BLACK

/datum/preference/color/ipc/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features[feature_key] = value

/datum/preference/color/ipc/chassis
	savefile_key = "ipc_chassis_color"
	feature_key = FEATURE_IPC_CHASSIS_COLOR

/datum/preference/color/ipc/screen
	savefile_key = "ipc_screen_color"
	feature_key = FEATURE_IPC_SCREEN_COLOR

/datum/preference/color/ipc/screen_secondary
	savefile_key = "ipc_screen_color_secondary"
	feature_key = FEATURE_IPC_SCREEN_COLOR_SECONDARY

/datum/preference/color/ipc/screen_secondary/create_default_value()
	return COLOR_WHITE

/datum/preference/color/ipc/antenna
	savefile_key = "ipc_antenna_color"
	feature_key = FEATURE_IPC_ANTENNA_COLOR
