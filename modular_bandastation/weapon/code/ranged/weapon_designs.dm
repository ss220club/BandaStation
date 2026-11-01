/datum/design/c9x25mm
	name = "pistol magazine (9x25mm) (Lethal)"
	desc = "Предназначен для быстрой перезарядки пистолетов GP-9."
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm/sec
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm_rubber
	name = "pistol magazine (9x25mm Rubber) (Less Lethal)"
	desc = "Предназначен для быстрой перезарядки пистолетов GP-9. Резиновые пули обладают отскоком и являются менее смертоносными."
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT * 10
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm_rubber/sec
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm/hp
	name = "pistol magazine (9x25mm) (Hollow-point)"
	desc = parent_type::desc + " Экспансивные пули отлично подходят для поражения небронированных целей, но бесполезны против бронированных."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT * 2.5
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol/hp
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm/ap
	name = "pistol magazine (9x25mm) (Armor-piercing)"
	desc = parent_type::desc + " Бронебойные пули отлично подходят для поражения бронированных целей, но наносят меньший урон."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT * 2.5
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol/ap
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/breaching_slug
	name = "Breaching Slug (Non-Lethal/Highly Destructive)"
	desc = "Предназначен для быстрого и эффективного пробивания шлюзов и окон."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 5
	)
	build_path = /obj/item/ammo_casing/shotgun/breacher
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c45_mag
	name = "pistol magazine (.45) (Lethal)"
	desc = "Предназначен для быстрой перезарядки пистолетов GP-45."
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10
	)
	transfered_materials = list(
		/obj/item/ammo_box/magazine/c45 = /obj/item/ammo_box/magazine/c45::custom_materials,
	)
	build_path = /obj/item/ammo_box/magazine/c45
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c45_mag/sec
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c45_mag_rubber
	name = "pistol magazine (.45 Rubber) (Less Lethal)"
	desc = "Предназначен для быстрой перезарядки пистолетов GP-45. Резиновые пули обладают отскоком и являются менее смертоносными."
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT * 10
	)
	transfered_materials = list(
		/obj/item/ammo_box/magazine/c45/rubber = /obj/item/ammo_box/magazine/c45/rubber::custom_materials,
	)
	build_path = /obj/item/ammo_box/magazine/c45/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c45_mag_rubber/sec
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/techweb_node/basic_arms/New()
	. = ..()
	unlocked_designs += list(
		/datum/design/c9x25mm_rubber/sec,
		/datum/design/c45_mag_rubber/sec,
		/datum/design/breaching_slug,
	)

/datum/techweb_node/riot_supression/New()
	. = ..()
	unlocked_designs += list(
		/datum/design/c9x25mm/sec,
		/datum/design/c45_mag/sec,
	)

/datum/techweb_node/exotic_ammo/New()
	. = ..()
	unlocked_designs += list(
		/datum/design/c9x25mm/hp,
		/datum/design/c9x25mm/ap,
	)

// Design for printing the Electrostaff construction kit on a Security Protolathe.
/datum/design/electrostaff
	name = "electrostaff"
	desc = "Комплект деталей для сборки электро-посоха."
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/weaponcrafting/gunkit/electrostaff
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_KITS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/techweb_node/electric_weapons/New()
	. = ..()
	unlocked_designs += /datum/design/electrostaff
