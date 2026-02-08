/obj/structure/bush_wall
	name = "живая изгородь"
	desc = "Живая изгородь из кустарника. На вид непроходимая, но мягкая."
	icon = 'modular_bandastation/turfs/icons/bush_wall.dmi'
	icon_state = "bush_wall"
	base_icon_state = "bush_wall-47"
	density = FALSE
	opacity = FALSE

/turf/closed/wall/bush/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/projectile))
		return TRUE
	if(istype(mover, /obj/effect))
		return TRUE

/turf/closed/wall/bush/CanAtmosPass(direction)
	return TRUE
