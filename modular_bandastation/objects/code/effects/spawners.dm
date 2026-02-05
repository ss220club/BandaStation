/obj/effect/spawner/random/id_stickers
	name = "id skins spawner"
	icon = 'modular_bandastation/objects/icons/obj/effects/spawners.dmi'
	icon_state = "random_id_sticker"
	loot = list(
		/obj/item/id_sticker/colored = 10,
		/obj/item/id_sticker/donut = 5,
		/obj/item/id_sticker/business = 5,
		/obj/item/id_sticker/ussp = 5,
		/obj/item/id_sticker/colored/silver = 5,
		/obj/item/id_sticker/silver = 5,
		/obj/item/id_sticker/gold = 1,
		/obj/item/id_sticker/lifetime = 1,
		/obj/item/id_sticker/clown = 1,
		/obj/item/id_sticker/neon = 1,
		/obj/item/id_sticker/colored/neon = 1,
		/obj/item/id_sticker/missing = 1,
		/obj/item/id_sticker/ouija = 1,
		/obj/item/id_sticker/paradise = 1,
		/obj/item/id_sticker/rainbow = 1,
		/obj/item/id_sticker/space = 1,
		/obj/item/id_sticker/kitty = 1,
		/obj/item/id_sticker/colored/kitty = 1,
		/obj/item/id_sticker/cursedmiku = 1,
		/obj/item/id_sticker/colored/snake = 1,
		/obj/item/id_sticker/magic = 1,
		/obj/item/id_sticker/terminal = 1,
		/obj/item/id_sticker/jokerge = 1,
		/obj/item/id_sticker/boykisser = 1
	)

/obj/effect/spawner/random/clothing/rus_camosuits
	name = "random camo suit spawner"
	icon_state = "costume"
	loot = list(
		/obj/item/clothing/under/syndicate/rus_army = 1,
		/obj/item/clothing/under/syndicate/rus_army/berezka = 1,
		/obj/item/clothing/under/syndicate/rus_army/flora = 1
	)

/obj/effect/spawner/random/clothing/soviet_armor
	name = "random soviet armor spawner"
	icon_state = "costume"
	loot = list(
		/obj/item/clothing/suit/armor/vest/russian = 50,
		/obj/item/clothing/suit/armor/vest/russian_coat = 50,
		/obj/item/clothing/suit/armor/vest/ussp = 20,
		/obj/item/clothing/suit/armor/vest/marine/security/ussp_security = 1,
		/obj/item/clothing/suit/armor/riot/ussp_riot = 10,
		/obj/item/clothing/suit/space/ussp_expedition = 10,
	)

/obj/effect/spawner/random/clothing/soviet_helmet
	name = "random soviet helmet spawner"
	icon_state = "costume"
	loot = list(
		/obj/item/clothing/head/hats/ussp = 50,
		/obj/item/clothing/head/helmet/rus_helmet = 50,
		/obj/item/clothing/head/helmet/rus_ushanka = 50,
		/obj/item/clothing/head/helmet/marine/security/ussp_kaska = 1,
		/obj/item/clothing/head/helmet/toggleable/riot = 10,
		/obj/item/clothing/head/helmet/space/ussp_expedition = 10,
	)

/obj/effect/spawner/random/sakhno
	loot = list(
		/obj/item/gun/ballistic/rifle/boltaction/surplus = 80,
		/obj/item/gun/ballistic/rifle/boltaction = 10,
		/obj/item/food/rationpack = 1,
		/obj/item/gun/ballistic/rifle/boltaction/tactical = 10,
		/obj/item/gun/ballistic/rifle/boltaction/tactical/surplus = 60,
		/obj/item/gun/ballistic/rifle/boltaction/army = 10,
		/obj/item/gun/ballistic/rifle/boltaction/army/surplus = 80,
		/obj/item/gun/ballistic/rifle/boltaction/army/tactical = 10,
		/obj/item/gun/ballistic/rifle/boltaction/army/tactical/surplus = 60,
		/obj/item/gun/ballistic/rifle/boltaction/mosin/empty = 1,
		/obj/item/gun/ballistic/rifle/boltaction/mosin/surplus/empty = 25,
		/obj/item/gun/ballistic/rifle/krov/no_mag = 5,
		/obj/item/gun/ballistic/rifle/sks/c762x54mmr/empty = 5,
		/obj/item/gun/ballistic/rifle/sks/empty = 5,
	)

/obj/effect/spawner/random/sakhno/ammo
	loot = list(
		/obj/item/ammo_box/speedloader/strilka310/surplus = 80,
		/obj/item/ammo_box/speedloader/strilka310 = 10,
		/obj/item/food/rationpack = 1,
		/obj/item/ammo_box/speedloader/strilka310/rubber = 5,
		/obj/item/ammo_box/speedloader/strilka310/ap = 5,
		/obj/item/ammo_box/speedloader/strilka310/incendiary = 5,
		/obj/item/ammo_box/speedloader/strilka310/hp = 5,
		/obj/item/ammo_box/speedloader/strilka310/phasic = 1,
		/obj/item/ammo_box/speedloader/c762x54mmr = 10,
		/obj/item/ammo_box/speedloader/c762x54mmr/ap = 5,
		/obj/item/ammo_box/speedloader/c762x54mmr/rubber = 5,
		/obj/item/ammo_box/speedloader/c762x54mmr/incendiary = 5,
		/obj/item/ammo_box/speedloader/c762x54mmr/hp = 5,
	)

/obj/effect/spawner/random/contraband/c46x30
	name = "random 4.6x30mm ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c46x30,
		/obj/item/ammo_box/c46x30/ap,
		/obj/item/ammo_box/c46x30/incendiary,
		/obj/item/ammo_box/c46x30/rubber,
	)

/obj/effect/spawner/random/contraband/c338
	name = "random .338 ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c338,
		/obj/item/ammo_box/c338/ap,
		/obj/item/ammo_box/c338/hp,
		/obj/item/ammo_box/c338/incendiary,
	)

/obj/effect/spawner/random/contraband/c762x51
	name = "random 7.62x51mm ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c762x51,
		/obj/item/ammo_box/c762x51/ap,
		/obj/item/ammo_box/c762x51/hp,
		/obj/item/ammo_box/c762x51/incendiary,
		/obj/item/ammo_box/c762x51/rubber,
	)

/obj/effect/spawner/random/contraband/c223
	name = "random 5.56x45mm ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c223,
		/obj/item/ammo_box/c223/ap,
		/obj/item/ammo_box/c223/hp,
		/obj/item/ammo_box/c223/incendiary,
		/obj/item/ammo_box/c223/rubber,
	)

/obj/effect/spawner/random/contraband/c9mm
	name = "random 9mm ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c9mm,
		/obj/item/ammo_box/c9mm/ap,
		/obj/item/ammo_box/c9mm/hp,
		/obj/item/ammo_box/c9mm/incendiary,
		/obj/item/ammo_box/c9mm/rubber,
	)

/obj/effect/spawner/random/contraband/c10mm
	name = "random 10mm ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c10mm,
		/obj/item/ammo_box/c10mm/ap,
		/obj/item/ammo_box/c10mm/hp,
		/obj/item/ammo_box/c10mm/incendiary,
		/obj/item/ammo_box/c10mm/rubber,
	)

/obj/effect/spawner/random/contraband/c585sol
	name = "random .585 Sol ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c585sol,
		/obj/item/ammo_box/c585sol/ap,
		/obj/item/ammo_box/c585sol/hp,
		/obj/item/ammo_box/c585sol/incendiary,
		/obj/item/ammo_box/c585sol/rubber,
	)

/obj/effect/spawner/random/contraband/c45
	name = "random .45 ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c45,
		/obj/item/ammo_box/c45/ap,
		/obj/item/ammo_box/c45/hp,
		/obj/item/ammo_box/c45/incendiary,
		/obj/item/ammo_box/c45/rubber,
	)

/obj/effect/spawner/random/contraband/c38
	name = "random .38 ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c38,
		/obj/item/ammo_box/c38/ap,
		/obj/item/ammo_box/c38/hp,
		/obj/item/ammo_box/c38/hotshot,
		/obj/item/ammo_box/c38/iceblox,
		/obj/item/ammo_box/c38/rubber,
	)

/obj/effect/spawner/random/contraband/c35sol
	name = "random .35 Sol Short ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c35sol,
		/obj/item/ammo_box/c35sol/ap,
		/obj/item/ammo_box/c35sol/hp,
		/obj/item/ammo_box/c35sol/rubber,
	)

/obj/effect/spawner/random/contraband/c762x54mmr
	name = "random 7.62x54mmR ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c762x54mmr,
		/obj/item/ammo_box/c762x54mmr/ap,
		/obj/item/ammo_box/c762x54mmr/hp,
		/obj/item/ammo_box/c762x54mmr/incendiary,
		/obj/item/ammo_box/c762x54mmr/rubber,
	)

/obj/effect/spawner/random/contraband/c762x39
	name = "random 7.62x39mm ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c762x39,
		/obj/item/ammo_box/c762x39/ap,
		/obj/item/ammo_box/c762x39/civilian,
		/obj/item/ammo_box/c762x39/incendiary,
		/obj/item/ammo_box/c762x39/rubber,
		/obj/item/ammo_box/c762x39/ricochet,
		/obj/item/ammo_box/c762x39/blank,
		/obj/item/ammo_box/c762x39/hunting,
		/obj/item/ammo_box/c762x39/emp,
	)

/obj/effect/spawner/random/contraband/c40sol
	name = "random .40 Sol Long ammo box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c40sol,
		/obj/item/ammo_box/c40sol/ap,
		/obj/item/ammo_box/c40sol/fragmentation,
		/obj/item/ammo_box/c40sol/incendiary,
	)

/obj/effect/spawner/random/contraband/shotgun_shells
	name = "random shotgun shells box spawner"
	icon_state = "buckshot"
	spawn_loot_count = 1
	loot = list(
		/obj/item/ammo_box/c12ga/breacher,
		/obj/item/ammo_box/c12ga/beanbag,
		/obj/item/ammo_box/c12ga/incendiary,
		/obj/item/ammo_box/c12ga/rubbershot,
		/obj/item/ammo_box/c12ga/old,
	)

/obj/effect/spawner/random/contraband/renoster
	name = "random Renoster shotgun spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/shotgun/riot/renoster,
		/obj/item/gun/ballistic/shotgun/riot/renoster/sawoff,
	)

/obj/effect/spawner/random/contraband/amk
	name = "random AMK rifle spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/automatic/sabel/auto,
		/obj/item/gun/ballistic/automatic/sabel/auto/short,
		/obj/item/gun/ballistic/automatic/sabel/auto/army,
		/obj/item/gun/ballistic/automatic/sabel/auto/army/alt,
		/obj/item/gun/ballistic/automatic/sabel/auto/short/army,
	)

/obj/effect/spawner/random/contraband/carwo
	name = "random Carwo rifle spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/automatic/carwo/auto,
		/obj/item/gun/ballistic/automatic/carwo/auto/wooden,
		/obj/item/gun/ballistic/automatic/carwo/marksman/wooden,
		/obj/item/gun/ballistic/automatic/carwo/marksman,
	)

/obj/effect/spawner/random/contraband/wespe
	name = "random Wespe pistol spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol/wespe,
		/obj/item/gun/ballistic/automatic/pistol/wespe_civ,
	)

/obj/effect/spawner/random/contraband/eland
	name = "random Eland revolvers spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/revolver/eland,
		/obj/item/gun/ballistic/revolver/eland/army,
	)

/obj/effect/spawner/random/contraband/takbok
	name = "random Takbok revolvers spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/revolver/takbok,
		/obj/item/gun/ballistic/revolver/takbok/army,
	)

/obj/effect/spawner/random/contraband/bobr
	name = "random Bobr revolvers spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/revolver/bobr/empty,
		/obj/item/gun/ballistic/revolver/bobr/short/empty,
	)

/obj/effect/spawner/random/contraband/skild
	name = "random Skild pistol spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol/skild,
		/obj/item/gun/ballistic/automatic/pistol/skild/army,
	)

/obj/effect/spawner/random/contraband/sindano
	name = "random Sindano SMG spawner"
	icon_state = "shotgun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/ballistic/automatic/sindano,
		/obj/item/gun/ballistic/automatic/sindano/compact,
	)

/obj/effect/spawner/random/contraband/armory
	spawn_loot_count = 3
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol/contraband = 50,
		/obj/item/sledgehammer = 50,
		/obj/effect/spawner/random/contraband/bobr = 50,
		/obj/effect/spawner/random/contraband/eland = 50,
		/obj/effect/spawner/random/contraband/takbok = 30,
		/obj/effect/spawner/random/contraband/skild = 30,
		/obj/effect/spawner/random/contraband/wespe = 50,
		/obj/item/gun/ballistic/automatic/pistol/m1911/gold = 10,
		/obj/item/gun/ballistic/automatic/pistol/zashch = 50,
		/obj/item/gun/ballistic/shotgun/riot/m64 = 30,
		/obj/item/gun/ballistic/automatic/pistol/deagle/contraband = 10,
		/obj/item/gun/ballistic/revolver/mateba = 10,
		/obj/item/gun/ballistic/revolver/reverse/mateba = 1,
		/obj/item/gun/energy/laser/musket = 50,
		/obj/item/gun/energy/laser/musket/prime = 30,
		/obj/item/gun/energy/laser/musket/repeater = 30,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 30,
		/obj/effect/spawner/random/contraband/grenades = 50,
		/obj/effect/spawner/random/contraband/c46x30 = 30,
		/obj/effect/spawner/random/contraband/c10mm = 30,
		/obj/effect/spawner/random/contraband/c223 = 30,
		/obj/effect/spawner/random/contraband/c45 = 30,
		/obj/effect/spawner/random/contraband/c38 = 30,
		/obj/effect/spawner/random/contraband/c40sol = 30,
		/obj/effect/spawner/random/contraband/c762x54mmr = 30,
		/obj/effect/spawner/random/contraband/c585sol = 30,
		/obj/effect/spawner/random/contraband/c762x39 = 30,
		/obj/effect/spawner/random/contraband/c762x51 = 30,
		/obj/effect/spawner/random/contraband/shotgun_shells = 30,
		/obj/effect/spawner/random/armory/strilka = 30,
		/obj/effect/spawner/random/contraband/c35sol = 30,
		/obj/effect/spawner/random/sakhno = 30,
		/obj/effect/spawner/random/sakhno/ammo = 30,
		/obj/effect/spawner/random/contraband/amk = 30,
		/obj/effect/spawner/random/contraband/carwo = 30,
		/obj/effect/spawner/random/contraband/renoster = 30,
		/obj/effect/spawner/random/contraband/sindano = 30,
	)
