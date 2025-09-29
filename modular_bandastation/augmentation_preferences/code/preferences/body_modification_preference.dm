/datum/preference/body_modifications
	savefile_key = "body_modifications"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODYPARTS
	can_randomize = FALSE
	var/list/pending_body_modifications

/datum/preference/body_modifications/is_valid(value)
	if(!islist(value))
		return FALSE

	var/list/values = value
	for(var/body_modification_key in values)
		var/entry = values[body_modification_key]
		if (islist(entry))
			// ожидаем entry["type"] = /datum/body_modification/...
			if (!ispath(entry["type"], /datum/body_modification))
				// бэкомпат: разрешим старый формат только если ключ есть в реестре
				if (isnull(GLOB.body_modifications[body_modification_key]))
					return FALSE
		else
			// старый TRUE — проверяем, что ключ существует в реестре
			if (isnull(GLOB.body_modifications[body_modification_key]))
				return FALSE

	return TRUE

/datum/preference/body_modifications/apply_to_human(mob/living/carbon/human/target, value)
	if (!istype(target))
		return
	if (!islist(value) || !length(value))
		return

	if (!pending_body_modifications)
		pending_body_modifications = list()
	pending_body_modifications[REF(target)] = value

	RegisterSignal(target, COMSIG_HUMAN_PREFS_APPLIED, PROC_REF(on_prefs_applied_after_core))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_qdel), TRUE)

/datum/preference/body_modifications/proc/on_target_qdel(mob/living/carbon/human/target)
	SIGNAL_HANDLER
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_HUMAN_PREFS_APPLIED))
	if (pending_body_modifications)
		pending_body_modifications -= REF(target)

/datum/preference/body_modifications/proc/on_prefs_applied_after_core(mob/living/carbon/human/target)
	SIGNAL_HANDLER
	UnregisterSignal(target, COMSIG_HUMAN_PREFS_APPLIED)

	if (!pending_body_modifications)
		return
	var/reference = REF(target)
	var/list/body_mods = pending_body_modifications[reference]
	pending_body_modifications -= reference

	apply_from_prefs(target, body_mods)

/datum/preference/body_modifications/proc/apply_from_prefs(mob/living/carbon/human/target, list/body_mods)
	if(!istype(target) || !body_mods)
		return

	var/list/amputations = list()
	var/list/prostheses = list()
	var/list/implants = list()

	for(var/key in body_mods)
		var/list/entry = islist(body_mods[key]) ? body_mods[key] : null
		var/typepath = entry ? entry["type"] : null

		if(!ispath(typepath, /datum/body_modification))
			var/datum/body_modification/fallback = GLOB.body_modifications[key] // бэкомпат
			if(!fallback)
				continue
			typepath = fallback.type

		if(ispath(typepath, /datum/body_modification/limb_amputation))
			amputations[key] = typepath
		else if(ispath(typepath, /datum/body_modification/bodypart_prosthesis))
			prostheses[key] = typepath
		else if(ispath(typepath, /datum/body_modification/implants))
			implants[key] = typepath

	for(var/key in amputations)
		var/typepath = amputations[key]
		var/datum/body_modification/limb_amputation/amputation = new typepath
		amputation.apply_to_human(target)
		qdel(amputation)

	for(var/key in prostheses)
		var/typepath = prostheses[key]
		var/datum/body_modification/bodypart_prosthesis/prosthesis = new typepath
		if(islist(body_mods[key]) && body_mods[key]["selected_manufacturer"])
			prosthesis.selected_manufacturer = body_mods[key]["selected_manufacturer"]
		prosthesis.apply_to_human(target)
		qdel(prosthesis)

	for(var/key in implants)
		var/typepath = implants[key]
		var/datum/body_modification/implants/implant = new typepath
		implant.apply_to_human(target)
		qdel(implant)

	target.icon_render_keys = list()
	target.update_body()

/datum/preference/body_modifications/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return list()

	var/list/result = list()

	for (var/body_modification_key in input)
		var/value = input[body_modification_key]

		if(islist(value))
			// гарантируем наличие type; при старом формате — подставим из реестра
			if (!ispath(value["type"], /datum/body_modification))
				if(!GLOB.body_modifications[body_modification_key])
					continue
				value = list("type" = GLOB.body_modifications[body_modification_key].type) + value
			result[body_modification_key] = value
		else
			// TRUE (старое) → новый формат с type, если ключ известен
			if(!GLOB.body_modifications[body_modification_key])
				continue
			result[body_modification_key] = list("type" = GLOB.body_modifications[body_modification_key].type)

	return result

/datum/preference/body_modifications/serialize(input)
	if(!islist(input))
		return list()

	var/list/result = list()

	for (var/body_modification_key in input)
		var/value = input[body_modification_key]
		if(islist(value))
			// стараемся сохранить type
			if(!ispath(value["type"], /datum/body_modification))
				if (GLOB.body_modifications[body_modification_key])
					value["type"] = GLOB.body_modifications[body_modification_key].type
			result[body_modification_key] = value
		else
			if (GLOB.body_modifications[body_modification_key])
				result[body_modification_key] = list("type" = GLOB.body_modifications[body_modification_key].type)

	return result

/datum/preference/body_modifications/create_default_value()
	return list()
