ADMIN_VERB(wl_ban, R_BAN, "WL Ban", "Выписать игрока из вайтлиста.", ADMIN_CATEGORY_MAIN)
	BLACKBOX_LOG_ADMIN_VERB("WL Ban")

	if(!SScentral.can_run())
		to_chat(user, span_bolddanger("Невозможно выписать игрока из вайтлиста. SS Central не настроен!"))
		stack_trace("Using whitelist/whitelist bans without SS Central is not supported")
		return

	var/banned_ckey = input(user, "Укажите ckey игрока для выписки.", "Выписка", "") as text|null
	banned_ckey = ckey(banned_ckey)
	if(!banned_ckey)
		return
	var/duration_days = input(user, "Укажите длительность выписки в днях.", "Длительность", "") as num|null
	if(isnull(duration_days) || duration_days < 0)
		return

	var/reason = input(user, "Укажите причину выписки.", "Причина", "") as message|null

	SScentral.whitelist_ban_player(banned_ckey, user.ckey, duration_days, reason)

	log_admin("[key_name(user)] banned [banned_ckey] from whitelist for [duration_days] days for reason: [reason]")
	message_admins("[key_name_admin(user)] выписал [banned_ckey] из вайтлиста на [duration_days] дней с причиной: [reason]")
