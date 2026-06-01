/atom/movable/screen/sky
	name = "Облака"
	icon = 'modular_bandastation/event/icons/obj/try2.dmi'
	icon_state = "sky"
	plane = RENDER_PLANE_TRANSPARENT
	layer = 1.0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER"
	appearance_flags = PIXEL_SCALE

/atom/movable/screen/sky/New(loc)
	..()
	pixel_x = -30
	pixel_y = -400
	animate(src, pixel_x = -300, time = 15 SECONDS, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(start_fade)), 7 SECONDS)

/atom/movable/screen/sky/proc/start_fade()
	animate(src, alpha = 0, time = 15 SECONDS, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(delete_self)), 30 SECONDS)

/atom/movable/screen/sky/proc/delete_self()
	qdel(src)


/atom/movable/screen/city
	name = "Лимнея"
	icon = 'modular_bandastation/event/icons/obj/try.dmi'
	icon_state = "city"
	plane = RENDER_PLANE_TRANSPARENT
	layer = 0.9
	mouse_opacity = MOUSE_OPACITY_ICON
	screen_loc = "CENTER"
	appearance_flags = PIXEL_SCALE

/atom/movable/screen/city/New(loc)
		..()
		pixel_x = 0
		pixel_y = -300
		//alpha = 0
		animate(src, pixel_x = -2500, time = 300 SECONDS, easing = LINEAR_EASING)


/*
		addtimer(CALLBACK(src, PROC_REF(start_fadde)), 2 SECONDS)

/atom/movable/screen/city/proc/start_fadde()
	animate(src, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
*/

/atom/movable/screen/limneya
	name = "Лимнея"
	desc = "Планета-эйкуменополис."
	icon = 'modular_bandastation/event/icons/obj/try3.dmi'
	icon_state = "limneya"
	plane = RENDER_PLANE_TRANSPARENT
	mouse_opacity = MOUSE_OPACITY_ICON
	screen_loc = "CENTER"
	var/appearance_time = 2 SECONDS
	var/current_scale = 1.0
	var/current_tx = 0
	var/current_ty = 0
	var/half_size = 512

/atom/movable/screen/limneya/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	spawn()
		planet_animation()

/atom/movable/screen/limneya/proc/planet_animation()
	var/matrix/start = matrix()
	start.Translate(-half_size, -half_size)
	start.Scale(0, 0)
	start.Translate(half_size, half_size)
	transform = start

	var/matrix/orbit = matrix()
	orbit.Translate(-half_size, -half_size)
	orbit.Scale(0.8, 0.8)
	orbit.Translate(half_size, half_size)
	orbit.Translate(-370, -420)

	animate(src, transform = orbit, time = appearance_time, easing = CUBIC_EASING | EASE_OUT, flags = ANIMATION_END_NOW)

	current_scale = 0.8
	current_tx = -370
	current_ty = -420
