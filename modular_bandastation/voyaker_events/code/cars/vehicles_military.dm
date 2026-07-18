/obj/structure/vehicle_prop
	name = "vehicle"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/vehicle_prop/hitbox
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/vehicle_prop/master

/obj/structure/vehicle_prop/hitbox/attackby(obj/item/C, mob/user, params)
    if(master)
        return master.attackby(C, user, params)

    return ..()

/obj/structure/vehicle_prop/humvee
	name = "брошенный Humvee"
	pixel_x = -32
	pixel_y = -32
	icon = 'modular_bandastation/voyaker_events/icons/humvee_prop.dmi'
	icon_state = "humvee_base"

/obj/structure/vehicle_prop/humvee/Initialize(mapload)
	. = ..()
	var/obj/structure/vehicle_prop/hitbox/H
	if(dir == NORTH || dir == SOUTH)
		H = new(get_step(src, NORTH))
		H.master = src
		H = new(get_step(src, SOUTH))
		H.master = src
	else if(dir == EAST || dir == WEST)
		H = new(get_step(src, EAST))
		H.master = src
		H = new(get_step(src, WEST))
		H.master = src

/obj/structure/vehicle_prop/military_truck
	name = "военный грузовик"
	icon_state = "military_truck"
	pixel_x = -32
	pixel_y = -32
	icon = 'modular_bandastation/voyaker_events/icons/large_truck.dmi'
	icon_state = "truck"
	var/list/drop_cooldowns = list()

/obj/structure/vehicle_prop/military_truck/proc/place_trucks(mob/living/carbon/human/user, obj/item/C)
	if(!user)
		return
	var/datum/trader_quest/Q = user.trader_quests?[TRADER_ROBINSON]
	if(!istype(Q, /datum/trader_quest/robinson_trucks))
		return
	var/area/A = get_area(src)
	if(!istype(A, /area/new_sydney/dark_forest))
		balloon_alert(user, "здесь нельзя установить маяк")
		return
	if(!istype(C, /obj/item/beacon))
		balloon_alert(user, "нужен маячок")
		return
	var/key = REF(user)
	if(drop_cooldowns[key] && world.time < drop_cooldowns[key])
		balloon_alert(user, "сюда уже положили")
		return
	balloon_alert(user, "закладывает...")
	if(!do_after(user, 5 SECONDS, target = src))
		return
	drop_cooldowns[key] = world.time + 10 MINUTES
	Q.add_progress(user, TRADER_ROBINSON)
	qdel(C)
	balloon_alert(user, "заложено")

/obj/structure/vehicle_prop/military_truck/attackby(obj/item/C, mob/user, params)
	if(!ishuman(user))
		return
	if(!istype(C, /obj/item/beacon))
		return
	place_trucks(user, C)
	return

/obj/structure/vehicle_prop/military_truck/Initialize(mapload)
	. = ..()
	var/obj/structure/vehicle_prop/hitbox/H
	if(dir == NORTH || dir == SOUTH)
		H = new(get_step(src, NORTH))
		H.master = src
		H = new(get_step(src, SOUTH))
		H.master = src
	else if(dir == EAST || dir == WEST)
		H = new(get_step(src, EAST))
		H.master = src
		H = new(get_step(src, WEST))
		H.master = src

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

/obj/structure/vehicle_prop/military_truck/wreck/attackby(obj/item/C, mob/user, params)
	if(!ishuman(user))
		return
	if(!istype(C, /obj/item/beacon))
		return
	place_trucks(user, C)
	return

/obj/structure/vehicle_prop/military_truck/enclosed
	name = "тентованный военный грузовик"
	icon_state = "truck_enclosed"

/obj/structure/vehicle_prop/military_truck/enclosed/attackby(obj/item/C, mob/user, params)
	if(!ishuman(user))
		return
	if(!istype(C, /obj/item/beacon))
		return
	place_trucks(user, C)
	return

/obj/structure/vehicle_prop/military_truck/enclosed/wreck
	name = "уничтоженный тентованный военный грузовик"
	icon_state = "truck_enclosed_wrecked"

/obj/structure/vehicle_prop/military_truck/enclosed/wreck/attackby(obj/item/C, mob/user, params)
	if(!ishuman(user))
		return
	if(!istype(C, /obj/item/beacon))
		return
	place_trucks(user, C)
	return
