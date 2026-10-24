/datum/job
	var/donor_tier = 0

/proc/donor_job_tier_allows(actual, required)
	if(!isnum(required) || required < 0 || required > MAX_DONATOR_LEVEL || round(required) != required)
		return FALSE
	return !required || (isnum(actual) && actual >= required && actual <= MAX_DONATOR_LEVEL && round(actual) == actual)

/datum/job/proc/get_required_donor_tier()
	return donor_tier

/datum/job/proc/donor_lock_reason(client/player)
	var/required = get_required_donor_tier()
	if(!required)
		return null
	if(!donor_job_tier_allows(MAX_DONATOR_LEVEL, required))
		return "Некорректный уровень подписки в объявлении профессии."
	if(!player || !donor_job_tier_allows(player.get_donator_level(), required))
		return "Требуется подписка уровня [required]."
	return null

/datum/job/donor
	abstract_type = /datum/job/donor
	faction = FACTION_STATION
	exp_granted_type = EXP_TYPE_CREW
	allow_bureaucratic_error = FALSE
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS
	tgui_icon = FA_ICON_USER

/datum/job/donor/config_check()
	return ..() && type != /datum/job/donor && CONFIG_GET(flag/donor_jobs_enabled)

/datum/job/donor/donor_lock_reason(client/player)
	if(!CONFIG_GET(flag/donor_jobs_enabled))
		return "Донатные профессии отключены."
	return ..()

/datum/job/prisoner/get_required_donor_tier()
	return CONFIG_GET(flag/donor_prisoner_gate) ? DONATOR_TIER_1 : 0

/datum/job/donor/requires_explicit_preference()
	return TRUE
