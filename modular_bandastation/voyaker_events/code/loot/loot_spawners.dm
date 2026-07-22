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
		/obj/item/defibrillator/compact = 70,
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
	max_items = 1
	spawn_chance = 70

/obj/effect/landmark/loot_spawn/weapon
	Initialize(mapload)
		. = ..()
		loot_table = GLOB.weapon_loot_table.Copy()

/obj/effect/landmark/loot_spawn/ammo
	name = "ammo loot spawn"
	icon_state = "x"
	max_items = 2
	spawn_chance = 90

/obj/effect/landmark/loot_spawn/ammo
	Initialize(mapload)
		. = ..()
		loot_table = GLOB.ammo_loot_table.Copy()

/obj/effect/landmark/loot_spawn/food
	name = "food loot spawn"
	icon_state = "x3"
	max_items = 3
	spawn_chance = 90

/obj/effect/landmark/loot_spawn/food
	Initialize(mapload)
		. = ..()
		loot_table = GLOB.food_loot_table.Copy()

/obj/effect/landmark/loot_spawn/treasure
	name = "treasure loot spawn"
	icon_state = "x4"
	max_items = 1
	spawn_chance = 90

/obj/effect/landmark/loot_spawn/treasure
	Initialize(mapload)
		. = ..()
		loot_table = GLOB.treasure_loot_table.Copy()

/obj/effect/landmark/loot_spawn/clothing
	name = "clothing loot spawn"
	icon_state = "city_of_cogs"
	max_items = 1
	spawn_chance = 70

/obj/effect/landmark/loot_spawn/clothing
	Initialize(mapload)
		. = ..()
		loot_table = GLOB.clothing_loot_table.Copy()

/obj/effect/landmark/loot_spawn/fashion_jacket
	name = "Fashion Jacket Spawn"
	icon_state = "city_of_cogs"
	loot_table = list(/obj/item/clothing/suit/jacket/leather_trenchcoat = 100)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/information
	name = "info loot spawn"
	icon_state = "random_loot"
	max_items = 1
	spawn_chance = 50

/obj/effect/landmark/loot_spawn/information
	Initialize(mapload)
		. = ..()
		loot_table = GLOB.info_loot_table.Copy()

/obj/effect/landmark/loot_spawn/technical
	name = "technical loot spawn"
	icon_state = "clockwork_orange"
	max_items = 2
	spawn_chance = 80

/obj/effect/landmark/loot_spawn/technical
	Initialize(mapload)
		. = ..()
		loot_table = GLOB.technical_loot_table.Copy()

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

/obj/effect/landmark/loot_spawn/seer_letter1
	name = "Seer Letter One"
	icon_state = "random_loot"
	loot_table = list(/obj/item/paper/fluff/eftk/seer/one = 100)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/seer_letter2
	name = "Seer Letter Two"
	icon_state = "random_loot"
	loot_table = list(/obj/item/paper/fluff/eftk/seer/two = 100)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/seer_letter3
	name = "Seer Letter Tree"
	icon_state = "random_loot"
	loot_table = list(/obj/item/paper/fluff/eftk/seer/tree = 100)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/advice_letters
	name = "Advice Letters Spawn"
	icon_state = "random_loot"
	loot_table = list(
		/obj/item/paper/fluff/eftk/advice/blessed = 100,
		/obj/item/paper/fluff/eftk/advice/keksuha = 100
	)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/mine_info
	name = "Mine Info Spawn"
	icon_state = "random_loot"
	loot_table = list(/obj/item/paper/fluff/eftk/mine = 100)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/quartermaster_letter
	name = "Quartermaster Letter Spawn"
	icon_state = "random_loot"
	loot_table = list(/obj/item/paper/fluff/eftk/quartermaster = 100)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/telephone_list
	name = "Telephone List Spawn"
	icon_state = "random_loot"
	loot_table = list(/obj/item/paper/fluff/eftk/phone = 100)
	max_items = 1
	spawn_chance = 100

/obj/effect/landmark/loot_spawn/walter_letter
	name = "Walter Letter Spawn"
	icon_state = "random_loot"
	loot_table = list(/obj/item/paper/fluff/eftk/home_walter = 100)
	max_items = 1
	spawn_chance = 100

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
	resistance_flags = INDESTRUCTIBLE

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
	if(do_after(user, 3 SECONDS, src))
		if(prob(loot_chance))
			user.visible_message(span_notice("[user] finds something inside the [src]."), \
				span_notice("You find something interesting inside the [src]."))
			if(prob(good_loot_chance))
				var/path = pick_weight(good_loot_type)
				new path(loc)
			else
				var/path = pick_weight(loot_type)
				new path(loc)
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
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 60
	good_loot_chance = 30

/obj/structure/loot/technical_crate
	Initialize(mapload)
		. = ..()
		loot_type = GLOB.technical_loot_table.Copy()
		good_loot_type = GLOB.info_loot_table.Copy()

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
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 50
	good_loot_chance = 30

/obj/structure/loot/army_crate
	Initialize(mapload)
		. = ..()
		loot_type = GLOB.ammo_loot_table.Copy()
		good_loot_type = GLOB.weapon_loot_table.Copy()

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
	icon_state = "footlocker_wood"
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 80
	good_loot_chance = 30

/obj/structure/loot/footlocker
	Initialize(mapload)
		. = ..()
		loot_type = GLOB.clothing_loot_table.Copy()
		good_loot_type = GLOB.treasure_loot_table.Copy()

/obj/structure/loot/shelf
	name = "shelf"
	desc = "A sturdy wooden shelf to store a variety of items on."
	icon = 'modular_bandastation/voyaker_events/icons/furniture.dmi'
	icon_state = "shelf_1"
	density = TRUE
	anchored = TRUE
	loot_chance = 60
	good_loot_chance = 30

/obj/structure/loot/shelf/Initialize(mapload)
	. = ..()
	loot_type = GLOB.food_loot_table.Copy()
	good_loot_type = GLOB.treasure_loot_table.Copy()
	if(random_appearence)
		icon_state = pick("shelf_1","shelf_2","shelf_3","shelf_4","shelf_5","shelf_6","shelf_7","shelf_8","shelf_9","shelf_10","shelf_11")

/obj/structure/loot/long_shelf_metal
	name = "long metal shelf"
	desc = "A sturdy metal shelf to store a variety of items on."
	icon = 'modular_bandastation/voyaker_events/icons/supermart.dmi'
	icon_state = "longrack_1"
	density = TRUE
	anchored = TRUE
	loot_chance = 60
	good_loot_chance = 30

/obj/structure/loot/long_shelf_metal/Initialize(mapload)
	. = ..()
	loot_type =  GLOB.food_loot_table.Copy()
	good_loot_type = GLOB.treasure_loot_table.Copy()
	if(random_appearence)
		icon_state = pick("longrack1","longrack2","longrack3","longrack4","longrack5","longrack6","longrack7")

/obj/structure/loot/file_cabinet
	name = "file cabinet"
	desc = "A sturdy metal cabinet to store a variety of documents."
	icon = 'modular_bandastation/voyaker_events/icons/cabinets.dmi'
	icon_state = "filing_cabinet"
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 40

/obj/structure/loot/file_cabinet/Initialize(mapload)
	. = ..()
	loot_type = GLOB.info_loot_table.Copy()
	good_loot_type = GLOB.treasure_loot_table.Copy()

/obj/structure/loot/file_cabinet/small
	name = "small file cabinet"
	desc = "A sturdy small metal cabinet to store a variety of documents."
	icon_state = "filing_cabinet_small"

/obj/structure/loot/skeleton
	name = "skeleton"
	desc = "An old human skeleton, perhaps there is still something on this bones."
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "skeleton"
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 60

/obj/structure/loot/skeleton/Initialize(mapload)
	. = ..()
	loot_type = GLOB.clothing_loot_table.Copy()
	good_loot_type = GLOB.treasure_loot_table.Copy()

/obj/structure/loot/skeleton/army/Initialize(mapload)
	. = ..()
	loot_type =  GLOB.clothing_loot_table.Copy()
	good_loot_type = GLOB.weapon_loot_table.Copy()
