/// Base type for explicit redspace events. Events are kept outside SSredspace so they can be registered independently later.
/datum/redspace_event
	var/event_id
	var/profile_id

/datum/redspace_event/proc/start(client/admin)
	return FALSE

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

/datum/redspace_event/lightning/start(client/admin)
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
