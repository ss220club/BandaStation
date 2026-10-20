/datum/preference/job_outfit_variants
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "job_outfit_variants"
	can_randomize = FALSE

/datum/preference/job_outfit_variants/create_default_value()
	return list()

/datum/preference/job_outfit_variants/deserialize(input, datum/preferences/preferences)
	var/list/variants = list()
	if(!islist(input))
		return variants
	var/visited = 0
	for(var/job_title in input)
		if(++visited > 128)
			break
		if(!istext(job_title) || !length(job_title) || length(job_title) > 128)
			continue
		var/variant_id = input[job_title]
		if(!istext(variant_id) || !length(variant_id) || length(variant_id) > 128)
			continue
		variants[job_title] = variant_id
	return variants

/datum/preference/job_outfit_variants/is_valid(value, datum/preferences/preferences)
	if(!islist(value) || length(value) > 128)
		return FALSE
	for(var/job_title in value)
		if(!istext(job_title) || !length(job_title) || length(job_title) > 128)
			return FALSE
		var/variant_id = value[job_title]
		if(!istext(variant_id) || !length(variant_id) || length(variant_id) > 128)
			return FALSE
	return TRUE

/datum/preference/job_outfit_variants/serialize(list/input)
	return input.Copy()

/datum/preference/job_outfit_variants/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return
