/// Calculates the central correction requested by a stabilizer before machine efficiency.
/proc/redspace_stabilizer_calculate_contribution(base_value, target_value, max_negative_contribution, efficiency = 1)
	if(!isnum(base_value) || !isnum(target_value) || !isnum(max_negative_contribution) || max_negative_contribution <= 0)
		return 0
	if(base_value > REDSPACE_MAX_NORMAL_VALUE)
		return 0

	var/required_correction = clamp(base_value - target_value, 0, max_negative_contribution)
	return -required_correction * clamp(efficiency, 0, 1)

/obj/machinery/redspace_stabilizer
	name = "bluespace boundary stabilizer"
	desc = "An engineering machine that locally reinforces the bluespace boundary against redspace pressure."
	icon = 'icons/obj/machines/shield_generator.dmi'
	icon_state = "shieldoff"
	density = TRUE
	anchored = TRUE
	max_integrity = 200
	circuit = /obj/item/circuitboard/machine/redspace_stabilizer
	use_power = NO_POWER_USE
	processing_flags = START_PROCESSING_MANUALLY
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN

	/// The replaceable battery is deliberately independent from area power.
	var/obj/item/stock_parts/power_store/cell/cell = /obj/item/stock_parts/power_store/cell/high
	var/active = FALSE
	var/datum/redspace_field_source/stabilizer/field_source

	/// Balance variables. max_negative_contribution is a positive magnitude.
	var/target_value = REDSPACE_STABILIZER_TARGET_VALUE
	var/max_negative_contribution = 4
	var/source_radius = REDSPACE_STABILIZER_DEFAULT_RADIUS

	/// Abstract thermal load displayed as a percentage-like value.
	var/heat = 0
	var/heat_gain_at_max_load_per_second = 6
	var/passive_cooling_per_second = 1.5
	var/cooling_per_coolant_unit = 2.5

	/// Resource consumption at zero and maximum field load.
	var/standby_power_drain_per_second = 0.01 * STANDARD_CELL_RATE
	var/max_power_drain_per_second = 0.12 * STANDARD_CELL_RATE
	var/coolant_use_at_max_load_per_second = 1.2

	/// Failure checks happen on a service interval, not every machinery tick.
	var/service_failure_chance = 5
	var/next_service_check = 0
	/// The field source fades linearly instead of disappearing when the machine stops.
	var/source_fade_duration = 10 SECONDS

	var/current_negative_contribution = 0
	var/current_load = 0

/obj/machinery/redspace_stabilizer/Initialize(mapload)
	. = ..()
	create_reagents(200, NO_REACT)
	reagents.add_reagent(/datum/reagent/cryostylane, reagents.maximum_volume)
	if(ispath(cell))
		cell = new cell(src)
	update_appearance()

/obj/machinery/redspace_stabilizer/Destroy()
	remove_field_source("stabilizer destroyed")
	QDEL_NULL(cell)
	return ..()

/obj/machinery/redspace_stabilizer/on_deconstruction(disassembled)
	if(cell)
		cell.forceMove(drop_location())
		cell = null
	return ..()

/obj/machinery/redspace_stabilizer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null

/obj/machinery/redspace_stabilizer/get_cell()
	return cell

/obj/machinery/redspace_stabilizer/attack_hand_secondary(mob/user, list/modifiers)
	if(panel_open && !active && cell)
		user.put_in_hands(cell)
		cell = null
		update_appearance()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/machinery/redspace_stabilizer/interact(mob/user)
	. = ..()
	if(.)
		return

	if(panel_open)
		to_chat(user, span_warning("Close the maintenance panel before operating the stabilizer."))
		return TRUE
	if(!anchored)
		to_chat(user, span_warning("The stabilizer must be secured to the floor first."))
		return TRUE
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("The stabilizer is broken and requires repairs."))
		return TRUE

	if(active)
		deactivate_stabilization(user, "manually switched off")
		return TRUE

	activate_stabilization(user)
	return TRUE

/obj/machinery/redspace_stabilizer/proc/activate_stabilization(mob/user)
	if(!cell || cell.charge <= 0)
		to_chat(user, span_warning("The stabilizer has no charged power cell."))
		return FALSE
	if(!reagents.get_reagent_amount(/datum/reagent/cryostylane))
		to_chat(user, span_warning("The stabilizer has no cryostylane coolant."))
		return FALSE

	var/turf/target = get_turf(src)
	if(!target || !SSredspace || !SSredspace.is_supported_z(target.z))
		to_chat(user, span_warning("The stabilizer cannot operate outside a supported station level."))
		return FALSE

	if(field_source && !is_field_source_registered())
		field_source = null
	if(!field_source)
		field_source = SSredspace.register_stabilizer_source(target, 0, source_radius, "stabilizer activated")
		if(!field_source)
			to_chat(user, span_warning("The stabilizer could not connect to the redspace field."))
			return FALSE
		RegisterSignal(field_source, COMSIG_REDSPACE_SOURCE_CHANGED, PROC_REF(on_field_source_changed))

	active = TRUE
	next_service_check = world.time + REDSPACE_STABILIZER_SERVICE_INTERVAL
	begin_processing()
	update_appearance()
	user?.visible_message(
		span_notice("[user] activates [src]."),
		span_notice("You activate [src]."),
	)
	return TRUE

/obj/machinery/redspace_stabilizer/proc/deactivate_stabilization(mob/user, reason = null)
	active = FALSE
	if(field_source)
		current_negative_contribution = field_source.strength
		current_load = get_load_ratio(current_negative_contribution)
	else
		current_negative_contribution = 0
		current_load = 0
	if(heat > 0 || field_source)
		begin_processing()
	else
		end_processing()
	update_appearance()

	if(user)
		user.visible_message(
			span_notice("[user] deactivates [src]."),
			span_notice("You deactivate [src]."),
		)
	else if(reason)
		visible_message(span_warning("[src] shuts down: [reason]."))

/obj/machinery/redspace_stabilizer/proc/remove_field_source(reason = "stabilizer source removed")
	if(!field_source)
		return

	var/datum/redspace_field_source/stabilizer/source = field_source
	field_source = null
	UnregisterSignal(source, COMSIG_REDSPACE_SOURCE_CHANGED)
	if(SSredspace && SSredspace.field_sources["[source.source_id]"] == source)
		SSredspace.remove_source(source.source_id, reason)
	else
		qdel(source)

/obj/machinery/redspace_stabilizer/proc/is_field_source_registered()
	return field_source && SSredspace && SSredspace.field_sources["[field_source.source_id]"] == field_source

/obj/machinery/redspace_stabilizer/proc/fade_field_source(seconds_per_tick)
	if(!field_source)
		return FALSE
	if(!is_field_source_registered())
		field_source = null
		current_negative_contribution = 0
		current_load = 0
		return FALSE
	if(field_source.strength >= 0 || max_negative_contribution <= 0 || source_fade_duration <= 0)
		remove_field_source("stabilizer field faded")
		current_negative_contribution = 0
		current_load = 0
		return FALSE

	var/fade_step = max_negative_contribution * seconds_per_tick / max(source_fade_duration / (1 SECONDS), 1)
	var/new_strength = min(0, field_source.strength + fade_step)
	if(new_strength != field_source.strength)
		SSredspace.update_source_strength(field_source.source_id, new_strength, "stabilizer field fading")
	current_negative_contribution = new_strength
	current_load = get_load_ratio(new_strength)
	if(new_strength >= 0)
		remove_field_source("stabilizer field faded")
		current_negative_contribution = 0
		current_load = 0
		return FALSE
	return TRUE

/obj/machinery/redspace_stabilizer/proc/on_field_source_changed(datum/redspace_field_source/stabilizer/source, change_type, old_value, new_value, reason)
	SIGNAL_HANDLER
	if(source != field_source || change_type != REDSPACE_SOURCE_CHANGE_REMOVED)
		return

	field_source = null
	active = FALSE
	current_negative_contribution = 0
	current_load = 0
	if(heat > 0)
		begin_processing()
	update_appearance()

/obj/machinery/redspace_stabilizer/process(seconds_per_tick)
	if(machine_stat & BROKEN)
		active = FALSE

	if(!active)
		var/source_fading = fade_field_source(seconds_per_tick)
		cool_down(seconds_per_tick)
		if(!source_fading && !field_source && heat <= 0)
			return PROCESS_KILL
		update_appearance()
		return

	if(!anchored || !is_operational || !field_source || !cell || cell.charge <= 0)
		deactivate_stabilization(null, "power or anchoring lost")
		return

	var/turf/target = get_turf(src)
	var/base_value = SSredspace?.get_value_without_source(target, field_source)
	if(isnull(base_value))
		deactivate_stabilization(null, "no supported redspace field")
		return

	var/datum/redspace_field_cell/field_cell = SSredspace.get_cell(target)
	var/explicit_value = field_cell && !isnull(field_cell.forced_value)
	var/zone_coefficient = SSredspace.get_zone_coefficient(target, field_cell)
	var/requested_contribution = explicit_value ? 0 : get_source_contribution(base_value, 1, zone_coefficient)
	var/requested_load = get_load_ratio(requested_contribution)
	var/thermal_efficiency = get_thermal_efficiency()
	var/power_demand = (standby_power_drain_per_second + (max_power_drain_per_second - standby_power_drain_per_second) * requested_load) * seconds_per_tick
	var/power_efficiency = clamp(cell.charge / max(power_demand, 1), 0, 1)
	var/coolant_available = reagents.get_reagent_amount(/datum/reagent/cryostylane)
	var/coolant_demand = coolant_use_at_max_load_per_second * requested_load * seconds_per_tick
	var/coolant_efficiency = coolant_demand ? clamp(coolant_available / coolant_demand, 0, 1) : 1

	if(requested_load && !coolant_efficiency)
		deactivate_stabilization(null, "coolant depleted")
		return

	var/efficiency = min(thermal_efficiency, power_efficiency, coolant_efficiency)
	var/new_contribution = explicit_value ? 0 : get_source_contribution(base_value, efficiency, zone_coefficient)
	var/new_load = get_load_ratio(new_contribution)

	var/power_used = (standby_power_drain_per_second + (max_power_drain_per_second - standby_power_drain_per_second) * new_load) * seconds_per_tick
	cell.use(power_used, force = TRUE)

	var/coolant_used = coolant_demand ? min(coolant_available, coolant_demand * (new_load / max(requested_load, 0.01))) : 0
	if(coolant_used)
		reagents.remove_reagent(/datum/reagent/cryostylane, coolant_used)

	heat = clamp(
		heat + (heat_gain_at_max_load_per_second * new_load * seconds_per_tick) - (passive_cooling_per_second * seconds_per_tick) - (coolant_used * cooling_per_coolant_unit),
		0,
		REDSPACE_STABILIZER_MAX_HEAT,
	)
	current_negative_contribution = new_contribution
	current_load = new_load

	if(field_source.strength != new_contribution)
		SSredspace.update_source_strength(field_source.source_id, new_contribution, "stabilizer load changed")

	if(heat >= REDSPACE_STABILIZER_MAX_HEAT)
		fail_stabilizer("critical thermal overload")
	else if(world.time >= next_service_check)
		perform_service_check()

	update_appearance()

/obj/machinery/redspace_stabilizer/proc/get_source_contribution(base_value, efficiency, zone_coefficient)
	if(!isnum(zone_coefficient) || zone_coefficient <= 0)
		return 0

	var/desired_field_correction = redspace_stabilizer_calculate_contribution(base_value, target_value, max_negative_contribution, efficiency)
	return clamp(desired_field_correction / zone_coefficient, -max_negative_contribution, 0)

/obj/machinery/redspace_stabilizer/proc/get_load_ratio(contribution)
	if(!max_negative_contribution)
		return 0
	return clamp(abs(contribution) / max_negative_contribution, 0, 1)

/obj/machinery/redspace_stabilizer/proc/get_thermal_efficiency()
	var/efficiency = clamp(atom_integrity / max_integrity, 0, 1)
	if(heat <= REDSPACE_STABILIZER_HEAT_WARNING)
		return efficiency

	var/overheat_ratio = (heat - REDSPACE_STABILIZER_HEAT_WARNING) / (REDSPACE_STABILIZER_MAX_HEAT - REDSPACE_STABILIZER_HEAT_WARNING)
	return efficiency * max(0.25, 1 - (overheat_ratio * 0.75))

/obj/machinery/redspace_stabilizer/proc/cool_down(seconds_per_tick)
	heat = max(0, heat - (passive_cooling_per_second * seconds_per_tick))

/obj/machinery/redspace_stabilizer/proc/perform_service_check()
	next_service_check = world.time + REDSPACE_STABILIZER_SERVICE_INTERVAL
	if(current_load <= 0.5 && heat < REDSPACE_STABILIZER_HEAT_WARNING)
		return

	var/failure_risk = service_failure_chance * current_load * (0.5 + (heat / REDSPACE_STABILIZER_MAX_HEAT))
	if(prob(failure_risk))
		fail_stabilizer("internal components failed under load")

/obj/machinery/redspace_stabilizer/proc/fail_stabilizer(reason)
	active = FALSE
	atom_integrity = 0
	set_machine_stat(machine_stat | BROKEN)
	visible_message(span_danger("[src] fails with a sharp burst of heat."))
	if(field_source)
		current_negative_contribution = field_source.strength
		current_load = get_load_ratio(current_negative_contribution)
	begin_processing()
	update_appearance()

/obj/machinery/redspace_stabilizer/on_set_machine_stat(old_value)
	. = ..()
	if(machine_stat & BROKEN)
		active = FALSE
		if(field_source)
			current_negative_contribution = field_source.strength
			current_load = get_load_ratio(current_negative_contribution)
		if(heat > 0 || field_source)
			begin_processing()
		update_appearance()

/obj/machinery/redspace_stabilizer/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	var/local_value
	var/local_state
	if(SSredspace)
		local_value = SSredspace.get_value(get_turf(src))
		local_state = SSredspace.get_state(get_turf(src))
	var/value_label = isnull(local_value) ? "unknown" : "[round(local_value, 0.1)]"
	var/state_label = local_state ? redspace_state_name(local_state) : "unknown"
	var/status_label = active ? "включён" : "выключен"
	var/stabilization_label = active ? "Стабилизация" : (field_source ? "Остаточный вклад" : "Стабилизация")

	. += span_notice("Статус: [status_label].")
	. += span_notice("Локальное значение поля: [value_label] ([state_label]).")
	. += span_notice("[stabilization_label]: [round(current_negative_contribution, 0.1)] ([round(current_load * 100)]% нагрузки).")
	. += span_notice("Тепловая нагрузка: [round(heat)]/[REDSPACE_STABILIZER_MAX_HEAT].")
	. += span_notice("Батарея: [cell ? "[round(cell.percent(), 1)]%" : "отсутствует"].")
	. += span_notice("Хладагент (криостилан): [round(reagents.get_reagent_amount(/datum/reagent/cryostylane), 1)]/[reagents.maximum_volume] ед.")
	if(panel_open)
		. += span_notice("На внутренней стороне панели выгравирована инструкция: извлеките отработанный энергоблок и установите новый.")
		. += span_notice("Охлаждающий контур заправляется криостиланом из открытой химической ёмкости.")
	else
		. += span_notice("Сервисная панель закрыта. Обслуживание энергоблока и охлаждающего контура проводится при открытой панели.")
	if(machine_stat & BROKEN)
		. += span_warning("Стабилизатор сломан. Откройте панель и отремонтируйте его сварочным инструментом.")
	else if(heat >= REDSPACE_STABILIZER_HEAT_WARNING)
		. += span_warning("Тепловая нагрузка приближается к критическому уровню.")

/obj/machinery/redspace_stabilizer/update_icon_state()
	. = ..()
	icon_state = "shield[active ? "on" : "off"][machine_stat & BROKEN ? "br" : null]"

/obj/machinery/redspace_stabilizer/wrench_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, span_warning("Turn off the stabilizer before moving it."))
		return ITEM_INTERACT_BLOCKING
	return default_unfasten_wrench(user, tool)

/obj/machinery/redspace_stabilizer/screwdriver_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, span_warning("Turn off the stabilizer before opening the maintenance panel."))
		return ITEM_INTERACT_BLOCKING
	return default_deconstruction_screwdriver(user, tool)

/obj/machinery/redspace_stabilizer/crowbar_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, span_warning("Turn off the stabilizer before deconstructing it."))
		return ITEM_INTERACT_BLOCKING
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/redspace_stabilizer/welder_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return NONE
	if(atom_integrity >= max_integrity && !(machine_stat & BROKEN))
		to_chat(user, span_notice("The stabilizer does not need repairs."))
		return ITEM_INTERACT_BLOCKING
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 1, volume = 50))
		return ITEM_INTERACT_BLOCKING

	repair_damage(INFINITY)
	heat = 0
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	to_chat(user, span_notice("You repair [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/redspace_stabilizer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stock_parts/power_store/cell))
		if(!panel_open || active)
			to_chat(user, span_warning("The stabilizer must be offline with its panel open to replace the power cell."))
			return ITEM_INTERACT_BLOCKING
		if(cell)
			to_chat(user, span_warning("There is already a power cell installed."))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		cell = tool
		tool.add_fingerprint(user)
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(is_reagent_container(tool) && tool.is_open_container())
		if(!panel_open || active)
			to_chat(user, span_warning("The stabilizer must be offline with its panel open to refill the coolant."))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/reagent_containers/container = tool
		if(!container.reagents.get_reagent_amount(/datum/reagent/cryostylane))
			to_chat(user, span_warning("Only cryostylane can be used as stabilizer coolant."))
			return ITEM_INTERACT_BLOCKING
		var/transfer_amount = min(container.amount_per_transfer_from_this, reagents.maximum_volume - reagents.total_volume)
		var/transferred = container.reagents.trans_to(src, transfer_amount, target_id = /datum/reagent/cryostylane, transferred_by = user)
		if(transferred)
			balloon_alert(user, "[round(transferred, 0.1)]u coolant transferred")
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	return NONE

/obj/item/circuitboard/machine/redspace_stabilizer
	name = "Bluespace Boundary Stabilizer Board"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/redspace_stabilizer
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/capacitor/tier3 = 2,
		/datum/stock_part/micro_laser/tier3 = 2,
		/datum/stock_part/matter_bin/tier3 = 1,
		/datum/stock_part/servo/tier2 = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/ore/bluespace_crystal = 2,
	)

/datum/design/board/redspace_stabilizer
	name = "Плата стабилизатора блюспейс-границы"
	desc = "Плата для создания стабилизатора блюспейс-границы."
	id = "redspace_stabilizer"
	build_path = /obj/item/circuitboard/machine/redspace_stabilizer
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

/datum/techweb_node/redspace_stabilization
	id = "redspace_stabilization"
	display_name = "Стабилизация редспейса"
	description = "Практическое укрепление блюспейсной границы в локальных зонах давления редспейса."
	prereq_ids = list(TECHWEB_NODE_APPLIED_BLUESPACE)
	design_ids = list("redspace_stabilizer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)
