/obj/structure/apc
	name = "брошенный БТР"
	desc = "Старая боевая машина, давно превратившаяся в груду металла."
	icon = 'modular_bandastation/voyaker_events/icons/arc_prop.dmi'
	icon_state = "arc_base"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	pixel_x = -16
	layer = ABOVE_MOB_LAYER
	var/list/parts = list()

/obj/structure/apc_part
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/apc/master

/obj/structure/apc_part/attackby(obj/item/I, mob/user, params)
	if(master)
		return master.attackby(I, user, params)
	return ..()

/obj/structure/apc/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/structure/apc_part(locate(T.x + 1, T.y, T.z))
	new /obj/structure/apc_part(locate(T.x + 2, T.y, T.z))
	new /obj/structure/apc_part(locate(T.x + 1, T.y + 1, T.z))
	new /obj/structure/apc_part(locate(T.x + 2, T.y + 1, T.z))
	new /obj/structure/apc_part(locate(T.x + 1, T.y + 2, T.z))
	new /obj/structure/apc_part(locate(T.x + 2, T.y + 2, T.z))

/obj/structure/apc/wreck
	name = "уничтоженный брошенный БТР"
	icon_state = "arc_destroyed"


