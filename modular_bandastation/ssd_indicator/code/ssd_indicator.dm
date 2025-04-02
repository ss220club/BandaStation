GLOBAL_VAR_INIT(ssd_indicator_overlay, mutable_appearance('modular_bandastation/ssd_indicator/icons/ssd_indicator.dmi', "default0", FLY_LAYER))

/datum/element/ssd
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/ssd/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOB_LOGOUT, PROC_REF(on_mob_logout))
	RegisterSignal(target, COMSIG_MOB_LOGIN, PROC_REF(on_mob_login))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))

/datum/element/ssd/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_MOB_LOGIN)
	UnregisterSignal(source, COMSIG_MOB_LOGOUT)
	UnregisterSignal(source, COMSIG_LIVING_DEATH)

/datum/element/ssd/proc/on_mob_logout(mob/living/source)
	SIGNAL_HANDLER

	source.add_overlay(GLOB.ssd_indicator_overlay)
	source.player_logged = FALSE

/datum/element/ssd/proc/on_mob_login(mob/living/source)
	SIGNAL_HANDLER

	source.cut_overlay(GLOB.ssd_indicator_overlay)
	source.player_logged = TRUE
	Detach(source)

/datum/element/ssd/proc/on_mob_death(mob/living/source)
	SIGNAL_HANDLER

	source.cut_overlay(GLOB.ssd_indicator_overlay)

/mob/living/Logout()
	AddElement(/datum/element/ssd)
	. = ..()

/mob/living
	var/player_logged = TRUE
