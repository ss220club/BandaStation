/mob/living/carbon/human
	var/can_leave_location_time = 0

/mob/living/carbon/human/proc/leave_to_hub(mob/living/carbon/human/H)
	if(world.time < H.can_leave_location_time)
		var/time_left = round((H.can_leave_location_time - world.time) / 10)
		to_chat(H, span_warning("Вы сможете покинуть локацию через [time_left] сек."))
		return FALSE
	if(!length(GLOB.hub_return_landmarks))
		return FALSE
	var/obj/effect/landmark/hub_return/L = pick(GLOB.hub_return_landmarks)
	H.forceMove(get_turf(L))
	set_static_vision(2 SECONDS)
	set_temp_blindness(1 SECONDS)
	return TRUE

/mob/living/carbon/human/proc/enter_dark_forest(mob/living/carbon/human/H)
	if(!length(GLOB.dark_forest_spawn_points))
		return
	var/obj/effect/landmark/dark_forest_spawn/L = pick(GLOB.dark_forest_spawn_points)
	H.forceMove(get_turf(L))
	set_static_vision(2 SECONDS)
	set_temp_blindness(1 SECONDS)
	H.can_leave_location_time = world.time + (3 MINUTES)
	to_chat(H, span_notice("Покинуть локацию можно через 3 минуты."))

/obj/structure/dark_forest_gate
	name = "Переход в Тёмный лес"
	desc = "Ведёт в зону Тёмного леса."
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal"
	resistance_flags = INDESTRUCTIBLE

/obj/structure/dark_forest_gate/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.enter_dark_forest(H)

/obj/structure/dark_forest_extract
	name = "Эвакуационный выход"
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal"
	resistance_flags = INDESTRUCTIBLE

/obj/structure/dark_forest_extract/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.leave_to_hub(H)


