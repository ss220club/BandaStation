/obj/structure/railing/wooden_fencing
	name = "wooden fence"
	desc = "A basic wooden fence meant to prevent people like you either in or out of somewhere."
	icon = 'modular_bandastation/expedition/icons/wooden_fence.dmi'
	icon_state = "fence"
	resistance_flags = FLAMMABLE
	flags_1 = ON_BORDER_1
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



/obj/structure/neon_sign
	name = "neon sign"
	icon = 'modular_bandastation/expedition/icons/urban64x64_signs.dmi'
	icon_state = "open"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	var/lit_icon_state
	var/enabled = TRUE
	light_range = 2
	light_power = 0.8
	light_color = "#FFD080"

/obj/structure/neon_sign/Initialize(mapload)
	. = ..()
	update_sign()

/obj/structure/neon_sign/proc/update_sign()
	if(enabled)
		icon_state = lit_icon_state
		set_light_on(TRUE)
	else
		icon_state = base_icon_state
		set_light_on(FALSE)

/obj/structure/neon_sign/attack_hand(mob/user)
	enabled = !enabled
	update_sign()
	to_chat(user, span_notice("Вы переключаете вывеску."))

/obj/structure/neon_sign/jacks
	name = "Jack's Supplies"
	icon_state = "jacksopen_on"
	base_icon_state = "jacksopen"
	lit_icon_state = "jacksopen_on"
	light_color = "#66CCFF"

/obj/structure/neon_sign/nightgold
	name = "Night Gold Casino"
	icon_state = "nightgoldcasinoopen_on"
	lit_icon_state = "nightgoldcasinoopen_on"
	base_icon_state = "nightgoldcasinoopen"
	light_color = "#FFCC55"

/obj/structure/neon_sign/open
	name = "Open"
	icon_state = "open_on"
	base_icon_state = "open"
	lit_icon_state = "open_on"
	light_color = "#FFCC55"

/obj/structure/neon_sign/open2
	name = "Open"
	icon_state = "open_on2"
	base_icon_state = "open2"
	lit_icon_state = "open_on2"
	light_color = "#FFCC55"

/obj/structure/neon_sign/pizza
	name = "Pizza Neon"
	icon_state = "pizzaneon_on"
	base_icon_state = "pizzaneon"
	lit_icon_state = "pizzaneon_on"
	light_color = "#FF8844"

/obj/structure/neon_sign/nt_mart
	name = "NT Mart"
	icon_state = "weymartsign2"
	base_icon_state = "weymartsign2_off"
	lit_icon_state = "weymartsign2"
	light_color = "#FF8844"

/obj/structure/neon_sign/mechanic
	name = "Mechanic"
	icon_state = "mechanicopen_on2"
	base_icon_state = "mechanicopen2"
	lit_icon_state = "mechanicopen_on2"
	light_color = "#44ffff"

/obj/structure/neon_sign/cuppajoes
	name = "Cuppa Joes"
	icon_state = "cuppajoes"
	base_icon_state = "cuppajoesoff"
	lit_icon_state = "cuppajoes"
	light_color = "#922320"

/obj/structure/neon_sign/billboard
	name = "Billboard"
	icon = 'modular_bandastation/expedition/icons/32x64_urbanbillboards.dmi'
	icon_state = "billboard_bigger"
	base_icon_state = "billboard_bigger"
	lit_icon_state = "billboard_bigger"
	light_color = "#44ffff"

/obj/structure/neon_sign/billboard/north
	dir = NORTH

/obj/structure/neon_sign/billboard/east
	dir = EAST

/obj/structure/neon_sign/billboard/west
	dir = WEST

/obj/structure/neon_sign/billboard/south
	dir = SOUTH

/obj/structure/neon_sign/billboard1
	name = "Billboard"
	icon = 'modular_bandastation/expedition/icons/32x64_urbanbillboards.dmi'
	icon_state = "billboard1"
	base_icon_state = "billboard1"
	lit_icon_state = "billboard1"
	light_color = "#44ffff"

/obj/structure/neon_sign/billboard1/north
	dir = NORTH
	pixel_y = 35

/obj/structure/neon_sign/billboard1/east
	dir = EAST

/obj/structure/neon_sign/billboard1/west
	dir = WEST

/obj/structure/neon_sign/billboard1/south
	dir = SOUTH
	pixel_y = -28

/obj/structure/neon_sign/billboard2
	name = "Billboard"
	icon = 'modular_bandastation/expedition/icons/32x64_urbanbillboards.dmi'
	icon_state = "billboard2"
	base_icon_state = "billboard2"
	lit_icon_state = "billboard2"
	light_color = "#44ffff"

/obj/structure/neon_sign/billboard2/north
	dir = NORTH
	pixel_y = 35

/obj/structure/neon_sign/billboard2/east
	dir = EAST

/obj/structure/neon_sign/billboard2/west
	dir = WEST

/obj/structure/neon_sign/billboard2/south
	dir = SOUTH
	pixel_y = -28

/obj/structure/neon_sign/billboard3
	name = "Billboard"
	icon = 'modular_bandastation/expedition/icons/32x64_urbanbillboards.dmi'
	icon_state = "billboard3"
	base_icon_state = "billboard3"
	lit_icon_state = "billboard3"
	light_color = "#44ffff"

/obj/structure/neon_sign/billboard3/north
	dir = NORTH
	pixel_y = 35

/obj/structure/neon_sign/billboard3/east
	dir = EAST

/obj/structure/neon_sign/billboard3/west
	dir = WEST

/obj/structure/neon_sign/billboard3/south
	dir = SOUTH
	pixel_y = -28

/obj/structure/neon_sign/billboard4
	name = "Billboard"
	icon = 'modular_bandastation/expedition/icons/32x64_urbanbillboards.dmi'
	icon_state = "billboard4"
	base_icon_state = "billboard4"
	lit_icon_state = "billboard4"
	light_color = "#44ffff"

/obj/structure/neon_sign/billboard4/north
	dir = NORTH
	pixel_y = 35

/obj/structure/neon_sign/billboard4/east
	dir = EAST

/obj/structure/neon_sign/billboard4/west
	dir = WEST

/obj/structure/neon_sign/billboard4/south
	dir = SOUTH
	pixel_y = -28

/obj/structure/neon_sign/billboard5
	name = "Billboard"
	icon = 'modular_bandastation/expedition/icons/32x64_urbanbillboards.dmi'
	icon_state = "billboard5"
	base_icon_state = "billboard5"
	lit_icon_state = "billboard5"
	light_color = "#44ffff"

/obj/structure/neon_sign/billboard5/north
	dir = NORTH
	pixel_y = 35

/obj/structure/neon_sign/billboard5/east
	dir = EAST

/obj/structure/neon_sign/billboard5/west
	dir = WEST

/obj/structure/neon_sign/billboard5/south
	dir = SOUTH
	pixel_y = -28

/obj/structure/neon_sign/billboard6
	name = "Digital Vacation"
	icon = 'modular_bandastation/expedition/icons/urban64x64_signs.dmi'
	icon_state = "billboard6"
	base_icon_state = "billboard6"
	lit_icon_state = "billboard6"
	light_color = "#44ffff"

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

/obj/structure/railing/wooden_fencing
	name = "wooden fence"
	desc = "A basic wooden fence meant to prevent people like you either in or out of somewhere."
	icon = 'modular_bandastation/voyaker_events/icons/wooden_fence.dmi'
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
