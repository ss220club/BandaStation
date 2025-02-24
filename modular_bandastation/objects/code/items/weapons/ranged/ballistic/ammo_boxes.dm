/obj/item/ammo_box/c35sol
	name = "ammo box (.35 Sol Short lethal)"
	desc = "Коробка со летальными пистолетными патронами калибра .35 Sol Short, вмещает двадцать четыре патрона."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "35box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SOL35SHORT
	ammo_type = /obj/item/ammo_casing/c35sol
	max_ammo = 24

/obj/item/ammo_box/c35sol/rubber
	name = "ammo box (.35 Sol Short rubber)"
	desc = "Коробка с нелетальными пистолетными патронами калибра .35 Sol Short, вмещает двадцать четыре патрона. Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "35box_disabler"
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/c35sol/ripper
	name = "ammo box (.35 Sol Short ripper)"
	desc = "Коробка с экспансивными пистолетными патронами калибра .35 Sol Short, вмещает двадцать четыре патрона. Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "35box_shrapnel"
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/c35sol/ap
	name = "ammo box (.35 Sol Short armor piercing)"
	desc = "Коробка с бронебойными пистолетными патронами калибра .35 Sol Short, вмещает двадцать четыре патрона. Серебрянная полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "35box_ap"
	ammo_type = /obj/item/ammo_casing/c35sol/ap
