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

/datum/design/c9x25mm/bs
	name = "pistol magazine (9x25mm) (Bluespace)"
	desc = "Designed to quickly reload GP-9 pistols. Bluespace bullets are faster than normal, but strikes with less damage."
	id = "c9x25mm_bs"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT * 2
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol/bs
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/breaching_slug
	name = "Breaching Slug (Non-Lethal/Highly Destructive)"
	desc = "Designed for breaching airlocks and windows, quickly and efficiently."
	id = "breaching_slug"
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

/datum/techweb_node/basic_arms/New()
	. = ..()
	design_ids += list(
		"c9x25mm_rubber_sec",
		"breaching_slug",
		"box_c9x25mm_rubber",
		"box_c38_rubber",
		"box_c38",
	)

/datum/techweb_node/riot_supression/New()
	. = ..()
	design_ids += list(
		"c9x25mm_sec",
		"box_c9x25mm",
	)

/datum/techweb_node/exotic_ammo/New()
	. = ..()
	design_ids += list(
		"c9x25mm_hp",
		"c9x25mm_ap",
		"c9x25mm_bs",
	)

/datum/design/box_c9x25mm
	name = "Ammo Box (9x25mm) (Lethal)"
	id = "box_c9x25mm"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20)
	build_path = /obj/item/ammo_box/c9x25mm
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/box_c9x25mm/rubber
	name = "Ammo Box (9x25mm) (Non-Lethal)"
	id = "box_c9x25mm_rubber"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15)
	build_path = /obj/item/ammo_box/c9x25mm/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/box_c38
	name = "Ammo Box (.38) (Lethal)"
	id = "box_c38"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 25)
	build_path = /obj/item/ammo_box/c38
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/box_c38/rubber
	name = "Ammo Box (.38) (Non-Lethal)"
	id = "box_c38_rubber"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20)
	build_path = /obj/item/ammo_box/c38/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9mm_mag
	name = "pistol magazine (9mm) (Lethal)"
	desc = "Designed to quickly reload Makarov pistols."
	id = "c9mm_mag"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20
	)
	build_path = /obj/item/ammo_box/magazine/m9mm
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c10mm_mag
	name = "pistol magazine (10mm) (Lethal)"
	desc = "Designed to quickly reload Ansem pistols."
	id = "c10mm_mag"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20
	)
	build_path = /obj/item/ammo_box/magazine/m10mm
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c10mm
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/c45
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/c9mm
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/box_c46x30mm
	name = "Ammo Box (4.6x30mm) (Lethal)"
	id = "box_c46x30mm"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 30)
	build_path = /obj/item/ammo_box/c46x30
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/rubber_mag
	name = "WT-550 Autorifle Rubber Magazine (4.6x30mm rubber) (Less-lethal)"
	desc = "A 20 round rubber magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_rubber"
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtrubber
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/hp_mag
	name = "WT-550 Autorifle Hollow-point Magazine (4.6x30mm HP) (Very-lethal)"
	desc = "A 20 round hollow-point magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_hp"
	build_path = /obj/item/ammo_box/magazine/wt550m9/wthp
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/techweb_node/syndicate_basic/New()
	. = ..()
	design_ids += list(
		"mag_autorifle_rubber",
		"mag_autorifle_hp",
		"c9mm_mag",
		"c10mm_mag",
		"c9mm",
		"c10mm",
		"c45",
		"box_c46x30mm",
	)
