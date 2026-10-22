/mob/dead/new_player
	var/datum/job_character_selection/assigned_character

/datum/job_character_selection
	var/job_type
	var/slot
	var/randomized = FALSE
	var/age
	var/species
	var/error
	var/list/saved
	var/list/values = list()
	var/datum/preferences/preferences

/// Resolve both slot settings without changing the selected character during job evaluation.
/datum/preferences/proc/select_job_character(datum/job/job, latejoin = FALSE, forced_slot)
	var/datum/job_character_selection/result = new
	result.job_type = job.type
	result.slot = default_slot
	result.preferences = src
	var/use_current = latejoin ? read_preference(/datum/preference/toggle/late_join_always_current_slot) : read_preference(/datum/preference/toggle/round_start_always_join_current_slot)
	if(!isnull(forced_slot))
		result.slot = forced_slot
	else if(!use_current)
		var/requested = pref_job_slots[job.title]
		if(requested == JOB_SLOT_RANDOMISED_SLOT)
			result.randomized = TRUE
		else if(!isnull(requested) && requested != JOB_SLOT_CURRENT_SLOT)
			result.slot = requested
	if(!isnum(result.slot) || round(result.slot) != result.slot || result.slot < 1 || result.slot > max_save_slots)
		result.error = "Некорректный слот персонажа."
		return result
	var/list/saved_profile = savefile.get_entry("character[result.slot]")
	if(islist(saved_profile))
		result.saved = saved_profile.Copy()
	if(result.slot == default_slot)
		// Include unsaved edits, using the same defaults as the native preferences reader.
		result.age = read_preference(/datum/preference/numeric/age)
		result.species = read_preference(/datum/preference/choiced/species)
		var/list/current_values = value_cache
		result.values = current_values.Copy()
	else if(!islist(result.saved) || !result.saved["real_name"])
		result.error = "Назначенный профиль отсутствует; выберите существующий слот."
		return result
	result.age = result.read_preference(/datum/preference/numeric/age)
	result.species = result.read_preference(/datum/preference/choiced/species)
	return result

/// Read the selected profile without loading it or retaining a temporary selection.
/datum/preferences/proc/get_job_character_species(datum/job/job, latejoin = FALSE)
	var/datum/job_character_selection/selection = select_job_character(job, latejoin)
	. = selection.species
	qdel(selection)

/// Supply the existing lobby checks with only preferences whose selected species is restricted.
/datum/preferences/proc/get_species_restricted_job_preferences()
	var/list/restricted_jobs = list()
	for(var/job_title in job_preferences)
		var/datum/job/job = SSjob.get_job(job_title)
		if(!job)
			continue
		var/species = get_job_character_species(job)
		if(species && job.character_species_error(species))
			restricted_jobs += job_title
	return restricted_jobs

/datum/job_character_selection/proc/read_preference(preference_type)
	if(error)
		return null
	if(preference_type in values)
		return values[preference_type]
	var/datum/preference/preference = GLOB.preference_entries[preference_type]
	var/value = preference.read(saved, preferences)
	if(isnull(value))
		value = preference.create_informed_default_value(preferences)
	values[preference_type] = value
	return value

/datum/job_character_selection/proc/is_too_young_for_job(datum/job/job)
	return !error && isnum(job.required_character_age) && (!isnum(age) || age < job.required_character_age)

/datum/job_character_selection/proc/character_error(datum/job/job, client/player, latejoin)
	if(error)
		return error
	if(is_too_young_for_job(job))
		return "Персонаж назначенного профиля слишком молод."
	if(ispath(job.spawn_type, /mob/living/carbon/human))
		var/species_error = job.character_species_error(species)
		if(species_error)
			return species_error
	if(latejoin && CONFIG_GET(flag/allow_respawn) == RESPAWN_FLAG_NEW_CHARACTER && !player.is_localhost())
		if("[slot]" in player.persistent_client.joined_as_slots)
			return "Вы уже играли на назначенном персонаже в этом раунде."
	return null

/datum/job/proc/character_species_error(species_type)
	var/list/restricted = CONFIG_GET(str_list/job_restrictions)
	var/list/allowed = CONFIG_GET(str_list/allowed_species)
	if(!(locate(/datum/station_trait/xenobureaucracy_error) in GLOB.lobby_station_traits) && (title in restricted) && length(allowed) && !("[species_type]" in allowed))
		return "Вид назначенного персонажа несовместим с профессией."
	return null

/datum/job_character_selection/proc/actual_body_error(datum/job/job, mob/living/body)
	if(!ishuman(body))
		return null
	var/mob/living/carbon/human/human_body = body
	if(isnum(job.required_character_age) && human_body.age < job.required_character_age)
		return "Созданный персонаж не проходит возрастное ограничение."
	return job.character_species_error(human_body.dna.species.type)

/mob/dead/new_player/proc/resolve_assigned_job_character(datum/job/job, latejoin = FALSE, forced_slot)
	if(assigned_character?.job_type == job.type && (isnull(forced_slot) || assigned_character.slot == forced_slot))
		return assigned_character
	QDEL_NULL(assigned_character)
	var/client/player = GET_CLIENT(src)
	assigned_character = player.prefs.select_job_character(job, latejoin, forced_slot)
	return assigned_character

/mob/dead/new_player/proc/load_assigned_job_character()
	var/client/player = GET_CLIENT(src)
	if(!assigned_character || assigned_character.error || !player)
		return FALSE
	if(player.prefs.default_slot != assigned_character.slot)
		player.prefs.save_character()
		if(!player.prefs.load_character(assigned_character.slot))
			return FALSE
		// Invalid saved values can also generate random defaults. Use the values inspected during assignment.
		for(var/preference_type in assigned_character.values)
			var/datum/preference/preference = GLOB.preference_entries[preference_type]
			player.prefs.write_preference(preference, preference.serialize(assigned_character.values[preference_type]))
	return TRUE
