SUBSYSTEM_DEF(voyaker_mobs)
	name = "EFTK Mob Spawn Subsystem"
	wait = 20 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/voyaker_mobs/fire()
	for(var/obj/effect/landmark/bigot_spawn/L in GLOB.bigot_spawners)
		L.spawn_mob()
	for(var/obj/effect/landmark/forest_mutant_spawn/L in GLOB.forest_mutant_spawners)
		L.spawn_mob()
	priority_announce(
	"Наши разведчики докладывают о появлении многочисленных тварей, которые вновь повылезали из своих нор. Будьте осторожны.",
	"Сообщение группы Чистильщиков"
	)
