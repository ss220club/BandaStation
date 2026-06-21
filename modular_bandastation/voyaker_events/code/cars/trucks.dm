/obj/structure/vehicle_wreck
	name = "брошенный транспорт"
	desc = "Ржавеющий памятник ушедшей эпохе."
	icon = 'modular_bandastation/voyaker_events/icons/128x32_vehiclesexpanded.dmi'
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	layer = ABOVE_MOB_LAYER
	pixel_x = -48
	var/list/collision_offsets = list()
	var/list/parts = list()

/obj/structure/vehicle_wreck/part
	name = ""
	icon = null
	density = TRUE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/vehicle_wreck/master

/obj/structure/vehicle_wreck/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	for(var/list/offset in collision_offsets)
		var/dx = offset[1]
		var/dy = offset[2]
		var/turf/target = locate(T.x + dx, T.y + dy, T.z)
		if(!target)
			continue
		var/obj/structure/vehicle_wreck/part/P = new(target)
		P.master = src
		parts += P

/obj/structure/vehicle_wreck/Destroy()
	for(var/obj/structure/vehicle_wreck/part/P in parts)
		qdel(P)
	return ..()

/obj/structure/vehicle_wreck/ambulance
	name = "брошенная скорая помощь"
	icon_state = "ambulance"
	collision_offsets = list(list(1, 0))

/obj/structure/vehicle_wreck/longtruck_kelland
	name = "грузовик Kelland Mining"
	icon_state = "longtruck_kellandmining"
	collision_offsets = list(list(-1, 0), list(1, 0))

/obj/structure/vehicle_wreck/longtruck_blue
	name = "синий грузовик"
	icon_state = "longtruck_blue_redstripe"
	collision_offsets = list(list(-1, 0), list(1, 0))

/obj/structure/vehicle_wreck/longtruck_red
	name = "красный грузовик"
	icon_state = "longtruck_red_bluestripe"
	collision_offsets = list(list(-1, 0), list(1, 0))

/obj/structure/vehicle_wreck/longtruck_brown
	name = "коричневый грузовик"
	icon_state = "longtruck_brown"
	collision_offsets = list(list(-1, 0), list(1, 0))

/obj/structure/vehicle_wreck/longtruck_donk
	name = "грузовик Donk"
	icon_state = "longtruck_donk"
	collision_offsets = list(list(-1, 0), list(1, 0))

/obj/structure/vehicle_wreck/longtruck_nt_black
	name = "грузовик НаноТрейзен"
	icon_state = "longtruck_nt_black"
	collision_offsets = list(list(-1, 0), list(1, 0))

/obj/structure/vehicle_wreck/longtruck_nt_blue
	name = "грузовик НаноТрейзен"
	icon_state = "longtruck_nt_blue"

/obj/structure/vehicle_wreck/armoredtruck_nt1
	name = "броневик НТ"
	icon_state = "armoredtruck_nt_security_1"
	collision_offsets = list(list(1, 0))

/obj/structure/vehicle_wreck/armoredtruck_nt2
	name = "броневик НТ"
	icon_state = "armoredtruck_nt_security_2"
	collision_offsets = list(list(1, 0))

/obj/structure/vehicle_wreck/armoredtruck_white
	name = "броневик"
	icon_state = "armoredtruck_white_white"
	collision_offsets = list(list(1, 0))

/obj/structure/vehicle_wreck/armoredtruck_teal
	name = "броневик"
	icon_state = "armoredtruck_white_teal"
	collision_offsets = list(list(1, 0))

/obj/structure/vehicle_wreck/armoredtruck_blue
	name = "броневик"
	icon_state = "armoredtruck_blue_white"
	collision_offsets = list(list(1, 0))
