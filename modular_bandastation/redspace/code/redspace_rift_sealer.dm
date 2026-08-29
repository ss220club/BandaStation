GLOBAL_LIST_EMPTY(redspace_active_rift_sealers)

/// Hotspots grow in discrete one-minute steps so their field cache is not rebuilt every machinery tick.
/datum/redspace_field_source/hotspot
	var/growth_last_update_at
	var/sealing_active = FALSE
	var/sealing_original_strength
	var/sealing_timer_id = TIMER_ID_NULL
	var/sealing_finishes_at = 0
	var/list/sealing_machines = list()

/datum/redspace_field_source/hotspot/New(new_id, turf/origin, new_strength, new_radius, new_profile_id, new_lifetime = null, new_reason = null)
	. = ..()
	growth_last_update_at = world.time

/datum/redspace_field_source/hotspot/requires_processing()
	return ..() || (!sealing_active && strength > 0 && (strength < REDSPACE_MAX_NORMAL_VALUE || radius < REDSPACE_MAX_SOURCE_RADIUS))

/datum/redspace_field_source/hotspot/set_strength(new_strength, reason = null)
	var/changed = ..()
	if(changed)
		growth_last_update_at = world.time
	return changed

/datum/redspace_field_source/hotspot/set_radius(new_radius, reason = null)
	if(!isnum(new_radius))
		return FALSE
	new_radius = clamp(new_radius, 0, REDSPACE_MAX_SOURCE_RADIUS)
	if(radius == new_radius)
		return FALSE
	radius = new_radius
	radius_squared = radius * radius
	reset_coverage_cache()
	change_reason = reason
	var/changed = TRUE
	if(changed)
		growth_last_update_at = world.time
	return changed

/datum/redspace_field_source/hotspot/proc/get_growth_update() as /list
	if(sealing_active || isnull(growth_last_update_at))
		return
	if(strength <= 0)
		growth_last_update_at = world.time
		return

	var/elapsed_minutes = floor((world.time - growth_last_update_at) / REDSPACE_HOTSPOT_GROWTH_INTERVAL)
	if(elapsed_minutes <= 0)
		return
	growth_last_update_at += elapsed_minutes * REDSPACE_HOTSPOT_GROWTH_INTERVAL

	return list(
		min(REDSPACE_MAX_NORMAL_VALUE, strength + REDSPACE_HOTSPOT_STRENGTH_GROWTH_PER_MINUTE * elapsed_minutes),
		min(REDSPACE_MAX_SOURCE_RADIUS, radius + REDSPACE_HOTSPOT_RADIUS_GROWTH_PER_MINUTE * elapsed_minutes),
	)

/datum/redspace_field_source/hotspot/proc/process_growth()
	var/list/growth_update = get_growth_update()
	if(!length(growth_update) || !SSredspace || SSredspace.field_sources["[source_id]"] != src)
		return FALSE

	var/changed = FALSE
	if(growth_update[1] != strength)
		if(SSredspace.update_source_strength(source_id, growth_update[1], "горячая зона усиливается со временем"))
			changed = TRUE
	if(growth_update[2] != radius)
		if(SSredspace.update_source_radius(source_id, growth_update[2], "радиус горячей зоны увеличивается со временем"))
			changed = TRUE
	return changed

/// Adds a machine to the shared sealing operation for this hotspot.
/datum/redspace_field_source/hotspot/proc/start_sealing(obj/machinery/redspace_rift_sealer/sealer)
	if(!sealer || QDELETED(sealer) || !SSredspace || SSredspace.field_sources["[source_id]"] != src || strength <= 0)
		return FALSE

	if(!(sealer in sealing_machines))
		sealing_machines += sealer
		RegisterSignal(sealer, COMSIG_QDELETING, PROC_REF(on_sealing_machine_deleted))

	if(sealing_active)
		return TRUE

	sealing_active = TRUE
	sealing_original_strength = strength
	growth_last_update_at = world.time
	sealing_finishes_at = world.time + rand(REDSPACE_RIFT_SEALING_MIN_DURATION, REDSPACE_RIFT_SEALING_MAX_DURATION)
	sealing_timer_id = addtimer(CALLBACK(src, PROC_REF(complete_sealing)), sealing_finishes_at - world.time, TIMER_STOPPABLE | TIMER_DELETE_ME)
	if(strength != REDSPACE_RIFT_SEALING_TARGET_STRENGTH)
		SSredspace.update_source_strength(source_id, REDSPACE_RIFT_SEALING_TARGET_STRENGTH, "начата процедура закрытия разлома")
	return TRUE

/datum/redspace_field_source/hotspot/proc/remove_sealer(obj/machinery/redspace_rift_sealer/sealer, reason = "установка закрытия отключена")
	if(!sealer || !(sealer in sealing_machines))
		return FALSE
	sealing_machines -= sealer
	UnregisterSignal(sealer, COMSIG_QDELETING, PROC_REF(on_sealing_machine_deleted))
	if(!length(sealing_machines))
		stop_sealing(reason)
	return TRUE

/datum/redspace_field_source/hotspot/proc/stop_sealing(reason = "процедура закрытия прервана")
	if(!sealing_active)
		return FALSE
	if(sealing_timer_id != TIMER_ID_NULL)
		deltimer(sealing_timer_id)
	sealing_timer_id = TIMER_ID_NULL
	sealing_finishes_at = 0
	sealing_active = FALSE
	growth_last_update_at = world.time

	var/restore_strength = sealing_original_strength
	sealing_original_strength = null
	if(isnum(restore_strength) && SSredspace && SSredspace.field_sources["[source_id]"] == src && strength != restore_strength)
		SSredspace.update_source_strength(source_id, restore_strength, reason)
	return TRUE

/datum/redspace_field_source/hotspot/proc/complete_sealing()
	sealing_timer_id = TIMER_ID_NULL
	if(!sealing_active || QDELETED(src))
		return FALSE

	sealing_active = FALSE
	sealing_finishes_at = 0
	sealing_original_strength = null
	growth_last_update_at = world.time

	var/turf/origin = locate(origin_x, origin_y, z_level)
	if(origin)
		origin.visible_message(span_notice("Разлом редспейса схлопывается и закрывается."))
		origin.flash_lighting_fx(range = 3, power = 1.5, color = LIGHT_COLOR_ORANGE, duration = 1 SECONDS)
		new /obj/effect/temp_visual/circle_wave(origin, "#ff5500")
		playsound(origin, 'sound/effects/magic/teleport_app.ogg', 60, TRUE)

	for(var/obj/machinery/redspace_rift_sealer/sealer as anything in sealing_machines.Copy())
		if(!sealer)
			continue
		UnregisterSignal(sealer, COMSIG_QDELETING, PROC_REF(on_sealing_machine_deleted))
		if(!QDELETED(sealer))
			sealer.on_rift_sealed(src)
	sealing_machines.Cut()

	if(SSredspace && SSredspace.field_sources["[source_id]"] == src)
		SSredspace.remove_source(source_id, "разлом закрыт")
	return TRUE

/datum/redspace_field_source/hotspot/proc/on_sealing_machine_deleted(obj/machinery/redspace_rift_sealer/sealer)
	SIGNAL_HANDLER
	remove_sealer(sealer, "установка закрытия уничтожена")

/datum/redspace_field_source/hotspot/Destroy()
	if(sealing_timer_id != TIMER_ID_NULL)
		deltimer(sealing_timer_id)
	sealing_timer_id = TIMER_ID_NULL
	for(var/obj/machinery/redspace_rift_sealer/sealer as anything in sealing_machines.Copy())
		if(!sealer)
			continue
		UnregisterSignal(sealer, COMSIG_QDELETING, PROC_REF(on_sealing_machine_deleted))
		if(!QDELETED(sealer))
			sealer.on_rift_source_removed(src)
	sealing_machines.Cut()
	return ..()

/// Players install this machine near a hotspot to start a timed sealing operation.
/obj/machinery/redspace_rift_sealer
	name = "redspace rift sealer"
	desc = "An engineering machine that forces a nearby redspace rift to collapse."
	icon = 'modular_bandastation/redspace/icons/obj/machinery_32x32.dmi'
	icon_state = "rift_sealer_off"
	density = TRUE
	anchored = FALSE
	max_integrity = 250
	uses_integrity = TRUE
	circuit = /obj/item/circuitboard/machine/redspace_rift_sealer
	use_power = NO_POWER_USE
	processing_flags = START_PROCESSING_MANUALLY
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN

	var/datum/redspace_field_source/hotspot/target_source
	var/active = FALSE
	var/closed = FALSE

/obj/machinery/redspace_rift_sealer/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_anchor_changed))
	update_sealer_appearance()
	return .

/obj/machinery/redspace_rift_sealer/post_machine_initialize()
	. = ..()
	if(anchored)
		try_start_sealing()

/obj/machinery/redspace_rift_sealer/Destroy()
	stop_sealing("установка закрытия уничтожена")
	if(target_source)
		UnregisterSignal(target_source, COMSIG_REDSPACE_SOURCE_CHANGED, PROC_REF(on_source_changed))
	GLOB.redspace_active_rift_sealers -= src
	return ..()

/obj/machinery/redspace_rift_sealer/proc/on_anchor_changed(atom/source, is_anchored)
	SIGNAL_HANDLER
	if(is_anchored)
		try_start_sealing()
	else
		stop_sealing("установка закрытия откреплена")

/obj/machinery/redspace_rift_sealer/proc/try_start_sealing(mob/user)
	if(active || closed || !anchored || machine_stat & BROKEN || !SSredspace?.initialized)
		return FALSE

	var/datum/redspace_field_source/hotspot/hotspot = SSredspace.get_nearest_hotspot(get_turf(src), REDSPACE_RIFT_SEALER_PLACEMENT_RADIUS)
	if(!hotspot)
		return FALSE

	target_source = hotspot
	RegisterSignal(target_source, COMSIG_REDSPACE_SOURCE_CHANGED, PROC_REF(on_source_changed))
	if(!target_source.start_sealing(src))
		UnregisterSignal(target_source, COMSIG_REDSPACE_SOURCE_CHANGED, PROC_REF(on_source_changed))
		target_source = null
		return FALSE

	active = TRUE
	GLOB.redspace_active_rift_sealers |= src
	begin_processing()
	update_sealer_appearance()
	visible_message(span_warning("[src] начинает процедуру закрытия разлома. Демонические существа устремляются к установке."))
	return TRUE

/obj/machinery/redspace_rift_sealer/proc/stop_sealing(reason = "процедура закрытия прервана")
	if(!active)
		return FALSE

	var/datum/redspace_field_source/hotspot/source = target_source
	active = FALSE
	GLOB.redspace_active_rift_sealers -= src
	if(source)
		UnregisterSignal(source, COMSIG_REDSPACE_SOURCE_CHANGED, PROC_REF(on_source_changed))
	target_source = null
	end_processing()
	if(source && !QDELETED(source))
		source.remove_sealer(src, reason)
	update_sealer_appearance()
	return TRUE

/obj/machinery/redspace_rift_sealer/proc/on_source_changed(
	datum/redspace_field_source/source,
	change_type,
	source_profile_id,
	old_value,
	new_value,
	reason,
)
	SIGNAL_HANDLER
	if(source != target_source || change_type != REDSPACE_SOURCE_CHANGE_REMOVED)
		return
	on_rift_source_removed(source, reason)

/obj/machinery/redspace_rift_sealer/proc/on_rift_source_removed(datum/redspace_field_source/source, reason)
	if(source != target_source)
		return
	UnregisterSignal(source, COMSIG_REDSPACE_SOURCE_CHANGED, PROC_REF(on_source_changed))
	var/was_active = active
	active = FALSE
	GLOB.redspace_active_rift_sealers -= src
	target_source = null
	end_processing()
	update_sealer_appearance()
	if(was_active)
		visible_message(span_warning("[src] теряет связь с разломом: процедура закрытия прервана."))

/obj/machinery/redspace_rift_sealer/proc/on_rift_sealed(datum/redspace_field_source/source)
	if(source != target_source)
		return
	UnregisterSignal(source, COMSIG_REDSPACE_SOURCE_CHANGED, PROC_REF(on_source_changed))
	active = FALSE
	closed = TRUE
	GLOB.redspace_active_rift_sealers -= src
	target_source = null
	end_processing()
	update_sealer_appearance()
	visible_message(span_notice("[src] подтверждает закрытие разлома."))

/obj/machinery/redspace_rift_sealer/process(seconds_per_tick)
	if(!active)
		return PROCESS_KILL
	if(machine_stat & (BROKEN | NOPOWER | MAINT | EMPED) || !is_operational || !anchored)
		stop_sealing("установка закрытия больше не работоспособна")
		return PROCESS_KILL
	if(!target_source)
		stop_sealing("установка закрытия потеряла источник разлома")
		return PROCESS_KILL
	if(QDELETED(target_source) || SSredspace?.field_sources["[target_source.source_id]"] != target_source)
		on_rift_source_removed(target_source, "источник разлома исчез")
		return PROCESS_KILL
	return

/obj/machinery/redspace_rift_sealer/on_set_machine_stat(old_value)
	. = ..()
	if(machine_stat & (BROKEN | NOPOWER | MAINT | EMPED))
		stop_sealing("установка закрытия вышла из строя")

/obj/machinery/redspace_rift_sealer/interact(mob/user)
	. = ..()
	if(.)
		return
	if(active)
		to_chat(user, span_warning("Процедура закрытия уже идёт. Установка должна оставаться закреплённой до завершения."))
	else if(closed)
		to_chat(user, span_notice("Разлом уже закрыт. Установку можно демонтировать."))
	else if(!anchored)
		to_chat(user, span_warning("Сначала закрепите установку на полу."))
	else if(!try_start_sealing(user))
		to_chat(user, span_warning("В радиусе [REDSPACE_RIFT_SEALER_PLACEMENT_RADIUS] тайлов не найдено подходящей горячей зоны."))
	return TRUE

/obj/machinery/redspace_rift_sealer/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, span_warning("Нельзя открепить установку во время закрытия разлома."))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/redspace_rift_sealer/wrench_act(mob/living/user, obj/item/tool)
	return default_unfasten_wrench(user, tool)

/obj/machinery/redspace_rift_sealer/screwdriver_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, span_warning("Сначала дождитесь завершения или прервите процедуру закрытия."))
		return ITEM_INTERACT_BLOCKING
	return default_deconstruction_screwdriver(user, tool)

/obj/machinery/redspace_rift_sealer/crowbar_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, span_warning("Нельзя демонтировать установку во время закрытия разлома."))
		return ITEM_INTERACT_BLOCKING
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/redspace_rift_sealer/welder_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, span_warning("Сначала дождитесь завершения или прервите процедуру закрытия."))
		return ITEM_INTERACT_BLOCKING
	if(!panel_open)
		return NONE
	if(atom_integrity >= max_integrity && !(machine_stat & BROKEN))
		to_chat(user, span_notice("Установка не нуждается в ремонте."))
		return ITEM_INTERACT_BLOCKING
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 1, volume = 50))
		return ITEM_INTERACT_BLOCKING
	repair_damage(INFINITY)
	set_machine_stat(machine_stat & ~BROKEN)
	update_sealer_appearance()
	to_chat(user, span_notice("Вы ремонтируете [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/redspace_rift_sealer/on_deconstruction(disassembled)
	stop_sealing("установка закрытия демонтирована")
	return ..()

/obj/machinery/redspace_rift_sealer/handle_basic_attack(mob/living/basic/user, list/modifiers)
	return attack_generic(user, rand(user.melee_damage_lower, user.melee_damage_upper), BRUTE, MELEE)

/obj/machinery/redspace_rift_sealer/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return
	if(active && target_source)
		var/remaining = max(0, target_source.sealing_finishes_at - world.time)
		. += span_warning("Процедура закрытия активна. Осталось примерно [round(remaining / (1 SECONDS))] с.")
	else if(closed)
		. += span_notice("Процедура завершена: разлом закрыт.")
	else
		. += span_notice("Установка ожидает закрепления рядом с горячей зоной.")

/obj/machinery/redspace_rift_sealer/proc/update_sealer_appearance()
	set_light(active ? 3 : 0, active ? 1 : 0, "#ff5500")
	update_appearance()

/obj/machinery/redspace_rift_sealer/update_icon_state()
	. = ..()
	icon_state = "rift_sealer_[active ? "on" : "off"]"

/obj/item/circuitboard/machine/redspace_rift_sealer
	name = "Redspace Rift Sealer Board"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/redspace_rift_sealer
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/capacitor/tier3 = 2,
		/datum/stock_part/micro_laser/tier3 = 2,
		/datum/stock_part/matter_bin/tier3 = 1,
		/datum/stock_part/servo/tier2 = 1,
		/obj/item/stock_parts/power_store/cell = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/ore/bluespace_crystal = 2,
	)
	def_components = list(
		/obj/item/stock_parts/power_store/cell = /obj/item/stock_parts/power_store/cell/high,
	)

/datum/design/board/redspace_rift_sealer
	name = "Плата установки закрытия разломов редспейса"
	desc = "Плата для создания установки закрытия разломов редспейса."
#ifdef TECHWEB_NODE_STARTER
	// Design IDs were replaced with design typepaths by the techweb refactor.
#else
	id = "redspace_rift_sealer"
#endif
	build_path = /obj/item/circuitboard/machine/redspace_rift_sealer
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/// The redspace target source keeps active sealers available even when they are outside normal vision range.
/datum/target_source/hearers/redspace_demon

/datum/target_source/hearers/redspace_demon/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = ..()
	var/turf/pawn_turf = get_turf(pawn)
	if(!pawn_turf)
		return .
	for(var/obj/machinery/redspace_rift_sealer/sealer as anything in GLOB.redspace_active_rift_sealers)
		if(!sealer || QDELETED(sealer) || !sealer.active)
			continue
		var/turf/sealer_turf = get_turf(sealer)
		if(sealer_turf?.z == pawn_turf.z)
			. |= sealer
	return .

/// Active sealers outrank normal targets, while multiple active sealers are resolved by distance.
/datum/target_priority_strategy/nearest/redspace_demon

/datum/target_priority_strategy/nearest/redspace_demon/get_target_priority(datum/ai_controller/controller, atom/target)
	if(istype(target, /obj/machinery/redspace_rift_sealer))
		var/obj/machinery/redspace_rift_sealer/sealer = target
		if(!QDELETED(sealer) && sealer.active)
			return 100000 - get_dist(controller.pawn, sealer)
	return ..()

/datum/target_priority_strategy/nearest/redspace_demon/select_target(datum/ai_controller/controller, list/atom/targets)
	var/atom/closest_sealer
	var/closest_distance = INFINITY
	for(var/atom/target as anything in targets)
		if(!istype(target, /obj/machinery/redspace_rift_sealer))
			continue
		var/obj/machinery/redspace_rift_sealer/sealer = target
		if(QDELETED(sealer) || !sealer.active)
			continue
		var/distance = get_dist(controller.pawn, sealer)
		if(distance >= closest_distance)
			continue
		closest_sealer = sealer
		closest_distance = distance
	if(closest_sealer)
		return closest_sealer
	return ..()

// The redspace controller uses a global target source so active sealers can attract demons across the station z-level.
/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/redspace_demon
	target_source = /datum/target_source/hearers/redspace_demon
