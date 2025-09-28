// MARK: Ability
/datum/action/cooldown/shadowling/commune
	name = "Связь роя"
	desc = "Передать мысленное сообщение всем тенелингам и слугам."
	button_icon_state = "shadow_talk"
	cooldown_time = 0
	max_range = 0
	channel_time = 0
	requires_dark_user = FALSE
	requires_dark_target = FALSE

/datum/action/cooldown/shadowling/commune/Trigger(mob/clicker, trigger_flags, atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(!IsAvailable(TRUE))
		return FALSE

	var/text_msg = tgui_input_text(H, "Сообщение для роя", "Связь роя", max_length = MAX_MESSAGE_LEN)
	if(!text_msg)
		return FALSE

	var/list/filter_result = CAN_BYPASS_FILTER(H) ? null : is_ic_filtered(text_msg)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(H, filter_result)
		return FALSE

	var/list/soft_filter_result = CAN_BYPASS_FILTER(H) ? null : is_soft_ic_filtered(text_msg)
	if(soft_filter_result)
		var/ans = tgui_alert(H, "Сообщение содержит \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\". Отправить?", "Мягкий фильтр", list("Да", "Нет"))
		if(ans != "Да")
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(H)] passed soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". Message: \"[html_encode(text_msg)]\"")
		log_admin_private("[key_name(H)] passed soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". Message: \"[text_msg]\"")

	if(!shadowling_commune_broadcast(H, text_msg))
		to_chat(H, span_warning("Улей молчит."))
		return FALSE

	H.log_talk(text_msg, LOG_SAY, tag = "SHADOW_HIVE")
	return TRUE

/datum/action/cooldown/shadowling/commune/proc/shadowling_commune_broadcast(mob/living/carbon/human/sender, message)
	if(!istype(sender))
		return FALSE

	if(!length(message))
		return FALSE

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return FALSE

	var/role_label = shadowling_commune_role_label(sender, hive)
	var/name_to_show = sender.real_name
	var/bold_name = shadowling_commune_bold_name(sender, hive)

	var/name_html = bold_name ? "<b>[html_encode(name_to_show)]</b>" : "[html_encode(name_to_show)]"
	var/body_html = html_encode(message)
	var/style = hive.leader == sender ? "shadowradio_leader" :"shadowradio"

	var/render = "<span class='[style]'>[role_label] [name_html]: [body_html]</span>"

	to_chat(sender, render, type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)

	for(var/mob/living/carbon/human/L in hive.lings)
		if(QDELETED(L))
			continue
		if(L == sender)
			continue
		to_chat(L, render, type = MESSAGE_TYPE_RADIO, avoid_highlighting = FALSE)

	for(var/mob/living/carbon/human/T in hive.thralls)
		if(QDELETED(T))
			continue
		if(T == sender)
			continue
		to_chat(T, render, type = MESSAGE_TYPE_RADIO, avoid_highlighting = FALSE)

	for(var/mob/dead/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, sender)
		to_chat(ghost, "[link] [render]", type = MESSAGE_TYPE_RADIO)

	return TRUE

/datum/action/cooldown/shadowling/commune/proc/shadowling_commune_role_label(mob/living/carbon/human/H, datum/team/shadow_hive/hive)
	if(H in hive.thralls)
		return "(Раб Тенеморфа)"

	if(!(H in hive.lings))
		return ""

	var/role = hive.get_ling_role(H)
	if(role == SHADOWLING_ROLE_LESSER)
		return "(Младший Тенеморф)"

	return "(Тенеморф)"

/datum/action/cooldown/shadowling/commune/proc/shadowling_commune_bold_name(mob/living/carbon/human/H, datum/team/shadow_hive/hive)
	if(!(H in hive.lings))
		return FALSE

	var/role = hive.get_ling_role(H)
	if(role == SHADOWLING_ROLE_LESSER)
		return FALSE

	return TRUE
