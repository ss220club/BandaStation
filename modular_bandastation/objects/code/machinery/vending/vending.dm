//MARK: Vending Machines

// Robotics Wardrobe
/obj/machinery/vending/wardrobe/robo_wardrobe
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "robodrobe"
	panel_type = "panel19"
	light_mask = null

/obj/machinery/vending/wardrobe/robo_wardrobe/build_inventories(start_empty)
	products |= list(
		/obj/item/clothing/head/beret = 2,
		/obj/item/clothing/head/cowboy/roboticist = 2,
		/obj/item/clothing/head/soft/roboticist_cap = 2,
		/obj/item/clothing/suit/hooded/roboticist_cloak = 2,
		/obj/item/clothing/suit/toggle/jacket/roboticist = 2,
		/obj/item/clothing/suit/hooded/wintercoat/science/robotics/alt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/red = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/hoodie = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/skirt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/skirt/red = 2,
		/obj/item/clothing/suit/jacket/bomber/roboticist =2,
		)
	. = ..()

// CentCom NT Ammunition
/obj/machinery/vending/nta
	name = "\improper NT Ammunition"
	desc = "A special equipment vendor."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Если ты увидел меня - сообщи разработчикам!"
	vend_reply = "Не нужно меня использовать, скорее сообщи разработчикам!"
	onstation = FALSE
	all_products_free = TRUE
	products = list(
		/obj/item/toy/plush/moth = 1
	)
	refill_canister = /obj/item/vending_refill/nta

/obj/item/vending_refill/nta
	machine_name = "NT Ammunition"
	icon = 'modular_bandastation/objects/icons/obj/machines/vending_restock.dmi'
	icon_state = "refill_nta"
	light_color = LIGHT_COLOR_BLUE

// Light Gear
/obj/machinery/vending/nta/light
	name = "\improper NT Ammunition - Amber ERT Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор средства для подавления беспорядков и нелетального задержания."
	product_ads = "Круши черепа синдиката!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снарядись на задание!"
	vend_reply = "Слава Нанотрейзен!"

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol/gp9 = 5,
				/obj/item/gun/ballistic/automatic/pistol/cm23 = 2,
				/obj/item/gun/ballistic/automatic/battle_rifle = 1,
				/obj/item/gun/ballistic/automatic/wt550 = 1,
				/obj/item/gun/ballistic/shotgun/riot = 5,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 1,
				/obj/item/gun/energy/disabler = 8,
				/obj/item/gun/energy/disabler/smg = 5,
				/obj/item/gun/energy/e_gun = 5,
				/obj/item/gun/energy/laser = 5,
				/obj/item/gun/energy/laser/carbine = 5,
				/obj/item/gun/energy/laser/pistol = 5,
				/obj/item/gun/energy/ionrifle = 2,
				/obj/item/gun/energy/e_gun/dragnet = 5,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/c12ga/beanbag = 10,
				/obj/item/ammo_box/c12ga/rubbershot = 10,
				/obj/item/ammo_box/c12ga/breacher = 3,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber = 10,
				/obj/item/ammo_box/magazine/c9x25mm_pistol = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber = 2,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = 2,
				/obj/item/ammo_box/magazine/c38/rubber = 5,
				/obj/item/ammo_box/magazine/c38 = 5,
				/obj/item/ammo_box/magazine/m38 = 5,
				/obj/item/ammo_box/magazine/wt550m9/wtrubber = 2,
				/obj/item/ammo_box/magazine/wt550m9 = 2,
				/obj/item/ammo_box/c9x25mm/rubber = 3,
				/obj/item/ammo_box/c9x25mm = 3,
				/obj/item/ammo_box/c38/rubber = 2,
				/obj/item/ammo_box/c38 = 2,
				/obj/item/ammo_box/c46x30/rubber = 2,
				/obj/item/ammo_box/c46x30 = 2,
				/obj/item/grenade/chem_grenade/teargas = 7,
				/obj/item/grenade/flashbang = 7,
				/obj/item/grenade/stingbang = 5,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/melee/baton = 3,
				/obj/item/melee/baton/security/loaded = 8,
				/obj/item/clothing/head/helmet/swat/nanotrasen = 8,
				/obj/item/clothing/suit/armor/swat/ert = 8,
				/obj/item/clothing/glasses/hud/security/sunglasses = 8,
				/obj/item/clothing/gloves/tackler/combat/insulated = 5,
				/obj/item/storage/backpack/ert/security = 8,
				/obj/item/mod/control/pre_equipped/safeguard = 5,
				/obj/item/storage/belt/bandolier = 3,
				/obj/item/storage/belt/military/ert = 8,
				/obj/item/shield/riot = 5,
				/obj/item/shield/riot/tele = 3,
				/obj/item/shield/riot/flash = 3,
				/obj/item/flashlight/seclite = 8,
				/obj/item/restraints/handcuffs = 20,
				/obj/item/restraints/legcuffs/bola/energy = 10,
			),
		),

		list(
			"name" = "Medical",
			"icon" = "briefcase",
			"products" = list(
				/obj/item/storage/medkit/regular = 5,
				/obj/item/storage/medkit/o2 = 3,
				/obj/item/storage/medkit/toxin = 3,
				/obj/item/storage/medkit/brute = 3,
				/obj/item/storage/medkit/fire = 3,
				/obj/item/storage/medkit/surgery = 1,
				/obj/item/stack/medical/wrap/gauze = 3,
				/obj/item/stack/medical/suture = 3,
				/obj/item/stack/medical/mesh = 3,
			),
		),
	)

// Red ERT Gear
/obj/machinery/vending/nta/medium
	name = "\improper NT Ammunition - Red ERT Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор штурмовое снаряжение и средства для нелетального задержания."
	product_ads = "Круши черепа синдиката!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снарядись на задание!"
	vend_reply = "Слава Нанотрейзен!"

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol/gp9/spec = 5,
				/obj/item/gun/ballistic/automatic/pistol/cm70 = 3,
				/obj/item/gun/ballistic/automatic/pistol/cm23 = 3,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
				/obj/item/gun/ballistic/shotgun/automatic/combat/compact = 1,
				/obj/item/gun/ballistic/automatic/cm5 = 3,
				/obj/item/gun/ballistic/automatic/wt550 = 1,
				/obj/item/gun/ballistic/automatic/battle_rifle/auto = 1,
				/obj/item/gun/ballistic/automatic/laser = 2,
				/obj/item/gun/energy/laser/assault = 2,
				/obj/item/gun/energy/e_gun/nuclear = 1,
				/obj/item/gun/energy/laser/hellgun = 1,
				/obj/item/gun/energy/laser/scatter = 1,
				/obj/item/gun/energy/lasercannon = 1,
				/obj/item/gun/energy/ionrifle/carbine = 2,
				/obj/item/gun/grenadelauncher = 1,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/c12ga/beanbag = 5,
				/obj/item/ammo_box/c12ga/rubbershot = 5,
				/obj/item/ammo_box/c12ga = 1,
				/obj/item/ammo_box/c12ga/slug = 1,
				/obj/item/ammo_box/c12ga/flechette = 2,
				/obj/item/ammo_box/c12ga/breacher = 2,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/hp = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap = 5,
				/obj/item/ammo_box/magazine/c45 = 10,
				/obj/item/ammo_box/magazine/c45/rubber = 10,
				/obj/item/ammo_box/magazine/c45/hp = 5,
				/obj/item/ammo_box/magazine/c45/ap = 5,
				/obj/item/ammo_box/magazine/c45/incendiary = 5,
				/obj/item/ammo_box/magazine/cm5 = 10,
				/obj/item/ammo_box/magazine/cm5/rubber = 10,
				/obj/item/ammo_box/magazine/cm5/ap = 5,
				/obj/item/ammo_box/magazine/cm5/hp = 5,
				/obj/item/ammo_box/magazine/wt550m9 = 5,
				/obj/item/ammo_box/magazine/wt550m9/wtrubber = 5,
				/obj/item/ammo_box/magazine/wt550m9/wtap = 5,
				/obj/item/ammo_box/magazine/wt550m9/wtic = 5,
				/obj/item/ammo_box/magazine/m38 = 5,
				/obj/item/ammo_box/magazine/m38/dumdum = 5,
				/obj/item/ammo_box/magazine/m38/flare = 5,
				/obj/item/ammo_box/magazine/m38/iceblox = 5,
				/obj/item/ammo_box/magazine/m38/hotshot = 5,
				/obj/item/ammo_box/magazine/m38/true = 5,
				/obj/item/ammo_box/magazine/c38 = 5,
				/obj/item/ammo_box/magazine/c38/hp = 5,
				/obj/item/ammo_box/magazine/c38/ap = 5,
				/obj/item/ammo_box/magazine/c38/iceblox = 5,
				/obj/item/ammo_box/magazine/c38/hotshot = 5,
				/obj/item/ammo_box/magazine/c38/true = 5,
				/obj/item/ammo_box/magazine/recharge = 10,
				/obj/item/ammo_box/c9x25mm/rubber = 5,
				/obj/item/ammo_box/c9x25mm = 5,
				/obj/item/ammo_box/c9x25mm/ap = 3,
				/obj/item/ammo_box/c9x25mm/hp = 3,
				/obj/item/ammo_box/c38/rubber = 5,
				/obj/item/ammo_box/c38 = 5,
				/obj/item/ammo_box/c38/ap = 3,
				/obj/item/ammo_box/c38/hp = 3,
				/obj/item/ammo_box/c38/hotshot = 3,
				/obj/item/ammo_box/c38/iceblox = 3,
				/obj/item/ammo_box/c46x30/rubber = 2,
				/obj/item/ammo_box/c46x30 = 2,
				/obj/item/ammo_box/c46x30/ap = 2,
				/obj/item/ammo_box/c46x30/incendiary = 2,
				/obj/item/ammo_box/c45/rubber = 5,
				/obj/item/ammo_box/c45 = 5,
				/obj/item/ammo_box/c45/ap = 3,
				/obj/item/ammo_box/c45/hp = 3,
				/obj/item/grenade/c4 = 2,
				/obj/item/grenade/chem_grenade/teargas = 7,
				/obj/item/grenade/smokebomb = 5,
				/obj/item/grenade/flashbang = 10,
				/obj/item/grenade/stingbang = 5,
				/obj/item/grenade/barrier = 7,
				/obj/item/grenade/mirage = 5,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/knife/combat = 5,
				/obj/item/melee/baton/security/loaded/hos = 10,
				/obj/item/sledgehammer/tactical = 1,
				/obj/item/clothing/head/helmet/marine = 8,
				/obj/item/clothing/suit/armor/vest/marine = 8,
				/obj/item/clothing/head/helmet/marine/pmc = 8,
				/obj/item/clothing/suit/armor/vest/marine/pmc = 8,
				/obj/item/clothing/gloves/tackler/combat/insulated = 8,
				/obj/item/storage/backpack/ert/security = 8,
				/obj/item/mod/control/pre_equipped/safeguard = 5,
				/obj/item/storage/belt/bandolier = 3,
				/obj/item/storage/belt/holster/ert = 5,
				/obj/item/storage/belt/military/army = 8,
				/obj/item/storage/belt/military/assault/ert = 5,
				/obj/item/shield/riot/tele = 5,
				/obj/item/shield/riot/flash = 5,
				/obj/item/flashlight/seclite = 8,
				/obj/item/restraints/handcuffs = 20,
				/obj/item/restraints/legcuffs/bola/energy = 10,
				/obj/item/restraints/legcuffs/bola/tactical = 5,
			),
		),

		list(
			"name" = "Medical",
			"icon" = "briefcase",
			"products" = list(
				/obj/item/storage/medkit/advanced = 2,
				/obj/item/storage/medkit/o2 = 2,
				/obj/item/storage/medkit/toxin = 2,
				/obj/item/storage/medkit/tactical_lite = 2,
				/obj/item/reagent_containers/hypospray/combat = 1,
				/obj/item/reagent_containers/medigel/aiuri = 3,
				/obj/item/reagent_containers/medigel/libital = 3,
			),
		),
	)

// Heavy Gear
/obj/machinery/vending/nta/heavy
	name = "\improper NT Ammunition - Gamma ERT Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор штурмовое снаряжение и средства для проведения сложных боевых операций."
	product_ads = "Круши черепа синдиката!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снарядись на задание!"
	vend_reply = "Слава Нанотрейзен!"
	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol/cm70 = 3,
				/obj/item/gun/ballistic/automatic/pistol/cm357 = 1,
				/obj/item/gun/ballistic/automatic/cm5/compact = 3,
				/obj/item/gun/ballistic/automatic/proto/unrestricted = 3,
				/obj/item/gun/ballistic/shotgun/automatic/combat/compact = 5,
				/obj/item/gun/energy/e_gun/advtaser = 5,
				/obj/item/gun/energy/e_gun/nuclear = 5,
				/obj/item/gun/energy/e_gun/stun = 5,
				/obj/item/gun/energy/laser/assault = 5,
				/obj/item/gun/energy/laser/hellgun = 5,
				/obj/item/gun/energy/laser/xray = 2,
				/obj/item/gun/energy/laser/scatter = 2,
				/obj/item/gun/energy/laser/scatter/shotty = 2,
				/obj/item/gun/energy/lasercannon = 2,
				/obj/item/gun/energy/ionrifle/carbine = 3,
				/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted = 1,
				/obj/item/gun/grenadelauncher/tactical = 1,
				/obj/item/deployable_turret_folded = 1,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/c12ga/beanbag = 5,
				/obj/item/ammo_box/c12ga/rubbershot = 5,
				/obj/item/ammo_box/c12ga = 5,
				/obj/item/ammo_box/c12ga/slug = 5,
				/obj/item/ammo_box/c12ga/flechette = 2,
				/obj/item/ammo_box/c12ga/breacher = 2,
				/obj/item/ammo_box/c12ga/incendiary = 2,
				/obj/item/ammo_box/c12ga/dragonsbreath = 1,
				/obj/item/ammo_box/magazine/c45 = 10,
				/obj/item/ammo_box/magazine/c45/hp = 5,
				/obj/item/ammo_box/magazine/c45/ap = 5,
				/obj/item/ammo_box/magazine/c45/incendiary = 5,
				/obj/item/ammo_box/magazine/c357 = 3,
				/obj/item/ammo_box/magazine/recharge = 10,
				/obj/item/ammo_box/magazine/cm5 = 10,
				/obj/item/ammo_box/magazine/cm5/rubber = 10,
				/obj/item/ammo_box/magazine/cm5/ap = 5,
				/obj/item/ammo_box/magazine/cm5/hp = 5,
				/obj/item/ammo_box/magazine/smgm9mm = 10,
				/obj/item/ammo_box/magazine/smgm9mm/rubber = 10,
				/obj/item/ammo_box/magazine/smgm9mm/ap = 5,
				/obj/item/ammo_box/magazine/smgm9mm/hp = 5,
				/obj/item/ammo_box/magazine/smgm9mm/fire = 5,
				/obj/item/ammo_box/a40mm/rubber = 5,
				/obj/item/ammo_box/a40mm/tear_gas = 5,
				/obj/item/ammo_box/a40mm = 2,
				/obj/item/ammo_box/a40mm/flak = 1,
				/obj/item/ammo_box/a40mm/incendiary = 1,
				/obj/item/ammo_box/c9x25mm/rubber = 5,
				/obj/item/ammo_box/c9x25mm = 5,
				/obj/item/ammo_box/c9x25mm/ap = 3,
				/obj/item/ammo_box/c9x25mm/hp = 3,
				/obj/item/ammo_box/c45/rubber = 5,
				/obj/item/ammo_box/c45 = 5,
				/obj/item/ammo_box/c45/ap = 3,
				/obj/item/ammo_box/c45/hp = 3,
				/obj/item/ammo_box/c9mm/rubber = 5,
				/obj/item/ammo_box/c9mm = 5,
				/obj/item/ammo_box/c9mm/ap = 3,
				/obj/item/ammo_box/c9mm/hp = 3,
				/obj/item/ammo_box/c9mm/incendiary = 3,
				/obj/item/ammo_box/c357 = 2,
				/obj/item/grenade/c4 = 5,
				/obj/item/grenade/c4/x4 = 5,
				/obj/item/grenade/chem_grenade/teargas = 10,
				/obj/item/grenade/smokebomb = 10,
				/obj/item/grenade/flashbang = 10,
				/obj/item/grenade/stingbang = 10,
				/obj/item/grenade/barrier = 7,
				/obj/item/grenade/frag = 7,
				/obj/item/grenade/chem_grenade/incendiary = 7,
				/obj/item/grenade/gluon = 1,
				/obj/item/grenade/antigravity = 1,
				/obj/item/grenade/mirage = 5,
				/obj/item/grenade/empgrenade = 5,
				/obj/item/grenade/flashbang/cluster = 1,
				/obj/item/grenade/clusterbuster/smoke = 1,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/knife/combat = 5,
				/obj/item/melee/baton/security/loaded/ert = 10,
				/obj/item/melee/baton/security/stunsword/loaded = 1,
				/obj/item/melee/baton/security/electrostaff/loaded = 1,
				/obj/item/sledgehammer/syndie = 1,
				/obj/item/clothing/gloves/tackler/combat/insulated = 8,
				/obj/item/mod/control/pre_equipped/responsory/security = 5,
				/obj/item/storage/belt/holster/ert = 5,
				/obj/item/storage/belt/military/holster = 8,
				/obj/item/storage/belt/military/assault/ert = 8,
				/obj/item/shield/riot/tele = 5,
				/obj/item/shield/riot/flash = 5,
				/obj/item/flashlight/seclite = 8,
				/obj/item/restraints/handcuffs = 20,
				/obj/item/restraints/legcuffs/bola/energy = 10,
				/obj/item/restraints/legcuffs/bola/tactical = 5,
			),
		),

		list(
			"name" = "Medical",
			"icon" = "briefcase",
			"products" = list(
				/obj/item/storage/medkit/o2 = 2,
				/obj/item/storage/medkit/toxin = 2,
				/obj/item/storage/medkit/tactical = 2,
				/obj/item/storage/medkit/tactical/premium = 1,
				/obj/item/defibrillator/compact/combat/loaded/nanotrasen = 1,
				/obj/item/reagent_containers/hypospray/combat = 3,
				/obj/item/reagent_containers/hypospray/medipen/stimpack = 5,
				/obj/item/reagent_containers/medigel/synthflesh = 3,
				/obj/item/storage/pill_bottle/mannitol = 3,
				/obj/item/storage/pill_bottle/mutadone = 3,
			),
		),
	)

// Ultra-Heavy
/obj/machinery/vending/nta/ultra_heavy
	name = "\improper NT Ammunition - Heavy Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор тяжелое штурмовое снаряжение и средства для проведения особо сложных боевых операций."
	product_ads = "УНИЧТОЖЬ ПРОТИВНИКА!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снарядись на задание!"
	vend_reply = "Слава Нанотрейзен!"
	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol/cm357 = 5,
				/obj/item/gun/ballistic/automatic/proto/unrestricted = 5,
				/obj/item/gun/ballistic/automatic/cm5/compact = 5,
				/obj/item/gun/ballistic/automatic/cm82 = 5,
				/obj/item/gun/ballistic/automatic/ar = 5,
				/obj/item/gun/ballistic/automatic/f4 = 5,
				/obj/item/gun/ballistic/automatic/cm40 = 1,
				/obj/item/gun/ballistic/automatic/cm15 = 2,
				/obj/item/gun/ballistic/automatic/f90 = 1,
				/obj/item/gun/ballistic/rifle/sniper_rifle = 1,
				/obj/item/gun/ballistic/automatic/gyropistol = 1,
				/obj/item/gun/ballistic/rocketlauncher/nobackblast = 1,
				/obj/item/gun/ballistic/shotgun/china_lake = 1,
				/obj/item/gun/energy/pulse/pistol/loyalpin = 2,
				/obj/item/gun/energy/pulse/carbine/loyalpin = 2,
				/obj/item/gun/energy/pulse/loyalpin = 2,
				/obj/item/gun/energy/pulse/destroyer = 1,
				/obj/item/gun/energy/e_gun/nuclear = 5,
				/obj/item/gun/energy/laser/xray = 5,
				/obj/item/gun/energy/mindflayer = 2,
				/obj/item/gun/energy/laser/scatter = 5,
				/obj/item/gun/energy/laser/scatter/shotty = 5,
				/obj/item/gun/energy/lasercannon = 5,
				/obj/item/gun/energy/ionrifle/carbine = 5,
				/obj/item/gun/grenadelauncher/tactical = 1,
				/obj/item/deployable_turret_folded/full_auto = 1,
				/obj/item/mounted_machine_gun_folded/full_auto = 1,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/c12ga = 5,
				/obj/item/ammo_box/c12ga/slug = 5,
				/obj/item/ammo_box/c12ga/flechette = 2,
				/obj/item/ammo_box/c12ga/breacher = 2,
				/obj/item/ammo_box/c12ga/incendiary = 2,
				/obj/item/ammo_box/c12ga/dragonsbreath = 2,
				/obj/item/ammo_box/c12ga/executioner = 2,
				/obj/item/ammo_box/c12ga/frag12 = 2,
				/obj/item/ammo_box/magazine/c357 = 6,
				/obj/item/ammo_box/magazine/c357/match = 2,
				/obj/item/ammo_box/magazine/c357/ap = 1,
				/obj/item/ammo_box/magazine/c357/heartseeker = 2,
				/obj/item/ammo_box/magazine/smgm9mm = 10,
				/obj/item/ammo_box/magazine/smgm9mm/ap = 5,
				/obj/item/ammo_box/magazine/smgm9mm/hp = 5,
				/obj/item/ammo_box/magazine/smgm9mm/fire = 5,
				/obj/item/ammo_box/magazine/cm5 = 10,
				/obj/item/ammo_box/magazine/cm5/ap = 5,
				/obj/item/ammo_box/magazine/cm5/hp = 5,
				/obj/item/ammo_box/magazine/c762x51mm = 10,
				/obj/item/ammo_box/magazine/c762x51mm/rubber = 10,
				/obj/item/ammo_box/magazine/c762x51mm/ap = 5,
				/obj/item/ammo_box/magazine/c762x51mm/hp = 5,
				/obj/item/ammo_box/magazine/c762x51mm/incendiary = 5,
				/obj/item/ammo_box/magazine/c223 = 10,
				/obj/item/ammo_box/magazine/c223/rubber = 10,
				/obj/item/ammo_box/magazine/c223/ap = 5,
				/obj/item/ammo_box/magazine/c223/hp = 5,
				/obj/item/ammo_box/magazine/c223/incendiary = 5,
				/obj/item/ammo_box/magazine/c223/phasic = 1,
				/obj/item/ammo_box/magazine/cm15/rubbershot = 10,
				/obj/item/ammo_box/magazine/cm15/beanbag = 10,
				/obj/item/ammo_box/magazine/cm15 = 5,
				/obj/item/ammo_box/magazine/cm15/drum = 1,
				/obj/item/ammo_box/magazine/cm15/slug = 2,
				/obj/item/ammo_box/magazine/cm15/drum/slug = 1,
				/obj/item/ammo_box/magazine/cm15/flechette = 5,
				/obj/item/ammo_box/magazine/cm15/executioner = 2,
				/obj/item/ammo_box/magazine/cm15/dragonsbreath = 2,
				/obj/item/ammo_box/magazine/cm15/breacher = 2,
				/obj/item/ammo_box/magazine/cm15/frag12 = 2,
				/obj/item/ammo_box/magazine/c338/extended = 2,
				/obj/item/ammo_box/magazine/c338/extended/ap = 2,
				/obj/item/ammo_box/magazine/c338/extended/hp = 2,
				/obj/item/ammo_box/magazine/c338/extended/incendiary = 2,
				/obj/item/ammo_box/magazine/sniper_rounds = 2,
				/obj/item/ammo_box/magazine/sniper_rounds/incendiary = 1,
				/obj/item/ammo_box/magazine/sniper_rounds/marksman = 1,
				/obj/item/ammo_box/magazine/sniper_rounds/penetrator = 1,
				/obj/item/ammo_box/magazine/sniper_rounds/disruptor = 1,
				/obj/item/ammo_box/magazine/cm40 = 2,
				/obj/item/ammo_box/magazine/cm40/rubber = 2,
				/obj/item/ammo_box/magazine/cm40/ap = 1,
				/obj/item/ammo_box/magazine/cm40/hp = 1,
				/obj/item/ammo_box/magazine/cm40/incendiary = 1,
				/obj/item/ammo_box/magazine/m75 = 2,
				/obj/item/ammo_box/a40mm = 5,
				/obj/item/ammo_box/a40mm/flak = 5,
				/obj/item/ammo_box/a40mm/incendiary = 5,
				/obj/item/ammo_box/rocket = 2,
				/obj/item/ammo_box/c9x25mm = 5,
				/obj/item/ammo_box/c9x25mm/ap = 3,
				/obj/item/ammo_box/c9x25mm/hp = 3,
				/obj/item/ammo_box/c357 = 5,
				/obj/item/ammo_box/c357/heartseeker = 2,
				/obj/item/ammo_box/c357/match = 2,
				/obj/item/ammo_box/c45 = 5,
				/obj/item/ammo_box/c45/ap = 3,
				/obj/item/ammo_box/c45/hp = 3,
				/obj/item/ammo_box/c9mm = 5,
				/obj/item/ammo_box/c9mm/ap = 3,
				/obj/item/ammo_box/c9mm/hp = 3,
				/obj/item/ammo_box/c9mm/incendiary = 3,
				/obj/item/ammo_box/c223 = 5,
				/obj/item/ammo_box/c223/ap = 3,
				/obj/item/ammo_box/c223/hp = 3,
				/obj/item/ammo_box/c223/incendiary = 3,
				/obj/item/ammo_box/c223/rubber = 3,
				/obj/item/ammo_box/c338 = 1,
				/obj/item/ammo_box/c338/ap = 2,
				/obj/item/ammo_box/c338/hp = 2,
				/obj/item/ammo_box/c338/incendiary = 2,
				/obj/item/ammo_box/c50 = 2,
				/obj/item/ammo_box/c50/disruptor = 2,
				/obj/item/ammo_box/c50/penetrator = 2,
				/obj/item/ammo_box/c50/incendiary = 2,
				/obj/item/ammo_box/c762x51 = 5,
				/obj/item/ammo_box/c762x51/ap = 3,
				/obj/item/ammo_box/c762x51/hp = 3,
				/obj/item/ammo_box/c762x51/incendiary = 3,
				/obj/item/grenade/frag = 10,
				/obj/item/grenade/c4/x4 = 10,
				/obj/item/grenade/smokebomb = 10,
				/obj/item/grenade/mirage = 5,
				/obj/item/grenade/gluon = 5,
				/obj/item/grenade/antigravity = 5,
				/obj/item/grenade/empgrenade = 5,
				/obj/item/grenade/chem_grenade/incendiary = 10,
				/obj/item/grenade/chem_grenade/clf3 = 3,
				/obj/item/grenade/clusterbuster/inferno = 2,
				/obj/item/grenade/clusterbuster/clf3 = 1,
				/obj/item/grenade/clusterbuster/smoke = 5,
				/obj/item/grenade/clusterbuster/emp = 2,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/melee/curator_whip = 2,
				/obj/item/melee/baton/nunchaku = 2,
				/obj/item/melee/baton/security/loaded/ert = 10,
				/obj/item/melee/baton/security/stunsword/loaded = 10,
				/obj/item/melee/baton/security/electrostaff/loaded = 10,
				/obj/item/melee/energy/sword = 10,
				/obj/item/sledgehammer/syndie = 2,
				/obj/item/mod/control/pre_equipped/responsory/commander = 5,
				/obj/item/clothing/accessory/holster/tacticool = 5,
				/obj/item/storage/belt/military/holster = 8,
				/obj/item/storage/belt/military/assault/ert = 8,
				/obj/item/shield/riot/tele = 5,
				/obj/item/shield/riot/flash = 5,
				/obj/item/flashlight/seclite = 8,
				/obj/item/restraints/legcuffs/bola/tactical = 10,
			),
		),

		list(
			"name" = "Medical",
			"icon" = "briefcase",
			"products" = list(
				/obj/item/storage/medkit/tactical = 5,
				/obj/item/storage/medkit/tactical/premium = 5,
				/obj/item/defibrillator/compact/combat/loaded/nanotrasen = 2,
				/obj/item/reagent_containers/hypospray/combat/nanites = 1,
				/obj/item/reagent_containers/hypospray/combat/heresypurge = 1,
				/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor = 5,
				/obj/item/reagent_containers/medigel/synthflesh = 3,
				/obj/item/storage/pill_bottle/mannitol = 3,
				/obj/item/storage/pill_bottle/mutadone = 3,
			),
		),
	)

// Clothing vendors
/obj/machinery/vending/autodrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/ratge = 1,
		)
	. = ..()

/obj/machinery/vending/wardrobe/chef_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/rank/civilian/chef/red = 2,
		/obj/item/clothing/suit/chef/red = 2,
		/obj/item/clothing/head/chefhat/red = 2,
		/obj/item/clothing/suit/apron/chef/red = 1,
		)
	. = ..()

/obj/machinery/vending/wardrobe/sec_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/cowboy/security = 3,
		/obj/item/clothing/head/soft/sec/corporate = 3,
		/obj/item/clothing/under/security/formal = 3,
		/obj/item/clothing/under/security/black = 3,
		/obj/item/clothing/under/security/alternative_black = 3,
		/obj/item/clothing/head/sec_beanie = 3,
		/obj/item/clothing/neck/cloak/sec_poncho = 3,
		/obj/item/clothing/under/rank/security/officer/corporate = 3,
		/obj/item/clothing/under/rank/security/officer/skirt/corporate = 3,
		/obj/item/clothing/under/security/alt_skirt = 3,
		/obj/item/clothing/suit/armor/vest/bomber = 3,
		/obj/item/clothing/suit/armor/vest/coat = 3,
		/obj/item/clothing/suit/armor/vest/caftan = 3,
		/obj/item/clothing/under/security/turtleneck = 3,
		)
	. = ..()

/obj/machinery/vending/wardrobe/science_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/cowboy/science = 3,
		/obj/item/clothing/suit/jacket/bomber/science = 3,
		/obj/item/clothing/neck/cloak/sci_mantle = 3,
		/obj/item/clothing/under/scientist/utility = 3,
		)
	. = ..()

/obj/machinery/vending/wardrobe/engi_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/engineering/telecomm = 3,
		/obj/item/clothing/under/engineering/telecomm/skirt = 3,
		/obj/item/clothing/under/engineering/mechanic = 3,
		)
	. = ..()

/obj/machinery/vending/wardrobe/medi_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/medical/paramed_light = 3,
		/obj/item/clothing/under/medical/paramed_light/skirt = 3,
		)
	. = ..()
