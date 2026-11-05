/datum/preference_middleware/names/get_name_to_use()
	if(istype(preferences.get_highest_priority_job(), /datum/job/donor/security_clown))
		var/datum/preference/clown_name = GLOB.preference_entries[/datum/preference/name/clown]
		return clown_name.savefile_key
	return ..()
