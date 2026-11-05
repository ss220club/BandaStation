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

/obj/effect/spawner/random/wild_west_fauna
	spawn_loot_chance = 65
	loot = list(
		/mob/living/basic/faithless/wild_west = 30,
		/mob/living/basic/creature/wild_west = 20,
		/mob/living/basic/migo/wild_west = 10,
	)

/obj/effect/spawner/random/book
	name = "random library book"
	icon_state = "book"

/obj/effect/spawner/random/book/spawn_loot(spawn_loc, type_path_to_make)
	create_random_books(amount = spawn_loot_count, location = loc, category = BOOK_CATEGORY_RANDOM)

/obj/effect/spawner/random/food_common
	name = "random common food"
	loot = list(
		/obj/effect/spawner/random/food_or_drink/booze,
		/obj/effect/spawner/random/food_or_drink/condiment,
		/obj/effect/spawner/random/food_or_drink/donkpockets_single,
		/obj/effect/spawner/random/food_or_drink/donuts,
		/obj/effect/spawner/random/food_or_drink/snack,
		/obj/effect/spawner/random/food_or_drink/snack/lizard,
	)

/obj/effect/spawner/random/food_uncommon
	name = "random uncommon food"
	loot = list(
		/obj/effect/spawner/random/food_or_drink/dinner,
		/obj/effect/spawner/random/food_or_drink/donkpockets,
		/obj/effect/spawner/random/food_or_drink/jelly_donuts,
		/obj/effect/spawner/random/food_or_drink/refreshing_beverage,
		/obj/effect/spawner/random/food_or_drink/salad,
		/obj/effect/spawner/random/food_or_drink/soup,
	)

/obj/effect/spawner/random/food_rare
	name = "random rare food"
	loot = list(
		/obj/effect/spawner/random/food_or_drink/pizzaparty,
		/obj/effect/spawner/random/food_or_drink/slime_jelly_donuts,
		/obj/effect/spawner/random/food_or_drink/three_course_meal,
		/obj/item/food/baguette/combat,
		/obj/item/food/croissant/throwing,
	)

/obj/effect/spawner/random/food_mixed
	name = "random mixed food"
	loot = list(
		/obj/effect/spawner/random/food_common = 90,
		/obj/effect/spawner/random/food_uncommon = 9,
		/obj/effect/spawner/random/food_rare = 1,
	)

/obj/effect/spawner/random/cult
	name = "random cult item"
	loot = list(
		/obj/item/shield/mirror,
		/obj/item/melee/cultblade,
		/obj/item/sharpener/cult,
		/obj/item/clothing/suit/hooded/cultrobes,
		/obj/item/reagent_containers/cup/beaker/unholywater,
		/obj/item/soulstone/anybody,
	)

/obj/effect/spawner/random/cult/valuable
	name = "random valuable cult item"
	loot = list(
		/obj/item/book_of_babel,
		/obj/item/nullrod/armblade,
		/obj/item/nullrod/claymore/talking,
		/obj/item/organ/heart/cursed/wizard,
		/obj/item/reagent_containers/cup/beaker/unholywater,
		/obj/item/shared_storage/red,
		/obj/item/soulstone/anybody,
	)

/// Loot schema: costumes, toys, useless gimmick items
/obj/effect/spawner/random/syndicate/common
	name = "syndicate loot, common"
	loot = list(
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/shoes/magboots/syndie,
		/obj/item/clothing/suit/jacket/leather/armored,
		/obj/item/clothing/suit/jacket/letterman_syndie,
		/obj/item/clothing/under/syndicate/combat,
		/obj/item/clothing/under/syndicate/sniper,
		/obj/item/coin/antagtoken,
		/obj/item/soap/syndie,
		/obj/item/stamp/chameleon,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/suppressor,
		/obj/item/toy/balloon/syndicate,
		/obj/item/toy/cards/deck/syndicate,
	)

/// Basic stealth, utility and environmental gear
/obj/effect/spawner/random/syndicate/rare
	name = "syndicate loot, rare"
	loot = list(
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/camera/flash,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/clothing/shoes/magboots/syndie,
		/obj/item/disk/computer/syndicate/camera_app,
		/obj/item/gun/ballistic/automatic/pistol/toy/riot,
		/obj/item/mod/module/chameleon,
		/obj/item/mod/module/holster,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/plate_compression,
		/obj/item/mod/module/visor/night,
		/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor,
		/obj/item/stamp/chameleon,
		/obj/item/storage/backpack/duffelbag/syndie/surgery,
		/obj/item/storage/backpack/satchel/flat,
		/obj/item/storage/belt/military,
		/obj/item/storage/box/syndie_kit/chameleon,
		/obj/item/storage/box/syndie_kit/space,
		/obj/item/storage/briefcase/secure/syndie,
	)

/// Primarily utility items with occasional low damage weaponry
/obj/effect/spawner/random/syndicate/officer
	name = "syndicate loot, officer"
	loot = list(
		/obj/item/borg/upgrade/syndicate,
		/obj/item/clothing/glasses/hud/security/chameleon,
		/obj/item/clothing/glasses/thermal,
		/obj/item/encryptionkey/binary,
		/obj/item/jammer,
		/obj/item/mod/control/pre_equipped/traitor,
		/obj/item/mod/module/power_kick,
		/obj/item/mod/module/visor/thermal,
		/obj/item/pen/edagger,
		/obj/item/storage/box/pinpointer_pairs,
		/obj/item/storage/toolbox/guncase/traitor,
	)

/// Combat orientated items that could give the player an advantage if an antag messes with them
/obj/effect/spawner/random/syndicate/armory
	name = "syndicate loot, armory"
	loot = list(
		/obj/item/chameleon,
		/obj/item/gun/medbeam,
		/obj/item/melee/energy/sword/saber,
		/obj/item/mod/control/pre_equipped/traitor_elite,
		/obj/item/mod/module/stealth,
		/obj/item/reagent_containers/hypospray/medipen/stimulants,
		/obj/item/shield/energy,
	)

/obj/effect/spawner/random/syndicate/mixed
	loot = list(
		/obj/effect/spawner/random/syndicate/common = 30,
		/obj/effect/spawner/random/syndicate/rare = 20,
		/obj/effect/spawner/random/syndicate/officer = 5,
		/obj/effect/spawner/random/syndicate/armory,
	)

/obj/effect/spawner/random/syndicate/common_rare
	loot = list(
		/obj/effect/spawner/random/syndicate/common = 3,
		/obj/effect/spawner/random/syndicate/rare = 2,
	)

/obj/effect/spawner/random/syndicate/mob
	icon_state = "showcase"
	loot = list(
		/obj/effect/spawner/random/syndicate/mob/common = 80,
		/obj/effect/spawner/random/syndicate/mob/modsuit = 19,
		/obj/effect/spawner/random/syndicate/mob/elite,
	)

/obj/effect/spawner/random/syndicate/mob/common
	loot = list(
		/mob/living/basic/trooper/syndicate/ranged = 4,
		/mob/living/basic/trooper/syndicate/melee = 3,
		/mob/living/basic/trooper/syndicate/melee/sword,
	)

// Used when we want our mob to be protected from environment pressure
/obj/effect/spawner/random/syndicate/mob/modsuit
	loot = list(
		/mob/living/basic/trooper/syndicate/melee/sword/space,
		/mob/living/basic/trooper/syndicate/ranged/smg/space,
	)

/obj/effect/spawner/random/syndicate/mob/elite
	loot = list(/mob/living/basic/trooper/syndicate/space/stormtrooper)

/obj/effect/spawner/random/wish_granter
	loot = list(
		/obj/item/dice/d20/fate/one_use,
		/obj/structure/wish_granter,
	)

/obj/effect/spawner/random/mining_tool
	loot = list(
		list(
			/obj/item/pickaxe = 7,
			/obj/item/pickaxe/emergency = 7,
			/obj/item/pickaxe/mini = 7,
		) = 21,
		/obj/item/gun/energy/plasmacutter = 5,
		/obj/item/gun/energy/plasmacutter/adv = 3,
		/obj/item/gun/energy/recharge/kinetic_accelerator = 3,
		/obj/item/kinetic_crusher = 3,
		/obj/item/pickaxe/diamond = 7,
		/obj/item/pickaxe/drill = 15,
		/obj/item/pickaxe/drill/diamonddrill = 5,
		/obj/item/pickaxe/drill/jackhammer = 3,
		/obj/item/pickaxe/silver = 10,
	)
