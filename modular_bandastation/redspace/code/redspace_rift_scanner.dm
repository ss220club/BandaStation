/// Counts persistent, active redspace hotspots on station levels.
/datum/controller/subsystem/redspace/proc/get_active_hotspot_count()
	if(!initialized || !length(field_sources))
		return 0

	var/active_hotspot_count = 0
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/hotspot/hotspot = field_sources[source_key]
		if(!istype(hotspot) || QDELETED(hotspot) || !hotspot.counts_as_active_hotspot || hotspot.strength <= 0 || !is_supported_z(hotspot.z_level))
			continue
		active_hotspot_count++

	return active_hotspot_count

/obj/machinery/redspace_rift_scanner
	name = "redspace rift scanner"
	desc = "A machine that periodically scans the station for active redspace hotspots."
	icon = 'modular_bandastation/redspace/icons/obj/machinery_32x64.dmi'
	icon_state = "rift_scanner_off"
	density = TRUE
	max_integrity = 200
	uses_integrity = TRUE
	circuit = /obj/item/circuitboard/machine/redspace_rift_scanner
	use_power = IDLE_POWER_USE
	processing_flags = START_PROCESSING_MANUALLY

	/// Most recent number of active hotspots found by the scanner.
	var/last_hotspot_count
	/// World time of the most recent completed scan.
	var/last_scan_at
	/// Earliest world time at which the next scan may begin.
	var/next_scan_at = 0

/obj/machinery/redspace_rift_scanner/Initialize(mapload)
	. = ..()
	RegisterSignals(src, list(COMSIG_MACHINERY_POWER_LOST, COMSIG_MACHINERY_POWER_RESTORED), PROC_REF(on_power_changed))
	reset_scan_cooldown()
	begin_processing()
	update_appearance()
	return .

/obj/machinery/redspace_rift_scanner/Destroy()
	UnregisterSignal(src, list(COMSIG_MACHINERY_POWER_LOST, COMSIG_MACHINERY_POWER_RESTORED))
	return ..()

/obj/machinery/redspace_rift_scanner/on_construction(mob/user)
	. = ..()
	reset_scan_cooldown()

/obj/machinery/redspace_rift_scanner/process(seconds_per_tick)
	if(machine_stat & (BROKEN | NOPOWER | MAINT | EMPED) || !is_operational || world.time < next_scan_at)
		return
	if(!SSredspace?.initialized)
		return

	last_hotspot_count = SSredspace.get_active_hotspot_count()
	last_scan_at = world.time
	reset_scan_cooldown()

/obj/machinery/redspace_rift_scanner/proc/reset_scan_cooldown()
	next_scan_at = world.time + REDSPACE_RIFT_SCANNER_SCAN_INTERVAL

/obj/machinery/redspace_rift_scanner/proc/on_power_changed(datum/source)
	SIGNAL_HANDLER
	reset_scan_cooldown()
	if(machine_stat & NOPOWER)
		end_processing()
	else
		begin_processing()
	update_appearance()

/obj/machinery/redspace_rift_scanner/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	if(isnull(last_hotspot_count))
		. += span_notice("Сканирование станции ещё не выполнялось.")
	else
		. += span_notice("Последнее сканирование выявило активных горячих зон: [last_hotspot_count].")

	if(machine_stat & NOPOWER)
		. += span_warning("Сканер обесточен. После восстановления питания отсчёт начнётся заново.")
	else
		var/remaining = max(0, next_scan_at - world.time)
		. += span_notice("Следующее сканирование примерно через [round(remaining / (1 SECONDS))] с.")

/obj/machinery/redspace_rift_scanner/update_icon_state()
	. = ..()
	icon_state = (machine_stat & (BROKEN | NOPOWER | MAINT | EMPED)) ? "rift_scanner_off" : "rift_scanner_on"
	return .

/obj/item/circuitboard/machine/redspace_rift_scanner
	name = "Redspace Rift Scanner Board"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/redspace_rift_scanner
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/capacitor/tier3 = 2,
		/datum/stock_part/scanning_module/tier3 = 2,
		/datum/stock_part/micro_laser/tier3 = 1,
		/datum/stock_part/matter_bin/tier2 = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)

/datum/design/board/redspace_rift_scanner
	name = "Плата сканера разломов редспейса"
	desc = "Плата для создания сканера разломов редспейса."
#ifdef TECHWEB_NODE_STARTER
	// Design IDs were replaced with design typepaths by the techweb refactor.
#else
	id = "redspace_rift_scanner"
#endif
	build_path = /obj/item/circuitboard/machine/redspace_rift_scanner
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE
