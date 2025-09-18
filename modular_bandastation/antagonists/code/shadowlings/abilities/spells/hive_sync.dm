/datum/action/cooldown/shadowling/hive_sync
	name = "Синхронизация улья"
	desc = "Показать число живых слуг и получить доступные вам способности по их количеству."
	button_icon_state = "shadow_sync"
	cooldown_time = 6 SECONDS
	channel_time = 3 SECONDS

/datum/action/cooldown/shadowling/hive_sync/DoEffect(mob/living/carbon/human/H, atom/target)
	StartCooldown()
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		to_chat(H, span_warning("Улей не отвечает."))
		return FALSE

	var/nt = hive.count_nt()

	var/list/new_unlocks = grant_unlocks_for(H, nt)
	if(length(new_unlocks))
		to_chat(H, span_notice("Живых слуг: [nt]. Новые способности: [jointext(new_unlocks, ", ")]."))
	else
		to_chat(H, span_notice("Живых слуг: [nt]. Новых способностей нет."))

	return TRUE

/datum/action/cooldown/shadowling/hive_sync/proc/has_action_of_type(mob/living/carbon/human/H, action_type)
	for(var/datum/action/A in H.actions)
		if(istype(A, action_type))
			return TRUE
	return FALSE

/datum/action/cooldown/shadowling/hive_sync/proc/get_ling_class(mob/living/carbon/human/H)
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return null
	if(H in hive.thralls)
		return SHADOWLING_ROLE_THRALL
	if(H in hive.lings)
		var/role = hive.get_ling_role(H)
		return role || SHADOWLING_ROLE_MAIN
	return null

/datum/action/cooldown/shadowling/hive_sync/proc/role_allowed(var/datum/action/cooldown/shadowling/A, ling_role)
	if(istype(A, /datum/action/cooldown/shadowling/election))
		if(GLOB.is_shadowling_vote_finished)
			return FALSE

	var/list/check_list = list()
	switch(ling_role)
		if(SHADOWLING_ROLE_THRALL)
			check_list = SHADOWLING_THRALL_ABILITIES
		if(SHADOWLING_ROLE_LESSER)
			check_list = SHADOWLING_MINOR_ABILITIES
		else
			var/datum/antagonist/shadowling/hive = get_shadowling_antag_of(owner)
			check_list = hive?.is_ascended ? SHADOWLING_ASCENDED_ABILITIES : SHADOWLING_BASE_ABILITIES

	return A.type in check_list

/datum/action/cooldown/shadowling/hive_sync/proc/get_required_thralls(var/datum/action/cooldown/shadowling/A)
	return A.required_thralls

/datum/action/cooldown/shadowling/hive_sync/proc/grant_unlocks_for(mob/living/carbon/human/H, nt)
	if(!istype(H))
		return list()
	var/ling_class = get_ling_class(H)
	if(!ling_class)
		return list()

	var/list/unlocked_names = list()

	for(var/path in typesof(/datum/action/cooldown/shadowling))
		if(path == /datum/action/cooldown/shadowling)
			continue
		if(path == /datum/action/cooldown/shadowling/hive_sync)
			continue
		if(has_action_of_type(H, path))
			continue

		var/datum/action/cooldown/shadowling/A = new path()
		if(!role_allowed(A, ling_class))
			qdel(A)
			continue

		var/req = get_required_thralls(A)
		if(nt < req)
			qdel(A)
			continue

		A.Grant(H)
		var/n = initial(A.name)
		if(n)
			unlocked_names += "[n]"

	return unlocked_names
