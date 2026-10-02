/datum/crafting_recipe/cargo_shelf_parts
	name = "Crate Shelf Parts"
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 2,
	)
	result = /obj/item/cargo_shelf_parts
	category = CAT_FURNITURE

/datum/crafting_recipe/cargo_shelf
	name = "Crate Shelf"
	reqs = list(
		/obj/item/cargo_shelf_parts = 1,
	)
	result = /obj/structure/cargo_shelf
	tool_behaviors = list(TOOL_SCREWDRIVER)
	category = CAT_FURNITURE
	time = 5 SECONDS
