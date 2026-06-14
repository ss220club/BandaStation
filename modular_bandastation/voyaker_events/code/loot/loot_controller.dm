SUBSYSTEM_DEF(voyaker_loot)
	name = "Voyaker Loot"
	wait = 15 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/voyaker_loot/fire()
	for(var/obj/effect/landmark/loot_spawn/L in GLOB.loot_spawners)
		L.spawn_loot()
		priority_announce(
			"Наши разведчики обнаружили новую добычу на всех локациях. Спешите поживиться первыми.",
			"Сообщение группы Чистильщиков"
		)
