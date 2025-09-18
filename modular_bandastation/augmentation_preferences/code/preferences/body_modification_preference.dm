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
	if(!istype(target))
		return

	if(target.client?.prefs)
		apply_from_prefs(target, target.client.prefs)
		return

	RegisterSignal(target, COMSIG_HUMAN_PREFS_APPLIED, PROC_REF(on_prefs_applied_after_core))

/datum/preference/body_modifications/proc/on_prefs_applied_after_core(mob/living/carbon/human/target)
	SIGNAL_HANDLER
	UnregisterSignal(target, COMSIG_HUMAN_PREFS_APPLIED)

	var/ck = target?.mind?.key || target?.ckey
	var/datum/preferences/prefs = ck ? GLOB.preferences_datums?[ck] : null
	if(!prefs)
		return

	apply_from_prefs(target, prefs)

/datum/preference/body_modifications/proc/apply_from_prefs(mob/living/carbon/human/target, datum/preferences/prefs)
	if(!istype(target) || !prefs)
		return

	var/list/body_mods = prefs.read_preference(type)
	if(!islist(body_mods) || !length(body_mods))
		return

	var/list/amputations = list()
	var/list/prostheses = list()
	var/list/implants = list()

	for(var/key in body_mods)
		var/datum/body_modification/mod_prototype = GLOB.body_modifications[key]
		if(!mod_prototype)
			continue

		if(istype(mod_prototype, /datum/body_modification/limb_amputation))
			amputations[key] = mod_prototype
		else if(istype(mod_prototype, /datum/body_modification/bodypart_prosthesis))
			prostheses[key] = mod_prototype
		else if(istype(mod_prototype, /datum/body_modification/implants))
			implants[key] = mod_prototype

	for(var/key in amputations)
		var/datum/body_modification/mod_prototype = amputations[key]
		var/datum/body_modification/limb_amputation/amputation = new mod_prototype.type
		amputation.apply_to_human(target)
		qdel(amputation)

	for(var/key in prostheses)
		var/datum/body_modification/mod_prototype = prostheses[key]
		var/datum/body_modification/bodypart_prosthesis/prosthesis = new mod_prototype.type
		if(islist(body_mods[key]) && body_mods[key]["selected_manufacturer"])
			prosthesis.selected_manufacturer = body_mods[key]["selected_manufacturer"]
		prosthesis.apply_to_human(target)
		qdel(prosthesis)

	for(var/key in implants)
		var/datum/body_modification/mod_prototype = implants[key]
		var/datum/body_modification/implants/implant = new mod_prototype.type
		implant.apply_to_human(target)
		qdel(implant)

	target.icon_render_keys = list()
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
