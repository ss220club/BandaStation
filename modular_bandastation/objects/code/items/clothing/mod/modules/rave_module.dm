/datum/design/module/mod_rave
	name = "Rave Module"
	id = "mod_rave"
	materials = list(
		/datum/material/iron =SMALL_MATERIAL_AMOUNT*5,
		/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_MODSUIT_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SERVICE
	)
	build_path = /obj/item/mod/module/visor/rave
