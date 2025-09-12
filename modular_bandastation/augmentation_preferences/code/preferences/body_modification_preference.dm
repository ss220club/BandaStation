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

/datum/preference/body_modifications/apply_to_human(mob/living/carbon/human/target, _value)
	if(!istype(target))
		return

	if(target.client?.prefs)
		apply_from_prefs(target, target.client.prefs)
		return

	UnregisterSignal(target, COMSIG_HUMAN_PREFS_APPLIED)
	RegisterSignal(target, COMSIG_HUMAN_PREFS_APPLIED, PROC_REF(on_prefs_applied_after_core))

/datum/preference/body_modifications/proc/on_prefs_applied_after_core(mob/living/carbon/human/target)
	SIGNAL_HANDLER
	UnregisterSignal(target, COMSIG_HUMAN_PREFS_APPLIED)

	var/ck = target?.mind?.key || target?.ckey
	var/datum/preferences/P = ck ? GLOB.preferences_datums?[ck] : null
	if(!P)
		return

	apply_from_prefs(target, P)

/datum/preference/body_modifications/proc/apply_from_prefs(mob/living/carbon/human/target, datum/preferences/P)
	if(!istype(target) || !P) return

	var/list/body_mods = P.read_preference(type)
	if(!islist(body_mods) || !body_mods.len) return

	for(var/key in body_mods)
		var/datum/body_modification/M = GLOB.body_modifications[key]
		if(!M || !istype(M, /datum/body_modification/limb_amputation)) continue
		var/datum/body_modification/limb_amputation/A = new M.type
		A.apply_to_human(target)
		qdel(A)

	for(var/key in body_mods)
		var/datum/body_modification/M2 = GLOB.body_modifications[key]
		if(!M2 || !istype(M2, /datum/body_modification/bodypart_prosthesis)) continue
		var/datum/body_modification/bodypart_prosthesis/PR = new M2.type
		if(islist(body_mods[key]) && body_mods[key]["selected_manufacturer"])
			PR.selected_manufacturer = body_mods[key]["selected_manufacturer"]
		PR.apply_to_human(target)
		qdel(PR)

	for(var/key in body_mods)
		var/datum/body_modification/M3 = GLOB.body_modifications[key]
		if(!M3 || !istype(M3, /datum/body_modification/implants)) continue
		var/datum/body_modification/implants/I = new M3.type
		I.apply_to_human(target)
		qdel(I)

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
