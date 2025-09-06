// MARK: 9x25mm magazines
/datum/design/c9x25mm
	name = "pistol magazine (9x25mm) (Lethal)"
	desc = "Designed to quickly reload GP-9 pistols."
	id = "c9x25mm"
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
	id = "c9x25mm_sec"
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
	autolathe_exportable = FALSE

/datum/design/c9x25mm_rubber
	name = "pistol magazine (9x25mm Rubber) (Less Lethal)"
	desc = "Designed to quickly reload GP-9 pistols. Rubber bullets are bouncy and less-than-lethal."
	id = "c9x25mm_rubber"
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
	id = "c9x25mm_rubber_sec"
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
	autolathe_exportable = FALSE

/datum/design/c9x25mm/hp
	name = "pistol magazine (9x25mm) (Hollow-point)"
	desc = "Designed to quickly reload GP-9 pistols. Hollow-point bullets are great against unarmored targets, but useless against armored ones."
	id = "c9x25mm_hp"
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
	desc = "Designed to quickly reload GP-9 pistols. Armor-piercing bullets are great against armored targets, but strikes with less damage."
	id = "c9x25mm_ap"
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

// MARK: Railgun rounds
/datum/design/railgun_round
	name = "railgun sabot-round (30mm NT) (Lethal)"
	desc = "Special anti-armor 30mm round for HEMC railguns. Great for killing anything, but at what cost?"
	id = "railgun_lethal"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 15
	)
	build_path = /obj/item/ammo_casing/railgun
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/railgun_round/taser
	name = "railgun taser-round (30mm NT) (Less-lethal)"
	desc = "Special less-lethal 30mm round for HEMC railguns. Less-lethal variant of 30mm round, great for stopping some very bad criminals."
	id = "railgun_taser"
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 10
	)
	build_path = /obj/item/ammo_casing/railgun/taser
