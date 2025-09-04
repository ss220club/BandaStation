/datum/action/cooldown/shadowling/recuperation
	name = "Рекуперация"
	desc = "Преобразовать связанного слугу в младшего шадоулинга. Требует 15 секунд и неподвижности цели."
	button_icon_state = "shadow_recuperation"
	cooldown_time = 45 SECONDS

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 1
	channel_time = 15 SECONDS

	click_to_activate = TRUE
	unset_after_click = TRUE

/datum/action/cooldown/shadowling/recuperation/Trigger(mob/clicker, trigger_flags, atom/target)
	// Используем стандартную логику действия: корректный тоггл click-mode по повторному нажатию
	return ..()

/datum/action/cooldown/shadowling/recuperation/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!IsAvailable(TRUE))
		// На всякий случай снимаем режим клика при любом клике
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/mob/living/carbon/human/T = target
	if(!istype(T))
		clicker.balloon_alert(clicker, "нужна гуманоидная цель")
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(get_dist(clicker, T) > 1)
		clicker.balloon_alert(clicker, "слишком далеко")
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(!(T in hive.thralls) || !T.get_organ_slot(ORGAN_SLOT_BRAIN_THRALL))
		clicker.balloon_alert(clicker, "требуется слуга")
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(T in hive.lings)
		clicker.balloon_alert(clicker, "уже в улье как линг")
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/start_loc = T.loc
	if(!do_after(clicker, channel_time, T))
		unset_click_ability(clicker, TRUE)
		return FALSE
	if(QDELETED(T) || T.loc != start_loc || get_dist(clicker, T) > 1)
		unset_click_ability(clicker, TRUE)
		return FALSE

	T.shadowling_strip_quirks()
	T.set_species(/datum/species/shadow/shadowling)
	for(var/datum/action/cooldown/ability in T.actions)
		if(ability.type in typesof(/datum/action/cooldown/shadowling))
			ability.Remove(T)

	to_chat(clicker, span_notice("Вы переплавляете сущность [T.real_name] во тьму — он восстаёт младшим шадоулингом."))
	to_chat(T, span_danger("Тьма переписывает вашу плоть и волю... Вы становитесь младшим шадоулингом!"))

	unset_click_ability(clicker, FALSE)
	StartCooldown()
	return TRUE
