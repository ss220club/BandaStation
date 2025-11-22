// MARK: .35 Sol Short
/obj/item/ammo_box/c35sol
	name = "ammo box (.35 Sol Short)"
	desc = "Коробка с пистолетными патронами калибра .35 Sol Short, вмещает 24 патрона."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "35box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SOL35SHORT
	ammo_type = /obj/item/ammo_casing/c35sol
	max_ammo = 24

/obj/item/ammo_box/c35sol/rubber
	name = "ammo box (.35 Sol Short rubber)"
	desc = parent_type::desc + "Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "35box_disabler"
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/c35sol/ripper
	name = "ammo box (.35 Sol Short ripper)"
	desc = parent_type::desc + "Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "35box_shrapnel"
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/c35sol/ap
	name = "ammo box (.35 Sol Short armor-piercing)"
	desc = parent_type::desc + "Серебрянная полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "35box_ap"
	ammo_type = /obj/item/ammo_casing/c35sol/ap

// MARK: .40 Sol Long
/obj/item/ammo_box/c40sol
	name = "ammo box (.40 Sol Long)"
	desc = "Коробка с винтовочными патронами калибра .40 Sol Long, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "40box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SOL40LONG
	ammo_type = /obj/item/ammo_casing/c40sol
	max_ammo = 30

/obj/item/ammo_box/c40sol/fragmentation
	name = "ammo box (.40 Sol Long resin-fragmentation)"
	desc = parent_type::desc + "Синяя полоска указывает на то, что здесь должны храниться травматические боеприпасы."
	icon_state = "40box_disabler"
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation

/obj/item/ammo_box/c40sol/pierce
	name = "ammo box (.40 Sol Long armor-piercing)"
	desc = parent_type::desc + "Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "40box_pierce"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce

/obj/item/ammo_box/c40sol/incendiary
	name = "ammo box (.40 Sol Long incendiary)"
	desc = parent_type::desc + "Оранжевая полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "40box_flame"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary

// MARK: 7.62x39mm
/obj/item/ammo_box/c762x39
	name = "ammo box (7.62x39mm)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x39box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x39mm
	ammo_type = /obj/item/ammo_casing/c762x39
	max_ammo = 45

/obj/item/ammo_box/c762x39/ricochet
	name = "ammo box (7.62x39mm ricochet)"
	desc = parent_type::desc + "Темно-красная марка указывает на то, что в ней должны храниться спортивные боеприпасы."
	icon_state = "762x39box_ricochet"
	ammo_type = /obj/item/ammo_casing/c762x39/ricochet

/obj/item/ammo_box/c762x39/fire
	name = "ammo box (7.62x39mm incendiary)"
	desc = parent_type::desc + "Красная марка указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "762x39box_fire"
	ammo_type = /obj/item/ammo_casing/c762x39/fire

/obj/item/ammo_box/c762x39/ap
	name = "ammo box (7.62x39mm armor-piercing)"
	desc = parent_type::desc + "Серая марка указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "762x39box_ap"
	ammo_type = /obj/item/ammo_casing/c762x39/ap

/obj/item/ammo_box/c762x39/emp
	name = "ammo box (7.62x39mm ion)"
	desc = parent_type::desc + "Голубая марка указывает на то, что в ней должны храниться ионные боеприпасы."
	icon_state = "762x39box_emp"
	ammo_type = /obj/item/ammo_casing/c762x39/emp

/obj/item/ammo_box/c762x39/civilian
	name = "ammo box (7.62x39mm civilian)"
	desc = parent_type::desc + "Желтая марка указывает на то, что в ней должны храниться гражданские боеприпасы."
	icon_state = "762x39boxmini_civ"
	ammo_type = /obj/item/ammo_casing/c762x39/civilian
	max_ammo = 30

/obj/item/ammo_box/c762x39/rubber
	name = "ammo box (7.62x39mm rubber)"
	desc = parent_type::desc + "Темно-синия марка указывает на то, что в ней должны храниться травматические боеприпасы."
	icon_state = "762x39box_rubber"
	ammo_type = /obj/item/ammo_casing/c762x39/rubber

/obj/item/ammo_box/c762x39/hunting
	name = "ammo box (7.62x39mm hunting)"
	desc = parent_type::desc + "Темно-зеленая марка указывает на то, что в ней должны храниться охотничьи боеприпасы."
	icon_state = "762x39box_xeno"
	ammo_type = /obj/item/ammo_casing/c762x39/hunting

/obj/item/ammo_box/c762x39/blank
	name = "ammo box (7.62x39mm blank)"
	desc = parent_type::desc + "Белая марка указывает на то, что в ней должны храниться холостые боеприпасы."
	icon_state = "762x39box_blank"
	ammo_type = /obj/item/ammo_casing/c762x39/blank

// MARK: 7.62x38mmR
/obj/item/ammo_box/n762_cylinder
	name = "speed loader (7.62x38mmR)"
	desc = "Designed to quickly reload revolvers. Made in USSP."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 7
	caliber = CALIBER_N762
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION
	ammo_band_icon = "+357_ammo_band"
	ammo_band_color = null

// MARK: 9x25mm NT
/obj/item/ammo_box/c9x25mm
	name = "ammo box (9x25mm NT)"
	desc = "Коробка с пистолетными патронами калибра 9x25мм НТ, вмещает 24 патрона."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo2.dmi'
	icon_state = "9mmbox"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_9x25NT
	ammo_type = /obj/item/ammo_casing/c9x25mm
	max_ammo = 24

/obj/item/ammo_box/c9x25mm/rubber
	name = "ammo box (9x25mm NT rubber)"
	desc = parent_type::desc + "Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "9mmbox-rubber"
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/c9x25mm/hp
	name = "ammo box (9x25mm NT hollow-point)"
	desc = parent_type::desc + "Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "9mmbox-hp"
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

/obj/item/ammo_box/c9x25mm/ap
	name = "ammo box (9x25mm NT armor-piercing)"
	desc = parent_type::desc + "<br> Серебрянная полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "9mmbox-ap"
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

// MARK: 5.56x45
/obj/item/ammo_box/c223
	name = "ammo box (5.56x45mm)"
	desc = "Коробка с винтовочными патронами калибра 5.56x45мм, вмещает 45 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo2.dmi'
	icon_state = "556box_big"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_A223
	ammo_type = /obj/item/ammo_casing/a223
	max_ammo = 45

/obj/item/ammo_box/c223/rubber
	name = "ammo box (5.56x45mm rubber)"
	desc = "Коробка с винтовочными патронами калибра 5.56x45мм, вмещает 45 патронов."
	icon_state = "556box_big-rubber"
	ammo_type = /obj/item/ammo_casing/a223/rubber

/obj/item/ammo_box/c223/ap
	name = "ammo box (5.56x45mm armor-piercing)"
	desc = "Коробка с винтовочными патронами калибра 5.56x45мм, вмещает 45 патронов."
	icon_state = "556box_big-ap"
	ammo_type = /obj/item/ammo_casing/a223/ap

/obj/item/ammo_box/c223/hp
	name = "ammo box (5.56x45mm hollow-point)"
	desc = "Коробка с винтовочными патронами калибра 5.56x45мм, вмещает 45 патронов."
	icon_state = "556box_big-hp"
	ammo_type = /obj/item/ammo_casing/a223/hp

/obj/item/ammo_box/c223/incendiary
	name = "ammo box (5.56x45mm incendiary)"
	desc = "Коробка с винтовочными патронами калибра 5.56x45мм, вмещает 45 патронов."
	icon_state = "556box_big-incendiary"
	ammo_type = /obj/item/ammo_casing/a223/incendiary

// MARK: BOXES WITH MAGAZINES / AMMO BOXES
/obj/item/storage/toolbox/ammobox/c9x25mm
	name = "9x25mm NT pistol magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c9x25mm_pistol

/obj/item/storage/toolbox/ammobox/c9x25mm/extended
	name = "9x25mm NT pistol extended magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c9x25mm_pistol/stendo

/obj/item/storage/toolbox/ammobox/c9x25mm
	name = "9x25mm NT ammo box"
	ammo_to_spawn = /obj/item/ammo_box/c9x25mm

/obj/item/storage/toolbox/ammobox/amk
	name = "7.62x39mm AMK magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c762x39mm

/obj/item/storage/toolbox/ammobox/amk
	name = "7.62x39mm ammo box"
	ammo_to_spawn = /obj/item/ammo_box/c762x39

/obj/item/storage/toolbox/ammobox/c40sol_mags
	name = ".40 Sol Long standart magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c40sol_rifle/standard

/obj/item/storage/toolbox/ammobox/c40sol_bullets
	name = ".40 Sol Long ammo box"
	ammo_to_spawn = /obj/item/ammo_box/c40sol

/obj/item/storage/toolbox/ammobox/c35sol_mags
	name = ".35 Sol short standart pistol magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c35sol_pistol

/obj/item/storage/toolbox/ammobox/c35sol_bullets
	name = ".35 Sol short ammo box"
	ammo_to_spawn = /obj/item/ammo_box/c35sol

/obj/item/storage/toolbox/ammobox/c762x51mm
	name = "7.62x51mm battle rifle magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c762x51mm

// /obj/item/storage/toolbox/ammobox/c762x54mmr
// 	name = "7.62x54mmR ammo box"
// 	ammo_to_spawn = /obj/item/ammo_box/magazine/c762x54mmr

/obj/item/storage/toolbox/ammobox/c223
	name = "5.56x45mm ARG magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c223

/obj/item/storage/toolbox/ammobox/c45
	name = ".45 pistol magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/c45

/obj/item/storage/toolbox/ammobox/m9mm_magazines
	name = "9mm SMG magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/smgm9mm

/obj/item/storage/toolbox/ammobox/m9mm_bullets
	name = "9mm ammo box"
	ammo_to_spawn = /obj/item/ammo_box/c9mm

/obj/item/storage/toolbox/ammobox/m10mm_magazines
	name = "10mm SMG magazines box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/smg10mm

/obj/item/storage/toolbox/ammobox/m10mm_bullets
	name = "10mm ammo box"
	ammo_to_spawn = /obj/item/ammo_box/c10mm
