GLOBAL_LIST_EMPTY(hub_return_landmarks)
GLOBAL_LIST_EMPTY(dark_forest_entry_points)
GLOBAL_LIST_EMPTY(dark_forest_spawn_points)
GLOBAL_LIST_EMPTY(dark_forest_exit_points)

/obj/effect/landmark/hub_return
	name = "EFTK Hub Return Subsystem"

/obj/effect/landmark/hub_return/Initialize(mapload)
	. = ..()
	GLOB.hub_return_landmarks += src

/obj/effect/landmark/hub_return/Destroy()
	GLOB.hub_return_landmarks -= src
	return ..()

/obj/effect/landmark/dark_forest_entry
	name = "EFTK Dark Forest Entry Points Subsystem"

/obj/effect/landmark/dark_forest_entry/Initialize(mapload)
	. = ..()
	GLOB.dark_forest_entry_points += src

/obj/effect/landmark/dark_forest_entry/Destroy()
	GLOB.dark_forest_entry_points -= src
	return ..()

/obj/effect/landmark/dark_forest_spawn
	name = "EFTK Dark Forest Spawn"

/obj/effect/landmark/dark_forest_spawn/Initialize(mapload)
	. = ..()
	GLOB.dark_forest_spawn_points += src

/obj/effect/landmark/dark_forest_spawn/Destroy()
	GLOB.dark_forest_spawn_points -= src
	return ..()

/obj/effect/landmark/dark_forest_exit
	name = "EFTK Dark Forest Exit Subsystem"

/obj/effect/landmark/dark_forest_exit/Initialize(mapload)
	. = ..()
	GLOB.dark_forest_exit_points += src

/obj/effect/landmark/dark_forest_exit/Destroy()
	GLOB.dark_forest_exit_points -= src
	return ..()
