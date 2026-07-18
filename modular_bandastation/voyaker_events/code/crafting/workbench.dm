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
	var/list/parts = list()

/obj/structure/workbench_part
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/apc/master

/obj/structure/workbench_part/attackby(obj/item/I, mob/user, params)
	if(master)
		return master.attackby(I, user, params)
	return ..()

/obj/structure/workbench/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/structure/workbench_part(locate(T.x + 1, T.y, T.z))
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
