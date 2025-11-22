// MARK: TSF
/obj/item/storage/belt/military/army/tsf
	icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
	icon_state = "military_holster"
	storage_type = /datum/storage/military_belt/tsf

/datum/storage/military_belt/tsf
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_SMALL * 8
	max_slots = 10

/obj/item/storage/belt/military/army/tsf/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_submachine/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_rifle_short/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/pierce(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_rifle_standart/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard/pierce(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_engineer/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_machinegun/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/box(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/box/pierce(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_infiltrator/PopulateContents()
	new /obj/item/gun/ballistic/automatic/sindano/compact/suppressed(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard/pierce(src)

/obj/item/storage/belt/holster/detective/full/ert/tsf_commander
	name = "TSF commander's holster"
	desc = "Wearing this makes you feel badass."

/obj/item/storage/belt/holster/detective/full/ert/tsf_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/r10mm = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle/regal = 1,
	),src)

// MARK: USSP
/obj/item/storage/belt/military/army/ussp
	icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt.dmi'
	icon_state = "ussp_belt"
	inhand_icon_state = "utility"
	worn_icon_state = "ussp_belt"
	storage_type = /datum/storage/military_belt/ussp

/datum/storage/military_belt/ussp
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_SMALL * 8
	max_slots = 10

/obj/item/storage/belt/military/army/ussp/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_rifle_small/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_rifle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_autorifle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_autorifle_spetsnaz/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/emp(src)

/obj/item/storage/belt/military/army/ussp/full_engineer/PopulateContents()
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/ammo_box/speedloader/strilka310(src)
	new /obj/item/knife/combat(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/stack/sheet/mineral/sandbags/thirty(src)

/obj/item/storage/belt/military/army/ussp/full_infiltrator/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/suppressed(src)
	new /obj/item/ammo_box/magazine/m9mm/ap(src)
	new /obj/item/ammo_box/magazine/m9mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/emp(src)
	new /obj/item/knife/combat(src)

/obj/item/stack/sheet/mineral/sandbags/thirty
	amount = 30

/obj/item/storage/belt/holster/detective/full/ert/ussp_commander
	name = "USSP commander's holster"
	desc = "Wearing this makes you feel comrade."
	icon_state = "holster"

/obj/item/storage/belt/holster/detective/full/ert/ussp_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/n762_cylinder = 2,
		/obj/item/gun/ballistic/revolver/nagant = 1,
	),src)

// MARK: ERT
/obj/item/storage/belt/security/webbing/ert
	name = "ERT security webbing"
	desc = "Тактическая разгрузка для снаряжения СБ, используемая отрядами быстрого реагирования."

/obj/item/storage/belt/security/webbing/ert/full/PopulateContents()
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/grenade/chem_grenade/teargas(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/melee/baton/security/loaded(src)

/obj/item/storage/belt/military/ert
	name = "ERT assault webbing"
	desc = "Тактическая штурмовая разгрузка, используемая отрядами быстрого реагирования."

/obj/item/storage/belt/military/ert/full_gamma_security/PopulateContents()
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/grenade/chem_grenade/teargas(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/grenade/frag(src)

/obj/item/storage/belt/military/ert/full_gamma_commander/PopulateContents()
	new /obj/item/ammo_box/magazine/smgm9mm/ap(src)
	new /obj/item/ammo_box/magazine/smgm9mm/ap(src)
	new /obj/item/ammo_box/magazine/smgm9mm(src)
	new /obj/item/ammo_box/magazine/smgm9mm(src)
	new /obj/item/grenade/chem_grenade/teargas(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/grenade/frag(src)

/obj/item/storage/belt/military/assault/ert
	name = "ERT assault belt"
	desc = "Тактический штурмовой пояс, используемый отрядами быстрого реагирования."

/obj/item/storage/belt/military/assault/ert/full_red_security/PopulateContents()
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/grenade/chem_grenade/teargas(src)
	new /obj/item/grenade/flashbang(src)

/obj/item/storage/belt/military/assault/ert/full_red_commander/PopulateContents()
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/grenade/chem_grenade/teargas(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/restraints/handcuffs(src)

/obj/item/storage/belt/military/assault/ert/full_red_clown/PopulateContents()
	new /obj/item/restraints/legcuffs/bola/gonbola(src)
	new /obj/item/grenade/chem_grenade/teargas/moustache(src)
	new /obj/item/grenade/chem_grenade/glitter/blue(src)
	new /obj/item/grenade/chem_grenade/glitter/pink(src)
	new /obj/item/grenade/chem_grenade/glitter(src)
	new /obj/item/restraints/handcuffs/fake(src)

/obj/item/storage/belt/military/assault/ert/full_gamma_clown/PopulateContents()
	new /obj/item/restraints/legcuffs/bola/gonbola(src)
	new /obj/item/grenade/chem_grenade/teargas/moustache(src)
	new /obj/item/grenade/chem_grenade/glitter/pink(src)
	new /obj/item/grenade/clusterbuster/soap(src)
	new /obj/item/grenade/spawnergrenade/clown(src)
	new /obj/item/restraints/handcuffs/fake(src)

/obj/item/storage/belt/holster/ert
	name = "ERT operative holster"
	desc = "Большая наплечная кобура, в которой можно хранить практически любое небольшое огнестрельное оружие и патроны к нему. Эта кобура предназначена специально для пистолетов."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/holster/nukie/cowboy

/obj/item/storage/belt/holster/ert/full_gp9r/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap = 1,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/hp = 1,
		/obj/item/gun/ballistic/automatic/pistol/gp9/spec = 1,
	),src)

/obj/item/storage/belt/holster/ert/full_gamma_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/energy/pulse/pistol/taserless/loyal = 1,
		/obj/item/ammo_box/magazine/smgm9mm = 1,
		/obj/item/gun/ballistic/automatic/proto/unrestricted = 1,
	),src)

/obj/item/storage/belt/military/holster
	name = "army belt with holster"
	desc = "Тактический штурмовой пояс с кобурой, используемый военными."
	icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
	icon_state = "military_holster"
	inhand_icon_state = "security"
	worn_icon_state = "military"
	storage_type = /datum/storage/military_belt/holster

/datum/storage/military_belt/holster
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 7

/datum/storage/military_belt/holster/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing/shotgun,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/flashlight/seclite,
		/obj/item/grenade,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/radio,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14,

	))
