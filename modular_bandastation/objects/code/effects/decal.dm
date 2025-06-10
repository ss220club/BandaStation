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
	name = "NBS Воля Трейзена"
	desc = "Флагманский корабль группировки \"Кулак Трейзена\"."
	icon = 'modular_bandastation/objects/icons/obj/effects/ship.dmi'
	icon_state = "ship"
	plane = RENDER_PLANE_TRANSPARENT
	var/matrix/scale = matrix(1.3, 0, 0, 0, 1.3, 0)
	var/patch_start = 0
	var/patch_arrive = -100
	var/patch = -115
	var/arrive_time = 1.0 SECONDS
	var/fly_time = 30 SECONDS

/atom/movable/screen/ship/augustus
	name = "NSCS Август"
	desc = "Авианесущий крейсер с опознавательными знаками Нанотрейзен."
	icon_state = "ship_2"
	scale = matrix(0.8, 0, 0, 0, 0.8, 0)
	fly_time = 15 SECONDS
	patch = -120

/atom/movable/screen/ship/principatus
	name = "NBS Принципат"
	desc = "Боевой крейсер с опознавательными знаками Нанотрейзен."
	scale = matrix(0.6, 0, 0, 0, 0.6, 0)
	fly_time = 5 SECONDS
	patch = -125

/atom/movable/screen/ship/arno
	name = "FSS Арно"
	desc = "Боевой крейсер с опознавательными ТСФ."
	icon_state = "ship_3"
	patch_arrive = 100
	patch = 110
	scale = matrix(0.8, 0, 0, 0, 0.8, 0)

/atom/movable/screen/ship/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	spawn()
		spawn_ship_animation()

/atom/movable/screen/ship/proc/spawn_ship_animation()
	transform = matrix(0.1, 0, 0, 0, 0.1, 0)
	pixel_x = patch_start
	var/matrix/mid_scale = matrix(0.5, 0, 0, 0, 0.5, 0)
	var/matrix/final_scale = scale || matrix()

	animate(src, transform = mid_scale, pixel_x = patch_arrive, time = arrive_time, easing = CUBIC_EASING | EASE_OUT, flags = ANIMATION_END_NOW)

	sleep (0.1 SECONDS)

	playsound(src,'modular_bandastation/objects/sounds/hyperspace.ogg', 75, extrarange = 20, pressure_affected = FALSE, ignore_walls = TRUE )
	animate(src, transform = final_scale, pixel_x = patch, time = fly_time, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
