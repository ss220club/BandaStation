/datum/quirk/death_dnr_poll
	name = "Thanatorenasia"
	desc = "Если вы умираете и выбираете опцию \"Не реанимировать\", при возрождении ваше тело может быть занято другим призраком - \
		у него будет новая личность и новые воспоминания."
	icon = FA_ICON_ZAP
	value = 0
	medical_record_text = "У пациента диагностирована танатореназия. В случае смерти и последующей реанимации \
		возможна потеря памяти или изменение личности."
	medical_symptom_text = "В случае смерти пациента и последующей реанимации \
		возможна потеря памяти или изменение личности."
	quirk_flags = QUIRK_NO_TRANSFER

	// Used the the spawners menu to describe the quirk
	var/you_are_text = "Вы - умерший член экипажа, страдающий танатореназией - \
		состоянием, которое меняет личность и вызывает потерю памяти при смерти и последующем возрождении."
	var/flavor_text = "Что-то... не так. \
		Вы не до конца понимаете, кто вы и что произошло. Вы помните только своё имя и то, что работаете здесь. \
		Что ж, пора браться за дело - меньше всего хочется остаться и без работы, и без памяти."
	var/important_text = "Продолжайте выполнять свои обязанности. \
		Если вы умираете и выбираете опцию \"Не реанимировать\", при возрождении ваше тело может быть занято другим призраком. \
		Вы всё ещё можете становиться антагонистом в середине раунда."

/datum/quirk/death_dnr_poll/add_unique(client/client_source)
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_LIVING_DNR, PROC_REF(mob_died))

/datum/quirk/death_dnr_poll/remove()
	. = ..()
	UnregisterSignal(quirk_holder, COMSIG_LIVING_DNR)

/datum/quirk/death_dnr_poll/proc/mob_died(mob/living/source, mob/dead/observer/dnring)
	SIGNAL_HANDLER

	var/whomst = source.real_name
	var/workable_job = (source.mind && !is_unassigned_job(source.mind.assigned_role))
	if(workable_job)
		whomst += "? Job: [span_notice(source.mind.assigned_role.title)]"
	if(length(source.mind?.get_special_roles()))
		whomst += "[workable_job ? "," : "?"] Status: [span_boldnotice(english_list(source.mind?.get_special_roles()))]"

	source.AddComponent(/datum/component/ghostrole_on_revive, \
		refuse_revival_if_failed = TRUE, \
		on_successful_revive = CALLBACK(src, PROC_REF(on_successful_revive)), \
		revive_title = whomst, \
		spawn_text = "Deceased Crew", \
		you_are_text = src.you_are_text, \
		flavor_text = src.flavor_text, \
		important_text = src.important_text, \
	)
	source.log_message("was made ghostrole pollable by [name] quirk.", LOG_GAME, color = COLOR_PURPLE)

/datum/quirk/death_dnr_poll/proc/on_successful_revive()
	quirk_holder.log_message("has had their body taken over by a ghost due to the [name] quirk.", LOG_GAME, color = COLOR_PURPLE)
	var/welcome_msg = boxed_message(span_notice("<b>[quirk_holder.real_name]</b> has <i>[name]</i> - you are [quirk_holder.p_their()] new owner.<br>\
		If you choose to <b>\"Do Not Resuscitate\"</b> upon death, another ghost will take over the body once again."))
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(to_chat), quirk_holder, welcome_msg), 2 SECONDS)
