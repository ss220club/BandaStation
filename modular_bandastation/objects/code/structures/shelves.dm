/obj/structure/shelf
	abstract_type = /obj/structure/shelf
	name = "shelf"
	desc = "A shelving unit with several shelves for placing items."
	icon = 'modular_bandastation/objects/icons/obj/structures/shelves.dmi'
	icon_state = "metal_shelf_2"
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW
	layer = TABLE_LAYER
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY
	max_integrity = 20
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)

	/// Y coordinates of shelf surfaces, in pixels from the bottom of the turf.
	/// The icon is expected to be 32x32 and to use the same coordinate system.
	var/list/shelf_levels = list(4, 14, 24)

/obj/structure/shelf/wood
	abstract_type = /obj/structure/shelf/wood
	name = "wooden shelf"
	desc = "A wooden shelving unit with several shelves for placing items."
	resistance_flags = FLAMMABLE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/shelf/wood/first
	icon_state = "wooden_shelf_1"
	shelf_levels = list(6, 20)

/obj/structure/shelf/wood/second
	icon_state = "wooden_shelf_2"
	shelf_levels = list(4, 14, 24)
/obj/structure/shelf/wood/third
	icon_state = "wooden_shelf_3"
	shelf_levels = list(4, 12, 20)

/obj/structure/shelf/iron
	abstract_type = /obj/structure/shelf/iron
	name = "iron shelf"
	desc = "An iron shelving unit with several shelves for placing items."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/shelf/iron/first
	icon_state = "metal_shelf_1"
	shelf_levels = list(6, 20)

/obj/structure/shelf/iron/second
	icon_state = "metal_shelf_2"
	shelf_levels = list(4, 14, 24)

/obj/structure/shelf/iron/third
	icon_state = "metal_shelf_3"
	shelf_levels = list(4, 12, 20)

/obj/structure/shelf/Initialize(mapload)
	. = ..()
	register_context()
	ADD_TRAIT(src, TRAIT_COMBAT_MODE_SKIP_INTERACTION, INNATE_TRAIT)

/obj/structure/shelf/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	if(isnull(held_item) || (held_item.item_flags & ABSTRACT) || user.combat_mode)
		return . || NONE

	context[SCREENTIP_CONTEXT_LMB] = "Установить"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/shelf/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .
	if((tool.item_flags & ABSTRACT) || user.combat_mode)
		return NONE

	var/click_x = LAZYACCESS(modifiers, ICON_X)
	var/click_y = LAZYACCESS(modifiers, ICON_Y)
	if(isnull(click_x))
		click_x = ICON_SIZE_X * 0.5
	else
		click_x = text2num(click_x)
	if(isnull(click_y))
		click_y = ICON_SIZE_Y * 0.5
	else
		click_y = text2num(click_y)

	click_x = clamp(click_x, 0, ICON_SIZE_X)
	click_y = clamp(click_y, 0, ICON_SIZE_Y)

	var/selected_level = get_closest_shelf_level(click_y)
	var/lowest_pixel = tool.get_lowest_visible_pixel()
	var/item_pixel_z = tool.pixel_z
	var/x_offset = clamp(click_x - (ICON_SIZE_X * 0.5), -(ICON_SIZE_X * 0.5), ICON_SIZE_X * 0.5)

	if(!user.transfer_item_to_turf(tool, get_turf(src), x_offset, 0, silent = FALSE))
		return ITEM_INTERACT_BLOCKING

	// transfer_item_to_turf() resets pixel_y to the item's base offset. Replace it
	// with the offset that puts the lowest visible sprite pixel on the shelf.
	tool.pixel_y = selected_level - lowest_pixel - item_pixel_z
	return ITEM_INTERACT_SUCCESS

/// Returns the shelf surface closest to the vertical click coordinate.
/obj/structure/shelf/proc/get_closest_shelf_level(click_y)
	if(!length(shelf_levels))
		return 0

	var/selected_level = shelf_levels[1]
	var/minimum_distance = abs(click_y - selected_level)

	for(var/level in shelf_levels)
		var/distance = abs(click_y - level)
		if(distance < minimum_distance)
			selected_level = level
			minimum_distance = distance

	return selected_level
