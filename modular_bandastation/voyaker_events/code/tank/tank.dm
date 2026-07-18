/obj/structure/tank
	name = "танк"
	desc = "Тяжёлая боевая машина."
	icon = 'modular_bandastation/voyaker_events/icons/campaign_bigger.dmi'
	icon_state = "tank"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	layer = ABOVE_MOB_LAYER
	var/list/parts = list()

/obj/structure/tank_part
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/tank/master

/obj/structure/tank_part/attackby(obj/item/I, mob/user, params)
	if(master)
		return master.attackby(I, user, params)
	return ..()

/obj/structure/tank/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/structure/tank_part(locate(T.x + 1, T.y,     T.z))
	new /obj/structure/tank_part(locate(T.x + 2, T.y,     T.z))
	new /obj/structure/tank_part(locate(T.x + 3, T.y,     T.z))
	new /obj/structure/tank_part(locate(T.x,     T.y + 1, T.z))
	new /obj/structure/tank_part(locate(T.x + 1, T.y + 1, T.z))
	new /obj/structure/tank_part(locate(T.x + 2, T.y + 1, T.z))
	new /obj/structure/tank_part(locate(T.x + 3, T.y + 1, T.z))
	new /obj/structure/tank_part(locate(T.x,     T.y + 2, T.z))
	new /obj/structure/tank_part(locate(T.x + 1, T.y + 2, T.z))
	new /obj/structure/tank_part(locate(T.x + 2, T.y + 2, T.z))
	new /obj/structure/tank_part(locate(T.x + 3, T.y + 2, T.z))

/obj/structure/tank/wreck
	name = "подбитый танк"
	desc = "Старая боевая машина, давно превратившаяся в груду металла."
	icon_state = "tank_broken"

/obj/structure/vtol
	name = "транспортер вертикального взлета"
	desc = "Транспортник, предназначенный для быстрой перевозки по воздуху."
	icon = 'modular_bandastation/voyaker_events/icons/vtol_prop.dmi'
	icon_state = "vtol"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	layer = ABOVE_MOB_LAYER
	var/list/parts = list()

/obj/structure/vtol_part
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/tank/master

/obj/structure/vtol_part/attackby(obj/item/I, mob/user, params)
	if(master)
		return master.attackby(I, user, params)
	return ..()

/obj/structure/vtol/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/structure/vtol_part(locate(T.x + 1, T.y + 1, T.z))
	new /obj/structure/vtol_part(locate(T.x + 2, T.y + 1, T.z))
	new /obj/structure/vtol_part(locate(T.x,     T.y + 2, T.z))
	new /obj/structure/vtol_part(locate(T.x + 1, T.y + 2, T.z))
	new /obj/structure/vtol_part(locate(T.x + 2, T.y + 2, T.z))
	new /obj/structure/vtol_part(locate(T.x + 3, T.y + 2, T.z))
	new /obj/structure/vtol_part(locate(T.x + 4, T.y + 2, T.z))

/obj/structure/vtol/wrecked
	icon_state = "vtol_damaged"

/obj/structure/vtol/wrecked/interact(mob/living/carbon/human/user)
	. = ..()
	var/datum/trader_quest/Q = user.trader_quests?[TRADER_SAMOPAL]
	if(!Q)
		return TRUE
	if(Q.id != "samopal_vtol")
		return TRUE
	var/area/A = get_area(src)
	if(!istype(A, /area/new_sydney/coast))
		balloon_alert(user, "не тот истребитель")
		return
	if(!user.check_trader_cooldown("samopal_blackbox"))
		var/time_left = round((user.trader_action_cooldowns["samopal_blackbox"] - world.time) / 10)
		balloon_alert(user, "ещё [time_left] сек.")
		return TRUE
	balloon_alert(user, "извлекает чёрный ящик...")
	if(!do_after(user, 10 SECONDS, target = src))
		return TRUE
	user.set_trader_cooldown("samopal_blackbox", 10 MINUTES)
	var/obj/item/blackbox/B = new(get_turf(src))
	user.put_in_hands(B)
	balloon_alert(user, "чёрный ящик извлечён")
	return TRUE
