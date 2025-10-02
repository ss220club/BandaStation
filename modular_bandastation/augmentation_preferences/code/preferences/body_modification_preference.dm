/datum/preference/body_modifications
	savefile_key = "body_modifications"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODYPARTS
	can_randomize = FALSE

/datum/preference/body_modifications/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return list()

	var/list/result = list()
	for(var/key,value in input)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification))
			continue

		if(!modification.preference_value_valid(value))
			continue

		result[key] = value

	return result


/datum/preference/body_modifications/create_default_value()
	return list()

/datum/preference/body_modifications/apply_to_human(mob/living/carbon/human/target, value)
	if (!istype(target))
		return

	if (!islist(value) || !length(value))
		return

	apply_body_modifications(target, value)

/datum/preference/body_modifications/is_valid(value)
	if(!islist(value))
		return FALSE

	var/list/values = value
	for(var/key,entry in values)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification))
			return FALSE

		if(!modification.preference_value_valid(entry))
			return FALSE

	return TRUE

/datum/preference/body_modifications/proc/apply_body_modifications(mob/living/carbon/human/target, list/body_modifications)
	if(!istype(target) || !length(body_modifications))
		return

	for(var/key,value in body_modifications)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification))
			continue

		modification.apply_to_human(target, value)
