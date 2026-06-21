SUBSYSTEM_DEF(voyaker_loot)
	name = "EFTK Loot Spawn System"
	wait = 15 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/voyaker_loot/Initialize()
	. = ..()
	spawn_all_loot(FALSE)
	addtimer(CALLBACK(src, PROC_REF(spawn_all_loot), FALSE), 10 SECONDS)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/voyaker_loot/fire()
	spawn_all_loot(TRUE)

/datum/controller/subsystem/voyaker_loot/proc/spawn_all_loot(show_announce = TRUE)
	for(var/obj/effect/landmark/loot_spawn/L in GLOB.loot_spawners)
		L.spawn_loot()
	if(show_announce)
		priority_announce(
			"Наши разведчики обнаружили новую добычу на всех локациях. Спешите поживиться первыми.",
			"Сообщение группы Чистильщиков"
		)
