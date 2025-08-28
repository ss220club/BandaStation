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

	// Выдаём все способности, чей required_thralls <= nt и подходят по роли
	grant_unlocks_for(H, nt)

	to_chat(H, span_notice("Живых слуг: [nt]."))
	return TRUE

/***********************
 * Раздача абилок по количеству траллов
 ***********************/

/// true, если у моба уже есть экшен данного типа
/datum/action/cooldown/shadowling/hive_sync/proc/has_action_of_type(mob/living/carbon/human/H, action_type)
	for(var/datum/action/A in H.actions)
		if(istype(A, action_type))
			return TRUE
	return FALSE

/// роль подходит? (по необязательным флагам в экшене)
/datum/action/cooldown/shadowling/hive_sync/proc/role_allowed(var/datum/action/cooldown/shadowling/A, is_ling)
	return is_ling ? (A.type in SHADOWLING_BASE_ABILITIES) : (A.type in SHADOWLING_THRALL_ABILITIES)

/// получить требуемое число слуг (если поле не объявлено — считаем 0)
/datum/action/cooldown/shadowling/hive_sync/proc/get_required_thralls(var/datum/action/cooldown/shadowling/A)
	if("required_thralls" in A.vars && isnum(A:required_thralls))
		return A:required_thralls
	return 0

/// основная логика
/datum/action/cooldown/shadowling/hive_sync/proc/grant_unlocks_for(mob/living/carbon/human/H, nt)
	if(!istype(H)) return
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive) return

	var/is_ling = (H in hive.lings)

	// переберём все сабтипы /datum/action/cooldown/shadowling
	for(var/path in typesof(/datum/action/cooldown/shadowling))
		// пропускаем базу и саму синхру
		if(path == /datum/action/cooldown/shadowling)
			continue
		if(path == /datum/action/cooldown/shadowling/hive_sync)
			continue

		// не выдаём повторно
		if(has_action_of_type(H, path)) continue

		// создаём временный экземпляр, чтобы посмотреть метаданные
		var/datum/action/cooldown/shadowling/A = new path()

		// фильтр по роли (если объявлен)
		if(!role_allowed(A, is_ling))
			qdel(A)
			continue

		// фильтр по числу слуг
		var/req = get_required_thralls(A)
		if(nt < req)
			qdel(A)
			continue

		// всё ок — выдаём
		A.Grant(H)
