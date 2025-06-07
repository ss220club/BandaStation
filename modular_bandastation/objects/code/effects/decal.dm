// MARK: Logotypes
// Note: Used to be non turf-decals so we can pixel-shift them
/obj/effect/decal/syndie_logo
	name = "Syndicate logo"
	icon = 'modular_bandastation/objects/icons/obj/effects/logos.dmi'
	icon_state = "logo1"
	layer = MID_TURF_LAYER // Above other decals

/obj/effect/decal/nt_logo
	name = "Nanotrasen logo"
	icon = 'modular_bandastation/objects/icons/obj/effects/logos.dmi'
	icon_state = "ntlogo_sec"
	alpha = 180
	layer = MID_TURF_LAYER // Above other decals

/obj/effect/decal/nt_logo/alt
	icon_state = "ntlogo"

/obj/effect/decal/solgov_logo
	name = "SolGov logo"
	icon = 'modular_bandastation/objects/icons/obj/effects/logos.dmi'
	icon_state = "sol_logo1"
	layer = MID_TURF_LAYER // Above other decals

//ТМ НА ОДИН РАУНД, НЕ ХОЧУ КОНФЛИКТОВ В OBJECTS.DME
/atom/movable/screen/planet
	name = "Ламэра"
	desc = "Разрушенный планетоид. Старый, как сама система."
	icon = 'modular_bandastation/objects/icons/obj/effects/planet.dmi'
	icon_state = "planet"
	plane = RENDER_PLANE_TRANSPARENT

/atom/movable/screen/ship
	name = "FSS Луизиана"
	desc = "Небольшой корабль. Опознавательных знаков нет."
	icon = 'modular_bandastation/objects/icons/obj/effects/ship.dmi'
	icon_state = "ship"
	plane = RENDER_PLANE_TRANSPARENT

/atom/movable/screen/ship/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	animate(src, pixel_x = 999, time = 300 SECONDS, easing = LINEAR_EASING)
