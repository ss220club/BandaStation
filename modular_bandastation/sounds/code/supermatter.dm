/datum/looping_sound/supermatter/hugbox
	volume = 10
	extra_range = -5

/obj/machinery/power/supermatter_crystal/hugbox

/obj/machinery/power/supermatter_crystal/hugbox/Initialize(mapload)
	. = ..()
	QDEL_NULL(soundloop)
	soundloop = new /datum/looping_sound/supermatter/hugbox(src, TRUE)
