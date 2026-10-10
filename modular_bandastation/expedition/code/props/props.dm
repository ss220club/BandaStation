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
