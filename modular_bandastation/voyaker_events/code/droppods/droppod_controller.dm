SUBSYSTEM_DEF(voyaker_droppods)
	name = "Voyaker Drop Pods"
	wait = 30 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/voyaker_droppods/fire()
	if(!length(GLOB.drop_pod_spawns))
		return
	var/obj/effect/landmark/drop_pod_spawn/L = pick(GLOB.drop_pod_spawns)
	L.spawn_supply_pod()
	priority_announce(
		"На локации [L.location_name] обнаружена посадка гуманитарной грузовой капсулы НаноТрейзен. Рекомендуется забрать содержимое.",
		"Автоматическая система наблюдения АСБ Ковчег"
	)
