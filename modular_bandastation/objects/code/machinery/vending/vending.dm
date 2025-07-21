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
	name = "\improper NT Ammunition - Light Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор средства для подавления беспорядков и нелетального задержания."
	product_ads = "Круши черепа синдиката!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снярядись на задание!"
	vend_reply = "Слава Нанотрейзен!"

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/shotgun/riot = 8,
				/obj/item/gun/energy/disabler = 8,
				/obj/item/gun/energy/disabler/smg = 1,
				/obj/item/gun/energy/e_gun/mini = 8,
				/obj/item/gun/energy/e_gun/nuclear = 3,
				/obj/item/gun/energy/ionrifle/carbine = 2,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/storage/box/rubbershot = 10,
				/obj/item/storage/box/beanbag = 10,
				/obj/item/storage/box/breacherslug = 3,
				/obj/item/grenade/chem_grenade/teargas = 7,
				/obj/item/grenade/flashbang = 7,
				/obj/item/grenade/barrier = 7,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/melee/baton = 5,
				/obj/item/melee/baton/security/loaded = 3,
				/obj/item/melee/curator_whip = 1,
				/obj/item/clothing/head/helmet/swat/nanotrasen = 8,
				/obj/item/clothing/head/helmet/toggleable/riot = 3,
				/obj/item/clothing/suit/armor/vest/blueshirt = 5,
				/obj/item/clothing/suit/armor/riot = 3,
				/obj/item/clothing/suit/armor/swat = 1,
				/obj/item/shield/riot = 5,
				/obj/item/shield/riot/tele = 3,
				/obj/item/shield/riot/flash = 2,
				/obj/item/clothing/mask/gas/sechailer/swat/spacepol = 8,
				/obj/item/clothing/glasses/hud/security/sunglasses = 8,
				/obj/item/clothing/gloves/tackler/combat/insulated = 8,
				/obj/item/storage/belt/bandolier = 3,
				/obj/item/storage/backpack/ert/security = 8,
				/obj/item/storage/belt/military = 8,
				/obj/item/storage/belt/holster = 3,
				/obj/item/flashlight/seclite = 8,
				/obj/item/clothing/accessory/armband/deputy = 8,
				/obj/item/restraints/handcuffs = 12,
			),
		),
	)

// Heavy Gear
/obj/machinery/vending/nta/heavy
	name = "\improper NT Ammunition - Heavy Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор штурмовое снаряжение и средства для проведения сложных боевых операций."
	product_ads = "Круши черепа синдиката!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снярядись на задание!"
	vend_reply = "Слава Нанотрейзен!"
	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/shotgun/lethal = 5,
				/obj/item/gun/energy/e_gun/lethal = 5,
				/obj/item/gun/energy/e_gun/stun = 1,
				/obj/item/gun/energy/e_gun/mini = 5,
				/obj/item/gun/ballistic/automatic/laser = 4,
				/obj/item/gun/energy/laser/carbine = 1,
				/obj/item/gun/energy/ionrifle = 1,
				/obj/item/gun/ballistic/automatic/proto/unrestricted = 2,
				/obj/item/gun/ballistic/automatic/wt550 = 3,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/storage/box/rubbershot = 8,
				/obj/item/storage/box/lethalshot = 8,
				/obj/item/storage/box/breacherslug = 4,
				/obj/item/ammo_box/magazine/recharge = 10,
				/obj/item/ammo_box/magazine/smgm9mm = 10,
				/obj/item/ammo_box/magazine/smgm9mm/ap = 4,
				/obj/item/ammo_box/magazine/wt550m9 = 10,
				/obj/item/ammo_box/magazine/wt550m9/wtap = 4,
				/obj/item/grenade/chem_grenade/teargas = 7,
				/obj/item/grenade/flashbang = 7,
				/obj/item/grenade/barrier = 7,
				/obj/item/grenade/frag = 3,
				/obj/item/grenade/chem_grenade/incendiary = 2,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/melee/baton/security/loaded = 5,
				/obj/item/clothing/head/helmet/toggleable/riot = 8,
				/obj/item/clothing/suit/armor/riot = 5,
				/obj/item/clothing/suit/armor/swat = 3,
				/obj/item/shield/riot/tele = 5,
				/obj/item/shield/riot/flash = 3,
				/obj/item/clothing/mask/gas/sechailer/swat/spacepol = 8,
				/obj/item/clothing/glasses/hud/security/sunglasses = 8,
				/obj/item/clothing/gloves/tackler/combat/insulated = 8,
				/obj/item/storage/belt/bandolier = 3,
				/obj/item/storage/backpack/ert/security = 8,
				/obj/item/mod/control/pre_equipped/responsory/security = 5,
				/obj/item/mod/control/pre_equipped/responsory/commander = 1,
				/obj/item/mod/control/pre_equipped/responsory/medic = 1,
				/obj/item/mod/control/pre_equipped/responsory/engineer = 1,
				/obj/item/storage/belt/military/assault = 8,
				/obj/item/storage/belt/holster = 4,
				/obj/item/flashlight/seclite = 8,
				/obj/item/clothing/accessory/armband/deputy = 8,
				/obj/item/restraints/handcuffs = 12,
			),
		),

		list(
			"name" = "Medical",
			"icon" = "briefcase",
			"products" = list(
				/obj/item/storage/medkit/advanced = 3,
				/obj/item/storage/medkit/o2 = 3,
				/obj/item/storage/medkit/toxin = 3,
				/obj/item/defibrillator/compact/combat/loaded/nanotrasen = 1,
				/obj/item/storage/pill_bottle/stimulant = 1,
				/obj/item/storage/medkit/surgery = 1,
			),
		),
	)
