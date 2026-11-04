/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force
	name = "SecForce pistol magazine"
	desc = "Общий магазин МК-58 «Регламент» и ПС-3 «Гюрза» на 12 патронов калибра 9x25 мм НТ."
	icon = 'modular_bandastation/weapon/icons/sec_force/magazines/objects.dmi'
	icon_state = "nt9x25"
	base_icon_state = "nt9x25"
	inhand_icon_state = "nt9x25"
	lefthand_file = 'modular_bandastation/weapon/icons/sec_force/magazines/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/sec_force/magazines/righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	max_ammo = 12
	multiple_sprites = AMMO_BOX_PER_BULLET
	// All ammunition variants share the same numerical icon states.
	multiple_sprite_use_base = TRUE
	ammo_band_icon = "+nt9x25_band_red"
	// The source stripes are already colored; white preserves their palette.
	ammo_band_color = COLOR_WHITE

/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber
	name = "SecForce rubber pistol magazine"
	desc = parent_type::desc + " Синяя маркировка обозначает штатное использование травматических патронов с резиновой пулей."
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber
	ammo_band_icon = "+nt9x25_band_blue"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5)

/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/ap
	name = "pistol magazine (9x25mm NT AP)"
	desc = parent_type::desc + " Предназначен для бронебойных патронов, эффективных против брони."
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 1.25,
	)

/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/hp
	name = "pistol magazine (9x25mm NT HP)"
	desc = parent_type::desc + " Предназначен для экспансивных патронов, эффективных против небронированных целей."
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 1.25,
	)
