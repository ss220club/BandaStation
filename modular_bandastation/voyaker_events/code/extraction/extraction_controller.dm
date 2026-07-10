GLOBAL_LIST_EMPTY(hub_return_landmarks)
GLOBAL_LIST_EMPTY(location_entry_points)
GLOBAL_LIST_EMPTY(location_spawn_points)
GLOBAL_LIST_EMPTY(location_exit_points)

/obj/effect/landmark/hub_return
	name = "EFTK Hub Return Subsystem"
	var/location_id = "hub"

/obj/effect/landmark/hub_return/Initialize(mapload)
	. = ..()
	GLOB.hub_return_landmarks += src

/obj/effect/landmark/hub_return/Destroy()
	GLOB.hub_return_landmarks -= src
	return ..()

/obj/effect/landmark/location_entry
	name = "EFTK Entry Points"
	var/location_id = "default"

/obj/effect/landmark/location_entry/Initialize(mapload)
	. = ..()
	if(!GLOB.location_entry_points[location_id])
		GLOB.location_entry_points[location_id] = list()
	GLOB.location_entry_points[location_id] += src


/obj/effect/landmark/location_entry/Destroy()
	var/list/L = GLOB.location_entry_points[location_id]
	if(L)
		L -= src
		if(!length(L))
			GLOB.location_entry_points -= location_id
	return ..()

/obj/effect/landmark/location_spawn
	name = "EFTK Spawn Point"
	var/location_id = "default"

/obj/effect/landmark/location_spawn/Initialize(mapload)
	. = ..()
	if(!GLOB.location_spawn_points[location_id])
		GLOB.location_spawn_points[location_id] = list()
	GLOB.location_spawn_points[location_id] += src

/obj/effect/landmark/location_spawn/Destroy()
	var/list/L = GLOB.location_spawn_points[location_id]
	if(L)
		L -= src
		if(!length(L))
			GLOB.location_spawn_points -= location_id
	return ..()

/obj/effect/landmark/location_exit
	name = "EFTK Exit Points"
	var/location_id = "default"

/obj/effect/landmark/location_exit/Initialize(mapload)
	. = ..()
	if(!GLOB.location_exit_points[location_id])
		GLOB.location_exit_points[location_id] = list()
	GLOB.location_exit_points[location_id] += src

/obj/effect/landmark/location_exit/Destroy()
	var/list/L = GLOB.location_exit_points[location_id]
	if(L)
		L -= src
		if(!length(L))
			GLOB.location_exit_points -= location_id
	return ..()

/obj/effect/landmark/location_entry/dark_forest
	location_id = "dark_forest"

/obj/effect/landmark/location_entry/village
	location_id = "village"

/obj/effect/landmark/location_entry/mine
	location_id = "mine"

/obj/effect/landmark/location_entry/coast
	location_id = "coast"

/obj/effect/landmark/location_spawn/dark_forest
	location_id = "dark_forest"

/obj/effect/landmark/location_spawn/village
	location_id = "village"

/obj/effect/landmark/location_spawn/mine
	location_id = "mine"

/obj/effect/landmark/location_spawn/coast
	location_id = "coast"

/obj/effect/landmark/location_exit/dark_forest
	location_id = "dark_forest"

/obj/effect/landmark/location_exit/village
	location_id = "village"

/obj/effect/landmark/location_exit/mine
	location_id = "mine"

/obj/effect/landmark/location_exit/coast
	location_id = "coast"
