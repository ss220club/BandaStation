/obj/structure/power_pole
	name = "power line tower"
	desc = "Высокая опора линии электропередачи."
	icon = 'modular_bandastation/voyaker_events/icons/lep.dmi'
	icon_state = "lep"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	pixel_y = 32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	CanAllowThrough(atom/movable/mover, border_dir)
		return FALSE

/obj/effect/power_pole_blocker
	name = "power pole collision"
	anchored = TRUE
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	resistance_flags = INDESTRUCTIBLE

/obj/structure/power_pole
	var/obj/effect/power_pole_blocker/left_blocker
	var/obj/effect/power_pole_blocker/right_blocker

/obj/structure/power_pole/Initialize(mapload)
	. = ..()

	left_blocker = new(get_turf(src))
	right_blocker = new(get_step(src, EAST))

/obj/structure/power_pole/Destroy()
	QDEL_NULL(left_blocker)
	QDEL_NULL(right_blocker)
	return ..()
