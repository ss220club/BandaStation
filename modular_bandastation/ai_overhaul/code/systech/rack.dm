/** Корпус серверного модуля с физическими CPU и планками RAM. */
/obj/item/server_rack
	name = "server rack"
	desc = "Серверный модуль (Server Rack). Откройте корпус отвёрткой и вставьте CPU и планки RAM. Закрытый модуль с комплектующими устанавливается в серверный шкаф. Активируйте в руке для осмотра и извлечения деталей."
	icon = 'modular_bandastation/ai_overhaul/icons/module.dmi'
	icon_state = "server_rack"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

	force = 5
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
	)

	/// Физические процессоры внутри серверного модуля.
	var/list/obj/item/ai_cpu/contained_cpus = list()
	/// Физические планки RAM внутри модуля.
	var/list/obj/item/ai_ram/contained_memory = list()
	/// Объём RAM внутри серверного модуля в ТБ.
	var/contained_ram = 0
	/// Открытый корпус разрешает установку и извлечение комплектующих.
	var/panel_open = FALSE

/obj/item/server_rack/examine(mob/user)
	. = ..()
	. += span_notice("Корпус [panel_open ? "открыт" : "закрыт"]. CPU: [length(contained_cpus)]/[available_slots()]. RAM: [length(contained_memory)]/[available_slots(memory = TRUE)].")
	var/total = get_cpu()
	for(var/obj/item/ai_cpu/cpu as anything in contained_cpus)
		. += span_notice("Установлен [cpu.declent_ru(NOMINATIVE)]: [cpu.speed] ТГц, потребление [cpu.get_power_usage()] Вт.")
	. += span_notice("Суммарная производительность CPU: [total] ТГц.")
	. += span_notice("----------------------")
	. += span_notice("Установлено RAM: [contained_ram] ТБ.")
	. += span_notice("Потребление электроэнергии: [get_power_usage()] Вт.")
	if(!length(contained_cpus) && !length(contained_memory))
		. += span_notice("Корпус пуст. CPU печатаются на принтере плат, планки RAM — на протолате.")

/** Разрешает обслуживание модуля в руках либо на соседней клетке. */
/obj/item/server_rack/proc/can_service(mob/user)
	return isliving(user) && !user.incapacitated && (isturf(loc) || user.is_holding(src)) && user.Adjacent(src)

/** Проверяет исследование разъёма CPU для ручной сборки. */
/obj/item/server_rack/proc/slot_unlocked_cpu(slot_number)
	if(!isnum(slot_number) || slot_number != round(slot_number) || slot_number < 1 || slot_number > AI_MAX_CPUS_PER_RACK)
		return FALSE
	if(slot_number == 1)
		return TRUE
	var/static/list/designs = list(/datum/design/ai_cpu_2, /datum/design/ai_cpu_3, /datum/design/ai_cpu_4)
	return !!ai_station_techweb(src)?.researched_designs[designs[slot_number - 1]]

/** Проверяет исследование разъёма RAM для ручной сборки. */
/obj/item/server_rack/proc/slot_unlocked_ram(slot_number)
	if(!isnum(slot_number) || slot_number != round(slot_number) || slot_number < 1 || slot_number > AI_MAX_RAM_PER_RACK)
		return FALSE
	if(slot_number == 1)
		return TRUE
	var/static/list/designs = list(/datum/design/ai_ram_2, /datum/design/ai_ram_3, /datum/design/ai_ram_4)
	return !!ai_station_techweb(src)?.researched_designs[designs[slot_number - 1]]

/** Считает последовательно открытые разъёмы выбранного типа. */
/obj/item/server_rack/proc/available_slots(memory = FALSE)
	var/result = 0
	for(var/index in 1 to (memory ? AI_MAX_RAM_PER_RACK : AI_MAX_CPUS_PER_RACK))
		if(!(memory ? slot_unlocked_ram(index) : slot_unlocked_cpu(index)))
			break
		result++
	return result

/** Пересчитывает RAM и обновляет установленный модуль при потере комплектующих. */
/obj/item/server_rack/proc/refresh_hardware()
	contained_ram = 0
	for(var/obj/item/ai_ram/memory as anything in contained_memory)
		if(!QDELETED(memory) && memory.loc == src)
			contained_ram += memory.capacity
	if(istype(loc, /obj/machinery/ai/server_cabinet))
		var/obj/machinery/ai/server_cabinet/cabinet = loc
		if(src in cabinet.installed_racks)
			cabinet.recalculate_racks()
	SStgui.update_uis(src)

/** Устанавливает удерживаемый CPU или RAM в открытый корпус. */
/obj/item/server_rack/proc/insert_component(mob/living/user, obj/item/part)
	if(!can_service(user) || !panel_open || !user.is_holding(part) || QDELETED(part))
		return FALSE
	if(istype(part, /obj/item/ai_cpu))
		if(!slot_unlocked_cpu(length(contained_cpus) + 1))
			balloon_alert(user, "разъём CPU недоступен!")
			return FALSE
		if(!user.transferItemToLoc(part, src))
			return FALSE
		contained_cpus += part
	else if(istype(part, /obj/item/ai_ram))
		if(!slot_unlocked_ram(length(contained_memory) + 1))
			balloon_alert(user, "разъём RAM недоступен!")
			return FALSE
		if(!user.transferItemToLoc(part, src))
			return FALSE
		contained_memory += part
	else
		return FALSE
	refresh_hardware()
	balloon_alert(user, "деталь установлена")
	return TRUE

/** Извлекает выбранную деталь из открытого корпуса без создания копии. */
/obj/item/server_rack/proc/remove_component(mob/living/user, obj/item/part)
	if(!can_service(user) || !panel_open || QDELETED(part) || part.loc != src || (!(part in contained_cpus) && !(part in contained_memory)))
		return FALSE
	part.forceMove(drop_location())
	user.put_in_hands(part)
	return TRUE

/obj/item/server_rack/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/ai_cpu) && !istype(tool, /obj/item/ai_ram))
		return NONE
	if(!panel_open)
		balloon_alert(user, "сначала откройте корпус!")
		return ITEM_INTERACT_BLOCKING
	return insert_component(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/item/server_rack/screwdriver_act(mob/living/user, obj/item/tool)
	if(!can_service(user) || !tool.use_tool(src, user, 1 SECONDS) || QDELETED(src) || !can_service(user))
		return ITEM_INTERACT_BLOCKING
	panel_open = !panel_open
	balloon_alert(user, panel_open ? "корпус открыт" : "корпус закрыт")
	SStgui.update_uis(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/server_rack/attack_self(mob/user)
	if(can_service(user))
		ui_interact(user)

/obj/item/server_rack/ui_status(mob/user)
	if(!can_service(user))
		return UI_CLOSE
	return ..()

/obj/item/server_rack/ui_interact(mob/user, datum/tgui/ui)
	if(!can_service(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiServerModule", "Серверный модуль")
		ui.open()

/obj/item/server_rack/ui_data(mob/user)
	if(!can_service(user))
		return list()
	var/list/cpus = list()
	for(var/obj/item/ai_cpu/cpu as anything in contained_cpus)
		cpus += list(list("ref" = REF(cpu), "name" = cpu.declent_ru(), "speed" = cpu.speed, "power" = cpu.get_power_usage()))
	var/list/memory = list()
	for(var/obj/item/ai_ram/ram as anything in contained_memory)
		memory += list(list("ref" = REF(ram), "name" = ram.declent_ru(), "capacity" = ram.capacity))
	return list("panel_open" = panel_open, "cpu_slots" = available_slots(), "ram_slots" = available_slots(memory = TRUE), "cpus" = cpus, "memory" = memory, "total_cpu" = get_cpu(), "total_ram" = contained_ram, "power" = get_power_usage())

/obj/item/server_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!can_service(ui.user) || !panel_open)
		return FALSE
	if(action == "eject_cpu")
		var/obj/item/ai_cpu/part = locate(params["ref"]) in contained_cpus
		return part && remove_component(ui.user, part)
	if(action == "eject_ram")
		var/obj/item/ai_ram/part = locate(params["ref"]) in contained_memory
		return part && remove_component(ui.user, part)

/obj/item/server_rack/Exited(atom/movable/gone, direction)
	. = ..()
	if(!(gone in contained_cpus) && !(gone in contained_memory))
		return
	contained_cpus -= gone
	contained_memory -= gone
	if(!QDELETED(src))
		refresh_hardware()

/obj/item/server_rack/Destroy()
	QDEL_LIST(contained_cpus)
	QDEL_LIST(contained_memory)
	return ..()

/** Суммирует частоты физических процессоров модуля в ТГц. */
/obj/item/server_rack/proc/get_cpu()
	var/amount = 0
	for(var/obj/item/ai_cpu/cpu as anything in contained_cpus)
		amount += cpu.speed
	return amount

/** Возвращает потребление установленного оборудования в ваттах. */
/obj/item/server_rack/proc/get_power_usage()
	var/usage = 0
	for(var/obj/item/ai_cpu/cpu as anything in contained_cpus)
		usage += cpu.get_power_usage()
	usage += contained_ram * AI_POWER_PER_CARD
	return usage

/obj/item/server_rack/roundstart/Initialize(mapload)
	. = ..()
	var/obj/item/ai_cpu/cpu = new(src)
	contained_cpus += cpu
	var/obj/item/ai_ram/ram = new(src)
	contained_memory += ram
	refresh_hardware()
