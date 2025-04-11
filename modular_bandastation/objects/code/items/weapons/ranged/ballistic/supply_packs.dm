/datum/supply_pack/security/wespe_guns
	name = "Wespe Pistols Crate"
	desc = "Вам нужны новые пистолеты? В таком случае в этом ящике находятся два пистолета 'Оса' калибра .35 Sol Short с двумя магазинами заряженными резиной, а также по одной коробке соответствующих летальных и нелетальных боеприпасов."
	cost = CARGO_CRATE_VALUE * 10
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/wespe = 2,
		/obj/item/ammo_box/magazine/c35sol_pistol/rubber = 2,
		/obj/item/ammo_box/c35sol = 1,
		/obj/item/ammo_box/c35sol/rubber = 1,
		)
	crate_name = "Wespe handguns crate"

/datum/supply_pack/security/wespe_ammo
	name = ".35 Sol Short Ammo Crate"
	desc = "Не хватает патронов? Не беспокойтесь, в этом ящике вы найдете два нелетальных магазина и два летальных магазина калибра .35 Sol Short, и соответствующие коробки с боеприпасами."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c35sol_pistol = 2,
		/obj/item/ammo_box/magazine/c35sol_pistol/rubber = 2,
		/obj/item/ammo_box/c35sol = 1,
		/obj/item/ammo_box/c35sol/rubber = 1,
		)
	crate_name = ".35 Sol Short ammo crate"

/datum/supply_pack/security/wespe_ammospecial
	name = ".35 Sol Short Special Ammo Crate"
	desc = "Нужны особые боеприпасы? Не беспокойтесь, в этом ящике вы найдете два бронебойных магазина и два экспансивных магазина калибра .35 Sol Short, и соответствующие коробки с боеприпасами."
	cost = CARGO_CRATE_VALUE * 8
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/ap = 2,
		/obj/item/ammo_box/magazine/c35sol_pistol/ripper = 2,
		/obj/item/ammo_box/c35sol/ap = 1,
		/obj/item/ammo_box/c35sol/ripper = 1,
		)
	crate_name = ".35 Sol Short special ammo crate"

/datum/supply_pack/security/wespe_mags_extended
	name = ".35 Sol Short Extended Magazines Crate"
	desc = "Не хватает патронов в магазине? Не беспокойтесь, в этом ящике находятся два увеличенных магазина калибра .35 Sol Short."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo = 1,
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo/rubber = 1,
		)
	crate_name = ".35 Sol Short extended magazines crate"

/datum/supply_pack/goody/wespe_mags_extended_single
	name = ".35 Sol Short Extended Magazine Crate"
	desc = "Не хватает патронов в магазине? Не беспокойтесь, в этом ящике находится один увеличенный магазин калибра .35 Sol Short."
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty = 1,
	    )

/datum/supply_pack/goody/wespe_single
	name = "Wespe Pistol Single-Pack"
	desc = "Вам нужен новый пистолет? В таком случае, в этом ящике вы найдете себе один пистолет 'Оса' калибра .35 Sol Short с пустым магазином."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/wespe/no_mag = 1,
		/obj/item/ammo_box/magazine/c35sol_pistol/starts_empty = 1,
		)

/datum/supply_pack/goody/rubber35
	name = ".35 Sol Short Rubber Ammo Box"
	desc = "Нужны нелетальные патроны? В таком случае, в этом ящике находится коробка резиновых патронов калибра .35 Sol Short."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c35sol/rubber = 1,
		)

/datum/supply_pack/goody/ripper35
	name = ".35 Sol Short HP Ammo Box"
	desc = "Нужны экспансивные патроны? В таком случае, в этом ящике находится коробка с экспансивными патронами калибра .35 Sol Short."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c35sol/ripper = 1,
		)

/datum/supply_pack/goody/ap35
	name = ".35 Sol Short AP Ammo Box"
	desc = "Нужны бронебойные патроны? В таком случае, в этом ящике находится коробка с бронебойными патронами калибра .35 Sol Short."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c35sol/ap = 1,
		)

/datum/supply_pack/goody/lethal35
	name = ".35 Sol Short Ammo Box"
	desc = "Нужны летальные патроны? В таком случае, в этом ящике находится коробка с летальными патронами калибра .35 Sol Short."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c35sol = 1,
		)
