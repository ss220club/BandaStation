// MARK:  Wespe aka sol pistol
/obj/item/ammo_box/magazine/c35sol_pistol
	name = "pistol magazine (.35 Sol Short)"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает 12 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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

// MARK: CM5 - SMG
/obj/item/ammo_box/magazine/cm5
	name = "SMG magazine (9x25mm NT)"
	desc = "Магазин для пистолетов-пулеметов калибра 9x25мм НТ, вмещающий 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm5_mag"
	base_icon_state = "cm5_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_9x25NT
	max_ammo = 30
	ammo_band_icon = "+cm5_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c9x25mm

/obj/item/ammo_box/magazine/cm5/rubber
	name = "SMG magazine (9x25mm NT rubber)"
	desc = "Магазин для пистолетов-пулеметов калибра 9x25мм НТ, вмещающий 30 травматических патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/magazine/cm5/hp
	name = "SMG magazine (9x25mm NT HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

/obj/item/ammo_box/magazine/cm5/ap
	name = "SMG magazine (9x25mm NT AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

// MARK: CM82 - assault rifle
/obj/item/ammo_box/magazine/c223
	name = "assault rifle magazine (5.56mm)"
	desc = "Магазин для штурмовых винтовок калибра 5.56мм, вмещающий 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm82_mag"
	base_icon_state = "cm82_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_A223
	max_ammo = 30
	ammo_band_icon = "+cm82_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/a223

/obj/item/ammo_box/magazine/c223/rubber
	name = "assault rifle magazine (5.56mm rubber)"
	desc = "Магазин для штурмовых винтовок калибра 5.56мм, вмещающий 30 патронов. Cодержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/a223/rubber

/obj/item/ammo_box/magazine/c223/hp
	name = "assault rifle magazine (5.56mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/a223/hp

/obj/item/ammo_box/magazine/c223/ap
	name = "assault rifle magazine (5.56mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/a223/ap

/obj/item/ammo_box/magazine/c223/phasic
	name = "assault rifle magazine (5.56mm phasic)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/a223/phasic

/obj/item/ammo_box/magazine/c223/incendiary
	name = "assault rifle magazine (5.56mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/a223/incendiary

// MARK: CM15 - auto shotgun
/obj/item/ammo_box/magazine/cm15
	name = "CM15 magazine (12ga buckshot)"
	desc = "Магазин для штурмовых дробовиков CM15 12-го калибра, вмещающий 8 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm15_standart"
	base_icon_state = "cm15_standart"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SHOTGUN
	max_ammo = 8
	ammo_band_icon = "+cm15_standart_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec

/obj/item/ammo_box/magazine/cm15/beanbag
	name = "CM15 magazine (12ga beanbag)"
	ammo_band_color = COLOR_GREEN
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cm15/rubbershot
	name = "CM15 magazine (12ga rubbershot)"
	ammo_band_color = COLOR_PINK
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/cm15/executioner
	name = "CM15 magazine (12ga HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/shotgun/executioner

/obj/item/ammo_box/magazine/cm15/slug
	name = "CM15 magazine (12ga slugs)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/cm15/breacher
	name = "CM15 magazine (12ga breaching)"
	ammo_band_color = COLOR_BLUE_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/cm15/frag12
	name = "CM15 magazine (12ga FRAG-12)"
	ammo_band_color = COLOR_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/magazine/cm15/dragonsbreath
	name = "CM15 magazine (12ga dragonsbreath)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/cm15/flechette
	name = "CM15 magazine (12ga flechette)"
	ammo_band_color = COLOR_ALMOST_BLACK
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/cm15/drum
	name = "CM15 drum magazine (12ga buckshot)"
	desc = "Барабан для штурмовых дробовиков CM15 12-го калибра, вмещающий 16 патронов."
	icon_state = "cm15_drum"
	base_icon_state = "cm15_drum"
	max_ammo = 16
	ammo_band_icon = "+cm15_drum_ammo_band"

/obj/item/ammo_box/magazine/cm15/drum/beanbag
	name = "CM15 drum magazine (12ga beanbag)"
	ammo_band_color = COLOR_GREEN
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cm15/drum/rubbershot
	name = "CM15 drum magazine (12ga rubbershot)"
	ammo_band_color = COLOR_PINK
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/cm15/drum/executioner
	name = "CM15 drum magazine (12ga HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/shotgun/executioner

/obj/item/ammo_box/magazine/cm15/drum/slug
	name = "CM15 drum magazine (12ga slugs)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/cm15/drum/breacher
	name = "CM15 drum magazine (12ga breaching)"
	ammo_band_color = COLOR_BLUE_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/cm15/drum/frag12
	name = "CM15 drum magazine (12ga FRAG-12)"
	ammo_band_color = COLOR_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/magazine/cm15/drum/dragonsbreath
	name = "CM15 drum magazine (12ga dragonsbreath)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/cm15/drum/flechette
	name = "CM15 drum magazine (12ga flechette)"
	ammo_band_color = COLOR_ALMOST_BLACK
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

// MARK: F4 - battle rifle
/obj/item/ammo_box/magazine/c762x51mm
	name = "battle rifle magazine (7.62x51mm)"
	desc = "Магазин для боевых винтовок калибра 7.62x51мм, вмещающий 20 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x51_mag"
	base_icon_state = "762x51_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x51mm
	max_ammo = 20
	ammo_band_icon = "+762x51_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c762x51mm

/obj/item/ammo_box/magazine/c762x51mm/rubber
	name = "battle rifle magazine (7.62x51mm rubber)"
	desc = "Магазин для боевых винтовок калибра 7.62x51мм, вмещающий 20 патронов. Cодержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x51mm/rubber

/obj/item/ammo_box/magazine/c762x51mm/hp
	name = "battle rifle magazine (7.62x51mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c762x51mm/hp

/obj/item/ammo_box/magazine/c762x51mm/ap
	name = "battle rifle magazine (7.62x51mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c762x51mm/ap

/obj/item/ammo_box/magazine/c762x51mm/incendiary
	name = "battle rifle magazine (7.62x51mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c762x51mm/incendiary

// MARK: CM40 - LMG
/obj/item/ammo_box/magazine/cm40
	name = "CM40 box (7.62x51mm)"
	desc = "Короб для легких пулеметов CM40 калибра 7.62x51мм, вмещающий 80 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm40_mag"
	base_icon_state = "cm40_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x51mm
	max_ammo = 80
	ammo_band_icon = "+cm40_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c762x51mm

/obj/item/ammo_box/magazine/cm40/rubber
	name = "CM40 box (7.62x51mm rubber)"
	desc = "Короб для легких пулеметов CM40 калибра 7.62x51мм, вмещающий 80 патронов. Cодержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x51mm/rubber

/obj/item/ammo_box/magazine/cm40/hp
	name = "CM40 box (7.62x51mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c762x51mm/hp

/obj/item/ammo_box/magazine/cm40/ap
	name = "CM40 box (7.62x51mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c762x51mm/ap

/obj/item/ammo_box/magazine/cm40/incendiary
	name = "CM40 box (7.62x51mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c762x51mm/incendiary

// MARK: F90 - sniper rifle
/obj/item/ammo_box/magazine/c338
	name = "sniper rifle magazine (.338)"
	desc = "Магазин для снайперских винтовок калибра .338, вмещающий 5 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "338_mag"
	base_icon_state = "338_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_338
	max_ammo = 5
	ammo_band_icon = "+338_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c338

/obj/item/ammo_box/magazine/c338/hp
	name = "sniper rifle magazine (.338 HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c338/hp

/obj/item/ammo_box/magazine/c338/ap
	name = "sniper rifle magazine (.338 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c338/ap

/obj/item/ammo_box/magazine/c338/incendiary
	name = "sniper rifle magazine (.338 incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c338/incendiary

/obj/item/ammo_box/magazine/c338/extended
	name = "extended sniper rifle magazine (.338)"
	desc = "Магазин для снайперских винтовок калибра .338, вмещающий 10 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "338_mag_ext"
	base_icon_state = "338_mag_ext"
	ammo_band_icon = "+338_ext_ammo_band"
	ammo_band_color = null
	max_ammo = 10

/obj/item/ammo_box/magazine/c338/extended/hp
	name = "extended sniper rifle magazine (.338 HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c338/hp

/obj/item/ammo_box/magazine/c338/extended/ap
	name = "extended sniper rifle magazine (.338 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c338/ap

/obj/item/ammo_box/magazine/c338/extended/incendiary
	name = "extended sniper rifle magazine (.338 incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c338/incendiary

// MARK: CM23 - .38 cal pistol
/obj/item/ammo_box/magazine/c38
	name = "pistol magazine (.38)"
	desc = "Пистолетный магазин калибра .38, вмещающий 12 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c38_mag"
	base_icon_state = "c38_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_38
	max_ammo = 12
	ammo_band_icon = "+c38_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_PER_BULLET
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c38

/obj/item/ammo_box/magazine/c38/rubber
	name = "pistol magazine (.38 Rubber)"
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy

/obj/item/ammo_box/magazine/c38/match
	name = "pistol magazine (.38 Match)"
	ammo_band_color = COLOR_AMMO_MATCH
	ammo_type = /obj/item/ammo_casing/c38/match

/obj/item/ammo_box/magazine/c38/true
	name = "pistol magazine (.38 True Strike)"
	ammo_band_color = COLOR_AMMO_TRUESTRIKE
	ammo_type = /obj/item/ammo_casing/c38/match/true

/obj/item/ammo_box/magazine/c38/laser
	name = "pistol magazine (.38 Flare)"
	ammo_band_color = COLOR_AMMO_HELLFIRE
	ammo_type = /obj/item/ammo_casing/c38/flare

/obj/item/ammo_box/magazine/c38/hotshot
	name = "pistol magazine (.38 Hot Shot)"
	ammo_band_color = COLOR_AMMO_HOTSHOT
	ammo_type = /obj/item/ammo_casing/c38/hotshot

/obj/item/ammo_box/magazine/c38/iceblox
	name = "pistol magazine (.38 Iceblox)"
	ammo_band_color = COLOR_AMMO_ICEBLOX
	ammo_type = /obj/item/ammo_casing/c38/iceblox

/obj/item/ammo_box/magazine/c38/ap
	name = "pistol magazine (.38 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c38/ap

/obj/item/ammo_box/magazine/c38/hp
	name = "pistol magazine (.38 DumDum)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c38/dumdum

// MARK: CM357 - .357 cal pistol
/obj/item/ammo_box/magazine/c357
	name = "pistol magazine (.357)"
	desc = "Пистолетный магазин калибра .357, вмещающий 8 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c357_mag"
	base_icon_state = "c357_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_357
	max_ammo = 8
	ammo_band_icon = "+c357_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c357

/obj/item/ammo_box/magazine/c357/ap
	name = "pistol magazine (.357 Phasic)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c357/phasic

/obj/item/ammo_box/magazine/c357/match
	name = "pistol magazine (.357 Match)"
	ammo_band_color = COLOR_AMMO_MATCH
	ammo_type = /obj/item/ammo_casing/c357/match

/obj/item/ammo_box/magazine/c357/heartseeker
	name = "pistol magazine (.357 Heartseeker)"
	ammo_band_color = "#a91e1e"
	ammo_type = /obj/item/ammo_casing/c357/heartseeker

// MARK: CM70 - .45 cal pistol
/obj/item/ammo_box/magazine/c45
	name = "pistol magazine (.45)"
	desc = "Пистолетный магазин калибра .45, вмещающий 10 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c45_mag"
	base_icon_state = "c45_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_45
	max_ammo = 10
	ammo_band_icon = "+c45_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c45

/obj/item/ammo_box/magazine/c45/ap
	name = "pistol magazine (.45 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c45/ap

/obj/item/ammo_box/magazine/c45/hp
	name = "pistol magazine (.45 HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c45/hp

/obj/item/ammo_box/magazine/c45/incendiary
	name = "pistol magazine (.45 incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c45/inc
