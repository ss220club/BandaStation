GLOBAL_VAR_INIT(ssd_indicator_overlay, mutable_appearance('modular_bandastation/ssd_indicator/icons/ssd_indicator.dmi', "default0", FLY_LAYER))

/mob/living
	var/ssd_indicator = FALSE

/mob/living/proc/set_ssd_indicator(state)
	if(state == ssd_indicator)
		return
	ssd_indicator = state
	if(ssd_indicator)
		add_overlay(GLOB.ssd_indicator_overlay)
		log_message("<font color='green'>has went SSD and got their indicator!</font>", LOG_ATTACK)
	else
		cut_overlay(GLOB.ssd_indicator_overlay)
		log_message("<font color='green'>is no longer SSD and lost their indicator!</font>", LOG_ATTACK)

/mob/living/Login()
	. = ..()
	set_ssd_indicator(FALSE)

/mob/living/Logout()
	set_ssd_indicator(TRUE)
	. = ..()

/mob/living/ghostize(can_reenter_corpse = TRUE)
	. = ..()
	set_ssd_indicator(FALSE)
