/// Base type for explicit redspace events. Events are kept outside SSredspace so they can be registered independently later.
/datum/redspace_event
	var/event_id
	var/profile_id
	/// Inclusive ordinary field range in which this event may run.
	var/min_value = 0
	var/max_value = REDSPACE_MAX_NORMAL_VALUE
	/// Event-only events require an explicit value above the ordinary ceiling.
	var/event_only = FALSE
	/// Metadata used by the future zone event budget.
	var/cooldown = 0
	var/budget_cost = 1
	var/dangerous = FALSE
	/// When true, the event remains alive after start() until it finishes itself.
	var/continues_after_start = FALSE

/datum/redspace_event/proc/can_start(turf/target)
	if(!target || !SSredspace || !SSredspace.is_supported_z(target.z))
		return FALSE

	var/value = SSredspace.get_value(target)
	if(isnull(value))
		return FALSE
	if(profile_id && (!SSredspace.context || SSredspace.context.active_profile_id != profile_id))
		return FALSE
	if(event_only)
		return value > REDSPACE_MAX_NORMAL_VALUE
	if(value < min_value || value > max_value)
		return FALSE
	return TRUE

/datum/redspace_event/proc/start(client/admin, turf/target)
	return FALSE

/datum/redspace_event/Destroy()
	if(SSredspace && src in SSredspace.active_events)
		SSredspace.active_events -= src
	return ..()

/// First safe content event: a short local distortion with no damage or forced status effect.
/datum/redspace_event/local_distortion
	event_id = "local_distortion"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = 4
	max_value = 6
	cooldown = 30 SECONDS
	budget_cost = 1
	dangerous = FALSE

/datum/redspace_event/local_distortion/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	SSredspace.notify_event_started(src, target, "локальное искажение началось")
	new /obj/effect/temp_visual/circle_wave/unsettle(target)
	playsound(target, 'sound/effects/ghost.ogg', 35, TRUE)
	target.visible_message(span_warning("Пространство в этой зоне на мгновение искажается."))
	if(admin)
		log_admin("[key_name(admin)] started a redspace local distortion at ([target.x], [target.y], [target.z]).")
		message_admins("[key_name_admin(admin)] запустил локальное искажение редспейса ([ADMIN_COORDJMP(target)]).")
	return TRUE

/// A telegraphed storm effect. Moving off the marked tile before the impact is the countermeasure.
/datum/redspace_event/storm_pulse
	event_id = "storm_pulse"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = 7
	max_value = 10
	cooldown = 45 SECONDS
	budget_cost = 2
	dangerous = TRUE
	continues_after_start = TRUE
	var/telegraph_timer_id
	var/turf/target_turf

/datum/redspace_event/storm_pulse/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	target_turf = target
	SSredspace.notify_event_started(src, target, "штормовой импульс телеграфирован")
	new /obj/effect/temp_visual/telegraphing/circle(target)
	playsound(target, 'sound/effects/magic/lightning_chargeup.ogg', 45, TRUE)
	target.visible_message(span_danger("Пространство вокруг этой точки начинает рваться. Покиньте отмеченный тайл!"))
	telegraph_timer_id = addtimer(CALLBACK(src, PROC_REF(resolve)), 2 SECONDS, TIMER_DELETE_ME)
	if(admin)
		log_admin("[key_name(admin)] started a redspace storm pulse at ([target.x], [target.y], [target.z]).")
		message_admins("[key_name_admin(admin)] запустил штормовой импульс редспейса ([ADMIN_COORDJMP(target)]).")
	return TRUE

/datum/redspace_event/storm_pulse/proc/resolve()
	telegraph_timer_id = null
	if(QDELETED(src))
		return

	var/turf/impact_turf = target_turf
	if(!impact_turf || QDELETED(impact_turf) || !SSredspace)
		if(SSredspace)
			SSredspace.finish_registered_event(src, impact_turf, "штормовой импульс отменён")
		return

	playsound(impact_turf, 'sound/effects/magic/lightningbolt.ogg', 60, TRUE)
	new /obj/effect/temp_visual/thunderbolt(impact_turf)
	impact_turf.visible_message(span_danger("Редспейсный разряд обрушивается на отмеченную точку!"))
	for(var/mob/living/victim in impact_turf)
		SSredspace.notify_exposure(victim, src, 10, "штормовой импульс редспейса")
		victim.adjust_fire_loss(10)
		victim.adjust_stamina_loss(35)
		victim.Paralyze(1 SECONDS)
		to_chat(victim, span_userdanger("Редспейсный разряд поражает вас!"), confidential = TRUE)
	SSredspace.finish_registered_event(src, impact_turf, "штормовой импульс завершён")

/datum/redspace_event/storm_pulse/Destroy()
	if(telegraph_timer_id)
		deltimer(telegraph_timer_id)
	telegraph_timer_id = null
	return ..()

/// First manual event used to verify target selection, logging, and visual exposure.
/datum/redspace_event/lightning
	event_id = "debug_lightning"
	profile_id = REDSPACE_PROFILE_DEMONIC
	var/impact_damage = 10
	var/stun_duration = 0

/datum/redspace_event/lightning/New(new_damage = 10, new_stun_duration = 0)
	. = ..()
	impact_damage = max(0, new_damage)
	stun_duration = max(0, new_stun_duration)

/datum/redspace_event/lightning/start(client/admin, turf/event_turf)
	if(!admin)
		return FALSE

	var/list/candidates = list()
	for(var/mob/living/candidate as anything in GLOB.alive_mob_list)
		var/turf/candidate_turf = get_turf(candidate)
		if(!candidate_turf || !SSredspace.is_supported_z(candidate_turf.z))
			continue
		if(istype(candidate, /mob/living/basic/demon))
			continue
		if(FACTION_HELL in candidate.faction)
			continue
		candidates += candidate

	if(!length(candidates))
		log_admin("[key_name(admin)] tried to start a redspace lightning strike, but no valid target was found.")
		message_admins("[key_name_admin(admin)] не смог запустить удар редспейсной молнии: подходящая цель не найдена.")
		return FALSE

	// Pick exactly once. The event does not keep rescanning for a target on later ticks.
	var/mob/living/target = pick(candidates)
	var/turf/target_turf = get_turf(target)
	var/turf/lightning_source = get_step(target_turf, NORTH)
	if(!lightning_source)
		lightning_source = target_turf
	SSredspace.notify_event_started(src, target_turf, "отладочный удар выбран")
	lightning_source.Beam(target, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(target_turf, 'sound/effects/magic/lightningbolt.ogg', 50, TRUE)
	SSredspace.notify_exposure(target, src, impact_damage, "удар редспейсной молнии")
	target.adjust_fire_loss(impact_damage)
	if(stun_duration)
		target.Paralyze(stun_duration)

	target.visible_message(
		span_danger("[target] поражён разрядом редспейсной молнии!"),
		span_userdanger("Вас поражает разряд редспейсной молнии!"),
		ignored_mobs = target,
	)
	to_chat(target, span_userdanger("Вас поражает разряд редспейсной молнии!"), confidential = TRUE)
	log_admin("[key_name(admin)] started redspace lightning strike on [key_name(target)] at ([target_turf.x], [target_turf.y], [target_turf.z]); damage [impact_damage], stun [stun_duration].")
	message_admins("[key_name_admin(admin)] запустил удар редспейсной молнии по [key_name_admin(target)] ([ADMIN_COORDJMP(target_turf)]).")
	SSredspace.notify_event_finished(src, target_turf, "отладочный удар завершён")
	return TRUE
