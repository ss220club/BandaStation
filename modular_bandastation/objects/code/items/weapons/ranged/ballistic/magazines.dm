// MARK:  Wespe aka sol pistol
/obj/item/ammo_box/magazine/c35sol_pistol
	name = "pistol magazine (.35 Sol Short)"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает 12 патронов."
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
	name = "extended pistol magazine (.35 Sol Short)"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 16 патронов."
	icon_state = "pistol_35_stended"
	base_icon_state = "pistol_35_stended"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 16

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/rubber
	name = "pistol magazine (.35 Sol Short rubber)"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает 12 травматических патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/rubber
	name = "extended pistol magazine (.35 Sol Short rubber)"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 16 травматических патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/ap
	name = "pistol magazine (.35 Sol Short AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ap
	name = "extended pistol magazine (.35 Sol Short AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/ripper
	name = "pistol magazine (.35 Sol Short HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ripper
	name = "extended pistol magazine (.35 Sol Short HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/magazine/c35sol_pistol/drum
	name = "drum pistol magazine (.35 Sol Short)"
	desc = "Барабанный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 35 патронов."
	icon_state = "pistol_35_drum"
	base_icon_state = "pistol_35_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 35

/obj/item/ammo_box/magazine/c35sol_pistol/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/drum/rubber
	name = "drum pistol magazine (.35 Sol Short rubber)"
	desc = "Барабанный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 35 травматических патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/drum/ap
	name = "drum pistol magazine (.35 Sol Short AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/drum/ripper
	name = "drum pistol magazine (.35 Sol Short HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

// MARK: AMK(AKM)
/obj/item/ammo_box/magazine/c762x39mm
	name = "rifle magazine (7.62x39mm)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами»."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "amk"
	ammo_band_icon = "+amk_ammo_band"
	ammo_band_color = null
	ammo_type = /obj/item/ammo_casing/a762x39
	caliber = CALIBER_762x39mm
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/c762x39mm/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c762x39mm/ricochet
	name = "rifle magazine (7.62x39mm match)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит патроны с высокой рикошетностью."
	ammo_band_color = COLOR_AMMO_MATCH
	ammo_type = /obj/item/ammo_casing/a762x39/ricochet

/obj/item/ammo_box/magazine/c762x39mm/fire
	name = "rifle magazine (7.62x39mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/a762x39/fire

/obj/item/ammo_box/magazine/c762x39mm/ap
	name = "rifle magazine (7.62x39mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/a762x39/ap

/obj/item/ammo_box/magazine/c762x39mm/emp
	name = "rifle magazine (7.62x39mm EMP)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит ионные патроны, которые хорошо подходят для выведения из строя электроники и разрушения мехов."
	ammo_band_color = "#1ea2ee"
	ammo_type = /obj/item/ammo_casing/a762x39/emp

/obj/item/ammo_box/magazine/c762x39mm/rubber
	name = "rifle magazine (7.62x39mm rubber)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит нелетальные травматические патроны."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/a762x39/rubber

/obj/item/ammo_box/magazine/c762x39mm/civ
	name = "rifle short magazine (7.62x39mm)"
	desc = "Укороченный двухрядный магазин, вмещающий 15 патронов калибра 7.62х39мм."
	icon_state = "amk_civ"
	max_ammo = 15
	ammo_type = /obj/item/ammo_casing/a762x39/civilian

/obj/item/ammo_box/magazine/c762x39mm/civ/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c762x39mm/hunting
	name = "rifle magazine (7.62x39mm hunting)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит патроны для охоты."
	ammo_band_color = "#05880c"
	ammo_type = /obj/item/ammo_casing/a762x39/hunting

// MARK: Fal aka Carwo
/obj/item/ammo_box/magazine/c40sol_rifle
	name = "rifle short magazine (.40 Sol Long)"
	desc = "Укороченный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 15 патронов."
	ammo_band_icon = "+40_ammo_band"
	ammo_band_color = null
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "rifle_short"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /obj/item/ammo_casing/c40sol
	caliber = CALIBER_SOL40LONG
	max_ammo = 10

/obj/item/ammo_box/magazine/c40sol_rifle/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/fragmentation
	name = "rifle short magazine (.40 Sol Long rubber-fragmentation)"
	desc = "Укороченный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 15 осколочно-травматических патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/pierce
	name = "rifle short magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/incendiary
	name = "rifle short magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/standard
	name = "rifle magazine (.40 Sol Long)"
	desc = "Магазин стандартного размера для винтовок ТСФ калибра .40 Sol Long, вмещает 20 патронов."
	icon_state = "rifle_standard"
	w_class = WEIGHT_CLASS_SMALL
	max_ammo = 20

/obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/standard/fragmentation
	name = "rifle magazine (.40 Sol Long rubber-fragmentation)"
	desc = "Магазин стандартного размера для винтовок ТСФ калибра .40 Sol Long, вмещает 20 осколочно-травматических патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/standard/pierce
	name = "rifle magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/standard/incendiary
	name = "rifle magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/long
	name = "rifle long magazine (.40 Sol Long)"
	desc = "Удлиненный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 30 патронов."
	icon_state = "rifle_long"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 30

/obj/item/ammo_box/magazine/c40sol_rifle/long/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/long/fragmentation
	name = "rifle long magazine (.40 Sol Long rubber-fragmentation)"
	desc = "Удлиненный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 30 осколочно-травматических патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/long/pierce
	name = "rifle long magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/long/incendiary
	name = "rifle long magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/drum
	name = "rifle drum magazine (.40 Sol Long)"
	desc = "Барабанный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 60 патронов."
	icon_state = "rifle_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 60

/obj/item/ammo_box/magazine/c40sol_rifle/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/drum/fragmentation
	name = "rifle drum magazine (.40 Sol Long rubber-fragmentation)"
	desc = "Барабанный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 60 осколочно-травматических патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/drum/pierce
	name = "rifle drum magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/drum/incendiary
	name = "rifle drum magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/box
	name = "rifle box magazine (.40 Sol Long)"
	desc = "Коробчатый магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 100 патронов."
	icon_state = "rifle_box"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 100

/obj/item/ammo_box/magazine/c40sol_rifle/box/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/box/fragmentation
	name = "rifle box magazine (.40 Sol Long rubber-fragmentation)"
	desc = "Коробчатый магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 100 осколочно-травматических патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/box/pierce
	name = "rifle box magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/box/incendiary
	name = "rifle box magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

// MARK: NT Glock aka GP-9
/obj/item/ammo_box/magazine/c9x25mm_pistol
	name = "pistol magazine (9x25mm NT)"
	desc = "Магазин стандартного размера для пистолетов НТ калибра 9x25мм, вмещает 12 патронов."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "pistol_9x25_standart"
	base_icon_state = "pistol_9x25_standart"
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /obj/item/ammo_casing/c9x25mm
	caliber = CALIBER_9x25NT
	max_ammo = 12
	ammo_band_icon = "+9x25_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo
	name = "extended pistol magazine (9x25mm NT)"
	desc = "Увеличенный магазин для пистолетов НТ калибра 9x25мм, вмещает 22 патронов."
	icon_state = "pistol_9x25_stendo"
	base_icon_state = "pistol_9x25_stendo"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 22

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber
	name = "pistol magazine (9x25mm NT rubber)"
	desc = "Магазин стандартного размера для пистолетов НТ калибра 9x25мм, вмещает 12 травматических патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber
	name = "extended pistol magazine (9x25mm NT rubber)"
	desc = "Увеличенный магазин для пистолетов НТ калибра 9x25мм, вмещает 22 травматических патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/magazine/c9x25mm_pistol/ap
	name = "pistol magazine (9x25mm NT AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap
	name = "extended pistol magazine (9x25mm NT AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

/obj/item/ammo_box/magazine/c9x25mm_pistol/hp
	name = "pistol magazine (9x25mm NT HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/hp
	name = "extended pistol magazine (9x25mm NT HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp
