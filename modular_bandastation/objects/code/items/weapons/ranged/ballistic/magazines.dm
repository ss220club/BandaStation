/obj/item/ammo_box/magazine/c35sol_pistol
	name = "Sol pistol magazine"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает двенадцать патронов."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "pistol_35_standard"
	base_icon_state = "pistol_35_standard"
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /obj/item/ammo_casing/c35sol
	caliber = CALIBER_SOL35SHORT
	max_ammo = 12
	ammo_band_icon = "+35_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/stendo
	name = "Sol extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает шестнадцать патронов."
	icon_state = "pistol_35_stended"
	base_icon_state = "pistol_35_stended"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 16

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/rubber
	name = "Sol rubber pistol magazine"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает двенадцать резиновых патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/rubber
	name = "Sol rubber extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает шестнадцать резиновых патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/ap
	name = "Sol AP pistol magazine"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает двенадцать бронебойных патронов."
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ap
	name = "Sol AP extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает шестнадцать бронебойных патронов."
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/ripper
	name = "Sol HP pistol magazine"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает двенадцать экспансивных патронов."
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ripper
	name = "Sol HP extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещающий шестнадцать экспансивных патронов."
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper
