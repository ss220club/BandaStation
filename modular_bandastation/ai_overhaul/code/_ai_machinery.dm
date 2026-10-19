#define AI_MACHINE_TOO_HOT "Слишком высокая температура среды"
#define AI_MACHINE_NO_MOLES "Недостаточно атмосферы"

/** Общий физический узел нейросети с питанием, атмосферой и теплообменом. */
/obj/machinery/ai
	name = "Вы не должны это видеть!"
	desc = "Вы не должны это видеть!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE
	/// Температура оборудования в K.
	var/core_temp = (T0C - 80)

/obj/machinery/ai/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	GLOB.ai_network_nodes += src
	SSai_networks.dirty = TRUE
	ai_refresh_cable_tile(get_turf(src))

/obj/machinery/ai/Destroy(force)
	GLOB.ai_network_nodes -= src
	ai_network = null
	SSai_networks.dirty = TRUE
	SSair.stop_processing_machine(src)
	ai_refresh_cable_tile(get_turf(src))
	return ..()

/obj/machinery/ai/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	SSai_networks.dirty = TRUE
	ai_refresh_cable_tile(get_turf(old_loc))
	ai_refresh_cable_tile(get_turf(src))

/obj/machinery/ai/process_atmos()
	if((machine_stat & (BROKEN|EMPED)) || !has_power())
		return FALSE
	var/turf/machine_turf = get_turf(src)
	if(!machine_turf || isspaceturf(machine_turf))
		return FALSE
	var/datum/gas_mixture/env = machine_turf?.return_air()
	if(!env?.total_moles())
		return FALSE
	var/new_temp = env.temperature_share(null, AI_HEATSINK_COEFF, core_temp, AI_HEATSINK_CAPACITY)
	core_temp = new_temp
	machine_turf.air_update_turf(FALSE, FALSE)
	return TRUE

/** Проверяет крепление, питание и атмосферу; ignore_temperature пропускает только проверку температуры. */
/obj/machinery/ai/proc/valid_holder(ignore_temperature = FALSE)
	if(!anchored || machine_stat & (BROKEN|EMPED) || !has_power())
		return FALSE

	var/turf/machine_turf = get_turf(src)
	var/datum/gas_mixture/env = machine_turf?.return_air()
	if(!env)
		return FALSE
	var/total_moles = env.total_moles()
	if(isspaceturf(machine_turf) || total_moles < 10)
		return FALSE

	if(!ignore_temperature && core_temp > resource_pool().get_temp_limit())
		return FALSE
	return TRUE

/** Проверяет наличие внешнего питания по состоянию машины. */
/obj/machinery/ai/proc/has_power()
	return !(machine_stat & (NOPOWER))

/** Возвращает известную местную причину неготовности оборудования либо null. */
/obj/machinery/ai/proc/get_holder_status()
	if(!anchored)
		return "Крепёжные болты ослаблены"
	if(machine_stat & BROKEN)
		return "Оборудование повреждено"
	if(machine_stat & EMPED)
		return "Электромагнитные помехи"
	if(!has_power())
		return "Нет питания"

	var/turf/machine_turf = get_turf(src)
	var/datum/gas_mixture/env = machine_turf?.return_air()
	if(!env)
		return AI_MACHINE_NO_MOLES
	var/total_moles = env.total_moles()
	if(istype(machine_turf, /turf/open/space) || total_moles < 10)
		return AI_MACHINE_NO_MOLES

	if(core_temp > resource_pool().get_temp_limit())
		return AI_MACHINE_TOO_HOT

#undef AI_MACHINE_TOO_HOT
#undef AI_MACHINE_NO_MOLES

/** Возвращает название помещения source в запрошенном русском падеже. */
/proc/ai_localized_area(atom/source, declension = NOMINATIVE)
	var/area/local_area = get_area(source)
	return local_area?.declent_ru(declension) || "Неизвестная область"

