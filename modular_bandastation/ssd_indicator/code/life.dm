/mob/living/proc/handle_ssd(seconds_per_tick, times_fired)
	if(player_logged)
		return
	SetSleeping(7 SECONDS) // Было 4, но в коммите 337ab7f зарефакторили тик статусов, тайминги съехали
