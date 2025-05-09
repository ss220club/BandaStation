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
	desc = "В этом ящике находятся два нелетальных магазина и два летальных магазина калибра .35 Sol Short, и соответствующие коробки с боеприпасами."
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
	desc = "В этом ящике находятся два бронебойных магазина и два экспансивных магазина калибра .35 Sol Short, и соответствующие коробки с боеприпасами."
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
	desc = "В этом ящике находятся два увеличенных магазина калибра .35 Sol Short."
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

/datum/supply_pack/security/armory/akm_civ
    name = "Sabel-42 Carbine Crate"
    desc = "Вам нужна надежная винтовка для самообороны, спортивной стрельбы или охоты? Тогда 'Сабля' станет отличным выбором."
    cost = CARGO_CRATE_VALUE * 100 //~20000
    access_view = ACCESS_ARMORY
    contains = list(
        /obj/item/gun/ballistic/automatic/akm/civ = 1,
        /obj/item/ammo_box/magazine/akm/civ = 1,
        /obj/item/ammo_box/a762x39/civilian = 1,
        /obj/item/ammo_box/a762x39/civilian/rubber = 1,
    )
    crate_name = "Sabel-42 carbine crate"

/datum/supply_pack/security/armory/akm_civ_magazines
    name = "Civilian 7.62x39mm Magazines Crate"
    desc = "B этом ящике находятся два магазина гражданского назначения калибра 7.62мм."
    cost = CARGO_CRATE_VALUE * 10 //~2000
    access_view = ACCESS_ARMORY
    contains = list(
        /obj/item/ammo_box/magazine/akm/civ/starts_empty = 2,
    )
    crate_name = "Civilian 7.62x39mm magazines crate"

/datum/supply_pack/security/armory/akm_civ_ammoboxes
    name = "Civilian 7.62x39mm Ammo Crate"
    desc = "В этом ящике находятся две коробки патронов гражданского назначения калибра 7.62мм."
    cost = CARGO_CRATE_VALUE * 10 //~2000
    access_view = ACCESS_ARMORY
    contains = list(
        /obj/item/ammo_box/a762x39/civilian = 1,
        /obj/item/ammo_box/a762x39/civilian/rubber = 1,
    )
    crate_name = "Civilian 7.62x39mm ammo crate"

/datum/supply_pack/goody/akm_hunting
    name = "Civilian 7.62x39mm Hunting Ammo Box"
    desc = "Хотите поохотится с вашим новым карабином? Не проблема, в этом ящике вы найдете коробку охотничьих калибра 7.62мм."
    cost = CARGO_CRATE_VALUE * 12 //~2400
    access_view = ACCESS_ARMORY
    contains = list(
        /obj/item/ammo_box/a762x39/civilian/hunting = 1,
    )

/datum/supply_pack/goody/akm_civ_goody
    name = "Sabel-42 Carbine Single-Pack"
    desc = "Вам нужна надежная винтовка для самообороны, спортивной стрельбы или охоты? Тогда 'Сабля' станет отличным вариантов для вас! \
	        В этом ящике находится один карабин 'Сабля-42'."
    cost = CARGO_CRATE_VALUE * 50 //~10000
    access_view = ACCESS_WEAPONS
    contains = list(
        /obj/item/gun/ballistic/automatic/akm/civ = 1,
    )

/datum/supply_pack/goody/akm_civ_magazines_goody
    name = "Civilian 7.62x39mm Magazines"
    desc = "Нужны магазины калибра 7.62 для вашего карабина? Не проблема, в этом ящике вы найдете два магазина гражданского назначения калибра 7.62мм."
    cost = CARGO_CRATE_VALUE * 12 //~2400
    access_view = ACCESS_WEAPONS
    contains = list(
        /obj/item/ammo_box/magazine/akm/civ/starts_empty = 2,
    )

/datum/supply_pack/goody/akm_civ_ammoboxes
    name = "Civilian 7.62x39mm Ammo Boxes"
    desc = "Нужны патроны калибра 7.62 для вашей винтовки? Не проблема, в этом ящике вы найдете коробку патронов гражданского назначения калибра 7.62мм."
    cost = CARGO_CRATE_VALUE * 12 //~2400
    access_view = ACCESS_WEAPONS
    contains = list(
        /obj/item/ammo_box/a762x39/civilian = 1,
    )

/datum/supply_pack/security/armory/sol_rifle_marksman
    name = ".40 Sol Long Carwo Marksman Rifle"
    desc = "Этот ящик содержит одну тяжелую марксманскую винтовку Carwo калибра .40 Sol Long вместе с одним магазином осколочно-резиновых патронов. \
	        Отличный инструмент для ликвидации серьезных угроз."
    cost = CARGO_CRATE_VALUE * 125 //~25000
    access_view = ACCESS_ARMORY
    contains = list(
        /obj/item/gun/ballistic/automatic/sol_rifle/marksman/wooden = 1,
        /obj/item/ammo_box/magazine/c40sol_rifle/fragmentation = 1,
    )
    crate_name = "Carwo marksman rifle crate"

/datum/supply_pack/security/armory/sol_rifle_ammo
    name = ".40 Sol Long Ammo Crate"
    desc = "Этот ящик содержит одну коробку нелетальных и одну коробку летальных боеприпасов калибра .40 Sol Long."
    cost = CARGO_CRATE_VALUE * 20 //~4000
    access_view = ACCESS_ARMORY
    contains = list(
        /obj/item/ammo_box/c40sol/fragmentation = 1,
        /obj/item/ammo_box/c40sol = 1,
    )
    crate_name = ".40 Sol Long ammo crate"

/datum/supply_pack/security/armory/sol_shotgun
    name = "Renoster Shotgun Crate"
    desc = "Этот ящик содержит два тяжелых дробовика Renoster. Используя тот же 12 калибр, наносит больше увечий. \
	        Когда в споре требуется аргумент побольше."
    cost = CARGO_CRATE_VALUE * 50 //~10000
    access_view = ACCESS_ARMORY
    contains = list(
        /obj/item/gun/ballistic/shotgun/riot/sol = 2,
    )
    crate_name = "Renoster shotgun crate"

/datum/supply_pack/goody/sol_shotgun
    name = "Renoster Shotgun Crate"
    desc = "Нужен серьезный аргумент в споре с соседом? Тогда вам отлично подойдет тяжелый дробовик Renoster. Используя тот же 12 калибр, наносит больше увечий. \
	        Когда в споре требуется аргумент побольше."
    cost = CARGO_CRATE_VALUE * 50 //~10000
    access_view = ACCESS_WEAPONS
    contains = list(
        /obj/item/gun/ballistic/shotgun/riot/sol = 1,
    )
