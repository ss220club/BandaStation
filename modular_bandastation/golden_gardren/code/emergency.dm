/// Time the pilots have to pick a landing spot before they are fired out.
#define GOLDEN_GARDREN_EJECT_DELAY (5 SECONDS)
/// How far from the mech a capsule may land, in tiles.
#define GOLDEN_GARDREN_EJECT_RANGE 5
/// Knockdown the pilots get once their capsule opens.
#define GOLDEN_GARDREN_EJECT_KNOCKDOWN (2 SECONDS)
/// Time until a launched capsule opens, in three stages.
#define GOLDEN_GARDREN_CAPSULE_TRANSIT (1 SECONDS)
#define GOLDEN_GARDREN_CAPSULE_FALL (0.4 SECONDS)
#define GOLDEN_GARDREN_CAPSULE_OPEN (0.5 SECONDS)

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
	/// Whether the mech has taken a lethal blow with pilots inside and blows up when the countdown runs out.
	var/dying = FALSE
	/// Type of visual particles for the countdown.
	var/smoke_type = /particles/smoke/burning
	/// Key reserved for this component so other smoke on the mech is unaffected.
	var/smoke_key
	/// Whether the chassis also vents smoke during a manual ejection and on capsule launch.
	var/heavy_smoke = FALSE

/datum/component/golden_gardren_ejection/Initialize(heavy_smoke = FALSE)
	if(!istype(parent, /obj/vehicle/sealed/mecha))
		return COMPONENT_INCOMPATIBLE
	src.heavy_smoke = heavy_smoke
	if(heavy_smoke)
		smoke_type = /particles/smoke/burning/golden_gardren
	smoke_key = "golden_gardren_ejection_[smoke_type]"

/datum/component/golden_gardren_ejection/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_take_damage))

/datum/component/golden_gardren_ejection/UnregisterFromParent()
	var/obj/vehicle/sealed/mecha/mech = parent
	mech.remove_shared_particles(smoke_key)
	UnregisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE)

/datum/component/golden_gardren_ejection/Destroy(force)
	deltimer(timer)
	timer = null
	for(var/mob/pilot as anything in markers?.Copy())
		clear_landing_choice(pilot)
	landings = null
	return ..()

/// A blow that would destroy the manned mech puts it into its last countdown instead; a dying mech takes no more damage.
/datum/component/golden_gardren_ejection/proc/on_take_damage(datum/source, damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	SIGNAL_HANDLER
	var/obj/vehicle/sealed/mecha/mech = parent
	if(dying)
		return COMPONENT_NO_TAKE_DAMAGE
	if(damage_amount < mech.get_integrity() || !LAZYLEN(mech.occupants))
		return NONE
	start_dying()
	return COMPONENT_NO_TAKE_DAMAGE

/**
 * The mech goes down burning: it cannot move or fight, and it blows up when the ejection countdown runs out.
 * A countdown the pilots have already started themselves is not restarted.
 */
/datum/component/golden_gardren_ejection/proc/start_dying()
	var/obj/vehicle/sealed/mecha/mech = parent
	dying = TRUE
	mech.update_integrity(1)
	mech.completely_disabled = TRUE
	mech.log_message("Took a lethal blow, blowing up once the ejection countdown runs out.", LOG_MECHA)
	mech.visible_message(span_userdanger("[mech.declent_ru(NOMINATIVE)] охвачен огнём и вот-вот взорвётся!"))
	mech.add_shared_particles(smoke_type, smoke_key)
	mech.spark_system?.start()
	playsound(mech, 'sound/machines/warning-buzzer.ogg', 100, FALSE)
	start()

/// On a lethal hit the chassis ejects the pilots as part of its destruction.
/datum/component/golden_gardren_ejection/proc/finish_countdown()
	if(!dying)
		eject()
		return
	var/obj/vehicle/sealed/mecha/mech = parent
	mech.update_integrity(0)
	mech.atom_destruction()

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
	if(heavy_smoke && !dying)
		mech.add_shared_particles(smoke_type, smoke_key)
	for(var/mob/pilot as anything in mech.occupants)
		set_landing_cursor(pilot, aiming = TRUE)
	timer = addtimer(CALLBACK(src, PROC_REF(finish_countdown)), GOLDEN_GARDREN_EJECT_DELAY, TIMER_STOPPABLE)
	return TRUE

/// While the countdown runs, a pilot's click picks the landing turf instead of punching or shooting. Returns TRUE if the click was taken.
/datum/component/golden_gardren_ejection/proc/handle_click(mob/user, atom/target)
	if(!timer)
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
/datum/component/golden_gardren_ejection/proc/eject(use_capsules = TRUE, destroying = FALSE)
	var/obj/vehicle/sealed/mecha/mech = parent
	deltimer(timer)
	timer = null
	mech.remove_shared_particles(smoke_key)
	var/list/taken_turfs = list()
	var/launched = FALSE
	for(var/mob/living/pilot as anything in mech.occupants?.Copy())
		var/turf/landing = LAZYACCESS(landings, pilot)
		// The picked turf may have turned unsafe or been taken during the countdown.
		if(!landing || landing_blocker(landing) || (landing in taken_turfs))
			landing = golden_gardren_find_exit_turf(mech, taken_turfs)
		mech.mob_exit(pilot, silent = TRUE, forced = TRUE)
		if(QDELETED(pilot))
			continue
		if(use_capsules)
			var/capsule_time = landing ? GOLDEN_GARDREN_CAPSULE_TRANSIT + GOLDEN_GARDREN_CAPSULE_FALL + GOLDEN_GARDREN_CAPSULE_OPEN : 0
			pilot.Knockdown(GOLDEN_GARDREN_EJECT_KNOCKDOWN + capsule_time)
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
	if(heavy_smoke && (launched || destroying))
		var/turf/origin = get_turf(mech)
		if(origin)
			new /obj/effect/temp_visual/golden_gardren_smoke(origin)

/// Sends a pilot to [landing] in a rescue capsule that harms nothing where it lands and vanishes after opening.
/datum/component/golden_gardren_ejection/proc/launch_capsule(mob/living/pilot, turf/landing)
	return podspawn(list(
		"target" = landing,
		"style" = /datum/pod_style/advanced,
		"spawn" = pilot,
		"explosionSize" = list(0, 0, 0, 0),
		"bluespace" = TRUE,
		"delays" = list(
			POD_TRANSIT = GOLDEN_GARDREN_CAPSULE_TRANSIT,
			POD_FALLING = GOLDEN_GARDREN_CAPSULE_FALL,
			POD_OPENING = GOLDEN_GARDREN_CAPSULE_OPEN,
			POD_LEAVING = 1 SECONDS,
		),
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
	desc = "Запускает отсчёт до выброса пилотов в капсулах. До выброса каждый пилот может кликом выбрать безопасную клетку посадки поблизости. Отменить нельзя."
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

/particles/smoke/burning/golden_gardren
	count = 96
	spawning = 7
	lifespan = 2 SECONDS
	fade = 1.5 SECONDS
	position = generator(GEN_VECTOR, list(-10, 4, 0), list(10, 12, 0), UNIFORM_RAND)
	velocity = generator(GEN_VECTOR, list(-0.8, 0.5, 0), list(0.8, 1.2, 0), UNIFORM_RAND)

/particles/smoke/burning/golden_gardren/burst
	count = 48
	spawning = 9
	lifespan = 1.5 SECONDS
	fade = 1.2 SECONDS
	position = generator(GEN_VECTOR, list(-15, -6, 0), list(15, 10, 0), UNIFORM_RAND)
	velocity = generator(GEN_VECTOR, list(-2, 0, 0), list(2, 0.8, 0), UNIFORM_RAND)

/obj/effect/temp_visual/golden_gardren_smoke
	name = "cloud of smoke"
	duration = 3 SECONDS
	randomdir = FALSE

/obj/effect/temp_visual/golden_gardren_smoke/Initialize(mapload)
	. = ..()
	particles = new /particles/smoke/burning/golden_gardren/burst
	addtimer(CALLBACK(src, PROC_REF(stop_spawning)), 0.6 SECONDS)

/obj/effect/temp_visual/golden_gardren_smoke/Destroy()
	QDEL_NULL(particles)
	return ..()

/obj/effect/temp_visual/golden_gardren_smoke/proc/stop_spawning()
	particles.spawning = 0

#undef GOLDEN_GARDREN_EJECT_DELAY
#undef GOLDEN_GARDREN_EJECT_RANGE
#undef GOLDEN_GARDREN_EJECT_KNOCKDOWN
#undef GOLDEN_GARDREN_CAPSULE_TRANSIT
#undef GOLDEN_GARDREN_CAPSULE_FALL
#undef GOLDEN_GARDREN_CAPSULE_OPEN
