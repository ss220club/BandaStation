/// Base type for explicit redspace events. Events are kept outside SSredspace so they can be registered independently later.
/datum/redspace_event
	var/event_id
	var/profile_id
	/// Ordinary effects use the event budget. Spawn subclasses opt into their own budget.
	var/event_category = REDSPACE_EVENT_CATEGORY_EFFECT
	/// Inclusive ordinary field range in which this event may run.
	var/min_value = 0
	var/max_value = REDSPACE_MAX_NORMAL_VALUE
	/// Event-only events require an explicit value above the ordinary ceiling.
	var/event_only = FALSE
	/// Metadata used by the future zone event budget.
	var/cooldown = 0
	var/budget_cost = 1
	var/dangerous = FALSE
	/// Whether the controller may select this definition on a range transition.
	var/automatic = FALSE
	/// Relative weight when several automatic definitions are eligible.
	var/weight = 1
	/// When true, the event remains alive after start() until it finishes itself.
	var/continues_after_start = FALSE
	/// Zone key reserved by the controller for this event instance.
	var/budget_zone_key
	/// Stable target retained for lifecycle signals and cancellation cleanup.
	var/turf/event_target
	/// Optional source that caused the event, when a scenario can identify one.
	var/source_id
	/// Lifecycle signals are emitted at most once per event instance.
	var/event_started_notified = FALSE
	var/event_finished_notified = FALSE

/datum/redspace_event/proc/uses_spawn_budget()
	return FALSE

/datum/redspace_event/proc/get_spawn_category()
	return null

/datum/redspace_event/proc/get_spawn_count()
	return 0

/datum/redspace_event/proc/get_spawn_budget_cost()
	return 0

/datum/redspace_event/proc/can_start(turf/target)
	if(!target || !SSredspace || !SSredspace.is_supported_z(target.z))
		return FALSE

	var/value = SSredspace.get_value(target)
	if(isnull(value))
		return FALSE
	var/datum/redspace_profile/active_profile = SSredspace.context?.active_profile
	if(profile_id && (!active_profile || active_profile.profile_id != profile_id || !active_profile.is_event_allowed(event_id)))
		return FALSE
	if(event_only)
		return value > REDSPACE_MAX_NORMAL_VALUE
	if(value < min_value || value > max_value)
		return FALSE
	return TRUE

/datum/redspace_event/proc/start(client/admin, turf/target)
	return FALSE

/datum/redspace_event/Destroy()
	if(SSredspace)
		if(src in SSredspace.active_events)
			var/zone_key = budget_zone_key
			SSredspace.active_events -= src
			SSredspace.release_event_budget(src)
			SSredspace.notify_event_finished(src, event_target, "событие уничтожено")
			SSredspace.cleanup_event_budget(zone_key)
			SSredspace.prune_event_cell(zone_key)
			SSredspace.wake()
	return ..()

/// Abstract event family for content that leaves a turf, object or mob behind.
/// Concrete profile content should inherit one of the typed children below and provide event_id/start().
/datum/redspace_event/spawn
	abstract_type = /datum/redspace_event/spawn
	event_category = REDSPACE_EVENT_CATEGORY_SPAWN
	/// Spawn events normally remain registered until their created content is cleaned up.
	continues_after_start = TRUE
	/// Spawn budget values are intentionally independent from budget_cost/dangerous.
	budget_cost = 0
	var/spawn_count = 1
	var/spawn_budget_cost = 1
	var/spawn_policy_id
	var/list/spawned_atoms = list()

/datum/redspace_event/spawn/uses_spawn_budget()
	return TRUE

/datum/redspace_event/spawn/get_spawn_category()
	return event_category

/datum/redspace_event/spawn/get_spawn_count()
	if(!isnum(spawn_count))
		return 0
	return max(round(spawn_count), 0)

/datum/redspace_event/spawn/get_spawn_budget_cost()
	if(!isnum(spawn_budget_cost))
		return 0
	return max(spawn_budget_cost, 0)

/// Keeps the lifecycle event aware of persistent content without making SSredspace scan the map.
/datum/redspace_event/spawn/proc/register_spawned_atom(atom/spawned_atom)
	if(!spawned_atom || QDELETED(spawned_atom))
		return FALSE
	if(spawned_atom in spawned_atoms)
		return TRUE
	spawned_atoms |= spawned_atom
	RegisterSignal(spawned_atom, COMSIG_QDELETING, PROC_REF(on_spawned_atom_deleted))
	return TRUE

/datum/redspace_event/spawn/proc/on_spawned_atom_deleted(atom/deleted_atom)
	SIGNAL_HANDLER
	UnregisterSignal(deleted_atom, COMSIG_QDELETING, PROC_REF(on_spawned_atom_deleted))
	spawned_atoms -= deleted_atom
	if(length(spawned_atoms) || !continues_after_start || !SSredspace || !(src in SSredspace.active_events))
		return
	SSredspace.finish_registered_event(src, event_target, "оставленное содержимое редспейса исчезло")

/datum/redspace_event/spawn/Destroy()
	for(var/atom/spawned_atom as anything in spawned_atoms)
		if(spawned_atom)
			UnregisterSignal(spawned_atom, COMSIG_QDELETING)
	spawned_atoms.Cut()
	return ..()

/// Future events that replace or create terrain.
/datum/redspace_event/spawn/turf
	abstract_type = /datum/redspace_event/spawn/turf
	event_category = REDSPACE_EVENT_CATEGORY_TURF_SPAWN

/// Future events that create persistent objects or scenery.
/datum/redspace_event/spawn/object
	abstract_type = /datum/redspace_event/spawn/object
	event_category = REDSPACE_EVENT_CATEGORY_OBJECT_SPAWN

/// Future events that create redspace creatures.
/datum/redspace_event/spawn/mob
	abstract_type = /datum/redspace_event/spawn/mob
	event_category = REDSPACE_EVENT_CATEGORY_MOB_SPAWN
	var/spawn_type
	var/spawn_message
	var/spawn_timer_id

/datum/redspace_event/spawn/mob/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE
	var/datum/redspace_profile/active_profile = SSredspace.context?.active_profile
	if(active_profile)
		active_profile.play_mob_spawn_telegraph(target)
	spawn_timer_id = addtimer(CALLBACK(src, PROC_REF(resolve_spawn)), REDSPACE_MOB_SPAWN_TELEGRAPH_DURATION, TIMER_STOPPABLE | TIMER_DELETE_ME)
	return TRUE

/datum/redspace_event/spawn/mob/proc/resolve_spawn()
	spawn_timer_id = null
	if(QDELETED(src) || !SSredspace || !(src in SSredspace.active_events))
		return
	var/turf/target = event_target
	if(!can_start(target))
		SSredspace.finish_registered_event(src, target, "спавн моба отменён")
		return
	var/mob/living/spawned_mob = new spawn_type(target)
	if(!spawned_mob || QDELETED(spawned_mob))
		SSredspace.finish_registered_event(src, target, "спавн моба не удался")
		return
	if(!register_spawned_atom(spawned_mob))
		qdel(spawned_mob)
		SSredspace.finish_registered_event(src, target, "спавн моба не удался")
		return
	var/datum/redspace_profile/active_profile = SSredspace.context?.active_profile
	if(active_profile)
		active_profile.play_mob_spawn_arrival(target)
	target.visible_message(span_warning(spawn_message))

/datum/redspace_event/spawn/mob/Destroy()
	if(spawn_timer_id)
		deltimer(spawn_timer_id)
	spawn_timer_id = null
	return ..()

/// Per-hex event budget. It is created only for zones that actually attempt an event.
/datum/redspace_event_budget
	var/zone_key
	var/window_started
	var/spent_points = 0
	var/last_event_time = 0
	var/active_event_count = 0
	var/active_dangerous_count = 0
	var/list/reserved_events = list()
	/// Spawn reservations are tracked separately from ordinary effect reservations.
	var/spawn_window_started
	var/spawn_spent_points = 0
	var/last_spawn_event_time = 0
	var/active_spawn_event_count = 0
	var/active_spawn_turf_count = 0
	var/active_spawn_object_count = 0
	var/active_spawn_mob_count = 0
	var/list/reserved_spawn_events = list()
	/// Next state-profile attempt for this active zone. Zero means unscheduled.
	var/next_attempt_at = 0
	var/scheduled_state

/datum/redspace_event_budget/New(new_zone_key)
	. = ..()
	zone_key = new_zone_key
	window_started = world.time
	spawn_window_started = world.time

/datum/redspace_event_budget/proc/reset_window()
	if(world.time - window_started < REDSPACE_EVENT_BUDGET_WINDOW)
		return
	window_started = world.time
	spent_points = 0

/datum/redspace_event_budget/proc/reset_spawn_window()
	if(world.time - spawn_window_started < REDSPACE_SPAWN_BUDGET_WINDOW)
		return
	spawn_window_started = world.time
	spawn_spent_points = 0

/datum/redspace_event_budget/proc/can_start(datum/redspace_event/event)
	if(!event)
		return FALSE
	if(event.uses_spawn_budget())
		return can_start_spawn(event)
	reset_window()
	if(active_event_count >= REDSPACE_EVENT_BUDGET_MAX_ACTIVE)
		return FALSE
	if(event.dangerous && active_dangerous_count >= REDSPACE_EVENT_BUDGET_MAX_DANGEROUS)
		return FALSE
	if(last_event_time && world.time < last_event_time + REDSPACE_EVENT_BUDGET_COOLDOWN)
		return FALSE
	var/event_cost = max(event.budget_cost, 0)
	return spent_points + event_cost <= REDSPACE_EVENT_BUDGET_MAX_POINTS

/datum/redspace_event_budget/proc/can_start_spawn(datum/redspace_event/event)
	if(!event || !event.uses_spawn_budget())
		return FALSE
	reset_spawn_window()
	if(active_spawn_event_count >= REDSPACE_SPAWN_BUDGET_MAX_ACTIVE_EVENTS)
		return FALSE
	if(last_spawn_event_time && world.time < last_spawn_event_time + REDSPACE_SPAWN_BUDGET_COOLDOWN)
		return FALSE

	var/spawn_category = event.get_spawn_category()
	var/spawn_count = event.get_spawn_count()
	var/category_limit = get_spawn_category_limit(spawn_category)
	if(!category_limit || spawn_count <= 0 || get_spawn_category_count(spawn_category) + spawn_count > category_limit)
		return FALSE

	var/spawn_cost = max(event.get_spawn_budget_cost(), 0)
	return spawn_spent_points + spawn_cost <= REDSPACE_SPAWN_BUDGET_MAX_POINTS

/datum/redspace_event_budget/proc/get_spawn_category_limit(spawn_category)
	switch(spawn_category)
		if(REDSPACE_EVENT_CATEGORY_TURF_SPAWN)
			return REDSPACE_SPAWN_BUDGET_MAX_TURFS
		if(REDSPACE_EVENT_CATEGORY_OBJECT_SPAWN)
			return REDSPACE_SPAWN_BUDGET_MAX_OBJECTS
		if(REDSPACE_EVENT_CATEGORY_MOB_SPAWN)
			return REDSPACE_SPAWN_BUDGET_MAX_MOBS
	return 0

/datum/redspace_event_budget/proc/get_spawn_category_count(spawn_category)
	switch(spawn_category)
		if(REDSPACE_EVENT_CATEGORY_TURF_SPAWN)
			return active_spawn_turf_count
		if(REDSPACE_EVENT_CATEGORY_OBJECT_SPAWN)
			return active_spawn_object_count
		if(REDSPACE_EVENT_CATEGORY_MOB_SPAWN)
			return active_spawn_mob_count
	return 0

/datum/redspace_event_budget/proc/adjust_spawn_category_count(spawn_category, amount)
	switch(spawn_category)
		if(REDSPACE_EVENT_CATEGORY_TURF_SPAWN)
			active_spawn_turf_count = max(active_spawn_turf_count + amount, 0)
		if(REDSPACE_EVENT_CATEGORY_OBJECT_SPAWN)
			active_spawn_object_count = max(active_spawn_object_count + amount, 0)
		if(REDSPACE_EVENT_CATEGORY_MOB_SPAWN)
			active_spawn_mob_count = max(active_spawn_mob_count + amount, 0)

/datum/redspace_event_budget/proc/reserve(datum/redspace_event/event)
	if(!event)
		return FALSE
	if(event.uses_spawn_budget())
		return reserve_spawn(event)
	if(!isnull(reserved_events[event]) || !can_start(event))
		return FALSE
	var/event_cost = max(event.budget_cost, 0)
	reserved_events[event] = event_cost
	spent_points += event_cost
	active_event_count++
	if(event.dangerous)
		active_dangerous_count++
	last_event_time = world.time
	return TRUE

/datum/redspace_event_budget/proc/reserve_spawn(datum/redspace_event/event)
	if(!event || !event.uses_spawn_budget() || !isnull(reserved_spawn_events[event]) || !can_start_spawn(event))
		return FALSE
	var/spawn_cost = max(event.get_spawn_budget_cost(), 0)
	var/spawn_count = event.get_spawn_count()
	var/spawn_category = event.get_spawn_category()
	reserved_spawn_events[event] = list(
		"cost" = spawn_cost,
		"count" = spawn_count,
		"category" = spawn_category,
	)
	spawn_spent_points += spawn_cost
	active_spawn_event_count++
	adjust_spawn_category_count(spawn_category, spawn_count)
	last_spawn_event_time = world.time
	return TRUE

/datum/redspace_event_budget/proc/release(datum/redspace_event/event, refund = FALSE)
	if(!event)
		return FALSE
	if(event.uses_spawn_budget())
		return release_spawn(event, refund)
	if(isnull(reserved_events[event]))
		return FALSE
	var/event_cost = reserved_events[event]
	reserved_events -= event
	active_event_count = max(active_event_count - 1, 0)
	if(event.dangerous)
		active_dangerous_count = max(active_dangerous_count - 1, 0)
	if(refund)
		spent_points = max(spent_points - event_cost, 0)
		if(last_event_time == world.time)
			last_event_time = 0
	return TRUE

/datum/redspace_event_budget/proc/release_spawn(datum/redspace_event/event, refund = FALSE)
	if(!event || !event.uses_spawn_budget() || isnull(reserved_spawn_events[event]))
		return FALSE
	var/list/reservation = reserved_spawn_events[event]
	reserved_spawn_events -= event
	active_spawn_event_count = max(active_spawn_event_count - 1, 0)
	adjust_spawn_category_count(reservation["category"], -reservation["count"])
	if(refund)
		spawn_spent_points = max(spawn_spent_points - reservation["cost"], 0)
		if(last_spawn_event_time == world.time)
			last_spawn_event_time = 0
	return TRUE

/// First safe content event: a short local distortion with no damage or forced status effect.
/datum/redspace_event/calm_echo
	event_id = "calm_echo"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = 0
	max_value = 3
	cooldown = 90 SECONDS
	budget_cost = 1
	dangerous = FALSE
	automatic = TRUE
	weight = 1

/datum/redspace_event/calm_echo/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	SSredspace.notify_event_started(src, target, "слабый отклик редспейса начался")
	if(QDELETED(src) || !(src in SSredspace.active_events))
		return FALSE
	target.flash_lighting_fx(
		range = 2,
		power = 0.45,
		color = LIGHT_COLOR_ORANGE,
		duration = 0.5 SECONDS,
	)
	playsound(target, 'sound/effects/ghost.ogg', 20, TRUE)
	target.visible_message(span_notice("В пространстве проходит едва заметная рябь."))
	if(admin)
		log_admin("[key_name(admin)] started a redspace calm echo at ([target.x], [target.y], [target.z]).")
		message_admins("[key_name_admin(admin)] запустил слабый отклик редспейса ([ADMIN_COORDJMP(target)]).")
	return TRUE

/// First safe content event: a short local distortion with no damage or forced status effect.
/datum/redspace_event/local_distortion
	event_id = "local_distortion"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = 4
	max_value = 6
	cooldown = 30 SECONDS
	budget_cost = 1
	dangerous = FALSE
	automatic = TRUE
	weight = 1

/datum/redspace_event/local_distortion/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	SSredspace.notify_event_started(src, target, "локальное искажение началось")
	if(QDELETED(src) || !(src in SSredspace.active_events))
		return FALSE
	// Keep the atmosphere local and event-driven: one temporary source, no station-wide light pass.
	target.flash_lighting_fx(
		range = 3,
		power = 1.25,
		color = LIGHT_COLOR_ORANGE,
		duration = 1 SECONDS,
	)
	new /obj/effect/temp_visual/circle_wave/unsettle(target)
	playsound(target, 'sound/effects/ghost.ogg', 35, TRUE)
	target.visible_message(span_warning("Пространство на мгновение искажается."))
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
	automatic = TRUE
	weight = 1
	continues_after_start = TRUE
	var/telegraph_timer_id
	var/turf/target_turf

/datum/redspace_event/storm_pulse/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	target_turf = target
	SSredspace.notify_event_started(src, target, "штормовой импульс телеграфирован")
	if(QDELETED(src) || !(src in SSredspace.active_events))
		return FALSE
	target.flash_lighting_fx(
		range = 3,
		power = 0.8,
		color = LIGHT_COLOR_FIRE,
		duration = 2 SECONDS,
	)
	new /obj/effect/temp_visual/telegraphing/circle(target)
	playsound(target, 'sound/effects/magic/lightning_chargeup.ogg', 45, TRUE)
	target.visible_message(span_danger("Пространство начинает рваться!"))
	telegraph_timer_id = addtimer(CALLBACK(src, PROC_REF(resolve)), 2 SECONDS, TIMER_STOPPABLE | TIMER_DELETE_ME)
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

	impact_turf.flash_lighting_fx(
		range = 4,
		power = 2,
		color = LIGHT_COLOR_ORANGE,
		duration = 0.5 SECONDS,
	)
	playsound(impact_turf, 'sound/effects/magic/lightningbolt.ogg', 60, TRUE)
	new /obj/effect/temp_visual/thunderbolt(impact_turf)
	impact_turf.visible_message(span_danger("Разряд редспейса обрушивается из ниоткуда!"))
	for(var/mob/living/victim in impact_turf)
		SSredspace.notify_exposure(victim, src, 10, "штормовой импульс редспейса")
		victim.adjust_fire_loss(10)
		victim.adjust_stamina_loss(35)
		victim.Paralyze(1 SECONDS)
		to_chat(victim, span_userdanger("Разряд редспейса поражает вас!"), confidential = TRUE)
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
	var/telegraph_timer_id
	var/mob/living/target
	var/turf/target_turf

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
		if(candidate.has_faction(FACTION_HELL))
			continue
		candidates += candidate

	if(!length(candidates))
		log_admin("[key_name(admin)] tried to start a redspace lightning strike, but no valid target was found.")
		message_admins("[key_name_admin(admin)] не смог запустить удар молнии редспейса: подходящая цель не найдена.")
		return FALSE

	// Pick exactly once. The event does not keep rescanning for a target on later ticks.
	target = pick(candidates)
	target_turf = get_turf(target)
	if(!target_turf)
		return FALSE
	event_target = target_turf
	if(!(src in SSredspace.active_events))
		SSredspace.active_events += src
	SSredspace.notify_event_started(src, target_turf, "отладочный удар выбран")
	target_turf.flash_lighting_fx(
		range = 3,
		power = 0.8,
		color = LIGHT_COLOR_FIRE,
		duration = 2 SECONDS,
	)
	new /obj/effect/temp_visual/telegraphing/circle(target_turf)
	playsound(target_turf, 'sound/effects/magic/lightning_chargeup.ogg', 45, TRUE)
	target_turf.visible_message(span_warning("В воздухе накапливается разряд молнии редспейса!"))
	telegraph_timer_id = addtimer(CALLBACK(src, PROC_REF(resolve)), 2 SECONDS, TIMER_STOPPABLE | TIMER_DELETE_ME)
	log_admin("[key_name(admin)] telegraphed a redspace lightning strike on [key_name(target)] at ([target_turf.x], [target_turf.y], [target_turf.z]); damage [impact_damage].")
	message_admins("[key_name_admin(admin)] телеграфировал удар молнии редспейса по [key_name_admin(target)] ([ADMIN_COORDJMP(target_turf)]).")
	return TRUE

/datum/redspace_event/lightning/proc/resolve()
	telegraph_timer_id = null
	if(QDELETED(src))
		return

	var/mob/living/impact_target = target
	var/turf/impact_turf = get_turf(impact_target)
	if(!impact_target || QDELETED(impact_target) || impact_target.stat == DEAD || !impact_turf || QDELETED(impact_turf) || !SSredspace || !SSredspace.is_supported_z(impact_turf.z))
		if(SSredspace)
			SSredspace.active_events -= src
			SSredspace.notify_event_finished(src, target_turf, "отладочный удар отменён: цель недоступна")
		qdel(src)
		return

	var/turf/lightning_source = get_step(impact_turf, NORTH)
	if(!lightning_source)
		lightning_source = impact_turf
	lightning_source.Beam(impact_target, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(impact_turf, 'sound/effects/magic/lightningbolt.ogg', 50, TRUE)
	new /obj/effect/temp_visual/thunderbolt(impact_turf)
	SSredspace.notify_exposure(impact_target, src, impact_damage, "удар молнии редспейса")
	impact_target.adjust_fire_loss(impact_damage)
	impact_target.visible_message(
		span_danger("[impact_target] поражён разрядом молнии редспейса!"),
		span_userdanger("Вас поражает разряд молнии редспейса!"),
		ignored_mobs = impact_target,
	)
	to_chat(impact_target, span_userdanger("Вас поражает разряд молнии редспейса!"), confidential = TRUE)
	log_admin("Redspace lightning strike hit [key_name(impact_target)] at ([impact_turf.x], [impact_turf.y], [impact_turf.z]); damage [impact_damage].")
	message_admins("Удар молнии редспейса по [key_name_admin(impact_target)] ([ADMIN_COORDJMP(impact_turf)]).")
	SSredspace.active_events -= src
	SSredspace.notify_event_finished(src, impact_turf, "отладочный удар завершён")
	qdel(src)

/datum/redspace_event/lightning/Destroy()
	if(telegraph_timer_id)
		deltimer(telegraph_timer_id)
	telegraph_timer_id = null
	return ..()
