/datum/element/shadow_hive
	// Идентификатор (если когда-то захочешь несколько роёв)
	var/hive_id = "main"

	// Состояние
	var/list/members = list()                  // все участники (линги и траллы)
	var/current_tier = TIER_T0
	var/highest_unlocked_tier = TIER_T0
	var/downtier_on_sync = FALSE

	// Карта «кому какие экшены выдали», чтобы аккуратно снимать
	var/list/granted_actions_by_mob = list()   // [mob] = list(datum/action/cooldown)

	// Пороги: живых траллов (NT) → тир
	var/list/tier_thresholds = list(
		TIER_T0 = 0,
		TIER_T1 = 1,
		TIER_T2 = 3,
		TIER_T3 = 5,
		TIER_T4 = 7,
		TIER_T5 = 15,
	)

/datum/element/shadow_hive/Attach(atom/target)
	. = ..()
	if(!ismob(target)) return
	var/mob/living/carbon/human/H = target
	if(!istype(H)) return

	// Выдать язык :8
	var/datum/language_holder/LH = ensure_language_holder(H)
	LH.grant_language(/datum/language/hivemind8, ALL, LANGUAGE_ATOM)

	// Учёт участника и выдача его набора
	if(!(H in members))
		members += H
	apply_set_for(H)

	// Авто-отписка
	RegisterSignal(H, COMSIG_QDELETING, PROC_REF(on_member_qdel))

/datum/element/shadow_hive/Detach(atom/target)
	if(ismob(target))
		var/mob/living/carbon/human/H = target
		remove_all_for(H)
		// Снять язык
		var/datum/language_holder/LH = ensure_language_holder(H)
		LH.remove_language(/datum/language/hivemind8, ALL, LANGUAGE_ATOM)
		members -= H
		UnregisterSignal(H, COMSIG_QDELETING)
	return ..()

/datum/element/shadow_hive/proc/on_member_qdel(atom/A)
	SIGNAL_HANDLER
	if(!ismob(A)) return
	var/mob/living/carbon/human/H = A
	remove_all_for(H)
	members -= H

// Установить динамический порог T5 от попа (зови при старте раунда, если нужно)
/datum/element/shadow_hive/proc/init_t5_from_pop(roundstart_pop)
	var/t5 = max(15, round(roundstart_pop / 6))
	tier_thresholds[TIER_T5] = t5

// Подсчёт живых траллов по наличию опухоли
/datum/element/shadow_hive/proc/count_live_thralls()
	var/n = 0
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(is_shadow_thrall(H))
			n++
	return n

/datum/element/shadow_hive/proc/tier_from_nt(nt)
	var/tier = TIER_T0
	for(var/t in list(TIER_T0, TIER_T1, TIER_T2, TIER_T3, TIER_T4, TIER_T5))
		if(nt >= (tier_thresholds[t] || 1e9))
			tier = t
	return tier

// Ручная синхронизация: считает NT, меняет тир (вверх/вниз по флагу), перераздаёт
/datum/element/shadow_hive/proc/sync(mob/living/carbon/human/triggerer)
	var/nt = count_live_thralls()
	var/calc = tier_from_nt(nt)
	var/target = downtier_on_sync ? calc : max(highest_unlocked_tier, calc)

	if(target == current_tier)
		announce(triggerer, "Живых траллов [nt]. Текущий тир [current_tier].")
		return current_tier

	var/old = current_tier
	current_tier = target
	highest_unlocked_tier = max(highest_unlocked_tier, current_tier)

	// Пере-выдаём всем
	for(var/mob/living/carbon/human/H in members)
		apply_set_for(H)

	announce(triggerer, "Живых траллов [nt]. Тир [old] → [current_tier].")
	return current_tier

/datum/element/shadow_hive/proc/announce(mob/living/carbon/human/from, message)
	var/name = (from && !QDELETED(from)) ? from.real_name : "???"
	var/msg = span_notice("[name]: [message]")
	for(var/mob/living/carbon/human/H in members)
		to_chat(H, msg)

// Снять все выданные этим элементом экшены у моба
/datum/element/shadow_hive/proc/remove_all_for(mob/living/carbon/human/H)
	var/list/L = granted_actions_by_mob[H]
	if(islist(L))
		for(var/datum/action/cooldown/A in L)
			if(H && !QDELETED(H))
				A.Remove(H)
			qdel(A)
	granted_actions_by_mob[H] = null

// Выдать корректный набор для моба (с предварительной очисткой)
/datum/element/shadow_hive/proc/apply_set_for(mob/living/carbon/human/H)
	if(!H || QDELETED(H)) return
	remove_all_for(H)

	var/list/granted = list()
	// Линг — все абилки до текущего тира
	if(is_shadowling_mob(H))
		for(var/ti = TIER_T0, ti <= current_tier, ti++)
			for(var/path in SHADOWLING_TIER_ABILITIES[ti] || list())
				var/datum/action/cooldown/A = new path(H)
				A.Grant(H)
				LAZYADD(granted, A)
	// Тралл — свой пул
	else if(is_shadow_thrall(H))
		for(var/path in SHADOWLING_THRALL_ABILITIES)
			var/datum/action/cooldown/A = new path(H)
			A.Grant(H)
			LAZYADD(granted, A)

	if(length(granted))
		granted_actions_by_mob[H] = granted

// Утилиты доступа
/proc/get_shadow_hive()
	if(!shadowling_hives.len)
		shadowling_hives += new /datum/element/shadow_hive("main")
	return shadowling_hives[1]

/proc/shadowling_join_hive(mob/living/carbon/human/H)
	if(!istype(H)) return
	H.AddElement(/datum/element/shadow_hive, "main")

/proc/shadowling_leave_hive(mob/living/carbon/human/H)
	if(!istype(H)) return
	if(hascall(H, "RemoveElement"))
		call(H, "RemoveElement")(/datum/element/shadow_hive, "main")
