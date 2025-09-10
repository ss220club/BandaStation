/datum/action/cooldown/shadowling/enthrall
	name = "Порабощение"
	desc = "Подчиняет ближайшее существо к вам в небольшом конусе служить улью."
	button_icon_state = "enthrall"
	cooldown_time = 45 SECONDS
	required_thralls = 0
	requires_dark_user = TRUE
	requires_dark_target = TRUE
	max_range = 2
	channel_time = 8
	cancel_on_bright = TRUE

/datum/action/cooldown/shadowling/enthrall/proc/find_cone_target(mob/living/carbon/human/H)
	var/mob/living/carbon/human/best = null
	var/best_dist = 999
	var/best_rank = 999
	for(var/mob/living/carbon/human/T in range(2, H))
		if(T == H)
			continue
		if(!in_front_cone(H, T, 90))
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

/datum/action/cooldown/shadowling/enthrall/proc/is_valid_target(mob/living/carbon/human/H, mob/living/carbon/human/T)
	if(!istype(T))
		return FALSE
	if(T?.mind)
		return FALSE
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(hive)
		if(T in hive.lings)
			return FALSE
		if(T in hive.thralls)
			return FALSE
	if(has_mindshield(T))
		return FALSE
	return TRUE

/datum/action/cooldown/shadowling/enthrall/proc/has_mindshield(mob/living/carbon/human/T)
	if(!istype(T))
		return FALSE
	if(islist(T.implants) && (locate(/obj/item/implant/mindshield) in T.implants))
		return TRUE
	return FALSE

/datum/action/cooldown/shadowling/enthrall/DoEffect(mob/living/carbon/human/H, atom/_ignored)
	var/mob/living/carbon/human/T = find_cone_target(H)
	if(!T)
		owner.balloon_alert(owner, "Нет доступных целей")
		enable()
		return FALSE

	if(!is_dark(H) || !is_dark(T))
		owner.balloon_alert(owner, "Свет разрушил связь")
		StartCooldown()
		return FALSE

	if(get_dist(H, T) > 2 || !is_valid_target(H, T))
		return FALSE


	var/obj/item/organ/existing = T.get_organ_slot(ORGAN_SLOT_BRAIN_THRALL)
	if(existing)
		owner.balloon_alert(owner, "Уже связан с ульем")
		to_chat(H, span_notice("[T.real_name] уже связан с ульем."))
		return TRUE

	to_chat(H, span_notice("Вы начинаете связывать разум [T.real_name] с ульем. Не шевелитесь и оставайтесь в тени..."))
	to_chat(T, span_danger("Холодная тьма обволакивает ваш разум..."))

	for(var/i = 1 to 3)
		if(cancel_on_bright && !is_dark(H))
			to_chat(H, span_warning("Свет разорвал связь."))
			return FALSE
		if(!do_after(H, channel_time SECONDS, T))
			to_chat(H, span_warning("Связь прервана."))
			return FALSE
		if(QDELETED(T) || get_dist(H, T) > 2 || has_mindshield(T) || !is_dark(T))
			to_chat(H, span_warning("Цель утрачена."))
			return FALSE
		T.adjustOxyLoss(30)

	T.adjustOxyLoss(-100)

	var/obj/item/organ/brain/shadow/tumor_thrall/O = new
	if(!O.Insert(T))
		qdel(O)
		owner.balloon_alert(owner, "Связать не удалось")
		to_chat(H, span_warning("Не удалось связать [T.real_name] с ульем."))
		return FALSE

	to_chat(H, span_notice("Вы связываете разум [T.real_name] с ульем."))
	to_chat(T, span_danger("Холодная тьма пронзает ваш мозг... Вы становитесь слугой улья!"))
	return TRUE
