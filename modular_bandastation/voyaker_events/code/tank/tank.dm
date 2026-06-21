/obj/structure/tank_wreck
	name = "подбитый танк"
	desc = "Старая боевая машина, давно превратившаяся в груду металла."
	icon = 'modular_bandastation/voyaker_events/icons/campaign_bigger.dmi'
	icon_state = "tank_broken"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	pixel_x = -16
	layer = ABOVE_MOB_LAYER

/obj/structure/tank
	name = "танк"
	desc = "Тяжёлая боевая машина."
	icon = 'modular_bandastation/voyaker_events/icons/campaign_bigger.dmi'
	icon_state = "tank"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	pixel_x = -16
	layer = ABOVE_MOB_LAYER

/obj/structure/vtol
	name = "транспортер вертикального взлета"
	desc = "Транспортник, предназначенный для быстрой перевозки по воздуху."
	icon = 'modular_bandastation/voyaker_events/icons/vtol_prop.dmi'
	icon_state = "vtol"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	pixel_x = -16
	layer = ABOVE_MOB_LAYER

/obj/structure/vtol/wrecked
	icon_state = "vtol_damaged"
