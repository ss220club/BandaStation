GLOBAL_LIST_EMPTY(bigot_spawners)

/obj/effect/landmark/bigot_spawn
	name = "EFTK Elite Mutant Spawn Subsystem"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "xeno_spawn"

/obj/effect/landmark/bigot_spawn/Initialize(mapload)
	. = ..()
	GLOB.bigot_spawners += src

/obj/effect/landmark/bigot_spawn/Destroy()
	GLOB.bigot_spawners -= src
	return ..()

/obj/effect/landmark/bigot_spawn/proc/spawn_mob()
	var/turf/T = get_turf(src)
	if(!T)
		return
	for(var/mob/living/basic/bigot/B in range(1, T))
		return
	new /mob/living/basic/bigot(T)
