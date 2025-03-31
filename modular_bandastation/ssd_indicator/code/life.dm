/mob/living/proc/handle_ssd(seconds_per_tick, times_fired)
	if(!ssd_indicator)
		return
	SetSleeping(4 SECONDS)
