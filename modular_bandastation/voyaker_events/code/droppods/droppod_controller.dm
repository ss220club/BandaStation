SUBSYSTEM_DEF(voyaker_droppods)
	name = "EFTK Drop Pods Subsystem"
	wait = 30 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/voyaker_droppods/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spawn_random_pod)), rand(5 MINUTES, 10 MINUTES), TIMER_DELETE_ME)
	next_fire = world.time + 40 MINUTES
	return SS_INIT_SUCCESS

/datum/controller/subsystem/voyaker_droppods/fire()
	spawn_random_pod()

/datum/controller/subsystem/voyaker_droppods/proc/spawn_random_pod()
	if(!length(GLOB.drop_pod_spawns))
		return
	var/obj/effect/landmark/drop_pod_spawn/L = pick(GLOB.drop_pod_spawns)
	if(!L)
		return
	L.spawn_supply_pod()

	priority_announce(
		"На локации [L.location_name] обнаружена посадка гуманитарной грузовой капсулы НаноТрейзен. Рекомендуется забрать содержимое.",
		"Автоматическая система наблюдения АСБ Ковчег"
	)
