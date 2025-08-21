/datum/action/cooldown/shadowling/hive_sync
	name = "Синхронизация улья"
	desc = "Показать число живых траллов и обновить тир способностей для всей стаи."
	button_icon_state = "hive_sync"
	cooldown_time = 10 SECONDS
	tier_required = TIER_T0
	allow_incorporeal = TRUE

/datum/action/cooldown/shadowling/hive_sync/Trigger(mob/clicker, trigger_flags)
	var/datum/element/shadow_hive/E = get_shadow_hive()
	if(!E)
		to_chat(clicker, span_warning("Улей не инициализирован."))
		return FALSE
	E.sync(clicker)
	return TRUE
