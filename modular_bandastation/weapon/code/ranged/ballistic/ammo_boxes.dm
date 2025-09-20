// MARK: .35 Sol Short
/obj/item/ammo_box/c35sol
	name = "ammo box (.35 Sol Short)"
	desc = "Коробка с летальными пистолетными патронами калибра .35 Sol Short, вмещает 24 патрона."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "35box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SOL35SHORT
	ammo_type = /obj/item/ammo_casing/c35sol
	max_ammo = 24

/obj/item/ammo_box/c35sol/rubber
	name = "ammo box (.35 Sol Short rubber)"
	desc = "Коробка с травматическими пистолетными патронами калибра .35 Sol Short, вмещает 24 патрона. Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "35box_disabler"
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/c35sol/ripper
	name = "ammo box (.35 Sol Short ripper)"
	desc = "Коробка с экспансивными пистолетными патронами калибра .35 Sol Short, вмещает 24 патрона. Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "35box_shrapnel"
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/c35sol/ap
	name = "ammo box (.35 Sol Short armor-piercing)"
	desc = "Коробка с бронебойными пистолетными патронами калибра .35 Sol Short, вмещает 24 патрона. Серебрянная полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
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
	desc = "Коробка с винтовочными патронами калибра .40 Sol Long, вмещает 30 патронов. Синяя полоска указывает на то, что здесь должны храниться травматические боеприпасы."
	icon_state = "40box_disabler"
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation

/obj/item/ammo_box/c40sol/pierce
	name = "ammo box (.40 Sol Long armor-piercing)"
	desc = "Коробка с винтовочными патронами калибра .40 Sol Long, вмещает 30 патронов. Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "40box_pierce"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce

/obj/item/ammo_box/c40sol/incendiary
	name = "ammo box (.40 Sol Long incendiary)"
	desc = "Коробка с винтовочными патронами калибра .40 Sol Long, вмещает 30 патронов. Оранжевая полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "40box_flame"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary

// MARK: 7.62x39mm
/obj/item/ammo_box/a762x39
	name = "ammo box (7.62x39mm)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x39box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x39mm
	ammo_type = /obj/item/ammo_casing/a762x39
	max_ammo = 45

/obj/item/ammo_box/a762x39/ricochet
	name = "ammo box (7.62x39mm ricochet)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов. Темно-красная марка указывает на то, что в ней должны храниться спортивные боеприпасы."
	icon_state = "762x39box_ricochet"
	ammo_type = /obj/item/ammo_casing/a762x39/ricochet

/obj/item/ammo_box/a762x39/fire
	name = "ammo box (7.62x39mm incendiary)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов. Красная марка указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "762x39box_fire"
	ammo_type = /obj/item/ammo_casing/a762x39/fire

/obj/item/ammo_box/a762x39/ap
	name = "ammo box (7.62x39mm armor-piercing)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов. Серая марка указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "762x39box_ap"
	ammo_type = /obj/item/ammo_casing/a762x39/ap

/obj/item/ammo_box/a762x39/emp
	name = "ammo box (7.62x39mm ion)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов. Голубая марка указывает на то, что в ней должны храниться ионные боеприпасы."
	icon_state = "762x39box_emp"
	ammo_type = /obj/item/ammo_casing/a762x39/emp

/obj/item/ammo_box/a762x39/civilian
	name = "ammo box (7.62x39mm civilian)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 30 патронов. Желтая марка указывает на то, что в ней должны храниться гражданские боеприпасы."
	icon_state = "762x39boxmini_civ"
	ammo_type = /obj/item/ammo_casing/a762x39/civilian
	max_ammo = 30

/obj/item/ammo_box/a762x39/rubber
	name = "ammo box (7.62x39mm rubber)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов. Темно-синия марка указывает на то, что в ней должны храниться травматические боеприпасы."
	icon_state = "762x39box_rubber"
	ammo_type = /obj/item/ammo_casing/a762x39/rubber

/obj/item/ammo_box/a762x39/hunting
	name = "ammo box (7.62x39mm hunting)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов. Темно-зеленая марка указывает на то, что в ней должны храниться охотничьи боеприпасы."
	icon_state = "762x39box_xeno"
	ammo_type = /obj/item/ammo_casing/a762x39/hunting

/obj/item/ammo_box/a762x39/blank
	name = "ammo box (7.62x39mm blank)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов. Белая марка указывает на то, что в ней должны храниться холостые боеприпасы."
	icon_state = "762x39box_blank"
	ammo_type = /obj/item/ammo_casing/a762x39/blank

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
	desc = "Коробка с летальными пистолетными патронами калибра 9x25мм НТ, вмещает 24 патрона."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "35box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_9x25NT
	ammo_type = /obj/item/ammo_casing/c9x25mm
	max_ammo = 24

/obj/item/ammo_box/c9x25mm/rubber
	name = "ammo box (9x25mm NT rubber)"
	desc = "Коробка с травматическими пистолетными патронами калибра 9x25мм НТ, вмещает 24 патрона. Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "35box_disabler"
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/c9x25mm/hp
	name = "ammo box (9x25mm NT hollow-point)"
	desc = "Коробка с экспансивными пистолетными патронами калибра 9x25мм НТ, вмещает 24 патрона. Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "35box_shrapnel"
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

/obj/item/ammo_box/c9x25mm/ap
	name = "ammo box (9x25mm NT armor-piercing)"
	desc = "Коробка с бронебойными пистолетными патронами калибра 9x25мм НТ, вмещает 24 патрона. Серебрянная полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "35box_ap"
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap
