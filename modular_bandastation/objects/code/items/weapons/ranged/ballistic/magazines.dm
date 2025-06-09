// MARK:  Wespe aka sol pistol
/obj/item/ammo_box/magazine/c35sol_pistol
	name = "Sol pistol magazine"
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
	name = "Sol extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 16 патронов."
	icon_state = "pistol_35_stended"
	base_icon_state = "pistol_35_stended"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 16

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/rubber
	name = "Sol rubber pistol magazine"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает 12 резиновых патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/rubber
	name = "Sol rubber extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 16 резиновых патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/ap
	name = "Sol AP pistol magazine"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает 12 бронебойных патронов."
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ap
	name = "Sol AP extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 16 бронебойных патронов."
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/ripper
	name = "Sol HP pistol magazine"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает 12 экспансивных патронов."
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ripper
	name = "Sol HP extended pistol magazine"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещающий 16 экспансивных патронов."
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/magazine/c35sol_pistol/drum
	name = "Sol drum pistol magazine"
	desc = "Барабанный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 35 патронов."
	icon_state = "pistol_35_drum"
	base_icon_state = "pistol_35_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 35

/obj/item/ammo_box/magazine/c35sol_pistol/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/drum/rubber
	name = "Sol rubber drum pistol magazine"
	desc = "Барабанный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 35 резиновых патронов."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/drum/ap
	name = "Sol AP drum pistol magazine"
	desc = "Барабанный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 35 бронебойных патронов."
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/drum/ripper
	name = "Sol HP drum pistol magazine"
	desc = "Барабанный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещающий 35 экспансивных патронов."
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

// MARK: AMK(AKM)
/obj/item/ammo_box/magazine/amk
	name = "AMK magazine"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами»."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "amk"
	ammo_band_icon = "+amk_ammo_band"
	ammo_band_color = null
	ammo_type = /obj/item/ammo_casing/a762x39
	caliber = CALIBER_762x39mm
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/amk/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/amk/ricochet
	name = "AMK magazine (MATCH)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит боеприпасы с высокой рикошетностью."
	ammo_band_color = COLOR_AMMO_MATCH
	ammo_type = /obj/item/ammo_casing/a762x39/ricochet

/obj/item/ammo_box/magazine/amk/fire
	name = "AMK magazine (INCENDIARY)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит зажигательные боеприпасы."
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/a762x39/fire

/obj/item/ammo_box/magazine/amk/ap
	name = "AMK magazine (ARMOR PIERCING)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит бронебойные боеприпасы."
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/a762x39/ap

/obj/item/ammo_box/magazine/amk/emp
	name = "AMK magazine (EMP)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит ионные боеприпасы, которые хорошо подходят для выведения из строя электроники и разрушения мехов."
	ammo_band_color = "#1ea2ee"
	ammo_type = /obj/item/ammo_casing/a762x39/emp

/obj/item/ammo_box/magazine/amk/rubber
	name = "AMK magazine (RUBBER)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит нелетальные резиновые боеприпасы."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/a762x39/rubber

/obj/item/ammo_box/magazine/amk/civ
	name = "Sabel magazine"
	desc = "Укороченный двухрядный магазин, вмещающий 15 гражданских патронов калибра 7.62х39 мм."
	icon_state = "amk_civ"
	max_ammo = 15
	ammo_type = /obj/item/ammo_casing/a762x39/civilian

/obj/item/ammo_box/magazine/amk/civ/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/amk/hunting
	name = "AMK magazine (HUNT)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62х39 мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами». Содержит боеприпасы для охоты."
	ammo_band_color = "#05880c"
	ammo_type = /obj/item/ammo_casing/a762x39/hunting

// MARK: Fal aka Carwo
/obj/item/ammo_box/magazine/c40sol_rifle
	name = "Sol rifle short magazine"
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
	name = "Sol rifle rubber-fragmentation short magazine"
	desc = "Укороченный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 15 осколочно-резиновых патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/pierce
	name = "Sol rifle armor-pierce short magazine"
	desc = "Укороченный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 15 бронебойных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/incendiary
	name = "Sol rifle incendiary short magazine"
	desc = "Укороченный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 15 зажигательных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/standard
	name = "Sol rifle magazine"
	desc = "Магазин стандартного размера для винтовок ТСФ калибра .40 Sol Long, вмещает 20 патронов."
	icon_state = "rifle_standard"
	w_class = WEIGHT_CLASS_SMALL
	max_ammo = 20

/obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/standard/fragmentation
	name = "Sol rifle rubber-fragmentation magazine"
	desc = "Магазин стандартного размера для винтовок ТСФ калибра .40 Sol Long, вмещает 20 осколочно-резиновых патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/standard/pierce
	name = "Sol rifle armor-pierce magazine"
	desc = "Магазин стандартного размера для винтовок ТСФ калибра .40 Sol Long, вмещает 20 бронебойных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/standard/incendiary
	name = "Sol rifle incendiary magazine"
	desc = "Магазин стандартного размера для винтовок ТСФ калибра .40 Sol Long, вмещает 20 зажигательных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/long
	name = "Sol rifle long magazine"
	desc = "Удлиненный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 30 патронов."
	icon_state = "rifle_long"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 30

/obj/item/ammo_box/magazine/c40sol_rifle/long/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/long/fragmentation
	name = "Sol rifle rubber-fragmentation long magazine"
	desc = "Удлиненный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 30 осколочно-резиновых патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/long/pierce
	name = "Sol rifle armor-pierce long magazine"
	desc = "Удлиненный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 30 бронебойных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/long/incendiary
	name = "Sol rifle incendiary long magazine"
	desc = "Удлиненный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 30 зажигательных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/drum
	name = "Sol rifle drum magazine"
	desc = "Барабанный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 60 патронов."
	icon_state = "rifle_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 60

/obj/item/ammo_box/magazine/c40sol_rifle/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/drum/fragmentation
	name = "Sol rifle rubber-fragmentation drum magazine"
	desc = "Барабанный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 60 осколочно-резиновых патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/drum/pierce
	name = "Sol rifle armor-pierce drum magazine"
	desc = "Барабанный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 60 бронебойных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/drum/incendiary
	name = "Sol rifle incendiary drum magazine"
	desc = "Барабанный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 60 зажигательных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/box
	name = "Sol rifle box magazine"
	desc = "Коробчатый магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 100 патронов."
	icon_state = "rifle_box"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 100

/obj/item/ammo_box/magazine/c40sol_rifle/box/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/box/fragmentation
	name = "Sol rifle rubber-fragmentation box magazine"
	desc = "Коробчатый магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 100 осколочно-резиновых патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/box/pierce
	name = "Sol rifle armor-pierce box magazine"
	desc = "Коробчатый магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 100 бронебойных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/box/incendiary
	name = "Sol rifle incendiary box magazine"
	desc = "Коробчатый магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 100 зажигательных патронов."
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY
