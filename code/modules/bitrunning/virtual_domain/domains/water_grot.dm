/datum/lazy_template/virtual_domain/water_grot
	name = "Водный сплав"
	cost = BITRUNNER_COST_LOW  // Стоимость запуска
	desc = "Доплыть до конца."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	help_text = "Награда ждет тебя в самом конце."
	key = "water_grot"
	map_name = "water_grot"
	reward_points = BITRUNNER_REWARD_LOW

/turf/open/water/groundwater
	name = "глубокие грунтовые воды"
	desc = "Холодная и чистая вода, просачивающаяся сквозь породы."
	immerse_overlay = "immerse_deep"
	icon = 'modular_bandastation/turfs/icons/water.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/groundwater
	is_swimming_tile = TRUE

/obj/effect/abstract/whirlpool
	name = "водоворот"
	desc = "Воронка на поверхности воды, затягивающая в пучину всё, что приближается."
	icon = 'modular_bandastation/turfs/icons/water.dmi'
	icon_state = "whirlpool"
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/abstract/whirlpool/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	if(T && !T.GetComponent(/datum/component/chasm))
		T.AddComponent(/datum/component/chasm, null, mapload)

/obj/effect/abstract/mist
	name = "туман"
	desc = "Густой туман над водой."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
