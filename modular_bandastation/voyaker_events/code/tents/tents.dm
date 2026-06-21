/obj/structure/tent_border
	name = ""
	icon = null
	anchored = TRUE
	density = TRUE
	flags_1 = ON_BORDER_1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = OBJ_LAYER
	resistance_flags = INDESTRUCTIBLE
	pass_flags_self = LETPASSTHROW

/obj/structure/tent_border/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(border_dir & dir)
		return FALSE
	if(border_dir & REVERSE_DIR(dir))
		return FALSE
	return TRUE

/obj/structure/tent
	name = "tent"
	icon = 'modular_bandastation/voyaker_events/icons/tents_deployed_classic.dmi'
	anchored = TRUE
	density = FALSE
	layer = OBJ_LAYER
	resistance_flags = INDESTRUCTIBLE
	var/obj/effect/tent_roof/roof
	var/list/borders = list()

/obj/structure/tent/Destroy()
	QDEL_NULL(roof)
	for(var/obj/O as anything in borders)
		qdel(O)
	return ..()

/obj/effect/tent_roof
	name = ""
	icon = 'modular_bandastation/voyaker_events/icons/tents_deployed_classic.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER

/obj/effect/tent_roof/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_TENT)

/obj/structure/tent/medical
	name = "medical tent"
	icon_state = "med_interior"

/obj/structure/tent/medical/Initialize(mapload)
	. = ..()
	roof = new /obj/effect/tent_roof/medical(loc)
	var/turf/T = get_turf(src)
	var/obj/structure/tent_border/B
	B = new /obj/structure/tent_border(locate(T.x, T.y + 2, T.z))
	B.dir = WEST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x, T.y + 2, T.z))
	B.dir = NORTH
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y + 2, T.z))
	B.dir = EAST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y + 2, T.z))
	B.dir = NORTH
	borders += B
	B = new /obj/structure/tent_border(locate(T.x, T.y + 1, T.z))
	B.dir = WEST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y + 1, T.z))
	B.dir = EAST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x, T.y, T.z))
	B.dir = WEST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y, T.z))
	B.dir = EAST
	borders += B

/obj/effect/tent_roof/medical
	icon_state = "med_top"
	pixel_y = 0

/obj/structure/tent/command
	icon_state = "cmd_interior"

/obj/structure/tent/command/Initialize(mapload)
	. = ..()
	roof = new /obj/effect/tent_roof/command(loc)
	var/turf/T = get_turf(src)
	var/obj/structure/tent_border/B
	B = new /obj/structure/tent_border(locate(T.x, T.y + 2, T.z))
	B.dir = WEST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x, T.y + 2, T.z))
	B.dir = NORTH
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y + 2, T.z))
	B.dir = EAST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y + 2, T.z))
	B.dir = NORTH
	borders += B
	B = new /obj/structure/tent_border(locate(T.x, T.y + 1, T.z))
	B.dir = WEST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y + 1, T.z))
	B.dir = EAST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x, T.y, T.z))
	B.dir = WEST
	borders += B
	B = new /obj/structure/tent_border(locate(T.x + 1, T.y, T.z))
	B.dir = EAST
	borders += B

/obj/effect/tent_roof/command
	icon_state = "cmd_top"
	pixel_y = 0
