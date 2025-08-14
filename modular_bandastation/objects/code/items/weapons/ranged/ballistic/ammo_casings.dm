// MARK: .35 Sol
/obj/item/ammo_casing/c35sol
	name = ".35 Sol Short bullet casing"
	desc = "Стандартный летальный пистолетный патрон ТСФ калибра .35 Sol Short."
	caliber = CALIBER_SOL35SHORT
	projectile_type = /obj/projectile/bullet/c35sol

/obj/item/ammo_casing/c35sol/rubber
	name = ".35 Sol Short rubber bullet casing"
	desc = "Стандартный травматический пистолетный патрон ТСФ с резиновой пулей калибра .35 Sol Short с пониженной летальностью. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "sr-casing"
	projectile_type = /obj/projectile/bullet/c35sol/rubber

// .35 Sol ripper, similar to the detective revolver's dumdum rounds, causes slash wounds and is weak to armor
/obj/item/ammo_casing/c35sol/ripper
	name = ".35 Sol Short ripper bullet casing"
	desc = "Стандартный экспансивный пистолетный патрон ТСФ калибра .35 Sol Short. Наносит целям режущие раны, но слаб против брони."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "sl-casing"
	projectile_type = /obj/projectile/bullet/c35sol/ripper

// .35 sol armor piercing are the AP rounds for this weapon
/obj/item/ammo_casing/c35sol/ap
	name = ".35 Sol Short armor-piercing bullet casing"
	desc = "Стандартный бронебойный пистолетный патрон ТСФ калибра .35 Sol Short. Пробивает броню, но довольно слаб против небронированных целей."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "sa-casing"
	projectile_type = /obj/projectile/bullet/c35sol/ap

// MARK: 7.62x39mm
/obj/item/ammo_casing/a762x39
	name = "7.62x39mm bullet casing"
	desc = "Патрон калибра 7.62x39мм."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "762x39-casing"
	caliber = CALIBER_762x39mm
	projectile_type = /obj/projectile/bullet/a762x39

/obj/item/ammo_casing/a762x39/ricochet
	name = "7.62x39mm match bullet casing"
	desc = "Спортивный патрон калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/a762x39/ricochet

/obj/item/ammo_casing/a762x39/fire
	name = "7.62x39mm incendiary bullet casing"
	desc = "Патрон с зажигательной пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/incendiary/a762x39

/obj/item/ammo_casing/a762x39/ap
	name = "7.62x39mm armor-piercing bullet casing"
	desc = "Патрон с бронебойной пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/a762x39/ap

/obj/item/ammo_casing/a762x39/emp
	name = "7.62x39mm ion bullet casing"
	desc = "Патрон с ионной пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/a762x39/emp

/obj/item/ammo_casing/a762x39/civilian
	name = "7.62x39mm civilian bullet casing"
	desc = "Гражданский патрон калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/a762x39/civilian

/obj/item/ammo_casing/a762x39/rubber
	name = "7.62x39mm rubber bullet casing"
	desc = "Патрон с резиновой пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/a762x39/rubber

/obj/item/ammo_casing/a762x39/hunting
	name = "7.62x39mm hunting bullet casing"
	desc = "Патрон с оболочечной пулей 7.62x39мм с мягким наконечником."
	projectile_type = /obj/projectile/bullet/a762x39/hunting

/obj/item/ammo_casing/a762x39/blank
	name = "7.62x39mm blank bullet casing"
	desc = "Холостой патрон калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/a762x39/blank
	harmful = FALSE

// MARK: .40 Sol Long
/obj/item/ammo_casing/c40sol
	name = ".40 Sol Long bullet casing"
	desc = "Стандартный винтовочный патрон ТСФ калибра .40 Sol Long."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "40sol"
	caliber = CALIBER_SOL40LONG
	projectile_type = /obj/projectile/bullet/c40sol

// .40 Sol fragmentation rounds, embeds shrapnel in the target almost every time at close to medium range. Teeeechnically less lethals.
/obj/item/ammo_casing/c40sol/fragmentation
	name = ".40 Sol Long rubber-fragmentation bullet casing"
	desc = "Стандартный осколочно-травматический винтовочный патрон ТСФ с резиновой пулей калибра .40 Sol Long. Разрывается при ударе, выбрасывая резиновую шрапнель, которая может вывести цель из строя."
	icon_state = "40sol_disabler"
	projectile_type = /obj/projectile/bullet/c40sol/fragmentation

// .40 Sol match grade, bounces a lot, and if there's less than 20 bullet armor on wherever these hit, it'll go completely through the target and out the other side
/obj/item/ammo_casing/c40sol/pierce
	name = ".40 Sol Long pierce bullet casing"
	desc = "Стандартный бронебойный винтовочный патрон ТСФ калибра .40 Sol Long. Стреляет под более высоким давлением и, \
	следовательно, несколько быстрее. По слухам, с ними можно пробивать несколько препятствий или противников насквозь, \
	хотя официальная рекомендация - стрелять только в цель, а не в стену рядом с ней."
	icon_state = "40sol_pierce"
	projectile_type = /obj/projectile/bullet/c40sol/pierce

// .40 Sol incendiary
/obj/item/ammo_casing/c40sol/incendiary
	name = ".40 Sol Long incendiary bullet casing"
	desc = "Стандартный зажигательный винтовочный патрон ТСФ калибра .40 Sol Long. Не оставляет огненного следа, воспламеняя цель только при попадании."
	icon_state = "40sol_flame"
	projectile_type = /obj/projectile/bullet/incendiary/c40sol

// MARK: 9x25mm NT
/obj/item/ammo_casing/c9x25mm
	name = "9x25mm NT bullet casing"
	desc = "Стандартный летальный пистолетный патрон НТ калибра 9x25мм."
	caliber = CALIBER_9x25NT
	projectile_type = /obj/projectile/bullet/c9x25mm

/obj/item/ammo_casing/c9x25mm/rubber
	name = "9x25mm NT rubber bullet casing"
	desc = "Стандартный травматический пистолетный патрон НТ с резиновой пулей калибра 9x25мм. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "sr-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/rubber

/obj/item/ammo_casing/c9x25mm/hp
	name = "9x25mm NT hollow-point bullet casing"
	desc = "Стандартный экспансивный пистолетный патрон НТ калибра 9x25мм. Наносит целям режущие раны, но слаб против брони."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "sl-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/hp

/obj/item/ammo_casing/c9x25mm/ap
	name = "9x25mm NT armor-piercing bullet casing"
	desc = "Стандартный бронебойный пистолетный патрон НТ калибра 9x25мм. Пробивает броню, но довольно слаб против небронированных целей."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "sa-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/ap
