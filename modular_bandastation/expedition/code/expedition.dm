/area/ruin/space/has_grav/hideout
	name = "Hideout Maintenance"

/area/ruin/space/has_grav/hideout/qm
	name = "Hideout Quartermaster Office"

/area/ruin/space/has_grav/hideout/dorms
	name = "Hideout Living Space"

/area/ruin/space/has_grav/hideout/kitchen
	name = "Hideout Kitchen"

/area/ruin/space/has_grav/hideout/cargobay
	name = "Hideout Cargo Bay"

/area/ruin/space/has_grav/hideout/securestorage
	name = "Hideout Secure Storage"

/area/ruin/space/has_grav/hideout/corridor2
	name = "Hideout Secure Corridor"

/area/ruin/space/has_grav/hideout/auxstorage
	name = "Hideout Storage Room"

/area/ruin/space/has_grav/hideout/brief
	name = "Hideout Brief Room"

/area/ruin/space/has_grav/hideout/cargooffice
	name = "Hideout Cargo Office"

/area/ruin/space/has_grav/powered/hideout/assaultpod
	name = "Hideout Assault Pod"

/area/ruin/space/has_grav/hideout/power
	name = "Hideout Electrical"

/area/ruin/space/has_grav/hideout/atmos
	name = "Hideout Atmos"

/area/ruin/space/has_grav/hideout/bar
	name = "Hideout Bar"

/area/ruin/space/has_grav/hideout/corridor
	name = "Hideout Corridor"

/area/ruin/space/has_grav/hideout/dnd
	name = "Hideout D&D Room"

/area/ruin/space/has_grav/hideout/freezer
	name = "Hideout Freezer"

/area/ruin/space/has_grav/hideout/botany
	name = "Hideout Botany"

/area/ruin/space/has_grav/hideout/tcomms
	name = "Hideout Tcomms"

/area/ruin/space/has_grav/hideout/medbay
	name = "Hideout Medbay"

/area/ruin/space/has_grav/hideout/science
	name = "Hideout Science"

/area/ruin/space/has_grav/hideout/engi
	name = "Hideout Engineering"

/area/ruin/space/has_grav/hideout/dump
	name = "Hideout Dumpster"

/area/ruin/space/has_grav/hideout/mdorms
	name = "Hideout Research Dorms"

/area/ruin/space/has_grav/hideout/dock
	name = "Hideout Medbay Lobby"

/area/ruin/space/has_grav/hideout/bar_maint
	name = "Hideout Bar Maints"

/datum/map_template/shuttle/expedition
	port_id = "shittle"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/expedition/shittle
	suffix = "basic"
	name = "Shitfuck"
	description = "Что-то что может летать и отдаленно похоже на под."

/obj/docking_port/mobile/shittle
	name = "shitfuck shuttle"
	shuttle_id = "shittle"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = NORTH
	port_direction = NORTH
	preferred_direction = NORTH
	can_move_docking_ports = 1
	rechargeTime = 1 MINUTES
	callTime = 4 MINUTES + 30 SECONDS

/obj/machinery/computer/camera_advanced/shuttle_docker/shittle
	name = "Shitfuck navigation computer"
	desc = "Used to pilot Shitfuck shuttle."
	icon_screen = "shuttle"
	icon_keyboard = "rd_key"
	shuttleId = "shittle"
	shuttlePortId = "shittle_custom"
	x_offset = 0
	y_offset = 0
	view_range = 5
	lock_override = CAMERA_LOCK_STATION
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/shuttle/shittle
	name = "Shitfuck transport Console"
	desc = "Used to control the Shitfuck."
	icon_screen = "teleport"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/shittle
	shuttleId = "shittle"
	possible_destinations = "shittle;shittle_home;shittle_custom;shittle_dock;shittle_cargo"
	req_access = list(ACCESS_CENT_SPECOPS)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	may_be_remote_controlled = TRUE

/obj/item/circuitboard/computer/shittle
	name = "Shitfuck Transport"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/shuttle/shittle

/area/shuttle/shittle
	name = "Shitfuck Shuttle"

/obj/structure/closet/secure_closet/personal/cabinet/stash/PopulateContents()

/obj/item/storage/toolbox/mechanical/empty/PopulateContents()
	return

/*
/mob/living/basic/trader/junker
	name = "Junker"
	desc = "Come buy some shit!"
	maxHealth = 2000
	health = 2000
	melee_damage_lower = 100
	melee_damage_upper = 100
	unsuitable_atmos_damage = 0
	speed = 0

	///The spawner we use to create our look
//	spawner_path = /obj/effect/mob_spawn/corpse/human/generic_assistant
	///Our species to create our look
//	species_path = /datum/species/human
	///The loot we drop when we die
//	loot = list(/obj/effect/mob_spawn/corpse/human/generic_assistant)
	///Casing used to shoot during retaliation
//	ranged_attack_casing = /obj/item/ammo_casing/shotgun/buckshot
	///Sound to make while doing a retalitory attack
//	ranged_attack_sound = 'sound/items/weapons/gun/pistol/shot.ogg'
	///Weapon path, for visuals
//	held_weapon_visual = /obj/item/gun/ballistic/shotgun

	///Type path for the trader datum to use for retrieving the traders wares, speech, etc
//	trader_data_path = /datum/trader_data/junker

/datum/trader_data/junker
	shop_spot_type = /obj/structure/chair/wood/wings
	sign_type = null

	initial_products = list(
		/obj/item/clothing/head/helmet/skull = list(PAYCHECK_CREW * 3, INFINITY),
		/obj/item/clothing/mask/bandana/skull/black = list(PAYCHECK_CREW, INFINITY),
		/obj/item/food/cookie/sugar/spookyskull = list(PAYCHECK_CREW * 0.2, INFINITY),
		/obj/item/instrument/trombone/spectral = list(PAYCHECK_CREW * 200, INFINITY),
		/obj/item/shovel/serrated = list(PAYCHECK_CREW * 3, INFINITY),
	)

	initial_wanteds = list(
		/obj/item/reagent_containers/condiment/milk = list(PAYCHECK_CREW * 20, INFINITY, ""),
		/obj/item/stack/sheet/bone = list(PAYCHECK_CREW * 8.4, INFINITY, ", per sheet of bone"),
	)

	say_phrases = list(
		ITEM_REJECTED_PHRASE = list(
			"Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk.",
		),
		ITEM_SELLING_CANCELED_PHRASE = list(
			"What a shame, tell me if you changed your mind.",
		),
		ITEM_SELLING_ACCEPTED_PHRASE = list(
			"Pleasure doing business with you.",
		),
		INTERESTED_PHRASE = list(
			"Hey, you've got an item that interests me, I'd like to buy it, I'll give you some cash for it, deal?",
		),
		BUY_PHRASE = list(
			"Bone appetit!",
		),
		NO_CASH_PHRASE = list(
			"Sorry adventurer, I can't give credit! Come back when you're a little mmmmm... richer!",
		),
		NO_STOCK_PHRASE = list(
			"Sorry adventurer, but that item is not in stock at the moment.",
		),
		NOT_WILLING_TO_BUY_PHRASE = list(
			"I don't want to buy that item for the time being, check back another time.",
		),
		ITEM_IS_WORTHLESS_PHRASE = list(
			"This item seems to be worthless on a closer look, I won't buy this.",
		),
		TRADER_HAS_ENOUGH_ITEM_PHRASE = list(
			"I already bought enough of this for the time being.",
		),
		TRADER_LORE_PHRASE = list(
			"Hello, I am Mr. Bones!",
			"The ride never ends!",
			"I'd really like a refreshing carton of milk!",
			"I'm willing to play big prices for BONES! Need materials to make merch, eh?",
			"It's a beautiful day outside. Birds are singing, Flowers are blooming... On days like these, kids like you... Should be buying my wares!",
		),
		TRADER_NOT_BUYING_ANYTHING = list(
			"I'm currently buying nothing at the moment.",
		),
		TRADER_NOT_SELLING_ANYTHING = list(
			"I'm currently selling nothing at the moment.",
		),
		TRADER_BATTLE_START_PHRASE = list(
			"The ride ends for you!",
		),
		TRADER_BATTLE_END_PHRASE = list(
			"Mr. Bones never misses!",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"My wild ride is open!",
		),
	)



/datum/trader_data/bruh
	shop_spot_type = /obj/structure/chair/wood/wings
	sign_type = null

	initial_products = list(
		/obj/item/nullrod/claymore/chainsaw_sword/kyle = list(PAYCHECK_CREW * 200, 1),
		/obj/item/sharpener = list(PAYCHECK_CREW * 200, INFINITY),
		/obj/item/book/bible = list(PAYCHECK_CREW * 1, INFINITY),
		/obj/item/reagent_containers/cup/glass/bottle/holywater = list(PAYCHECK_CREW * 5, INFINITY),
		/obj/item/grenade/chem_grenade/holy = list(PAYCHECK_CREW * 20, INFINITY),
		/obj/item/ammo_casing/arrow = list(PAYCHECK_CREW * 10, INFINITY),
		/obj/item/ammo_casing/arrow/holy = list(PAYCHECK_CREW * 5, INFINITY),
		/obj/item/gun/ballistic/bow/shortbow = list(PAYCHECK_CREW * 40, INFINITY),
		/obj/item/ammo_casing/arrow/holy/blazing = list(PAYCHECK_CREW * 10, INFINITY),
	)

//tome
	initial_wanteds = list(
		/obj/item/fake_items/time_stopper/no_anchor = list(PAYCHECK_CREW * 40, INFINITY, "Good work killing that wizard"),
		/obj/item/fake_items/wabbajack/no_anchor = list(PAYCHECK_CREW * 40, INFINITY, "Good work killing that wizard"),
		/obj/item/fake_items/abductor_win_stick/no_anchor = list(PAYCHECK_CREW * 40, INFINITY, "Good work killing that wizard"),
		/obj/item/clothing/head/collectable/paper = list(PAYCHECK_CREW * 40, INFINITY, "Good work killing that wizard"),
		/obj/item/clothing/suit/wizrobe/paper = list(PAYCHECK_CREW * 40, INFINITY, "Good work killing that wizard"),
		/obj/item/gun/magic/wand/disabler = list(PAYCHECK_CREW * 40, INFINITY, "Good work retrieving the relic"),
		/obj/item/boulder/true_boulder = list(PAYCHECK_CREW * 40, INFINITY, "Good work retrieving the relic"),
		/obj/item/gun/magic/wand/fireball/inert = list(PAYCHECK_CREW * 40, INFINITY, "Good work retrieving the relic"),
		/obj/item/gun/magic/wand/resurrection/inert = list(PAYCHECK_CREW * 40, INFINITY, "Good work retrieving the relic"),
		/obj/item/soulstone = list(PAYCHECK_CREW * 40, INFINITY, "Good work retrieving the relic"),
		/obj/item/soulstone/anybody = list(PAYCHECK_CREW * 5, 1, "Good work retrieving the con- oh, I recognize this, I'll see if I can scramble a team for the station"),//to-do, spawn a red alert security ert if this item is sold
		/obj/item/soulstone/anybody/chaplain = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/soulstone/anybody/chaplain/sparring = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/soulstone/anybody/mining = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/soulstone/anybody/purified = list(PAYCHECK_CREW * 10, INFINITY, "Good work retrieving the relic"),
		/obj/item/soulstone/anybody/revolver = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/soulstone/mystic = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/guardian_creator/miner = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/guardian_creator/wizard = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/guardian_creator/carp = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the relic"),
		/obj/item/card/emag = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/card/emag/doorjack = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/card/emag/battlecruiser = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the con- oh, I recognize this, I'll see if I can scramble a team for the station"),//to-do, spawn a red alert security ert if this item is sold
		/obj/item/disk/nuclear/fake = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband, hard to tell these apart"),
		/obj/item/gun/ballistic/revolver/badass = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/crowbar/power/syndicate = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/documents/syndicate = list(PAYCHECK_CREW * 5, INFINITY, "Sorry, but these are out-dated, We cant glean much from this."),
		/obj/item/documents/syndicate/blue = list(PAYCHECK_CREW * 50, INFINITY, "Hope you didnt look over these. Here, take some extra dough"),
		/obj/item/documents/syndicate/red = list(PAYCHECK_CREW * 50, INFINITY, "Hope you didnt look over these. Here, take some extra doug."),
		/obj/item/documents/syndicate/mining = list(PAYCHECK_CREW * 5, INFINITY, "Sorry, but these are outdated. We cant glean much from this"),
		/obj/item/gun/ballistic/rifle/sniper_rifle/syndicate = list(PAYCHECK_CREW * 60, INFINITY, "Well ho-lee-shit *whistles* a nice point fifty sniper rifle, I'll be taking that"),//to-do, make it appear on his back after purchasing this
		/obj/item/mod/control/pre_equipped/empty/syndicate = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/storage/toolbox/syndicate = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the contraband"),
		/obj/item/toy/cards/deck/syndicate = list(PAYCHECK_CREW * 1, INFINITY, "this is not REALLY contraband, but I'll take it anyhow"),
		/obj/item/syndicate_teleporter = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the contraband"),
		/obj/item/encryptionkey/syndicate = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the contraband"),
		/obj/item/clothing/suit/space/syndicate/black/red = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the contraband"),
		/obj/item/clothing/head/helmet/space/syndicate/black/red = list(PAYCHECK_CREW * 5, INFINITY, "Good work retrieving the contraband"),
		/obj/item/gun/ballistic/automatic/pistol/contraband = list(PAYCHECK_CREW * 10, INFINITY, "Good work retrieving the contraband"),
		/obj/item/gun/ballistic/rifle/rebarxbow/syndie = list(PAYCHECK_CREW * 10, INFINITY, "Good work retrieving the contraband"),
		/obj/item/mod/control/pre_equipped/traitor = list(PAYCHECK_CREW * 10, INFINITY, "Good work retrieving the contraband"),
		/obj/item/mod/control/pre_equipped/traitor_elite = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/melee/energy/sword = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/melee/energy/axe = list(PAYCHECK_CREW * 100, INFINITY, "How the fuck- whatever, here is your money"),
		/obj/item/dualsaber = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/item/dualsaber/red = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
		/obj/effect/fun_balloon = list(PAYCHECK_CREW * 0, INFINITY, "Why would I care about a red balloon with an S on it?!"),
		/obj/item/nuke_core = list(PAYCHECK_CREW * 40, INFINITY, "*He puts his hands up, shielding himself from the plutonium rock* OH MY GOD WHY DID YOU BRING ME THIS THING?! *he then seems to remember that his suit is radiation proof, after which he snatches it out of your hand*"),
		/obj/item/melee/supermatter_sword = list(PAYCHECK_CREW * 200, INFINITY, "*He stares at you completely silent for what feels like two minutes* W-Well- that is, an interesting product of your stations rnd- ill just be taking that"),
		/obj/item/melee/cultblade/haunted = list(PAYCHECK_CREW * 20, 1, "Good work retrieving the cont- oh, this is specialized nar'sien equipment... I'll send a team over to the station"),//to-do, spawn a red alert inquisition ert if this item is sold
		/obj/item/seeds/kudzu = list(PAYCHECK_CREW * 20, INFINITY, "Good work retrieving the contraband"),
	)

	say_phrases = list(
		ITEM_REJECTED_PHRASE = list(
			"Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk.",
		),
		ITEM_SELLING_CANCELED_PHRASE = list(
			"What a shame, tell me if you changed your mind.",
		),
		ITEM_SELLING_ACCEPTED_PHRASE = list(
			"Pleasure doing business with you, if you give me enough i could talk to some people, maybe get you a promotion.",
		),
		INTERESTED_PHRASE = list(
			"Hey, you've got an item that interests me, I'd like to buy it, I'll give you some cash for it, deal?",
		),
		BUY_PHRASE = list(
			"Enjoy the extra credits sl- i mean, valued and appriciated employee",
		),
		NO_CASH_PHRASE = list(
			"Sorry wagie, Come back when you're a little mmmmm... richer!",
		),
		NO_STOCK_PHRASE = list(
			"I'm only giving out one of each of these things, thats all im permitted to do- except whetstones.",
		),
		NOT_WILLING_TO_BUY_PHRASE = list(
			"I don't want to buy that item for the time being, check back another time.",
		),
		ITEM_IS_WORTHLESS_PHRASE = list(
			"This item seems to be worthless on a closer look, I won't buy this.",
		),
		TRADER_HAS_ENOUGH_ITEM_PHRASE = list(
			"I already bought enough of this for the time being.",
		),
		TRADER_LORE_PHRASE = list(
			"Hello valuable employee, to the north of us we have located a large concentration of wizards! I'm not gonna sugarcoat it, go kill them, and when one of them drops something magical, bring it to me, or bring me any contraband station side and ill buy it off ya.",
			"Hello valuable employee, to the north of us we have located a large concentration of wizards! I'm not gonna sugarcoat it, go kill them, and when one of them drops something magical, bring it to me, or bring me any contraband station side and ill buy it off ya.",
			"Hello wagie, to the north of us we have located a large concentration of wizards! I'm not gonna sugarcoat it, go kill them, and when one of them drops something magical, bring it to me, or bring me any contraband station side and ill buy it off ya.",
			"Hello SLAVE, to the north of us we have located a large concentration of wizards! I'm not gonna sugarcoat it, go kill them, and when one of them drops something magical, bring it to me, or bring me any contraband station side and ill buy it off ya.",
		),
		TRADER_NOT_BUYING_ANYTHING = list(
			"You got nothing i can pay for.",
		),
		TRADER_NOT_SELLING_ANYTHING = list(
			"I'm currently selling nothing at the moment.",
		),
		TRADER_BATTLE_START_PHRASE = list(
			"IM GOING TO DEMOTE YOU OVER THIS!",
		),
		TRADER_BATTLE_END_PHRASE = list(
			"Eh whatever, theyll just be cloned again and forget this, im putting this on their internal record however.",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"Its simple, go north, get artifacts, sell them to me, go to the station, get contraband, sell it to me.",
		),
	)

*/
