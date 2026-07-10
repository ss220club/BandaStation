GLOBAL_LIST_EMPTY(forest_mutant_spawners)

/obj/effect/landmark/forest_mutant_spawn
	name = "EFTK Forest Mutant Spawn"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "carp_spawn"
	var/list/mob_pool = list(
		/mob/living/basic/spider/giant/hunter = 50,
		/mob/living/basic/flesh_spider = 55,
		/mob/living/basic/faithless = 45,
		/mob/living/basic/faithless/old = 10,
	)

/obj/effect/landmark/forest_mutant_spawn/Initialize(mapload)
	. = ..()
	GLOB.forest_mutant_spawners += src

/obj/effect/landmark/forest_mutant_spawn/Destroy()
	GLOB.forest_mutant_spawners -= src
	return ..()

/obj/effect/landmark/forest_mutant_spawn/proc/spawn_mob()
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/path = pick_weight(mob_pool)
	if(path)
		new path(T)

/obj/effect/landmark/forest_mutant_spawn/faithless
	name = "Faithless Spawn"
	mob_pool = list(
		/mob/living/basic/faithless = 50,
		/mob/living/basic/faithless/old = 15,
	)

/obj/effect/landmark/forest_mutant_spawn/flesh_spider
	name = "Flesh Spider Spawn"
	mob_pool = list(/mob/living/basic/flesh_spider = 60)

/obj/effect/landmark/forest_mutant_spawn/hunter_spider
	name = "Hunter Spider Spawn"
	mob_pool = list(/mob/living/basic/spider/giant/hunter = 70)
