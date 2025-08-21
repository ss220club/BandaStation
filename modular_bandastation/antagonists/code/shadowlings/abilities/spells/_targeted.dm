/datum/action/cooldown/shadowling/targeted
	name = "Shadowling Targeted Ability"
	// TG имеет готовые таргетед-экшены, но для совместимости делаем минималку:
	var/target_selection = TRUE

	Trigger()
		var/mob/living/carbon/human/H = owner
		if(!H || QDELETED(H)) return
		if(!CanUse(H)) { to_chat(H, span_warning("Сейчас нельзя.")); return }
		// в TG можно использовать встроенный механизм targeted; если его нет — просим игрока кликнуть
		H.client?.ClickIntercept(src) // если у вас есть перехват кликов
		to_chat(H, span_notice("Кликни по цели в радиусе [range] тайлов."))
		// если ClickIntercept недоступен, см. ниже OnClickTarget()

	// Этот прок должен вызываться из вашего обработчика кликов,
	// когда активен режим выбора цели для данного экшена.
	proc/OnClickTarget(mob/living/carbon/human/H, atom/A)
		if(!CanUse(H)) return
		if(!A || get_dist(H, A) > range) { to_chat(H, span_warning("Слишком далеко.")); return }
		if(requires_dark_target && !shadow_dark_ok(A))
			to_chat(H, span_warning("Цель вне тени."))
			return
		var/mob/living/carbon/M = A
		if(!istype(M)) { to_chat(H, span_warning("Нужна живая цель.")); return }
		if(channel_time > 0)
			if(!PerformChannel(H, M)) return
		if(DoEffect(H, M)) StartCooldown()

/datum/action/cooldown/shadowling/targeted_turf
	name = "Shadowling Ground Ability"

	proc/OnClickTurf(mob/living/carbon/human/H, turf/T)
		if(!CanUse(H)) return
		if(!istype(T)) return
		if(get_dist(H, T) > range) { to_chat(H, span_warning("Слишком далеко.")); return }
		if(requires_dark_target && !shadow_dark_ok(T))
			to_chat(H, span_warning("Нужно выбрать тёмное место."))
			return
		if(channel_time > 0)
			if(!PerformChannel(H, T)) return
		if(DoEffect(H, T)) StartCooldown()

/datum/action/cooldown/shadowling/cone
	name = "Shadowling Cone Ability"
	var/cone_range = 5
	var/cone_degrees = 60

	Trigger()
		var/mob/living/carbon/human/H = owner
		if(!H || QDELETED(H)) return
		if(!CanUse(H)) { to_chat(H, span_warning("Сейчас нельзя.")); return }

		// Собираем цели в конусе
		var/list/targets = shadowling_collect_cone_targets(H, cone_range, cone_degrees)
		if(channel_time > 0)
			if(!PerformChannel(H, null)) return
		if(DoConeEffect(H, targets))
			StartCooldown()

	// Переопредели этот прок в наследниках
	proc/DoConeEffect(mob/living/carbon/human/H, list/targets)
		return TRUE

// Утилита конуса (упростил; подставь свою геометрию, если есть)
/proc/is_in_cone(mob/center, atom/A, degrees)
	// Заглушка: считаем, что всё в oview() подходит. Для точности используй доты углов.
	return TRUE

/proc/shadowling_collect_cone_targets(mob/living/carbon/human/H, max_range, degrees)
	var/list/L = list()
	for(var/mob/living/carbon/M in oview(H, max_range))
		if(M == H) continue
		if(!is_in_cone(H, M, degrees)) continue
		L += M
	return L
