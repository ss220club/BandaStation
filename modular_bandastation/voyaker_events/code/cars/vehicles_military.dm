/obj/structure/vehicle_prop
	name = "vehicle"
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/vehicle_prop/hitbox
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/vehicle_prop/humvee
	name = "брошенный Humvee"
	pixel_x = -32
	pixel_y = -32
	icon = 'modular_bandastation/voyaker_events/icons/humvee_prop.dmi'
	icon_state = "humvee_base"

/obj/structure/vehicle_prop/humvee/Initialize(mapload)
	. = ..()

	new /obj/structure/vehicle_prop/hitbox(get_step(src, NORTH))
	new /obj/structure/vehicle_prop/hitbox(get_step(src, SOUTH))
	new /obj/structure/vehicle_prop/hitbox(get_step(src, EAST))
	new /obj/structure/vehicle_prop/hitbox(get_step(src, WEST))

/obj/structure/vehicle_prop/military_truck
	name = "военный грузовик"
	icon_state = "military_truck"
	pixel_x = -32
	pixel_y = -32
	icon = 'modular_bandastation/voyaker_events/icons/large_truck.dmi'
	icon_state = "truck"

/obj/structure/vehicle_prop/military_truck/Initialize(mapload)
	. = ..()

	new /obj/structure/vehicle_prop/hitbox(get_step(src, NORTH))
	new /obj/structure/vehicle_prop/hitbox(get_step(src, SOUTH))
	new /obj/structure/vehicle_prop/hitbox(get_step(src, EAST))
	new /obj/structure/vehicle_prop/hitbox(get_step(src, WEST))

/obj/structure/vehicle_prop/humvee/wreck
	name = "уничтоженный Humvee"
	icon_state = "humvee_base_wreck"

/obj/structure/vehicle_prop/humvee/carrier
	name = "брошенный тентованный Humvee"
	icon_state = "humvee_carrier"

/obj/structure/vehicle_prop/humvee/carrier/wreck
	name = "уничтоженный тентованный Humvee"
	icon_state = "humvee_carrier"

/obj/structure/vehicle_prop/humvee/med
	name = "брошенный медицинский Humvee"
	icon_state = "humvee_med"

/obj/structure/vehicle_prop/humvee/med/wreck
	name = "уничтоженный медицинский Humvee"
	icon_state = "humvee_med_wreck"

/obj/structure/vehicle_prop/military_truck/wreck
	name = "уничтоженный военный грузовик"
	icon_state = "truck_wrecked"

/obj/structure/vehicle_prop/military_truck/enclosed
	name = "тентованный военный грузовик"
	icon_state = "truck_enclosed"

/obj/structure/vehicle_prop/military_truck/enclosed/wreck
	name = "уничтоженный тентованный военный грузовик"
	icon_state = "truck_enclosed_wrecked"
