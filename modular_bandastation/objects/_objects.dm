/datum/modpack/objects
	name = "Объекты"
	desc = "В основном включает в себя портированные объекты и всякие мелочи, которым не нужен отдельный модпак."
	author = "dj-34, Chorden, Aylong, npukoJl"

/datum/modpack/objects/initialize()
	. = ..()
	for(var/datum/stack_recipe/recipe in GLOB.wood_recipes)
		if(recipe.result_type == /obj/item/stack/tile/wood)
			GLOB.wood_recipes -= recipe
			qdel(recipe)
			break

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
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый", /obj/item/stack/tile/wood/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый", /obj/item/stack/tile/wood/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый", /obj/item/stack/tile/wood/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый", /obj/item/stack/tile/wood/guaiacum, 5, 4, 20),
			)),
		new /datum/stack_recipe_list("Деревянный пол (Цельный)", list(
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood/large, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/large/oak, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/large/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/large/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый ", /obj/item/stack/tile/wood/large/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый ", /obj/item/stack/tile/wood/large/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый ", /obj/item/stack/tile/wood/large/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый ", /obj/item/stack/tile/wood/large/guaiacum, 5, 4, 20),
			)),
		new /datum/stack_recipe_list("Паркет", list(
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood/parquet, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/parquet/oak, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/parquet/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/parquet/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый", /obj/item/stack/tile/wood/parquet/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый", /obj/item/stack/tile/wood/parquet/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый", /obj/item/stack/tile/wood/parquet/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый", /obj/item/stack/tile/wood/parquet/guaiacum, 5, 4, 20),
			)),
		new /datum/stack_recipe_list("Паркет (Классический)", list(
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood/tile, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/tile/oak, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/tile/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/tile/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый", /obj/item/stack/tile/wood/tile/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый", /obj/item/stack/tile/wood/tile/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый", /obj/item/stack/tile/wood/tile/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый", /obj/item/stack/tile/wood/tile/guaiacum, 5, 4, 20),
			)),
		null)

	GLOB.arcade_prize_pool += list(
		/obj/item/storage/box/id_stickers = 2
	)
