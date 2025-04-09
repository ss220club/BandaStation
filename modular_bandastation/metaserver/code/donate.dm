/client/New()
	. = ..()
	if(!SScentral.can_run())
		return
	SScentral.update_player_donate_tier_async(src)
