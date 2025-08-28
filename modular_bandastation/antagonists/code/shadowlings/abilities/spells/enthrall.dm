/datum/action/cooldown/shadowling/enthrall
	name = "Enthrall"
	desc = "Bind a nearby humanoid to the Hive through a painful ritual of darkness."
	button_icon_state = "shadow_enthrall"
	cooldown_time = 45 SECONDS

	required_thralls = 0
	requires_dark_user = TRUE
	requires_dark_target = TRUE
	max_range = 2
	channel_time = 0                 // каналим сами внутри DoEffect
	cancel_on_bright = TRUE

/***********************
 * Вспомогательные (конус и проверки)
 ***********************/

/// Ближайшая валидная цель в конусе 90° на 2 тайла
/datum/action/cooldown/shadowling/enthrall/proc/find_cone_target(mob/living/carbon/human/H)
	var/mob/living/carbon/human/best = null
	var/best_dist = 999
	var/best_rank = 999

	for(var/mob/living/carbon/human/T in range(2, H))
		if(T == H)
			continue
		if(!in_front_cone_90(H, T))
			continue
		if(!is_valid_target(H, T))
			continue

		var/d = get_dist(H, T)
		var/tdir = get_dir(H, T)
		var/rank = (tdir == H.dir) ? 0 : 1

		if(d < best_dist || (d == best_dist && rank < best_rank))
			best = T
			best_dist = d
			best_rank = rank

	return best

/datum/action/cooldown/shadowling/enthrall/proc/in_front_cone_90(mob/living/carbon/human/H, atom/A)
	if(!H.dir)
		return TRUE
	var/tdir = get_dir(H, A)
	if(!tdir)
		return FALSE
	var/list/allowed = list(H.dir, turn(H.dir, 45), turn(H.dir, -45))
	return (tdir in allowed)

/// цель пригодна для конверсии?
/datum/action/cooldown/shadowling/enthrall/proc/is_valid_target(mob/living/carbon/human/H, mob/living/carbon/human/T)
	if(!istype(T))
		return FALSE

	var/datum/shadow_hive/hive = get_shadow_hive()
	if(hive)
		if(T in hive.lings)   return FALSE
		if(T in hive.thralls) return FALSE

	if(has_mindshield(T))
		return FALSE

	return TRUE

/datum/action/cooldown/shadowling/enthrall/proc/has_mindshield(mob/living/carbon/human/T)
	if(islist(T.implants) && (locate(/obj/item/implant/mindshield) in T.implants))
		return TRUE
	for(var/obj/item/implant/mindshield/I in T.contents)
		return TRUE
	return FALSE

/***********************
 * Эффект (включая канал внутри)
 ***********************/

/// 3×8 c do_after на выбранной цели; по завершении — вставка опухоли
/datum/action/cooldown/shadowling/enthrall/DoEffect(mob/living/carbon/human/H, atom/_ignored)
	// выбираем ближайшую цель в конусе
	var/mob/living/carbon/human/T = find_cone_target(H)
	if(!T)
		to_chat(H, span_warning("Перед вами нет подходящих целей."))
		return FALSE

	// финальные проверки света и дистанции
	if(!is_dark(H) || !is_dark(T))
		to_chat(H, span_warning("Свет рассеивает связь."))
		return FALSE

	if(get_dist(H, T) > 2 || !is_valid_target(H, T))
		return FALSE

	// три канала по 8 сек
	for(var/i = 1 to 3)
		if(cancel_on_bright && !is_dark(H))
			return FALSE

		if(!do_after(H, 8 SECONDS, T))
			return FALSE

		// цель остаётся валидной?
		if(QDELETED(T) || get_dist(H, T) > 2 || has_mindshield(T) || !is_dark(T))
			return FALSE

		// немного удушья в процессе
		T.adjustOxyLoss(30)

	// снять накопленное удушье (30)
	T.adjustOxyLoss(-100)

	// не дублируем, если уже есть опухоль
	var/obj/item/organ/existing = T.get_organ_slot(ORGAN_SLOT_BRAIN_THRALL)
	if(existing)
		to_chat(H, span_notice("[T.real_name] уже связан с ульем."))
		return TRUE

	// вставляем опухоль
	var/obj/item/organ/brain/shadow/tumor_thrall/O = new
	if(!O.Insert(T))
		qdel(O)
		to_chat(H, span_warning("Связать не удалось."))
		return FALSE

	to_chat(H, span_notice("Вы связываете разум [T.real_name] с ульем."))
	to_chat(T, span_danger("Холодная тьма пронзает ваш мозг... Вы становитесь слугой улья!"))
	return TRUE
