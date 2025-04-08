/client/New()
	. = ..()
	if(!SScentral.active)
		return
	SScentral.update_player_donate_tier_async(src)
