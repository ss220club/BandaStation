/obj/effect/landmark/loot_spawn
	name = "loot spawn"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	var/list/loot_table = list()
	var/max_items = 2
	var/spawn_chance = 100

/obj/effect/landmark/loot_spawn/proc/spawn_loot()

	if(prob(100 - spawn_chance))
		return
	var/turf/T = get_turf(src)

	if(!T)
		return
	var/current_items = 0
	for(var/obj/item/I in T)
		current_items++
	if(current_items >= max_items)
		return

	var/path = pick_weight(loot_table)
	if(path)
		new path(T)

GLOBAL_LIST_EMPTY(loot_spawners)

/obj/effect/landmark/loot_spawn/Initialize(mapload)
	. = ..()
	GLOB.loot_spawners += src

/obj/effect/landmark/loot_spawn/Destroy()
	GLOB.loot_spawners -= src
	return ..()

/obj/effect/landmark/loot_spawn/medical
	name = "medical loot spawn"
	icon_state = "x3"
	loot_table = list(
		/obj/item/healthanalyzer = 60,
		/obj/item/healthanalyzer/simple = 50,
		/obj/item/healthanalyzer/advanced = 30,
		/obj/item/clothing/neck/stethoscope = 40,
		/obj/item/autosurgeon = 10,
		/obj/item/organ/cyberimp/chest/pump = 10,
		/obj/item/organ/cyberimp/brain/anti_drop = 10,
		/obj/item/pinpointer/crew = 15,
		/obj/item/storage/box/bandages = 90,
		/obj/item/stack/medical/suture = 80,
		/obj/item/stack/medical/ointment = 90,
		/obj/item/stack/medical/mesh = 85,
		/obj/item/stack/medical/wrap/gauze = 80,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 80,
		/obj/item/reagent_containers/hypospray/medipen = 70,
		/obj/item/reagent_containers/cup/bottle/epinephrine = 70,
		/obj/item/reagent_containers/syringe/epinephrine = 70,
		/obj/item/reagent_containers/syringe/antiviral = 80,
		/obj/item/reagent_containers/applicator/patch/libital = 60,
		/obj/item/reagent_containers/applicator/patch/aiuri = 60,
		/obj/item/reagent_containers/cup/bottle/morphine = 60,
		/obj/item/storage/medkit/regular = 50,
		/obj/item/reagent_containers/blood/o_minus = 50,
		/obj/item/storage/pill_bottle/happinesspsych = 60,
		/obj/item/storage/pill_bottle/penacid = 40,
		/obj/item/storage/medkit/o2 = 60,
		/obj/item/reagent_containers/hypospray/cmo = 30,
		/obj/item/storage/medkit/toxin = 40,
		/obj/item/storage/medkit/brute = 40,
		/obj/item/storage/medkit/fire = 40,
		/obj/item/reagent_containers/medigel/libital = 50,
		/obj/item/reagent_containers/medigel/aiuri = 50,
		/obj/item/storage/medkit/surgery = 20,
		/obj/item/storage/pill_bottle/mannitol = 60,
		/obj/item/reagent_containers/cup/bottle/potass_iodide = 25,
		/obj/item/storage/medkit/advanced = 10,
		/obj/item/storage/medkit/tactical = 10,
		/obj/item/reagent_containers/hypospray/combat = 5
	)
	max_items = 2
	spawn_chance = 80

/obj/effect/landmark/loot_spawn/weapon
	name = "weapon loot spawn"
	icon_state = "x"
	loot_table = list(
		/obj/item/gun/ballistic/automatic/pistol = 90,
		/obj/item/gun/ballistic/automatic/pistol/zashch = 70,
		/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher = 50,
		/obj/item/gun/ballistic/automatic/pistol/wespe = 90,
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 60,
		/obj/item/gun/ballistic/automatic/pistol/clandestine = 50,
		/obj/item/gun/ballistic/rifle/sks = 75,
		/obj/item/gun/ballistic/rifle/boltaction/mosin = 80,
		/obj/item/gun/ballistic/automatic/sabel/auto = 60,
		/obj/item/gun/ballistic/rifle/sks/c762x54mmr = 70,
		/obj/item/gun/ballistic/rifle/boltaction/mosin/strilka310 = 70,
		/obj/item/gun/ballistic/automatic/bison = 70,
		/obj/item/gun/ballistic/automatic/sabel/auto/army/alt = 50,
		/obj/item/gun/ballistic/automatic/sabel/auto/modern = 40,
		/obj/item/gun/ballistic/automatic/lanca = 30,
		/obj/item/gun/ballistic/shotgun/riot = 80,
		/obj/item/knife/combat/survival = 90,
		/obj/item/knife/combat = 90,
		/obj/item/suppressor = 60,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 20,
		/obj/item/gun/ballistic/automatic/carwo = 80,
		/obj/item/gun/ballistic/shotgun/riot/renoster/sawoff = 70,
		/obj/item/gun/ballistic/automatic/carwo/auto = 60,
		/obj/item/gun/ballistic/automatic/sindano = 70,
		/obj/item/gun/ballistic/automatic/carwo/marksman = 40,
		/obj/item/gun/ballistic/automatic/mini_uzi = 50,
		/obj/item/gun/ballistic/automatic/carwo/auto/wooden = 50
	)
	max_items = 1
	spawn_chance = 70

/obj/effect/landmark/loot_spawn/ammo
	name = "ammo loot spawn"
	icon_state = "x"
	loot_table = list(
		/obj/item/ammo_box/magazine/m9mm = 90,
		/obj/item/ammo_box/speedloader/strilka310 = 90,
		/obj/item/ammo_box/magazine/zashch = 80,
		/obj/item/ammo_box/c762x39/ricochet = 80,
		/obj/item/ammo_box/c762x54mmr = 80,
		/obj/item/storage/toolbox/ammobox/c762x54mmr_bullets = 60,
		/obj/item/grenade/frag = 60,
		/obj/item/ammo_box/c762x39/hunting = 70,
		/obj/item/ammo_box/magazine/strilka310 = 70,
		/obj/item/ammo_box/magazine/c762x39mm = 60,
		/obj/item/ammo_box/magazine/m9mm/hp = 70,
		/obj/item/ammo_box/magazine/bison = 70,
		/obj/item/ammo_box/magazine/bison/hp = 60,
		/obj/item/storage/toolbox/ammobox/amk_mags = 40,
		/obj/item/ammo_box/c762x39/emp = 30,
		/obj/item/ammo_box/magazine/c762x39mm/emp = 30,
		/obj/item/ammo_box/magazine/m9mm/ap = 50,
		/obj/item/ammo_box/magazine/m10mm/hp = 60,
		/obj/item/ammo_box/magazine/m10mm/ap = 50,
		/obj/item/grenade/c4 = 40,
		/obj/item/ammo_box/c762x39/ap = 30,
		/obj/item/ammo_box/magazine/bison/ap = 40,
		/obj/item/ammo_box/magazine/smg10mm = 40,
		/obj/item/ammo_box/magazine/c40sol_rifle = 80,
		/obj/item/storage/box/lethalshot = 90,
		/obj/item/ammo_box/magazine/m50 = 30,
		/obj/item/ammo_box/c12ga/slug = 20,
		/obj/item/ammo_box/magazine/c35sol_pistol = 90,
		/obj/item/grenade/smokebomb = 70,
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 70,
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo = 70,
		/obj/item/ammo_box/magazine/c35sol_pistol/hp = 60,
		/obj/item/ammo_box/magazine/c35sol_pistol/drum = 60,
		/obj/item/ammo_box/magazine/c35sol_pistol/drum/hp = 50,
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo/hp = 60,
		/obj/item/ammo_box/magazine/c40sol_rifle/long = 60,
		/obj/item/ammo_box/magazine/c40sol_rifle/long/ap = 30,
		/obj/item/ammo_box/magazine/c35sol_pistol/drum/ap = 40,
		/obj/item/ammo_box/magazine/c40sol_rifle/drum = 50,
		/obj/item/ammo_box/magazine/c35sol_pistol/ap = 50,
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ap = 50,
		/obj/item/ammo_box/magazine/c40sol_rifle/box = 20,
		/obj/item/ammo_box/magazine/uzim9mm = 90,
		/obj/item/ammo_box/magazine/m10mm = 80,
		/obj/item/ammo_box/magazine/c45 = 70,
		/obj/item/ammo_box/magazine/smgm45 = 70,
		/obj/item/ammo_box/magazine/fn18 = 60,
		/obj/item/ammo_box/magazine/m9mm_aps = 70,
		/obj/item/ammo_box/magazine/c762x51mm = 50,
		/obj/item/ammo_box/magazine/as32 = 50,
		/obj/item/ammo_box/magazine/c338 = 30,
		/obj/item/ammo_box/speedloader/c357/match = 40,
		/obj/item/ammo_box/magazine/c762x39mm/ap = 30,
		/obj/item/ammo_box/magazine/m223 = 40,
		/obj/item/ammo_box/magazine/m12g = 30,
		/obj/item/ammo_box/magazine/m12g/slug = 20
	)
	max_items = 2
	spawn_chance = 90

/obj/effect/landmark/loot_spawn/food
	name = "food loot spawn"
	icon_state = "x3"
	loot_table = list(
		/obj/item/food/cherrycupcake = 90,
		/obj/item/food/candy = 90,
		/obj/item/food/sosjerky = 90,
		/obj/item/food/peanuts/random = 80,
		/obj/item/food/peanuts = 80,
		/obj/item/reagent_containers/cup/glass/coffee = 80,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 80,
		/obj/item/reagent_containers/cup/soda_cans/cola = 90,
		/obj/item/food/energybar = 70,
		/obj/item/food/shok_roks/random = 60,
		/obj/item/food/shok_roks = 60,
		/obj/item/reagent_containers/cup/soda_cans/volt_energy = 50,
		/obj/item/reagent_containers/cup/glass/mug/coco = 60,
		/obj/item/food/canned/beans = 80,
		/obj/item/food/rationpack = 60,
	)
	max_items = 3
	spawn_chance = 90

/obj/effect/landmark/loot_spawn/treasure
	name = "treasure loot spawn"
	icon_state = "x4"
	loot_table = list(
		/obj/item/clothing/accessory/medal = 90,
		/obj/item/clothing/mask/bandana/gold = 80,
		/obj/item/stack/sheet/mineral/gold = 70,
		/obj/item/bikehorn/golden = 90,
		/obj/item/instrument/violin/golden = 30,
		/obj/item/clothing/accessory/anti_sec_pin = 70,
		/obj/item/clothing/accessory/deaf_pin = 70,
		/obj/item/clothing/accessory/debt_payer_pin = 70,
		/obj/item/clothing/accessory/kheiral_cuffs = 30,
		/obj/item/clothing/accessory/gloves_accessory/ring/silver = 60,
		/obj/item/clothing/accessory/gloves_accessory/ring = 40,
		/obj/item/clothing/accessory/gloves_accessory/ring/diamond = 20,
		/obj/item/reagent_containers/cup/glass/mug/britcup = 80,
		/obj/item/storage/belt/champion = 30,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 40,
		/obj/item/sticker/purity_seal = 70,
		/obj/item/book/bible = 80,
		/obj/item/clothing/neck/necklace/dope = 40
	)
	max_items = 1
	spawn_chance = 90

/obj/effect/landmark/loot_spawn/clothing
	name = "clothing loot spawn"
	icon_state = "city_of_cogs"
	loot_table = list(
		/obj/item/clothing/head/wig/natural = 60,
		/obj/item/clothing/head/beret = 70,
		/obj/item/clothing/head/beanie = 60,
		/obj/item/clothing/head/costume/fancy = 50,
		/obj/item/clothing/mask/bandana = 70,
		/obj/item/clothing/mask/bandana/skull = 60,
		/obj/item/clothing/mask/facescarf = 70,
		/obj/item/clothing/neck/scarf = 70,
		/obj/item/clothing/neck/large_scarf = 60,
		/obj/item/clothing/neck/tie = 70,
		/obj/item/clothing/neck/bowtie = 70,
		/obj/item/clothing/head/rasta = 70,
		/obj/item/clothing/head/hats/tophat = 40,
		/obj/item/clothing/head/fedora = 50,
		/obj/item/clothing/head/fedora/greyscale = 50,
		/obj/item/clothing/head/cowboy/white = 40,
		/obj/item/clothing/head/costume/sombrero/green = 30,
		/obj/item/clothing/neck/tie/horrible = 40,
		/obj/item/clothing/accessory/waistcoat = 50,
		/obj/item/clothing/glasses/regular = 70,
		/obj/item/clothing/glasses/red = 50,
		/obj/item/clothing/glasses/monocle = 30,
		/obj/item/clothing/gloves/fingerless = 60,
		/obj/item/clothing/neck/cloak/colorable_cloak = 70,
		/obj/item/clothing/under/costume/buttondown/skirt = 70,
		/obj/item/clothing/under/costume/buttondown/slacks = 70,
		/obj/item/clothing/under/dress/sundress = 50,
		/obj/item/clothing/under/dress/tango = 30,
		/obj/item/clothing/under/dress/skirt/plaid = 50,
		/obj/item/clothing/under/dress/skirt/turtleskirt = 40,
		/obj/item/clothing/under/misc/overalls = 60,
		/obj/item/clothing/under/pants/camo = 50,
		/obj/item/clothing/under/dress/striped = 50,
		/obj/item/clothing/under/dress/sailor = 40,
		/obj/item/clothing/under/dress/eveninggown = 20,
		/obj/item/clothing/suit/toggle/jacket/sweater = 70,
		/obj/item/clothing/suit/toggle/jacket/trenchcoat = 60,
		/obj/item/clothing/suit/jacket/fancy = 40,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 50,
		/obj/item/clothing/suit/hooded/wintercoat/pullover = 60,
		/obj/item/clothing/under/suit/navy = 50,
		/obj/item/clothing/under/suit/black_really = 40,
		/obj/item/clothing/under/suit/burgundy = 30,
		/obj/item/clothing/under/suit/white = 40,
		/obj/item/clothing/under/suit/charcoal = 40,
		/obj/item/clothing/suit/costume/hawaiian = 60,
		/obj/item/clothing/suit/jacket/letterman_red = 60,
		/obj/item/clothing/under/rank/civilian/purple_bartender = 50,
		/obj/item/clothing/under/dress/skirt = 40,
		/obj/item/clothing/suit/jacket/miljacket = 70,
		/obj/item/clothing/shoes/swagshoes = 20,
		/obj/item/instrument/piano_synth/headphones/spacepods = 10,
		/obj/item/clothing/under/suit/checkered = 10,
		/obj/item/clothing/suit/jacket/letterman_nanotrasen = 15,
		/obj/item/clothing/suit/jacket/leather/biker = 10,
		/obj/item/clothing/glasses/meson = 50,
		/obj/item/clothing/suit/utility/radiation = 30,
		/obj/item/clothing/head/utility/radiation = 30,
		/obj/item/clothing/suit/armor/vest = 40,
		/obj/item/bikehorn/rubberducky = 60,
	)
	max_items = 1
	spawn_chance = 70

/obj/effect/landmark/loot_spawn/information
	name = "info loot spawn"
	icon_state = "random_loot"
	loot_table = list(
		/obj/item/documents = 80,
		/obj/item/documents/nanotrasen = 50,
		/obj/item/documents/syndicate = 50,
		/obj/item/documents/syndicate/red = 30,
		/obj/item/documents/syndicate/blue = 15,
		/obj/item/disk/holodisk = 70,
		/obj/item/disk/holodisk/donutstation/whiteship = 50,
		/obj/item/disk/holodisk/ruin/cyborg_mothership = 40,
		/obj/item/disk/holodisk/ruin/waystation = 10,
		/obj/item/disk/computer = 90,
		/obj/item/disk/computer/super = 70,
		/obj/item/disk/computer/command = 50,
		/obj/item/disk/computer/hdd_theft = 60,
		/obj/item/disk/computer/syndie_ai_upgrade = 30,
		/obj/item/disk/computer/black_market = 20,
		/obj/item/disk/computer/virus = 20,
		/obj/item/book/granter/crafting_recipe/equipment_manual_light = 60,
		/obj/item/book/granter/crafting_recipe/equipment_manual_medium = 30,
		/obj/item/book/granter/crafting_recipe/equipment_manual_elite = 10,
		/obj/item/book/granter/crafting_recipe/ammo_manual_light = 70,
		/obj/item/book/granter/crafting_recipe/ammo_manual_medium = 40,
		/obj/item/book/granter/crafting_recipe/ammo_manual_elite = 20,
		/obj/item/book/granter/crafting_recipe/medical_manual_light = 70,
		/obj/item/book/granter/crafting_recipe/medical_manual_medium = 40,
		/obj/item/book/granter/crafting_recipe/medical_manual_elite = 20,
		/obj/item/keycard/forest_bunker = 60,
		/obj/item/keycard/nt_labs = 40,
		/obj/item/keycard/nt_commsbuoy/village_base = 40,
		/obj/item/keycard/blue/mine_exit = 50,
		/obj/item/keycard/cafeteria/administration = 30
	)
	max_items = 1
	spawn_chance = 50

/obj/effect/landmark/loot_spawn/technical
	name = "technical loot spawn"
	icon_state = "clockwork_orange"
	loot_table = list(
		/obj/item/stack/cable_coil = 80,
		/obj/item/stack/medical/wrap/sticky_tape = 80,
		/obj/item/stack/cable_coil/five = 60,
		/obj/item/assembly/igniter = 60,
		/obj/item/stack/sheet/iron = 70,
		/obj/item/stack/sheet/glass = 70,
		/obj/item/stock_parts/capacitor = 70,
		/obj/item/stock_parts/scanning_module = 60,
		/obj/item/stock_parts/servo = 60,
		/obj/item/stock_parts/subspace/ansible = 50,
		/obj/item/stock_parts/subspace/filter = 40,
		/obj/item/stock_parts/subspace/amplifier = 40,
		/obj/item/stock_parts/subspace/analyzer = 40,
		/obj/item/stock_parts/subspace/crystal = 30,
		/obj/item/stock_parts/card_reader = 50,
		/obj/item/stock_parts/water_recycler = 50,
		/obj/item/weaponcrafting/receiver = 40,
		/obj/item/assembly/signaler = 60,
		/obj/item/analyzer = 60,
		/obj/item/stack/sheet/leather = 70,
		/obj/item/stack/sheet/leather/five = 60,
		/obj/item/stack/sheet/plasteel = 40,
		/obj/item/stack/sheet/rglass = 40,
		/obj/item/stack/sheet/plastitaniumglass = 30,
		/obj/item/crafting_items/gunpowder = 70,
		/obj/item/crafting_items/gunpowder/medium = 50,
		/obj/item/crafting_items/gunpowder/high = 30,
		/obj/item/reagent_containers/cup/fuel_can = 60,
		/obj/item/stack/sheet/plastic = 80,
		/obj/item/stack/sheet/plastic/five = 60,
		/obj/item/screwdriver = 70,
		/obj/item/weldingtool = 60,
		/obj/item/wirecutters = 60,
		/obj/item/fuel_pellet = 60,
		/obj/item/circuitboard/machine/thermomachine = 40
	)
	max_items = 2
	spawn_chance = 80

/obj/effect/landmark/loot_spawn/magma_artifact
	name = "magma wing spawn"
	icon_state = "clockwork_orange"
	loot_table = list(/obj/item/artifact/fire_wing = 100)
	max_items = 1
	spawn_chance = 50

/obj/effect/landmark/loot_spawn/ice_artifact
	name = "ice crystal spawn"
	icon_state = "clockwork_orange"
	loot_table = list(/obj/item/artifact/ice_crystal = 100)
	max_items = 1
	spawn_chance = 50

/obj/effect/landmark/loot_spawn/stone_artifact
	name = "stone eye spawn"
	icon_state = "clockwork_orange"
	loot_table = list(/obj/item/artifact/stone_eye = 100)
	max_items = 1
	spawn_chance = 50

/obj/structure/loot
	name = "trash bags"
	desc = "A collection of trash. Incomplete without you."
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "trashbags_1"
	var/searched = FALSE
	var/random_appearence = TRUE
	var/loot_chance = 35
	var/loot_amount = 1
	var/unsanitary = TRUE
	var/loot_type = /obj/effect/spawner/random/trash/garbage
	var/good_loot_type = /obj/effect/spawner/random/trash/garbage
	var/good_loot_chance = 25
	var/reset_cooldown_period = 15 MINUTES

/obj/structure/loot/proc/reset_loot()
	searched = FALSE

/obj/structure/loot/trash/garbage
	name = "trash bags"
	desc = "A collection of trash. Incomplete without you."
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "trashbags_1"

/obj/structure/loot/trash/garbage/Initialize(mapload)
	. = ..()
	if(random_appearence)
		icon_state = pick("trashbags_1","trashbags_2","trashbags_3","trashbags_4","trashbags_5","trashbags_6")

/obj/structure/loot/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return
	if(searched)
		user.visible_message(span_notice("[user] examines [src], before turning away."), \
			span_notice("The [src] have already been searched."))
		return
	user.visible_message(span_notice("[user] begins to sift through the [src] for anything useful."), \
		span_notice("You begin to dig through the [src] for something interesting."))
	if(do_after(user, 7 SECONDS, src))
		if(prob(loot_chance))
			user.visible_message(span_notice("[user] finds something inside the [src]."), \
				span_notice("You find something interesting inside the [src]."))
			if(prob(good_loot_chance))
				new good_loot_type(loc, loot_amount)
			else
				new loot_type(loc, loot_amount)
		else
			if(prob(40))
				new /obj/effect/spawner/random/trash/garbage(loc, rand(1,2))
				user.visible_message(span_notice("[user] finds something inside the [src]."), \
				span_notice("Just some scrap, garbage, and other bits."))
			else
				user.visible_message(span_notice("[user] finds nothing inside the [src]."), \
					span_notice("Nothing good..."))
		searched = TRUE;
		addtimer(CALLBACK(src, PROC_REF(reset_loot)), reset_cooldown_period)

/obj/structure/loot/trash/garbage/dumpster
	name = "dumpster"
	desc = "A large green dumpster, full of goodies."
	icon_state = "dumpster"
	density = TRUE
	anchored = TRUE
	random_appearence = FALSE
	loot_chance = 80

/obj/structure/loot/technical_crate
	name = "large wooden crate"
	icon = 'modular_bandastation/voyaker_events/icons/crates.dmi'
	desc = "Большой деревянный складской ящик. Возможно в нем хранится что-то полезное."
	icon_state = "wood_crate"
	loot_type = /obj/effect/landmark/loot_spawn/technical
	good_loot_type = /obj/effect/landmark/loot_spawn/information
	random_appearence = FALSE

/obj/structure/loot/technical_crate/small
	name = "wooden crate"
	desc = "Деревянный складской ящик. Возможно в нем хранится что-то полезное."
	icon_state = "plain_crate"

/obj/structure/loot/technical_crate/metal
	name = "metal crate"
	desc = "Металический складской ящик. Возможно в нем хранится что-то полезное."
	icon_state = "aluminum"

/obj/structure/loot/technical_crate/metal/red
	icon_state = "red"

/obj/structure/loot/army_crate
	name = "military crate"
	icon = 'modular_bandastation/voyaker_events/icons/crates.dmi'
	desc = "Военный ящик для хранения. Возможно в нем хранится что-то полезное."
	icon_state = "army"
	loot_type = /obj/effect/landmark/loot_spawn/ammo
	good_loot_type = /obj/effect/landmark/loot_spawn/weapon
	random_appearence = FALSE

/obj/structure/loot/army_crate/gray
	name = "unmarked military crate"
	desc = "Военный ящик для хранения. Возможно в нем хранится что-то полезное."
	icon_state = "aluminum"

/obj/structure/loot/army_crate/red
	name = "red military crate"
	desc = "Военный ящик для хранения. Возможно в нем хранится что-то полезное."
	icon_state = "red"

/obj/structure/loot/army_crate/alt
	name = "military crate"
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "weaponcrate"

/obj/structure/loot/army_crate/alt/brown
	icon_state = "plasmacrate"

/obj/structure/loot/footlocker
	name = "footlocker"
	icon = 'modular_bandastation/voyaker_events/icons/crates.dmi'
	desc = "Ящик для хранения личных вещей. Возможно в нем хранится что-то полезное."
	icon_state = "footlocker"
	loot_type = /obj/effect/landmark/loot_spawn/clothing
	good_loot_type = /obj/effect/landmark/loot_spawn/treasure
	random_appearence = FALSE

/obj/structure/loot/shelf
	name = "shelf"
	desc = "A sturdy wooden shelf to store a variety of items on."
	icon = 'modular_bandastation/voyaker_events/icons/furniture.dmi'
	icon_state = "shelf_1"
	loot_type = /obj/effect/landmark/loot_spawn/food
	good_loot_type = /obj/effect/landmark/loot_spawn/treasure

/obj/structure/loot/shelf/Initialize(mapload)
	. = ..()
	if(random_appearence)
		icon_state = pick("shelf_1","shelf_2","shelf_3","shelf_4","shelf_5","shelf_6","shelf_7","shelf_8","shelf_9","shelf_10","shelf_11")

/obj/structure/loot/long_shelf_metal
	name = "long metal shelf"
	desc = "A sturdy metal shelf to store a variety of items on."
	icon = 'modular_bandastation/voyaker_events/icons/supermart.dmi'
	icon_state = "longrack_1"
	loot_type = /obj/effect/landmark/loot_spawn/food
	good_loot_type = /obj/effect/landmark/loot_spawn/treasure

/obj/structure/loot/long_shelf_metal/Initialize(mapload)
	. = ..()
	if(random_appearence)
		icon_state = pick("longrack1","longrack2","longrack3","longrack4","longrack5","longrack6","longrack7")

/obj/structure/loot/file_cabinet
	name = "file cabinet"
	desc = "A sturdy metal cabinet to store a variety of documents."
	icon = 'modular_bandastation/voyaker_events/icons/cabinets.dmi'
	icon_state = "filing_cabinet"
	loot_type = /obj/effect/landmark/loot_spawn/information
	good_loot_type = /obj/effect/landmark/loot_spawn/treasure
	random_appearence = FALSE

/obj/structure/loot/file_cabinet/small
	name = "small file cabinet"
	desc = "A sturdy small metal cabinet to store a variety of documents."
	icon_state = "filing_cabinet_small"
