/obj/item/ammo_casing/c35sol
	name = ".35 Sol Short lethal bullet casing"
	desc = "Стандартный летальный пистолетный патрон ТСФ калибра .35 Sol Short."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "35sol"
	caliber = CALIBER_SOL35SHORT
	projectile_type = /obj/projectile/bullet/c35sol

/obj/item/ammo_casing/c35sol/rubber
	name = ".35 Sol Short rubber bullet casing"
	desc = "Стандартный резиновый пистолетный патрон ТСФ калибра .35 Sol Short с пониженной летальностью. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "35sol_disabler"
	projectile_type = /obj/projectile/bullet/c35sol/rubber
	harmful = FALSE

// .35 Sol ripper, similar to the detective revolver's dumdum rounds, causes slash wounds and is weak to armor

/obj/item/ammo_casing/c35sol/ripper
	name = ".35 Sol Short ripper bullet casing"
	desc = "Стандартный экспансивный пистолетный патрон ТСФ калибра .35 Sol Short. Наносит целям режущие раны, но слаб против брони."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "35sol_shrapnel"
	projectile_type = /obj/projectile/bullet/c35sol/ripper

//.35 sol armor piercing are the AP rounds for this weapon

/obj/item/ammo_casing/c35sol/ap
	name = ".35 Sol Short armor piercing bullet casing"
	desc = "Стандартный бронебойный пистолетный патрон ТСФ калибра .35 Sol Short. Пробивает броню, но довольно слаб против небронированных целей."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "35sol_ap"
	projectile_type = /obj/projectile/bullet/c35sol/ap
