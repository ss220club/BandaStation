// MARK: Basic shelfs

/obj/structure/shelves
	name = "полки"
	desc = "Для всякой всячины."
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "wooden_shelf_1"
	density = TRUE
	anchored = TRUE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	max_integrity = 100

/obj/structure/shelves/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .

	if(tool.item_flags & ABSTRACT)
		return ITEM_INTERACT_BLOCKING

	return shelf_place_act(user, tool, modifiers)

/obj/structure/shelves/proc/shelf_place_act(mob/living/user, obj/item/tool, list/modifiers)
	var/x_offset = 0
	var/y_offset = 0

	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		x_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X * 0.5), ICON_SIZE_X * 0.5)
		y_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(ICON_SIZE_Y * 0.5), ICON_SIZE_Y * 0.5)

	if(!user.transfer_item_to_turf(tool, get_turf(src), x_offset, y_offset, silent = FALSE))
		return ITEM_INTERACT_BLOCKING

	AfterPutItemOnShelf(tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/shelves/proc/AfterPutItemOnShelf(obj/item/thing, mob/living/user)
	return

/obj/structure/shelves/wrench_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	drop_materials()
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/shelves/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	drop_materials()
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/shelves/atom_deconstruct(disassembled = TRUE)
	drop_materials()

/obj/structure/shelves/proc/drop_materials()
	new /obj/item/stack/sheet/mineral/wood(get_turf(src), 3)

// MARK: Variations

// Wooden

/obj/structure/shelves/style2
	icon_state = "wooden_shelf_2"

/obj/structure/shelves/style3
	icon_state = "wooden_shelf_3"

// Metal

/obj/structure/shelves/metal
	icon_state = "metal_shelf_1"

/obj/structure/shelves/metal/drop_materials()
	new /obj/item/stack/sheet/iron(get_turf(src), 3)

/obj/structure/shelves/metal/style2
	icon_state = "metal_shelf_2"

/obj/structure/shelves/metal/style3
	icon_state = "metal_shelf_3"
