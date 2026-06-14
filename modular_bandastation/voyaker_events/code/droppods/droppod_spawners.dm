GLOBAL_LIST_EMPTY(drop_pod_spawns)

/obj/effect/landmark/drop_pod_spawn
	name = "drop pod spawn"
	icon_state = "generic_event"
	var/location_name = "неизвестный район"

	var/list/crate_pool = list(
		/obj/structure/closet/crate/loot/common
	)

	Initialize()
		. = ..()

		if(!GLOB.drop_pod_spawns)
			GLOB.drop_pod_spawns = list()
		GLOB.drop_pod_spawns += src

/obj/effect/landmark/drop_pod_spawn/proc/spawn_supply_pod()
	var/chosen_type = pick(crate_pool)
	var/obj/crate = new chosen_type
	podspawn(list(
		"target" = get_turf(src),
		"path" = /obj/structure/closet/supplypod,
		"spawn" = list(crate)
	))

/obj/effect/landmark/drop_pod_spawn/new_sydney
	location_name = "Новый Сидней"

/obj/effect/landmark/drop_pod_spawn/coast
	location_name = "Побережье"

/obj/effect/landmark/drop_pod_spawn/village
	location_name = "Поселок"

/obj/effect/landmark/drop_pod_spawn/dark_forest
	location_name = "Тёмный Лес"
