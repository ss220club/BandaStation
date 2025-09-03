/datum/action/cooldown/shadowling/hive_sync
	name = "Синхронизация улья"
	desc = "Показать число живых слуг и получить доступные вам способности по их количеству."
	button_icon_state = "hive_sync"
	cooldown_time = 6 SECONDS

/datum/action/cooldown/shadowling/hive_sync/DoEffect(mob/living/carbon/human/H, atom/target)
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		to_chat(H, span_warning("Улей не отвечает."))
		return FALSE

	var/nt = hive.count_nt()

	grant_unlocks_for(H, nt)

	to_chat(H, span_notice("Живых слуг: [nt]."))
	return TRUE

/datum/action/cooldown/shadowling/hive_sync/proc/has_action_of_type(mob/living/carbon/human/H, action_type)
	for(var/datum/action/A in H.actions)
		if(istype(A, action_type))
			return TRUE
	return FALSE

/datum/action/cooldown/shadowling/hive_sync/proc/role_allowed(var/datum/action/cooldown/shadowling/A, ling_role)
	var/list/check_list = list()
	switch(ling_role)
		if(SHADOWLING_ROLE_MAIN)
			check_list = SHADOWLING_BASE_ABILITIES
		if(SHADOWLING_ROLE_THRALL)
			check_list = SHADOWLING_THRALL_ABILITIES
		if(SHADOWLING_ROLE_LESSER)
			check_list = SHADOWLING_MINOR_ABILITIES
	return A.type in check_list

/datum/action/cooldown/shadowling/hive_sync/proc/get_required_thralls(var/datum/action/cooldown/shadowling/A)
	return A.required_thralls

/datum/action/cooldown/shadowling/hive_sync/proc/grant_unlocks_for(mob/living/carbon/human/H, nt)
	if(!istype(H)) return
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive) return

	var/ling_class = null
	if(H in hive.lings)
		ling_class = SHADOWLING_ROLE_MAIN
	if(H in hive.thralls)
		ling_class = SHADOWLING_ROLE_THRALL
	if((H in hive.lings) && (H in hive.thralls))
		ling_class = SHADOWLING_ROLE_LESSER

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
