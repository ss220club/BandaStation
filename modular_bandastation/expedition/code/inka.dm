// Planet Inka
/atom/movable/screen/inka
	name = "Инка"
	desc = "Небольшая болотистая планета."
	icon = 'modular_bandastation/expedition/icons/planet.dmi'
	icon_state = "inka"
	plane = RENDER_PLANE_TRANSPARENT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER"
	var/appearance_time = 2 SECONDS
	var/current_scale = 1.0
	var/current_tx = 0
	var/current_ty = 0
	var/half_size = 512

/atom/movable/screen/inka/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	spawn()
		planet_animation()

/atom/movable/screen/inka/proc/planet_animation()
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

/atom/movable/screen/inka/proc/landing_animation(duration = 10 SECONDS, target_scale = 2.5, extra_left = 400, vertical_offset = 0)
	var/matrix/final = matrix()
	final.Translate(-half_size, -half_size)
	final.Scale(target_scale, target_scale)
	final.Translate(half_size, half_size)
	final.Translate(-extra_left, vertical_offset)

	animate(src, transform = final, time = duration, easing = CUBIC_EASING | EASE_IN, flags = ANIMATION_END_NOW)

	current_scale = target_scale
	current_tx = -extra_left
	current_ty = vertical_offset

// APC Nanotrasen. Мозги сильно не ебите
/obj/vehicle/sealed/car/apc
	name = "БТР Нанотрейзен"
	desc = "Стандартный многофункциональный бронетранспортер Корпорации Нанотрейзен."
	icon = 'modular_bandastation/expedition/icons/apc.dmi'
	engine_sound = 'modular_bandastation/expedition/sound/apc.ogg'
	icon_state = "apc"
	layer = ABOVE_MOB_LAYER
	max_occupants = 4
	pixel_y = -48
	pixel_x = -48
	enter_delay = 1.5 SECONDS
	escape_time = 1.5 SECONDS
	vehicle_move_delay = 5


/turf/open/water/alternative/muddy/deep
	name = "болотина"
	icon = 'modular_bandastation/expedition/icons/water.dmi'
	desc = "Болотистая вода. Если быть неосторожным - утянет."
	icon_state = "water_swamp"
	base_icon_state = "water_swamp"
	baseturfs = /turf/open/water/alternative/muddy/deep
	is_swimming_tile = TRUE
	stamina_entry_cost = 50
	ticking_stamina_cost = 20
	ticking_oxy_damage = 4
	exhaust_swimmer_prob = 100

/area/awaymission/inka
	name = "Инка"
	icon_state = "awaycontent1"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/inka/outside
	name = "Лес"
	icon_state = "awaycontent17"

/area/awaymission/inka/outside/port
	name = "Порт"
	icon_state = "awaycontent3"

/area/awaymission/inka/inside
	name = "Деревня"
	icon_state = "awaycontent4"
	static_lighting = TRUE
	base_lighting_alpha = 0

/area/awaymission/inka/inside/cave
	name = "Пещера"
	icon_state = "awaycontent5"

/area/awaymission/inka/inside/base
	name = "Аванпост \"Воздаяние\""
	icon_state = "awaycontent6"

/area/awaymission/inka/inside/shields
	name = "Аванпост \"Воздаяние\""
	icon_state = "awaycontent8"

//Snowless Pine
/obj/structure/flora/tree/snowless_pine
	name = "pine tree"
	desc = "A coniferous pine tree."
	icon = 'modular_bandastation/expedition/icons/pinetrees.dmi'
	icon_state = "snowlesspine_1"
	var/list/icon_states = list("snowlesspine_1", "snowlesspine_2", "snowlesspine_3", "snowlesspine_4")

/obj/structure/flora/tree/snowless_pine/get_seethrough_map()
	return SEE_THROUGH_MAP_DEFAULT_TWO_TALL

/obj/structure/flora/tree/snowless_pine/style_2
	icon_state = "snowlesspine_2"

/obj/structure/flora/tree/snowless_pine/style_3
	icon_state = "snowlesspine_3"

/obj/structure/flora/tree/snowless_pine/style_4
	icon_state = "snowlesspine_4"

/obj/structure/flora/tree/snowless_pine/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowlesspine_[rand(1,4)]"
	update_appearance()

/obj/structure/flora/tree/stump/snowless_pine
	icon = 'modular_bandastation/expedition/icons/pinetrees.dmi'
	icon_state = "snowlesspine_tree_stump"

//Large Pine
/obj/structure/flora/tree/large_pine
	name = "large pine tree"
	desc = "A coniferous large pine tree."
	icon = 'modular_bandastation/expedition/icons/tall_trees.dmi'
	icon_state = "large_pine_1"
	var/list/icon_states = list("large_pine_1", "large_pine_2", "large_pine_3")

/obj/structure/flora/tree/large_pine/get_seethrough_map()
	return SEE_THROUGH_MAP_DEFAULT_TWO_TALL

/obj/structure/flora/tree/large_pine/style_2
	icon_state = "large_pine_2"

/obj/structure/flora/tree/large_pine/style_3
	icon_state = "large_pine_3"

/obj/structure/flora/tree/large_pine/style_random/Initialize(mapload)
	. = ..()
	icon_state = "large_pine_[rand(1,3)]"
	update_appearance()

//Large Tree
/obj/structure/flora/tree/large_tree
	name = "large dead tree"
	desc = "A large dead tree."
	icon = 'modular_bandastation/expedition/icons/tall_trees.dmi'
	icon_state = "large_tree_1"
	var/list/icon_states = list("large_tree_1", "large_tree_2", "large_tree_3")

/obj/structure/flora/tree/large_tree/get_seethrough_map()
	return SEE_THROUGH_MAP_DEFAULT_THREE_TALL

/obj/structure/flora/tree/large_tree/style_2
	icon_state = "large_tree_2"

/obj/structure/flora/tree/large_tree/style_3
	icon_state = "large_tree_3"

/obj/structure/flora/tree/large_tree/style_random/Initialize(mapload)
	. = ..()
	icon_state = "large_tree_[rand(1,3)]"
	update_appearance()

/obj/structure/flora/tree/stump/large_tree
	icon = 'modular_bandastation/expedition/icons/tall_trees.dmi'
	icon_state = "large_tree_stump"

//Grass Sticks
/obj/structure/flora/grass_sticks
	name = "stick"
	desc = "Watch your step."
	icon = 'modular_bandastation/expedition/icons/grass-sticks.dmi'
	icon_state = "stick_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/grass_sticks/style_2
	icon_state = "stick_2"

/obj/structure/flora/grass_sticks/style_3
	icon_state = "stick_3"

/obj/structure/flora/grass_sticks/style_4
	icon_state = "stick_4"

/obj/structure/flora/grass_sticks/style_random/Initialize(mapload)
	. = ..()
	icon_state = "stick_[rand(1, 4)]"
	update_appearance()

//Dry Grass
/obj/structure/flora/dry_grass
	name = "dry grass"
	desc = "Dead, dry grass."
	icon = 'modular_bandastation/expedition/icons/grass-sticks.dmi'
	icon_state = "dry_grass_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/dry_grass/style_2
	icon_state = "dry_grass_2"

/obj/structure/flora/dry_grass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "dry_grass_[rand(1, 2)]"
	update_appearance()

//Tall Grass
/obj/structure/flora/tall_grass
	name = "tall grass"
	desc = "Thick clumps of grass."
	icon = 'modular_bandastation/expedition/icons/grass-sticks.dmi'
	icon_state = "tall_grass_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/tall_grass/style_2
	icon_state = "tall_grass_2"

/obj/structure/flora/tall_grass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tall_grass_[rand(1, 2)]"
	update_appearance()

// Dry Log
/obj/structure/flora/dry_log
	name = "dry log"
	icon_state = "dry_log"
	desc = "A dry log. It's almost rotten."
	icon = 'modular_bandastation/expedition/icons/grass-sticks.dmi'
	density = TRUE
	resistance_flags = FLAMMABLE
	harvest_amount_low = 2
	harvest_amount_high = 4
	harvest_message_med = "You finish chopping the log."
	harvest_verb = "chop"
	flora_flags = FLORA_WOODEN
	can_uproot = FALSE
	delete_on_harvest = TRUE

/obj/structure/flora/dry_log/get_potential_products()
	return list(/obj/item/grown/log/tree = 1)

/obj/effect/particle_effect/fluid/smoke/quick/swamp
	color = COLOR_ASSEMBLY_GREEN

/obj/structure/railing/wooden_fencing
	name = "wooden fence"
	desc = "A basic wooden fence meant to prevent people like you either in or out of somewhere."
	icon = 'modular_bandastation/expedition/icons/wooden_fence.dmi'
	icon_state = "fence"
	resistance_flags = FLAMMABLE
	flags_1 = ON_BORDER_1
	/// If we randomize our icon on spawning
	var/random_icons = TRUE

/obj/structure/railing/wooden_fencing/Initialize(mapload)
	. = ..()
	if(!random_icons)
		return
	icon_state = pick(
		"fence",
		"fence_2",
		"fence_3",
	)
	update_appearance()

/obj/structure/railing/wooden_fencing/atom_deconstruct(disassembled)
	var/obj/plank = new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)
	transfer_fingerprints_to(plank)

// formerly NO_DECONSTRUCTION
/obj/structure/railing/wooden_fencing/wirecutter_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/railing/wooden_fencing/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	to_chat(user, span_warning("You pry apart the railing."))
	tool.play_tool_sound(src, 100)
	deconstruct()
	return TRUE

// Fence gates for the above mentioned fences

/obj/structure/railing/wooden_fencing/gate
	name = "wooden fence gate"
	desc = "A basic wooden gate meant to prevent animals like you escaping."
	icon_state = "gate"
	random_icons = FALSE
	/// Has the gate been opened or not?
	var/opened = FALSE

/obj/structure/railing/wooden_fencing/gate/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	return open_or_close(user)

/// Proc that checks if the gate is open or not, then closes/opens the gate repsectively
/obj/structure/railing/wooden_fencing/gate/proc/open_or_close(mob/user)
	if(!user.can_interact_with(src))
		balloon_alert(user, "can't interact")
		return
	opened = !opened
	set_density(!opened)
	icon_state = "[opened ? "gate_open" : "gate"]"
	playsound(src, (opened ? 'sound/machines/closet/wooden_closet_open.ogg' : 'sound/machines/closet/wooden_closet_close.ogg'), 100, TRUE)
	update_appearance()

/obj/structure/railing/wooden_fencing/gate/update_icon()
	. = ..()
	if(!opened)
		return
