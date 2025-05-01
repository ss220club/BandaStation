// Fake small
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/small, 0)

// Fake tube
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/spot, 0)

/obj/structure/light_fake
	name = "light fixture"
	desc = "A lighting fixture."
	icon = 'modular_bandastation/objects/icons/obj/structure/light.dmi'
	icon_state = "tube"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF | ACID_PROOF | UNACIDABLE
	light_color = "#FFFFFF"
	light_power = 1
	light_range = 8

/obj/structure/light_fake/small
	name = "light fixture"
	desc = "A small lighting fixture."
	icon_state = "bulb"
	light_color = "#a0a080"
	light_range = 4

/obj/structure/light_fake/spot
	name = "spotlight"
	light_range = 12
	light_power = 4

/obj/structure/light_fake/floor
	light_range = 12
	light_power = 4
	light_angle = 360
	icon_state = "floor"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE

/obj/structure/light_fake/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glass/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/tools/welder.ogg', 100, TRUE)
