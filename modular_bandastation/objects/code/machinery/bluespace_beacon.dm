/datum/station_goal/bluespace_beacon
	name = "Bluespace Harvester"
	var/goal = 45000
	VAR_PRIVATE/cached_points

/obj/item/circuitboard/machine/bluespace_beacon
	name = "Bluespace beacon"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/bluespace_beacon
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/capacitor/tier3 = 5,
		/datum/stock_part/servo/tier3 = 5,
		/obj/item/stack/cable_coil = 2)

/datum/supply_pack/engineering/bluespace_beacon
	name = "Bluespace beacon parts"
	desc = "Тут нихуя нет"
	cost = CARGO_CRATE_VALUE * 24
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/circuitboard/machine/bluespace_beacon)
	crate_name= "bluespace beacon parts crate"

/datum/station_goal/bluespace_beacon/get_report()
	return {"<b>Bluespace Harvester Experiment</b><br>
	Another research station has developed a device called a Bluespace Harvester.
	It reaches through bluespace into other dimensions to shift through them for interesting objects.<br>
	Due to unforseen circumstances the large-scale test of the prototype could not be completed on the original research station. It will instead be carried out on your station.
	Acquire the circuit board, construct the device over a wire knot and feed it enough power to strike a motherlode of objects, located [goal] points deep.
	<br><br>
	Be advised that the device is experimental and might act in slightly unforseen ways if sufficiently powered. It may also require maintenance irregularly.
	<br>
	Nanotrasen Science Directorate"}

/datum/station_goal/bluespace_beacon/on_report()
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/bluespace_beacon]
	P.order_flags |= ORDER_SPECIAL_ENABLED

/datum/station_goal/bluespace_beacon/check_completion()
	if(..())
		return TRUE
	if(cached_points >= goal)
		return TRUE
	return FALSE

/obj/machinery/bluespace_beacon
	name = "Bluespace beacon"
	icon = 'modular_bandastation/objects/icons/obj/machines/bluespace_tap.dmi'
	icon_state = "bluespace_tap"
	base_icon_state = "bluespace_tap"
	max_integrity = 300
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_OFFLINE
	luminosity = 1
	var/list/obj/structure/fillers = list()

	var/current_charge = 0
	var/actual_power_usage = 0
	var/maximum_charge = 100
	var/input_attempt = FALSE
	var/inputting = FALSE
	var/input_level = 50 KILO WATTS
	var/input_level_max = 200 KILO WATTS

/obj/machinery/bluespace_beacon/Initialize(mapload)

	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,SOUTHEAST,SOUTHWEST, NORTH, NORTHWEST, NORTHEAST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

	return ..()

/obj/machinery/bluespace_beacon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceBeacon", name)
		ui.open()

/obj/machinery/bluespace_beacon/ui_static_data(mob/user)
	. = list(
		"maximumCharge" = maximum_charge,
		"inputLevelMax" = input_level_max,
	)

/obj/machinery/bluespace_beacon/ui_data()
	. = list(
		"inputting" = inputting,
		"inputAttempt" = input_attempt,
		"inputAvailable" = energy_to_power(actual_power_usage),
		"charge" = current_charge,
		"powerUsage" = actual_power_usage,
		"inputLevel" = input_level,
	)

/obj/machinery/bluespace_beacon/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("tryinput")
			input_attempt = !input_attempt
			update_appearance(UPDATE_OVERLAYS)
			return TRUE

		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = input_level_max
				. = TRUE
			else if(adjust)
				target = input_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				input_level = clamp(target, 0, input_level_max)
				return
