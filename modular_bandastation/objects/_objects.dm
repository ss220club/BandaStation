/datum/modpack/objects
	name = "Объекты"
	desc = "В основном включает в себя портированные объекты и всякие мелочи, которым не нужен отдельный модпак."
	author = "dj-34, Chorden, Aylong"

/datum/modpack/objects/initialize()
	. = ..()
	for(var/datum/stack_recipe/recipe in GLOB.wood_recipes)
		if(recipe.result_type == /obj/item/stack/tile/wood)
			GLOB.wood_recipes -= recipe
			qdel(recipe)
			break

	GLOB.autodrobe_supernatural_items += list(
		/obj/item/clothing/neck/crow = 1,
	)

	GLOB.autodrobe_fancy_items += list(
		/obj/item/clothing/under/carnival/formal = 2,
		/obj/item/clothing/under/carnival/jacket = 2,
		/obj/item/clothing/under/carnival/dress_fancy = 2,
		/obj/item/clothing/under/carnival/dress_corset = 2,
		/obj/item/clothing/mask/carnival/feather = 2,
		/obj/item/clothing/mask/carnival/half = 2,
		/obj/item/clothing/mask/carnival/triangles = 2,
		/obj/item/clothing/mask/carnival/colored = 2,
	)

	GLOB.autodrobe_other_items += list(
		/obj/item/clothing/suit/ny_sweater = 5,
		/obj/item/clothing/suit/garland = 5,
		/obj/item/clothing/neck/cloak/ny_cloak = 5,
		/obj/item/clothing/neck/garland = 5,
	)

	GLOB.all_autodrobe_items |= (
		GLOB.autodrobe_fancy_items \
		+ GLOB.autodrobe_other_items
	)

	GLOB.wood_recipes += list(
		null,
		new /datum/stack_recipe_list("Деревянный пол", list(
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/oak, 1, 4, 20),
			new /datum/stack_recipe("Тёмный", /obj/item/stack/tile/wood/darkwood, 1, 4, 20),
			new /datum/stack_recipe("Светлый", /obj/item/stack/tile/wood/lightwood, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый", /obj/item/stack/tile/wood/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый", /obj/item/stack/tile/wood/ebonite, 2, 4, 20),
			new /datum/stack_recipe("Умниниевый", /obj/item/stack/tile/wood/pink_ivory, 2, 4, 20),
			new /datum/stack_recipe("Бакаутовый", /obj/item/stack/tile/wood/guaiacum, 2, 4, 20),
			)),
		null)

	GLOB.wood_recipes += list(
		null,
		new /datum/stack_recipe_list("Деревянные полки", list(
			new /datum/stack_recipe("Деревянная полка 1", /obj/structure/shelf/wood/first, 2, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
			new /datum/stack_recipe("Деревянная полка 2", /obj/structure/shelf/wood/second, 2, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
			new /datum/stack_recipe("Деревянная полка 3", /obj/structure/shelf/wood/third, 2, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
			)),
		null)

	GLOB.metal_recipes += list(
		null,
		new /datum/stack_recipe_list("Железные полки", list(
			new /datum/stack_recipe("Железная полка 1", /obj/structure/shelf/iron/first, 2, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
			new /datum/stack_recipe("Железная полка 2", /obj/structure/shelf/iron/second, 2, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
			new /datum/stack_recipe("Железная полка 3", /obj/structure/shelf/iron/third, 2, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
			)),
		null)

	GLOB.arcade_prize_pool += list(
		/obj/item/storage/box/id_stickers = 2
	)
