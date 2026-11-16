/// Time the pilots have to pick a landing spot before they are fired out.
#define GOLDEN_GARDREN_EJECT_DELAY (5 SECONDS)
/// How far from the mech a capsule may land, in tiles.
#define GOLDEN_GARDREN_EJECT_RANGE 5
/// Knockdown the pilots get once their capsule opens.
#define GOLDEN_GARDREN_EJECT_KNOCKDOWN (2 SECONDS)
/// Capsule flight in deciseconds: short drop, opens at once, vanishes after landing.
#define GOLDEN_GARDREN_CAPSULE_DELAYS list(POD_TRANSIT = 10, POD_FALLING = 4, POD_OPENING = 5, POD_LEAVING = 10)

/**
 * ## Golden-Gardren emergency ejection
 *
 * Rescue capsules of the Golden, the Gardren and the combined mech. The countdown gives every pilot time to click
 * the turf their capsule lands on; without a choice the capsule lands on a free turf right next to the mech.
 * A blow that would destroy a manned mech does not destroy it at once: the mech goes down burning and blows up
 * once the same countdown runs out, so the pilots get the time to aim their capsules.
 * The owner routes its pilots' clicks during the countdown, pilots leaving the seat, and its destruction through here.
 */
/datum/component/golden_gardren_ejection
	/// Timer of a running ejection countdown.
	var/timer
	/// Assoc list: pilot -> turf they picked for their capsule during the countdown.
	var/list/landings
	/// Assoc list: pilot -> landing marker image shown to that pilot only.
	var/list/markers
	/// Timer of the blow-up of a mech that has taken a lethal blow with pilots inside.
	var/dying_timer

/datum/component/golden_gardren_ejection/Initialize()
	if(!istype(parent, /obj/vehicle/sealed/mecha))
		return COMPONENT_INCOMPATIBLE

/datum/component/golden_gardren_ejection/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_take_damage))

/datum/component/golden_gardren_ejection/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE)

/datum/component/golden_gardren_ejection/Destroy(force)
	deltimer(timer)
	timer = null
	deltimer(dying_timer)
	dying_timer = null
	for(var/mob/pilot as anything in markers?.Copy())
		clear_landing_choice(pilot)
	landings = null
	return ..()

/// A blow that would destroy the manned mech puts it into its last countdown instead; a dying mech takes no more damage.
/datum/component/golden_gardren_ejection/proc/on_take_damage(datum/source, damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	SIGNAL_HANDLER
	var/obj/vehicle/sealed/mecha/mech = parent
	if(dying_timer)
		return COMPONENT_NO_TAKE_DAMAGE
	if(damage_amount < mech.get_integrity() || !LAZYLEN(mech.occupants))
		return NONE
	start_dying()
	return COMPONENT_NO_TAKE_DAMAGE

/// The mech goes down burning: it cannot move or fight, the ejection countdown starts, and it blows up when the countdown runs out.
/datum/component/golden_gardren_ejection/proc/start_dying()
	var/obj/vehicle/sealed/mecha/mech = parent
	mech.update_integrity(1)
	mech.completely_disabled = TRUE
	mech.log_message("Took a lethal blow, blowing up in [DisplayTimeText(GOLDEN_GARDREN_EJECT_DELAY)].", LOG_MECHA)
	mech.visible_message(span_userdanger("[mech.declent_ru(NOMINATIVE)] охвачен огнём и вот-вот взорвётся!"))
	mech.add_shared_particles(/particles/smoke/burning, "golden_gardren_dying")
	mech.spark_system?.start()
	playsound(mech, 'sound/machines/warning-buzzer.ogg', 100, FALSE)
	start()
	dying_timer = addtimer(CALLBACK(src, PROC_REF(finish_dying)), GOLDEN_GARDREN_EJECT_DELAY, TIMER_STOPPABLE)

/// The countdown of a dying mech has run out: it is destroyed the regular way, firing out whoever is still inside.
/datum/component/golden_gardren_ejection/proc/finish_dying()
	var/obj/vehicle/sealed/mecha/mech = parent
	dying_timer = null
	mech.remove_shared_particles("golden_gardren_dying")
	mech.update_integrity(0)
	mech.atom_destruction(BRUTE)

/**
 * Starts the countdown and lets the pilots aim their capsules. Returns FALSE if one is already running.
 * Without [user] the countdown was started by the mech itself going down.
 */
/datum/component/golden_gardren_ejection/proc/start(mob/user)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(timer)
		if(user)
			mech.balloon_alert(user, "катапультирование уже идёт!")
		return FALSE
	mech.log_message("[user ? key_name(user) : "Lethal damage"] started the emergency ejection.", LOG_MECHA)
	to_chat(mech.occupants, span_userdanger("АВАРИЙНОЕ КАТАПУЛЬТИРОВАНИЕ через [DisplayTimeText(GOLDEN_GARDREN_EJECT_DELAY)]! Кликните по клетке, куда сядет ваша капсула: не дальше [GOLDEN_GARDREN_EJECT_RANGE] клеток и в зоне видимости. Без выбора капсула сядет рядом с мехом."))
	playsound(mech, 'sound/machines/warning-buzzer.ogg', 75, FALSE)
	for(var/mob/pilot as anything in mech.occupants)
		set_landing_cursor(pilot, aiming = TRUE)
	timer = addtimer(CALLBACK(src, PROC_REF(eject)), GOLDEN_GARDREN_EJECT_DELAY, TIMER_STOPPABLE)
	return TRUE

/// While the countdown runs, a pilot's click picks the landing turf instead of punching or shooting. Returns TRUE if the click was taken.
/datum/component/golden_gardren_ejection/proc/handle_click(mob/user, atom/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!timer || !mech.is_occupant(user))
		return FALSE
	choose_landing(user, target)
	return TRUE

/// Returns why a capsule cannot land on [landing], or null if it can.
/datum/component/golden_gardren_ejection/proc/landing_blocker(turf/landing)
	var/turf/center = get_turf(parent)
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
/datum/component/golden_gardren_ejection/proc/choose_landing(mob/user, atom/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!timer || !mech.is_occupant(user))
		return FALSE
	var/turf/landing = get_turf(target)
	var/blocker = landing_blocker(landing)
	if(blocker)
		mech.balloon_alert(user, blocker)
		return FALSE
	for(var/mob/other_pilot as anything in landings)
		if(other_pilot != user && landings[other_pilot] == landing)
			mech.balloon_alert(user, "место занято другой капсулой")
			return FALSE
	remove_landing_marker(user)
	LAZYSET(landings, user, landing)
	var/image/marker = image('icons/mob/telegraphing/telegraph.dmi', landing, "target_circle")
	SET_PLANE_EXPLICIT(marker, ABOVE_GAME_PLANE, landing)
	LAZYSET(markers, user, marker)
	user.client?.images += marker
	mech.balloon_alert(user, "место посадки выбрано")
	return TRUE

/// Forgets a pilot's landing choice and gives the regular cursor back.
/datum/component/golden_gardren_ejection/proc/clear_landing_choice(mob/user)
	remove_landing_marker(user)
	LAZYREMOVE(landings, user)
	set_landing_cursor(user, aiming = FALSE)

/datum/component/golden_gardren_ejection/proc/remove_landing_marker(mob/user)
	var/image/marker = LAZYACCESS(markers, user)
	if(marker)
		user.client?.images -= marker
	LAZYREMOVE(markers, user)

/datum/component/golden_gardren_ejection/proc/set_landing_cursor(mob/user, aiming)
	if(!user.client)
		return
	user.client.mouse_override_icon = aiming ? 'icons/effects/mouse_pointers/supplypod_down_target.dmi' : null
	user.update_mouse_pointer()

/**
 * Fires every occupant out: in a capsule to the turf they picked if it is still fine, otherwise to the nearest free neighbour.
 * Without [use_capsules] the pilots are put straight on their turfs, used when the mech is deleted outright.
 */
/datum/component/golden_gardren_ejection/proc/eject(use_capsules = TRUE, stun = TRUE)
	var/obj/vehicle/sealed/mecha/mech = parent
	deltimer(timer)
	timer = null
	var/list/taken_turfs = list()
	var/launched = FALSE
	for(var/mob/living/pilot as anything in mech.occupants?.Copy())
		var/turf/landing = LAZYACCESS(landings, pilot)
		clear_landing_choice(pilot)
		// The picked turf may have turned unsafe or been taken during the countdown.
		if(!landing || landing_blocker(landing) || (landing in taken_turfs))
			landing = golden_gardren_find_exit_turf(mech, taken_turfs)
		mech.mob_exit(pilot, silent = TRUE, forced = TRUE)
		if(QDELETED(pilot))
			continue
		if(stun)
			pilot.Knockdown(GOLDEN_GARDREN_EJECT_KNOCKDOWN + (use_capsules ? 1.5 SECONDS : 0))
		// Without any free turf around the pilot stays where the base exit put them, on the mech's own turf.
		if(!landing)
			continue
		taken_turfs += landing
		mech.log_message("[key_name(pilot)] ejected to [AREACOORD(landing)].", LOG_MECHA)
		if(use_capsules)
			launch_capsule(pilot, landing)
			launched = TRUE
		else
			pilot.forceMove(landing)
	if(launched)
		mech.visible_message(span_warning("Из [mech.declent_ru(GENITIVE)] с грохотом вылетают спасательные капсулы!"))
		playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 75, TRUE)

/// Sends a pilot to [landing] in a rescue capsule that harms nothing where it lands and vanishes after opening.
/datum/component/golden_gardren_ejection/proc/launch_capsule(mob/living/pilot, turf/landing)
	return podspawn(list(
		"target" = landing,
		"style" = /datum/pod_style/advanced,
		"spawn" = pilot,
		"explosionSize" = list(0, 0, 0, 0),
		"bluespace" = TRUE,
		"delays" = GOLDEN_GARDREN_CAPSULE_DELAYS,
	))

/// Whether the ejection countdown of [mech] is running.
/proc/golden_gardren_is_ejecting(obj/vehicle/sealed/mecha/mech)
	var/datum/component/golden_gardren_ejection/ejection = mech.GetComponent(/datum/component/golden_gardren_ejection)
	return !!ejection?.timer

/**
 * Picks a turf next to [mech] a pilot or a half can be put on: a safe one if there is any, otherwise any passable one.
 * Turfs in [exclude] are skipped so two things do not land on the same turf. Returns null if no neighbour fits.
 */
/proc/golden_gardren_find_exit_turf(atom/mech, list/exclude)
	var/turf/center = get_turf(mech)
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

/// Starts the ejection countdown. During it each pilot clicks the turf their capsule lands on.
/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject
	name = "АВАРИЙНОЕ КАТАПУЛЬТИРОВАНИЕ"
	desc = "Через 5 секунд выстреливает пилотов в капсулах. До выстрела каждый пилот кликом выбирает место посадки: не дальше 5 клеток, в зоне видимости, безопасное. Отменить нельзя."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "emergency_eject"

/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	var/datum/component/golden_gardren_ejection/ejection = chassis.GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.start(owner)

#undef GOLDEN_GARDREN_EJECT_DELAY
#undef GOLDEN_GARDREN_EJECT_RANGE
#undef GOLDEN_GARDREN_EJECT_KNOCKDOWN
#undef GOLDEN_GARDREN_CAPSULE_DELAYS
