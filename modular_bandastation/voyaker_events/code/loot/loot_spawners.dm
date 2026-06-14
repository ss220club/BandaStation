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
		/obj/item/gun/ballistic/revolver/dvoystvol/low_caliber = 50,
		/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher = 50,
		/obj/item/gun/ballistic/revolver/dvoystvol = 40,
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
		/obj/item/clothing/suit/jacket/leather/biker = 10
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
		/obj/item/disk/computer/virus = 20
	)
	max_items = 1
	spawn_chance = 50
