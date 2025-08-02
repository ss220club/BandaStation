/datum/preference/body_modifications
	savefile_key = "body_modifications"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODYPARTS
	can_randomize = FALSE

/datum/preference/body_modifications/is_valid(value)
	if(!islist(value))
		return FALSE

	var/list/values = value
	for(var/body_modification_key in values)
		if(isnull(GLOB.body_modifications[body_modification_key]))
			return FALSE

	return TRUE

/datum/preference/body_modifications/apply_to_human(mob/living/carbon/human/target, value)
	if(!islist(value))
		return

	var/list/body_modifications = value
	for(var/obj/item/bodypart/L in target.bodyparts)
		if(	L.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
			qdel(L)

	target.regenerate_limbs()

	for(var/key in body_modifications)
		var/datum/body_modification/mod_proto = GLOB.body_modifications[key]
		if(!mod_proto || !istype(mod_proto, /datum/body_modification/limb_amputation))
			continue

		var/datum/body_modification/limb_amputation/amputation = new mod_proto.type
		amputation.apply_to_human(target)
		qdel(amputation)

	for(var/key in body_modifications)
		var/datum/body_modification/mod_proto = GLOB.body_modifications[key]
		if(!mod_proto || !istype(mod_proto, /datum/body_modification/bodypart_prosthesis))
			continue

		var/datum/body_modification/bodypart_prosthesis/prosthesis = new mod_proto.type
		if(islist(body_modifications[key]) && body_modifications[key]["selected_manufacturer"])
			prosthesis.selected_manufacturer = body_modifications[key]["selected_manufacturer"]

		prosthesis.apply_to_human(target)
		qdel(prosthesis)

	for(var/key in body_modifications)
		var/datum/body_modification/mod_proto = GLOB.body_modifications[key]
		if(!mod_proto || !istype(mod_proto, /datum/body_modification/implants))
			continue

		var/datum/body_modification/implants/implant = new mod_proto.type
		implant.apply_to_human(target)
		qdel(implant)

	// Обновляем тело один раз в конце
	target.update_body()

/datum/preference/body_modifications/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return list()

	var/list/result = list()

	for (var/body_modification_key in input)
		if(!GLOB.body_modifications[body_modification_key])
			continue

		var/value = input[body_modification_key]

		if(islist(value))
			result[body_modification_key] = value
		else
			result[body_modification_key] = TRUE

	return result

/datum/preference/body_modifications/serialize(input)
	if(!islist(input))
		return list()

	var/list/result = list()

	for (var/body_modification_key in input)
		if(!GLOB.body_modifications[body_modification_key])
			continue

		var/value = input[body_modification_key]
		if(islist(value))
			result[body_modification_key] = value
		else
			result[body_modification_key] = TRUE

	return result

/datum/preference/body_modifications/create_default_value()
	return list()
