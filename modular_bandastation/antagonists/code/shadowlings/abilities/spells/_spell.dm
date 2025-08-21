// Базовый action для всех способностей тенелинга/роя
/datum/action/cooldown/shadowling
	name = "Shadowling Ability"
	desc = "Innate power of the brood."
	background_icon_state = "shadow_demon_bg"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "shadow_generic"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 10 SECONDS

	// Общие гейты
	var/tier_required = TIER_T0
	var/requires_dark_user = FALSE
	var/requires_dark_target = FALSE
	var/allow_incorporeal = FALSE
	var/range = 7
	var/channel_time = 0
	var/cancel_on_bright = TRUE
	var/cancel_on_move = TRUE
	var/cancel_on_damage = TRUE

	// базовый Trigger: self-каст
/datum/action/cooldown/shadowling/Trigger(mob/clicker, trigger_flags)
	var/mob/living/carbon/human/H = owner
	if(!H || QDELETED(H)) return
	if(!CanUse(H))
		to_chat(H, span_warning("Сейчас нельзя."))
		return
	if(channel_time > 0)
		if(!PerformChannel(H, H))
			return
	if(DoEffect(H, H))
		StartCooldown()

/datum/action/cooldown/shadowling/proc/CanUse(mob/living/carbon/human/H)
	// член роя должен быть хотя бы траллом/лингом
	if(!is_shadowling_mob(H) && !is_shadow_thrall(H))
		return FALSE
	// проверка тира (только для лингов)
	if(is_shadowling_mob(H))
		var/datum/element/shadow_hive/E = get_shadow_hive()
		if(E && E.current_tier < tier_required)
			return FALSE
	// тьма на кастере
	if(requires_dark_user && !shadow_dark_ok(H))
		return FALSE
	// фаза
	if(!allow_incorporeal && is_incorporeal(H))
		return FALSE
	return TRUE

/datum/action/cooldown/shadowling/proc/PerformChannel(mob/living/carbon/human/H, atom/target)
	if(cancel_on_bright && !shadow_dark_ok(H))
		return FALSE
	if(!do_after(H, channel_time, target))
		return FALSE
	if(cancel_on_bright && !shadow_dark_ok(H))
		return FALSE
	return TRUE

// Переопределяется наследниками
/datum/action/cooldown/shadowling/proc/DoEffect(mob/living/carbon/human/H, atom/target)
	return TRUE
