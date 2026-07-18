/obj/structure/vehicle_light
	name = "брошенная машина"
	desc = "Ржавеющий памятник ушедшей эпохе."
	icon = 'modular_bandastation/voyaker_events/icons/vehiclesexpanded.dmi'
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	layer = ABOVE_MOB_LAYER
	var/has_hitbox = TRUE

/obj/structure/vehicle_hitbox
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/vehicle_light/master

/obj/structure/vehicle_hitbox/attackby(obj/item/C, mob/user, params)
    if(master)
        return master.attackby(C, user, params)
    return ..()

/obj/structure/vehicle_light/Initialize(mapload)
	. = ..()
	if(!has_hitbox)
		return
	var/turf/T = get_step(src, EAST)
	if(!T)
		return
	var/obj/structure/vehicle_hitbox/H = new(T)
	H.master = src

/obj/structure/vehicle_light/suv1
	name = "SUV Минивэн"
	icon_state = "SUV"

/obj/structure/vehicle_light/suv2
	name = "SUV Минивэн"
	icon_state = "SUV1"

/obj/structure/vehicle_light/suv1/dmg
	name = "уничтоженный минивэн"
	icon_state = "SUV_damaged"

/obj/structure/vehicle_light/suv2/dmg
	name = "уничтоженный минивэн"
	icon_state = "SUV1_damaged"

/obj/structure/vehicle_light/suv_ambu
	name = "SUV скорая помощь"
	icon_state = "ambulance"

/obj/structure/vehicle_light/whitevan
	icon_state = "whitevan"

/obj/structure/vehicle_light/greyvan
	icon_state = "greyvan"

/obj/structure/vehicle_light/greyvan/dmg
	icon_state = "greyvan_damaged"

/obj/structure/vehicle_light/marshalls
	name = "полицейский фургон"
	icon_state = "marshalls"

/obj/structure/vehicle_light/maintenance
	name = "брошенный фургон дорожной службы"
	icon_state = "maintenanceSUV"

/obj/structure/vehicle_light/zengarbagetruck
	name = "брошенный мусоровоз"
	icon_state = "zengarbagetruck"

/obj/structure/vehicle_light/miningcrawler
	name = "шахтёрский тягач"
	icon_state = "miningcrawler1"

/obj/structure/vehicle_light/truck_mining
	name = "брошенный шахтёрский грузовик"
	icon_state = "truck_mining"

/obj/structure/vehicle_light/meridian
	icon_state = "MeridianCar_7"

/obj/structure/vehicle_light/meridian/marshalls
	name = "брошенная полицейская машина"
	icon_state = "marshalls2"

/obj/structure/vehicle_light/meridian/var2
	icon_state = "MeridianCar_1"

/obj/structure/vehicle_light/meridian/var3
	icon_state = "MeridianCar_2"

/obj/structure/vehicle_light/meridian/var4
	icon_state = "MeridianCar_5"

/obj/structure/vehicle_light/meridian/shell
	icon_state = "MeridianCar_shell"

/obj/structure/vehicle_light/cargo
	icon = 'modular_bandastation/voyaker_events/icons/cargo.dmi'
	icon_state = "cargo_engine"
	has_hitbox = FALSE

/obj/structure/vehicle_light/cargo/trailer
	icon_state = "cargo_trailer"
	has_hitbox = FALSE
