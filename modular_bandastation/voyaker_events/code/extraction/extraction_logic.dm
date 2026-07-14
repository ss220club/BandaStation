/mob/living/carbon/human
	var/can_leave_location_time = 0

/mob/living/carbon/human/proc/leave_to_hub()
	if(world.time < can_leave_location_time)
		var/time_left = round((can_leave_location_time - world.time) / 10)
		to_chat(src, span_warning("Вы сможете покинуть локацию через [time_left] сек."))
		return FALSE
	if(!length(GLOB.hub_return_landmarks))
		return FALSE
	var/obj/effect/landmark/hub_return/L = pick(GLOB.hub_return_landmarks)
	forceMove(get_turf(L))
	set_static_vision(2 SECONDS)
	set_temp_blindness(1 SECONDS)
	return TRUE

/mob/living/carbon/human/proc/enter_location(location_id)
	var/list/spawns = GLOB.location_spawn_points[location_id]
	if(!length(spawns))
		return FALSE
	var/list/free_spawns = list()
	for(var/obj/effect/landmark/location_spawn/L in spawns)
		var/free = TRUE
		for(var/mob/living/carbon/human/H in range(10, L))
			if(H == src)
				continue
			free = FALSE
			break
		if(free)
			free_spawns += L
	if(!length(free_spawns))
		to_chat(src, span_warning("Сейчас нет свободных точек для появления. Пожалуйста, подождите..."))
		return FALSE
	var/obj/effect/landmark/location_spawn/L = pick(free_spawns)
	forceMove(get_turf(L))
	set_static_vision(2 SECONDS)
	set_temp_blindness(1 SECONDS)
	can_leave_location_time = world.time + (3 MINUTES)
	to_chat(src, span_notice("Покинуть локацию можно через 3 минуты."))
	return TRUE

/obj/structure/gate
	name = "Переход."
	desc = "Ведёт в зону."
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = FALSE
	var/location_id = null

/obj/structure/gate/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.enter_location(location_id)

/obj/structure/extract
	name = "Эвакуационный выход"
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = FALSE

/obj/structure/extract/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.leave_to_hub()

/obj/structure/gate/dark_forest
	name = "Блюспейс-переход."
	desc = "Ведёт в зону Тёмного Леса"
	location_id = "dark_forest"

/obj/structure/gate/village
	name = "Блюспейс-переход."
	desc = "Ведёт в определённую зону."
	location_id = "village"

/obj/structure/gate/mine
	name = "Блюспейс-переход."
	desc = "Ведёт в определённую зону."
	location_id = "mine"

/obj/structure/gate/coast
	name = "Блюспейс-переход."
	desc = "Ведёт в определённую зону."
	location_id = "coast"

/obj/structure/extract/dark_forest
	name = "Выход из Тёмного Леса"

/obj/structure/extract/village
	name = "Выход из Посёлка"

/obj/structure/extract/mine
	name = "Выход из Шахты"

/obj/structure/extract/coast
	name = "Выход c Побережья"
