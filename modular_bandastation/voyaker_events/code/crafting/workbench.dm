/obj/structure/workbench
	name = "верстак"
	icon = 'modular_bandastation/voyaker_events/icons/workbench.dmi'
	icon_state = "off"
	desc = "Довольно грязное, потрепанное временем, но подходящее рабочее пространство для создания большинства предметов."
	density = TRUE
	anchored = TRUE
	light_range = 0
	light_power = 0
	light_color = "#c9cfad"
	var/powered = FALSE

/obj/structure/workbench/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/workbench/proc/set_power(state)
	powered = state
	if(powered)
		icon_state = "on"
		set_light(2, 1.2,"#c9cfad")
	else
		icon_state = "off"
		set_light(0)
	update_appearance()

/obj/structure/workbench/proc/has_power()
	return powered
