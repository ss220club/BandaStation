/datum/modpack/objects
	name = "Объекты"
	desc = "В основном включает в себя портированные объекты и всякие мелочи, которым не нужен отдельный модпак."
	author = "dj-34, Chorden, npukoJl"

/datum/modpack/objects/initialize()
	. = ..()
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
