/datum/preference_middleware/job_variants
	action_delegations = list("set_job_variant" = PROC_REF(set_job_variant))

/datum/preference_middleware/job_variants/pre_set_preference(mob/user, preference, value)
	// Variants are edited through the slot-checked action, not an arbitrary preference payload.
	return preference == "job_outfit_variants"

/datum/preference_middleware/job_variants/proc/set_job_variant(list/params, mob/user)
	var/client/player = GET_CLIENT(user)
	if(!player || player.prefs != preferences)
		return FALSE
	if(params["slot"] != preferences.default_slot)
		return FALSE
	var/job_title = params["job"]
	var/variant_id = params["variant"]
	if(!istext(job_title) || !istext(variant_id))
		return FALSE
	var/datum/job/job = SSjob.get_job(job_title)
	if(!job || job.title != job_title || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		return FALSE
	if(job.get_join_lock_reason(player))
		return FALSE
	var/list/variants = job.get_job_variants()
	if(!variants[variant_id])
		return FALSE
	var/list/saved_selection = preferences.read_preference(/datum/preference/job_outfit_variants)
	var/list/selection = saved_selection?.Copy() || list()
	selection[job.title] = variant_id
	return preferences.update_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], selection)

/datum/preference_middleware/job_variants/get_ui_data(mob/user)
	var/list/job_variants = list()
	var/list/selection = preferences.read_preference(/datum/preference/job_outfit_variants)
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/required_tier = job.get_required_donor_tier()
		if(!length(job.job_variant_specs) && !required_tier)
			continue
		var/list/variants = job.get_job_variants()
		var/list/options = list()
		for(var/variant_id in variants)
			var/datum/job_variant/variant = variants[variant_id]
			options += list(list("id" = variant_id, "name" = variant.public_title))
		var/datum/job_variant/selected_variant = job.resolve_job_variant(selection[job.title])
		var/datum/job_variant/default_variant = job.resolve_job_variant(null)
		job_variants[job.title] = list(
			"title" = default_variant?.public_title,
			"selected" = selected_variant?.id,
			"icon" = job.get_job_variant_icon_base64(selected_variant?.id),
			"variants" = options,
			"required_tier" = required_tier,
			"lock_reason" = job.get_join_lock_reason(user.client),
		)
	return list(
		"job_variants" = job_variants,
	)
