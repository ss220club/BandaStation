/// Time between two summons.
#define GOLDEN_GARDREN_SUMMON_COOLDOWN (1 MINUTES)
/// How long the mech climbs into the sky before it is sent down.
#define GOLDEN_GARDREN_SUMMON_TAKEOFF (1.5 SECONDS)
/// How far from the summoner the mech may land, in tiles.
#define GOLDEN_GARDREN_SUMMON_RANGE 2
/// Drop timings in deciseconds: two seconds of warning over the landing spot, then the fall.
#define GOLDEN_GARDREN_SUMMON_DELAYS list(POD_TRANSIT = 20, POD_FALLING = 8, POD_OPENING = 1, POD_LEAVING = 1)
/// From launch to touchdown, in deciseconds.
#define GOLDEN_GARDREN_SUMMON_FLIGHT 28

/// Returns TRUE for any mech of the Golden-Gardren family.
/proc/is_golden_gardren_mech(atom/thing)
	return istype(thing, /obj/vehicle/sealed/mecha/golden) || istype(thing, /obj/vehicle/sealed/mecha/gardren) || istype(thing, /obj/vehicle/sealed/mecha/golden_gardren)

/**
 * ## Golden-Gardren summon implant
 *
 * Admin-only: not in any vendor, uplink, research node, map or loot table, only spawned by admins.
 * Activated inside a mech of the pair it binds to that mech; activated outside it calls the bound mech down next to the implantee.
 */
/obj/item/implant/golden_gardren_summon
	name = "\improper Golden-Gardren summon implant"
	desc = "Маячок вызова, связанный с одним мехом пары Голден-Гардрен."
	icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	icon_state = "summon"
	implant_color = "r"
	implant_info = "Активируется вручную. Внутри меха пары Голден-Гардрен привязывает имплант к этому меху. \
		Снаружи вызывает привязанный мех: тот взлетает, где бы ни был, и падает с неба рядом с владельцем. \
		Мех должен быть пустым; перезарядка — минута."
	implant_lore = "Экспериментальный маячок ЦК для ивентовых машин. Подаёт сигнал автопилоту меха, \
		который поднимает машину на реактивной тяге и сбрасывает её по координатам носителя."
	/// The mech this implant calls.
	var/datum/weakref/linked_mech
	COOLDOWN_DECLARE(summon_cooldown)

/obj/item/implant/golden_gardren_summon/on_activate()
	. = ..()
	var/mob/living/user = imp_in
	if(!user)
		return
	if(is_golden_gardren_mech(user.loc))
		linked_mech = WEAKREF(user.loc)
		balloon_alert(user, "мех привязан")
		return
	var/obj/vehicle/sealed/mecha/mech = get_linked_mech()
	if(!mech)
		balloon_alert(user, "мех не привязан!")
		to_chat(user, span_warning("Сядьте в Голдена, Гардрена или Голден-Гардрена и активируйте имплант, чтобы привязать его."))
		return
	var/turf/landing = find_landing(user)
	var/blocker = summon_blocker(mech, user, landing, check_cooldown = TRUE)
	if(blocker)
		balloon_alert(user, blocker)
		return
	COOLDOWN_START(src, summon_cooldown, GOLDEN_GARDREN_SUMMON_COOLDOWN)
	GLOB.golden_gardren_combining += mech
	user.log_message("summoned [mech] from [AREACOORD(mech)] with a summon implant.", LOG_GAME)
	to_chat(user, span_notice("Сигнал принят: [mech.declent_ru(NOMINATIVE)] вылетает к вам!"))
	take_off(mech)
	addtimer(CALLBACK(src, PROC_REF(launch), mech, user), GOLDEN_GARDREN_SUMMON_TAKEOFF)

/// The bound mech; a docked half answers through the combined frame it sits in.
/obj/item/implant/golden_gardren_summon/proc/get_linked_mech()
	var/obj/vehicle/sealed/mecha/mech = linked_mech?.resolve()
	if(istype(mech?.loc, /obj/vehicle/sealed/mecha/golden_gardren))
		mech = mech.loc
	return mech

/// Returns why [mech] cannot come down at [landing] for [user] right now, or null if it can.
/obj/item/implant/golden_gardren_summon/proc/summon_blocker(obj/vehicle/sealed/mecha/mech, mob/living/user, turf/landing, check_cooldown)
	if(QDELETED(mech))
		return "мех уничтожен"
	if(QDELETED(user) || !isturf(user.loc))
		return "нужно стоять на полу"
	if(check_cooldown && !COOLDOWN_FINISHED(src, summon_cooldown))
		return "имплант перезаряжается"
	if(!isturf(mech.loc))
		return "мех недоступен"
	if(length(mech.occupants))
		return "в мехе кто-то есть"
	if(mech.completely_disabled || mech.is_currently_ejecting || (check_cooldown && (mech in GLOB.golden_gardren_combining)))
		return "мех занят"
	var/obj/vehicle/sealed/mecha/golden_gardren/frame = mech
	if(istype(frame) && frame.emergency_eject_timer)
		return "мех занят"
	if(!landing)
		return "нет места для посадки"
	return null

/// Picks the closest free, visible floor around [user] the mech can land on.
/obj/item/implant/golden_gardren_summon/proc/find_landing(mob/living/user)
	var/turf/center = get_turf(user)
	if(!center)
		return null
	for(var/radius in 1 to GOLDEN_GARDREN_SUMMON_RANGE)
		var/list/candidates = list()
		for(var/turf/candidate in orange(radius, center))
			if(get_dist(center, candidate) != radius || !isopenturf(candidate) || isgroundlessturf(candidate))
				continue
			if(candidate.is_blocked_turf() || !can_see(center, candidate, radius))
				continue
			candidates += candidate
		if(length(candidates))
			return pick(candidates)
	return null

/// The mech fires its jets and climbs out of sight where it stands.
/obj/item/implant/golden_gardren_summon/proc/take_off(obj/vehicle/sealed/mecha/mech)
	var/turf/origin = get_turf(mech)
	// Nobody held in the claw goes up into the sky with it.
	golden_gardren_release_claw(mech)
	mech.visible_message(span_warning("[mech.declent_ru(NOMINATIVE)] с рёвом двигателей взмывает в небо!"))
	playsound(origin, 'sound/vehicles/rocketlaunch.ogg', 80, TRUE)
	for(var/turf/smoke_turf in range(1, origin))
		new /obj/effect/temp_visual/small_smoke/halfsecond(smoke_turf)
	animate(mech, pixel_z = mech.base_pixel_z + 10 * ICON_SIZE_Y, alpha = 0, time = GOLDEN_GARDREN_SUMMON_TAKEOFF, easing = QUAD_EASING | EASE_IN)

/// After the climb: send the mech down to the summoner, or put it back if anything changed in the meantime.
/obj/item/implant/golden_gardren_summon/proc/launch(obj/vehicle/sealed/mecha/mech, mob/living/user)
	GLOB.golden_gardren_combining -= mech
	if(QDELETED(mech))
		return
	animate(mech)
	mech.pixel_z = mech.base_pixel_z
	mech.alpha = initial(mech.alpha)
	var/turf/landing = (QDELETED(user) || user != imp_in) ? null : find_landing(user)
	var/blocker = (QDELETED(user) || user != imp_in) ? "носитель импланта пропал" : summon_blocker(mech, user, landing, check_cooldown = FALSE)
	if(blocker)
		mech.visible_message(span_warning("[mech.declent_ru(NOMINATIVE)] не находит цели и опускается обратно."))
		if(!QDELETED(user))
			to_chat(user, span_warning("Вызов сорвался: [blocker]."))
		return
	drop_mech(mech, landing)

/// Sends [mech] down onto [landing] in an invisible drop pod, so the mech itself is seen falling from the sky.
/obj/item/implant/golden_gardren_summon/proc/drop_mech(obj/vehicle/sealed/mecha/mech, turf/landing)
	mech.log_message("Summoned to [AREACOORD(landing)].", LOG_MECHA)
	podspawn(list(
		"target" = landing,
		"style" = /datum/pod_style/seethrough,
		"spawn" = mech,
		"explosionSize" = list(0, 0, 0, 0),
		"bluespace" = TRUE,
		"delays" = GOLDEN_GARDREN_SUMMON_DELAYS,
	))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_summon_impact), landing), GOLDEN_GARDREN_SUMMON_FLIGHT)

/// Touchdown: a heavy thud, dust and shaking screens around the landing spot.
/proc/golden_gardren_summon_impact(turf/landing)
	playsound(landing, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	playsound(landing, 'sound/effects/explosion/explosion_distant.ogg', 60, TRUE)
	new /obj/effect/temp_visual/mook_dust(landing)
	for(var/mob/living/witness in range(6, landing))
		shake_camera(witness, 4, 3)

/obj/item/implanter/golden_gardren_summon
	name = "implanter (Golden-Gardren summon)"
	imp_type = /obj/item/implant/golden_gardren_summon

#undef GOLDEN_GARDREN_SUMMON_COOLDOWN
#undef GOLDEN_GARDREN_SUMMON_TAKEOFF
#undef GOLDEN_GARDREN_SUMMON_RANGE
#undef GOLDEN_GARDREN_SUMMON_DELAYS
#undef GOLDEN_GARDREN_SUMMON_FLIGHT
