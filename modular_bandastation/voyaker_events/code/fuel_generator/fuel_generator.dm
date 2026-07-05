#define REPAIR_CAPACITORS 0
#define REPAIR_SCREWDRIVER 1
#define REPAIR_METAL 2
#define REPAIR_WELDER 3

/obj/machinery/power/fuel_generator
	name = "топливный генератор на жидкостном охлаждении"
	desc = "Небольшой генератор, работающий на жидком топливе."
	icon = 'modular_bandastation/voyaker_events/icons/geothermal.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	processing_flags = START_PROCESSING_ON_INIT
	light_range = 0
	light_power = 0
	light_color = "#66CCFF"
	/// Генерируемая мощность
	var/power_gen = 30000
	/// Включен ли генератор
	var/active = FALSE
	/// Максимальный объём топлива
	var/max_fuel = 100
	var/sound_loop = FALSE
	/// Температура генератора
	var/current_heat = T20C
	/// Максимально допустимая температура
	var/max_heat = T0C + 100
	/// Количество охлаждающей жидкости
	var/max_coolant = 100
	/// Сколько тепла создаётся за тик
	var/heat_per_tick = 3.5
	/// Насколько охлаждает вода
	var/cooling_power = 0.6
	/// Сломан ли генератор
	var/broken = FALSE
	/// Включено ли жидкостное охлаждение
	var/cooling_enabled = TRUE
	var/repair_stage = REPAIR_CAPACITORS
	var/capacitators_installed = 0
	var/has_water_recycler = FALSE
	var/obj/item/fuel_pellet/fuel_pellet = null

/obj/machinery/power/fuel_generator/Initialize(mapload)
	. = ..()
	create_reagents(max_fuel + max_coolant)
	for(var/obj/structure/workbench/W in range(1, src))
		W.set_power(FALSE)
	update_appearance()
	current_heat = get_ambient_temperature()

/obj/machinery/power/fuel_generator/examine(mob/user)
	. = ..()

	. += span_notice("Топливо: [round(reagents.get_reagent_amount(/datum/reagent/fuel))]/100")
	. += span_notice("Вода: [round(reagents.get_reagent_amount(/datum/reagent/water))]/100")
	. += span_notice("Температура: [round(current_heat)]K")
	if(broken)
		. += span_danger("Генератор повреждён!")
		switch(repair_stage)
			if(REPAIR_CAPACITORS)
				. += span_warning("Необходимо установить конденсаторы ([capacitators_installed]/2).")
			if(REPAIR_SCREWDRIVER)
				. += span_warning("Закрутите крепления отвёрткой.")
			if(REPAIR_METAL)
				. += span_warning("Закройте корпус листом металла.")
			if(REPAIR_WELDER)
				. += span_warning("Заварите корпус сваркой.")
	else
		. += span_notice(active ? "Генератор работает." : "Генератор выключен.")

/obj/machinery/power/fuel_generator/proc/toggle_power(force)
	if(broken)
		return
	if(!isnull(force))
		active = force
	else
		active = !active
	if(active && reagents.get_reagent_amount(/datum/reagent/fuel) <= 0)
		active = FALSE
	if(active)
		set_light(3, 1.8, "#66CCFF")
		play_loop()
	else
		set_light(0)
	update_appearance()
	for(var/obj/structure/workbench/W in range(1, src))
		W.set_power(active)

/obj/machinery/power/fuel_generator/process(seconds_per_tick)
	if(broken)
		return
	if(active)
		if(!process_fuel())
			return
		process_heating()
		add_avail(power_gen)
	process_cooling()
	current_heat = clamp(current_heat, get_ambient_temperature(), max_heat)
	if(current_heat >= max_heat)
		overheat()
		return
	var/old_icon = icon_state
	update_appearance()
	if(icon_state != old_icon)
		SStgui.update_uis(src)

/obj/machinery/power/fuel_generator/proc/process_fuel()
	if(reagents.get_reagent_amount(/datum/reagent/fuel) <= 0)
		toggle_power(FALSE)
		return FALSE

	var/fuel_use = 0.5
	if(fuel_pellet)
		fuel_use *= 0.2

	reagents.remove_reagent(/datum/reagent/fuel, fuel_use)

	return TRUE

/obj/machinery/power/fuel_generator/proc/process_heating()
	var/heat_gain = heat_per_tick
	if(cooling_enabled && reagents.get_reagent_amount(/datum/reagent/water) > 0)
		heat_gain *= 0.45
	current_heat += heat_gain

/obj/machinery/power/fuel_generator/proc/process_cooling()
	var/ambient = get_ambient_temperature()
	if(current_heat > ambient)
		current_heat = max(current_heat - 0.8, ambient)
	else if(current_heat < ambient)
		current_heat = min(current_heat + 0.2, ambient)
	current_heat -= get_pipe_cooling()
	if(cooling_enabled && current_heat <= T20C)
		cooling_enabled = FALSE
		SStgui.update_uis(src)
	if(!cooling_enabled)
		return
	var/water = reagents.get_reagent_amount(/datum/reagent/water)
	if(water <= 0)
		return
	var/use
	if(active)
		use = has_water_recycler ? 0.3 : 0.6
	else
		use = has_water_recycler ? 0.15 : 0.3
	use = min(use, water)
	reagents.remove_reagent(/datum/reagent/water, use)

/obj/machinery/power/fuel_generator/update_icon_state()
	if(broken)
		icon_state = "weld"
		return ..()
	if(!active)
		icon_state = "off"
	else
		var/fuel = reagents.get_reagent_amount(/datum/reagent/fuel)
		if(fuel >= 76)
			icon_state = "on-100"
		else if(fuel >= 51)
			icon_state = "on-75"
		else if(fuel >= 26)
			icon_state = "on-50"
		else if(fuel >= 11)
			icon_state = "on-25"
		else
			icon_state = "on-10"

	return ..()

/obj/machinery/power/fuel_generator/attackby(obj/item/I, mob/living/user, params)
	if(broken)
		return repair_attackby(I, user)
	if(istype(I, /obj/item/fuel_pellet))
		if(fuel_pellet)
			balloon_alert(user, "картридж уже установлен")
			return TRUE
		if(!do_after(user, 2 SECONDS, target = src))
			return TRUE
		fuel_pellet = I
		user.transferItemToLoc(I, src)
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		balloon_alert(user, "картридж установлен")
		SStgui.update_uis(src)
		return TRUE
	if(istype(I, /obj/item/stock_parts/water_recycler))
		if(has_water_recycler)
			balloon_alert(user, "уже установлен")
			return TRUE
		if(!do_after(user, 2 SECONDS, target = src))
			return TRUE
		has_water_recycler = TRUE
		qdel(I)
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		balloon_alert(user, "рециркулятор установлен")
		SStgui.update_uis(src)
		return TRUE
	if(!istype(I, /obj/item/reagent_containers/cup/fuel_can))
		return ..()
	var/obj/item/reagent_containers/cup/fuel_can/can = I
	var/current_fuel = reagents.get_reagent_amount(/datum/reagent/fuel)
	var/current_water = reagents.get_reagent_amount(/datum/reagent/water)
	var/fuel = can.reagents.get_reagent_amount(/datum/reagent/fuel)
	var/water = can.reagents.get_reagent_amount(/datum/reagent/water)
	if(fuel > 0)
		if(current_fuel >= max_fuel)
			balloon_alert(user, "генератор полный")
			return TRUE
		playsound(src, 'sound/effects/liquid_pour/liquid_pour1.ogg', 50, TRUE)
		if(!do_after(user, 2 SECONDS, target = src))
			return TRUE
		current_fuel = reagents.get_reagent_amount(/datum/reagent/fuel)
		var/amount = min(fuel, max_fuel-current_fuel)
		can.reagents.remove_reagent(/datum/reagent/fuel, amount)
		reagents.add_reagent(/datum/reagent/fuel, amount)
		balloon_alert(user, "заправлено топливо")
	else if(water > 0)
		if(current_water >= max_coolant)
			balloon_alert(user, "буфер полный")
			return TRUE
		playsound(src, 'sound/effects/liquid_pour/liquid_pour1.ogg', 50, TRUE)
		if(!do_after(user, 2 SECONDS, target = src))
			return TRUE
		current_water = reagents.get_reagent_amount(/datum/reagent/water)
		var/amount = min(water, max_coolant-current_water)
		can.reagents.remove_reagent(/datum/reagent/water, amount)
		reagents.add_reagent(/datum/reagent/water, amount)
		balloon_alert(user, "залита вода")
	else
		balloon_alert(user, "канистра пуста")
		return TRUE
	update_appearance()
	SStgui.update_uis(src)
	playsound(src, 'sound/effects/compressed_air/tank_insert_clunky.ogg', 50, TRUE)
	return TRUE

/obj/machinery/power/fuel_generator/attack_hand(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/power/fuel_generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FuelGenerator", name)
		ui.open()

/obj/machinery/power/fuel_generator/ui_data()
	var/list/data = list()
	var/ambient = get_ambient_temperature()
	var/fuel = reagents.get_reagent_amount(/datum/reagent/fuel)
	var/water = reagents.get_reagent_amount(/datum/reagent/water)
	data["active"] = active
	data["fuel"] = round(fuel)
	data["water"] = round(water)
	data["water_percent"] = water / max_coolant
	data["fuel_percent"] = fuel / max_fuel
	data["power_output"] = display_power(power_gen, convert = FALSE)
	data["heat"] = round(current_heat)
	data["heat_percent"] = clamp((current_heat - ambient) / (max_heat - ambient), 0, 1)
	data["broken"] = broken
	data["max_heat"] = max_heat
	data["max_fuel"] = max_fuel
	data["max_coolant"] = max_coolant
	data["water_recycler"] = has_water_recycler
	data["fuel_pellet"] = !!fuel_pellet
	data["cooling_enabled"] = cooling_enabled

	return data

/obj/machinery/power/fuel_generator/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_power")
			toggle_power()
			return TRUE
		if("toggle_cooling")
			cooling_enabled = !cooling_enabled
			SStgui.update_uis(src)
			return TRUE

/obj/machinery/power/fuel_generator/proc/get_ambient_temperature()
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return T20C
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return T20C
	return air.temperature

/obj/machinery/power/fuel_generator/proc/get_pipe_cooling()
	var/list/checked_parents = list()
	var/pipe_cooling = 0
	for(var/obj/machinery/atmospherics/pipe/heat_exchanging/simple/P in range(1, src))
		if(!P.parent)
			continue
		if(P.parent in checked_parents)
			continue
		checked_parents += P.parent
		var/datum/gas_mixture/air = P.parent.air
		if(!air)
			continue
		if(air.temperature < 270)
			var/delta = 270 - air.temperature
			var/moles_factor = min(air.total_moles() / 50, 1)
			var/cooling = (delta / 160) * moles_factor
			pipe_cooling += min(cooling, 0.6)

/obj/machinery/power/fuel_generator/proc/play_loop()
	if(sound_loop)
		return
	sound_loop = TRUE
	while(active && !QDELETED(src))
		playsound(src, 'sound/machines/generator/generator_mid1.ogg', 40, TRUE)
		sleep(50)
	sound_loop = FALSE

/obj/machinery/power/fuel_generator/proc/overheat()
	active = FALSE
	broken = TRUE
	capacitators_installed = 0
	repair_stage = REPAIR_CAPACITORS
	has_water_recycler = FALSE
	sound_loop = FALSE
	current_heat = T20C
	set_light(0)
	reagents.clear_reagents()
	explosion(src,
		devastation_range = 0,
		heavy_impact_range = 1,
		light_impact_range = 2,
		flash_range = 3)
	for(var/mob/living/L in range(2, src))
		L.adjust_fire_stacks(6)
		L.ignite_mob()
	icon_state = "weld"
	update_appearance()
	SStgui.update_uis(src)
	for(var/obj/structure/workbench/W in range(1, src))
		W.set_power(FALSE)
	if(fuel_pellet)
		qdel(fuel_pellet)
		fuel_pellet = null

/obj/machinery/power/fuel_generator/proc/repair_attackby(obj/item/I, mob/living/user)
	switch(repair_stage)
		if(REPAIR_CAPACITORS)
			if(!istype(I, /obj/item/stock_parts/capacitor))
				balloon_alert(user, "нужен конденсатор")
				return TRUE
			qdel(I)
			capacitators_installed++
			if(capacitators_installed >= 2)
				repair_stage = REPAIR_SCREWDRIVER
				balloon_alert(user, "конденсаторы установлены")
			else
				balloon_alert(user, "установлен конденсатор ([capacitators_installed]/2)")
			return TRUE
		if(REPAIR_SCREWDRIVER)
			if(I.tool_behaviour != TOOL_SCREWDRIVER)
				balloon_alert(user, "нужна отвёртка")
				return TRUE
			if(!I.use_tool(src, user, 2 SECONDS))
				return TRUE
			repair_stage = REPAIR_METAL
			balloon_alert(user, "конденсаторы закреплены")
			return TRUE
		if(REPAIR_METAL)
			if(!istype(I, /obj/item/stack/sheet/iron))
				balloon_alert(user, "нужен металл")
				return TRUE
			var/obj/item/stack/sheet/iron/S = I
			if(!S.use(1))
				return TRUE
			repair_stage = REPAIR_WELDER
			balloon_alert(user, "корпус восстановлен")
			return TRUE
		if(REPAIR_WELDER)
			if(I.tool_behaviour != TOOL_WELDER)
				balloon_alert(user, "нужна сварка")
				return TRUE
			if(!I.tool_start_check(user, amount = 1))
				return TRUE
			if(!I.use_tool(src, user, 4 SECONDS, amount = 1))
				return TRUE
			finish_repair()
			balloon_alert(user, "генератор восстановлен")
			return TRUE

	return TRUE

/obj/machinery/power/fuel_generator/proc/finish_repair()
	broken = FALSE
	active = FALSE
	repair_stage = REPAIR_CAPACITORS
	capacitators_installed = 0
	current_heat = T20C
	reagents.clear_reagents()
	has_water_recycler = FALSE
	fuel_pellet = FALSE
	sound_loop = FALSE
	set_light(0)
	icon_state = "off"
	update_appearance()
	SStgui.update_uis(src)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	for(var/obj/structure/workbench/W in range(1, src))
		W.set_power(FALSE)

