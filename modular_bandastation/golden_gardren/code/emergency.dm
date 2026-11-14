/// Time the pilots have to pick a landing spot before they are fired out.
#define GOLDEN_GARDREN_EJECT_DELAY (5 SECONDS)
/// How far from the mech a capsule may land, in tiles.
#define GOLDEN_GARDREN_EJECT_RANGE 5
/// Knockdown the pilots get once their capsule opens.
#define GOLDEN_GARDREN_EJECT_KNOCKDOWN (2 SECONDS)
/// Capsule flight in deciseconds: short drop, opens at once, vanishes after landing.
#define GOLDEN_GARDREN_CAPSULE_DELAYS list(POD_TRANSIT = 10, POD_FALLING = 4, POD_OPENING = 5, POD_LEAVING = 10)

/// Starts the ejection countdown. During it each pilot clicks the turf their capsule lands on.
/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject
	name = "АВАРИЙНОЕ КАТАПУЛЬТИРОВАНИЕ"
	desc = "Через 5 секунд выстреливает обоих пилотов в капсулах. До выстрела каждый пилот кликом выбирает место посадки: не дальше 5 клеток, в зоне видимости, безопасное. Отменить нельзя."
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

/// Starts the ejection countdown and lets the pilots aim their capsules. Returns FALSE if one is already running.
/obj/vehicle/sealed/mecha/golden_gardren/proc/start_emergency_eject(mob/user)
	if(emergency_eject_timer)
		balloon_alert(user, "катапультирование уже идёт!")
		return FALSE
	log_message("[key_name(user)] started the emergency ejection.", LOG_MECHA)
	to_chat(occupants, span_userdanger("АВАРИЙНОЕ КАТАПУЛЬТИРОВАНИЕ через [DisplayTimeText(GOLDEN_GARDREN_EJECT_DELAY)]! Кликните по клетке, куда сядет ваша капсула: не дальше [GOLDEN_GARDREN_EJECT_RANGE] клеток и в зоне видимости. Без выбора капсула сядет рядом с мехом."))
	playsound(src, 'sound/machines/warning-buzzer.ogg', 75, FALSE)
	for(var/mob/pilot as anything in occupants)
		set_landing_cursor(pilot, aiming = TRUE)
	emergency_eject_timer = addtimer(CALLBACK(src, PROC_REF(emergency_eject)), GOLDEN_GARDREN_EJECT_DELAY, TIMER_STOPPABLE)
	return TRUE

/// While the countdown runs, a pilot's click picks the landing turf instead of punching or shooting.
/obj/vehicle/sealed/mecha/golden_gardren/on_mouseclick(mob/user, atom/target, list/modifiers)
	if(emergency_eject_timer && is_occupant(user))
		choose_landing(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	return ..()

/// Returns why a capsule cannot land on [landing], or null if it can.
/obj/vehicle/sealed/mecha/golden_gardren/proc/landing_blocker(turf/landing)
	var/turf/center = get_turf(src)
	if(!isturf(landing) || !center || landing.z != center.z)
		return "сюда не долететь"
	if(landing == center)
		return "капсула не сядет на сам мех"
	if(get_dist(center, landing) > GOLDEN_GARDREN_EJECT_RANGE)
		return "слишком далеко"
	if(!can_see(center, landing, GOLDEN_GARDREN_EJECT_RANGE))
		return "нет прямой видимости"
	if(landing.is_blocked_turf(exclude_mobs = TRUE))
		return "место занято"
	if(!is_safe_turf(landing, extended_safety_checks = TRUE))
		return "опасное место"
	return null

/// Remembers the landing turf a pilot clicked and marks it for that pilot only.
/obj/vehicle/sealed/mecha/golden_gardren/proc/choose_landing(mob/user, atom/target)
	if(!emergency_eject_timer || !is_occupant(user))
		return FALSE
	var/turf/landing = get_turf(target)
	var/blocker = landing_blocker(landing)
	if(blocker)
		balloon_alert(user, blocker)
		return FALSE
	for(var/mob/other_pilot as anything in eject_landings)
		if(other_pilot != user && eject_landings[other_pilot] == landing)
			balloon_alert(user, "место занято другой капсулой")
			return FALSE
	remove_landing_marker(user)
	LAZYSET(eject_landings, user, landing)
	var/image/marker = image('icons/mob/telegraphing/telegraph.dmi', landing, "target_circle")
	SET_PLANE_EXPLICIT(marker, ABOVE_GAME_PLANE, landing)
	LAZYSET(eject_markers, user, marker)
	user.client?.images += marker
	balloon_alert(user, "место посадки выбрано")
	return TRUE

/// Forgets a pilot's landing choice and gives the regular cursor back.
/obj/vehicle/sealed/mecha/golden_gardren/proc/clear_landing_choice(mob/user)
	remove_landing_marker(user)
	LAZYREMOVE(eject_landings, user)
	set_landing_cursor(user, aiming = FALSE)

/obj/vehicle/sealed/mecha/golden_gardren/proc/remove_landing_marker(mob/user)
	var/image/marker = LAZYACCESS(eject_markers, user)
	if(marker)
		user.client?.images -= marker
	LAZYREMOVE(eject_markers, user)

/obj/vehicle/sealed/mecha/golden_gardren/proc/set_landing_cursor(mob/user, aiming)
	if(!user.client)
		return
	user.client.mouse_override_icon = aiming ? 'icons/effects/mouse_pointers/supplypod_down_target.dmi' : null
	user.update_mouse_pointer()

/**
 * Fires every occupant out: in a capsule to the turf they picked if it is still fine, otherwise to the nearest free neighbour.
 * Without [use_capsules] the pilots are put straight on their turfs, used when the frame is deleted outright.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/emergency_eject(use_capsules = TRUE, stun = TRUE)
	deltimer(emergency_eject_timer)
	emergency_eject_timer = null
	var/list/taken_turfs = list()
	var/launched = FALSE
	for(var/mob/living/pilot as anything in occupants?.Copy())
		var/turf/landing = LAZYACCESS(eject_landings, pilot)
		clear_landing_choice(pilot)
		// The picked turf may have turned unsafe or been taken during the countdown.
		if(!landing || landing_blocker(landing) || (landing in taken_turfs))
			landing = find_exit_turf(taken_turfs)
		mob_exit(pilot, silent = TRUE, forced = TRUE)
		if(QDELETED(pilot))
			continue
		if(stun)
			pilot.Knockdown(GOLDEN_GARDREN_EJECT_KNOCKDOWN + (use_capsules ? 1.5 SECONDS : 0))
		// Without any free turf around the pilot stays where the base exit put them, on the mech's own turf.
		if(!landing)
			continue
		taken_turfs += landing
		log_message("[key_name(pilot)] ejected to [AREACOORD(landing)].", LOG_MECHA)
		if(use_capsules)
			launch_capsule(pilot, landing)
			launched = TRUE
		else
			pilot.forceMove(landing)
	if(launched)
		visible_message(span_warning("Из [declent_ru(GENITIVE)] с грохотом вылетают спасательные капсулы!"))
		playsound(src, 'sound/vehicles/mecha/hydraulic.ogg', 75, TRUE)

/// Sends a pilot to [landing] in a rescue capsule that harms nothing where it lands and vanishes after opening.
/obj/vehicle/sealed/mecha/golden_gardren/proc/launch_capsule(mob/living/pilot, turf/landing)
	return podspawn(list(
		"target" = landing,
		"style" = /datum/pod_style/advanced,
		"spawn" = pilot,
		"explosionSize" = list(0, 0, 0, 0),
		"bluespace" = TRUE,
		"delays" = GOLDEN_GARDREN_CAPSULE_DELAYS,
	))

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
#undef GOLDEN_GARDREN_EJECT_RANGE
#undef GOLDEN_GARDREN_EJECT_KNOCKDOWN
#undef GOLDEN_GARDREN_CAPSULE_DELAYS
