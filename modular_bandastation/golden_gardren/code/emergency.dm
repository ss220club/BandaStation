/// Time between pressing the emergency eject and both pilots being thrown out.
#define GOLDEN_GARDREN_EJECT_DELAY (3 SECONDS)
/// Knockdown the pilots get from an emergency ejection.
#define GOLDEN_GARDREN_EJECT_KNOCKDOWN (3 SECONDS)

/// Throws both pilots out after a short countdown. Either seat may start it.
/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject
	name = "АВАРИЙНОЕ КАТАПУЛЬТИРОВАНИЕ"
	desc = "Через 3 секунды выбрасывает обоих пилотов на безопасные соседние клетки. Отменить нельзя."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "emergency_eject"

/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/mecha/golden_gardren/mech = chassis
	if(!istype(mech) || !(owner in mech.occupants))
		return
	mech.start_emergency_eject(owner)

/// Starts the ejection countdown. Returns FALSE if one is already running.
/obj/vehicle/sealed/mecha/golden_gardren/proc/start_emergency_eject(mob/user)
	if(emergency_eject_timer)
		balloon_alert(user, "катапультирование уже идёт!")
		return FALSE
	log_message("[key_name(user)] started the emergency ejection.", LOG_MECHA)
	to_chat(occupants, span_userdanger("АВАРИЙНОЕ КАТАПУЛЬТИРОВАНИЕ через [DisplayTimeText(GOLDEN_GARDREN_EJECT_DELAY)]!"))
	playsound(src, 'sound/machines/warning-buzzer.ogg', 75, FALSE)
	emergency_eject_timer = addtimer(CALLBACK(src, PROC_REF(emergency_eject)), GOLDEN_GARDREN_EJECT_DELAY, TIMER_STOPPABLE)
	return TRUE

/// Throws every occupant out onto separate free neighbour turfs, safe ones first.
/obj/vehicle/sealed/mecha/golden_gardren/proc/emergency_eject(stun = TRUE)
	emergency_eject_timer = null
	var/list/taken_turfs = list()
	for(var/mob/living/pilot as anything in occupants?.Copy())
		var/turf/landing = find_exit_turf(taken_turfs)
		mob_exit(pilot, silent = TRUE, forced = TRUE)
		if(QDELETED(pilot))
			continue
		// Without a free neighbour turf the pilot stays where the base exit put them, on the mech's own turf.
		if(landing)
			pilot.forceMove(landing)
			taken_turfs += landing
		if(stun)
			pilot.Knockdown(GOLDEN_GARDREN_EJECT_KNOCKDOWN)
		pilot.visible_message(span_warning("[pilot.declent_ru(NOMINATIVE)] вылетает из кабины [declent_ru(GENITIVE)]!"), span_userdanger("Вас выбрасывает из кабины!"))
	if(length(taken_turfs))
		playsound(src, 'sound/vehicles/mecha/hydraulic.ogg', 75, TRUE)

/**
 * Picks a neighbour turf a pilot or a half can be put on: a safe one if there is any, otherwise any passable one.
 * Turfs in [exclude] are skipped so two things do not land on the same turf. Returns null if no neighbour fits.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/find_exit_turf(list/exclude)
	var/turf/center = get_turf(src)
	if(!center)
		return null
	var/list/safe_turfs = list()
	var/list/passable_turfs = list()
	for(var/turf/candidate in orange(1, center))
		if((candidate in exclude) || candidate.is_blocked_turf(exclude_mobs = TRUE) || !center.Adjacent(candidate))
			continue
		if(is_safe_turf(candidate, extended_safety_checks = TRUE))
			safe_turfs += candidate
		else
			passable_turfs += candidate
	if(length(safe_turfs))
		return pick(safe_turfs)
	if(length(passable_turfs))
		return pick(passable_turfs)
	return null

#undef GOLDEN_GARDREN_EJECT_DELAY
#undef GOLDEN_GARDREN_EJECT_KNOCKDOWN
