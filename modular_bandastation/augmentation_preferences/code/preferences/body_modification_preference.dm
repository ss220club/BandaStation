/datum/preference/body_modifications
	savefile_key = "body_modifications"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODYPARTS
	can_randomize = FALSE

/datum/preference/body_modifications/apply_to_human(mob/living/carbon/human/target, value)
	if(!islist(value))
		return

	var/list/body_modifications = value
	for(var/body_modification_key in body_modifications)
		GLOB.body_modifications[body_modification_key].apply_to_human(target)

/datum/preference/body_modifications/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return list()

	var/list/body_modifications = input
	var/list/valid_body_modification_keys = list()
	for(var/body_modification_key in body_modifications)
		if(!GLOB.body_modifications[body_modification_key])
			continue

		valid_body_modification_keys[body_modification_key] = TRUE

	return valid_body_modification_keys

/datum/preference/body_modifications/serialize(input)
	if(!islist(input))
		return list()

	var/list/body_modifications = input
	var/list/valid_body_modification_keys = list()
	for(var/body_modification_key in body_modifications)
		if(!GLOB.body_modifications[body_modification_key])
			continue

		valid_body_modification_keys |= body_modification_key

	return valid_body_modification_keys

/datum/preference/body_modifications/create_default_value()
	return list()
