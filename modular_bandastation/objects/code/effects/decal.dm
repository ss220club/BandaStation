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
/atom/movable/screen/ship
	name = "FSS Флёр"
	desc = "Крейсер с опознавательными знаками ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/effects/ship.dmi'
	icon_state = "ship"
	plane = RENDER_PLANE_TRANSPARENT
	var/matrix/scale = null
	var/patch = 192

/atom/movable/screen/ship/arno
	name = "FSS Арно"
	desc = "Авианесущий крейсер с опознавательными знаками ТСФ."
	icon_state = "ship_2"
	scale = matrix(0.8, 0, 0, 0, 0.8, 0)
	patch = 187

/atom/movable/screen/ship/dyuwo
	name = "FSS Дюво"
	scale = matrix(0.6, 0, 0, 0, 0.6, 0)
	patch = 180

/atom/movable/screen/ship/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	spawn()
		spawn_ship_animation()

/atom/movable/screen/ship/proc/spawn_ship_animation()
	transform = matrix(0.1, 0, 0, 0, 0.1, 0)
	pixel_x = 0
	var/matrix/final_scale = scale || matrix()

	animate(src, transform = final_scale, pixel_x = 175, time = 1 SECONDS, easing = CUBIC_EASING | EASE_OUT)
	sleep (0.1 SECONDS)
	playsound(src,'modular_bandastation/objects/sounds/hyperspace.ogg', 75, extrarange = 20, pressure_affected = FALSE, ignore_walls = TRUE )
	animate(src, pixel_x = patch, time = 5 SECONDS, easing = LINEAR_EASING)
