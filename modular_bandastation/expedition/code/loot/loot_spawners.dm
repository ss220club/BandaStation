#define WEAPON_LOOT "weapon_loot"
#define AMMO_LOOT "ammo_loot"
#define FOOD_LOOT "food_loot"
#define TREASURE_LOOT "treasure_loot"
#define CLOTHING_LOOT "clothing_loot"
#define INFO_LOOT "info_loot"
#define TECHNICAL_LOOT "technical_loot"

/obj/effect/spawner/random/loot_spawn
	name = "loot spawn"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	var/loot_table = WEAPON_LOOT

/obj/effect/spawner/random/loot_spawn/Initialize(mapload)
	switch(loot_table)
		if(WEAPON_LOOT)
			loot = GLOB.weapon_loot_table
		if(AMMO_LOOT)
			loot = GLOB.ammo_loot_table
		if(FOOD_LOOT)
			loot = GLOB.food_loot_table
		if(TREASURE_LOOT)
			loot = GLOB.treasure_loot_table
		if(CLOTHING_LOOT)
			loot = GLOB.clothing_loot_table
		if(INFO_LOOT)
			loot = GLOB.info_loot_table
		if(TECHNICAL_LOOT)
			loot = GLOB.technical_loot_table
	return ..()

/obj/effect/spawner/random/loot_spawn/medical
	name = "medical loot spawn"
	icon_state = "x3"
	loot = list(
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
	spawn_loot_count = 2
	spawn_loot_chance = 80

/obj/effect/spawner/random/loot_spawn/weapon
	name = "weapon loot spawn"
	icon_state = "x"
	spawn_loot_count = 1
	spawn_loot_chance = 70
	loot_table = WEAPON_LOOT

/obj/effect/spawner/random/loot_spawn/ammo
	name = "ammo loot spawn"
	icon_state = "x"
	spawn_loot_count = 2
	spawn_loot_chance = 90
	loot_table = AMMO_LOOT

/obj/effect/spawner/random/loot_spawn/food
	name = "food loot spawn"
	icon_state = "x3"
	spawn_loot_count = 3
	spawn_loot_chance = 90
	loot_table = FOOD_LOOT

/obj/effect/spawner/random/loot_spawn/treasure
	name = "treasure loot spawn"
	icon_state = "x4"
	spawn_loot_count = 1
	spawn_loot_chance = 90
	loot_table = TREASURE_LOOT

/obj/effect/spawner/random/loot_spawn/clothing
	name = "clothing loot spawn"
	icon_state = "city_of_cogs"
	spawn_loot_count = 1
	spawn_loot_chance = 70
	loot_table = CLOTHING_LOOT

/obj/effect/spawner/random/loot_spawn/information
	name = "info loot spawn"
	icon_state = "random_loot"
	spawn_loot_count = 1
	spawn_loot_chance = 50
	loot_table = INFO_LOOT

/obj/effect/spawner/random/loot_spawn/technical
	name = "technical loot spawn"
	icon_state = "clockwork_orange"
	spawn_loot_count = 2
	spawn_loot_chance = 80
	loot_table = TECHNICAL_LOOT

// /obj/effect/landmark/loot_spawn/magma_artifact
// 	name = "magma wing spawn"
// 	icon_state = "clockwork_orange"
// 	loot = list(/obj/item/artifact/fire_wing = 100)
// 	spawn_loot_count = 1
// 	spawn_loot_chance = 50

// /obj/effect/landmark/loot_spawn/ice_artifact
// 	name = "ice crystal spawn"
// 	icon_state = "clockwork_orange"
// 	loot = list(/obj/item/artifact/ice_crystal = 100)
// 	spawn_loot_count = 1
// 	spawn_loot_chance = 50

// /obj/effect/landmark/loot_spawn/stone_artifact
// 	name = "stone eye spawn"
// 	icon_state = "clockwork_orange"
// 	loot = list(/obj/item/artifact/stone_eye = 100)
// 	spawn_loot_count = 1
// 	spawn_loot_chance = 50

#undef WEAPON_LOOT
#undef AMMO_LOOT
#undef FOOD_LOOT
#undef TREASURE_LOOT
#undef CLOTHING_LOOT
#undef INFO_LOOT
#undef TECHNICAL_LOOT

/obj/structure/loot
	name = "trash bags"
	desc = "A collection of trash. Incomplete without you."
	icon = 'modular_bandastation/expedition/icons/miscellaneous.dmi'
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

/obj/structure/loot/examine(mob/user)
	. = ..()
	. += "<b>ПКМ</b> чтобы обыскать."

/obj/structure/loot/trash/garbage
	name = "trash bags"
	desc = "A collection of trash. Incomplete without you."
	icon = 'modular_bandastation/expedition/icons/miscellaneous.dmi'
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
	icon = 'modular_bandastation/expedition/icons/crates.dmi'
	desc = "Большой деревянный складской ящик. Возможно в нем хранится что-то полезное."
	icon_state = "wood_crate"
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 60
	good_loot_chance = 30

/obj/structure/loot/technical_crate/Initialize(mapload)
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
	icon = 'modular_bandastation/expedition/icons/crates.dmi'
	desc = "Военный ящик для хранения. Возможно в нем хранится что-то полезное."
	icon_state = "army"
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 50
	good_loot_chance = 30

/obj/structure/loot/army_crate/Initialize(mapload)
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
	icon = 'modular_bandastation/expedition/icons/crates.dmi'
	desc = "Ящик для хранения личных вещей. Возможно в нем хранится что-то полезное."
	icon_state = "footlocker_wood"
	random_appearence = FALSE
	density = TRUE
	anchored = TRUE
	loot_chance = 80
	good_loot_chance = 30

/obj/structure/loot/footlocker/Initialize(mapload)
	. = ..()
	loot_type = GLOB.clothing_loot_table.Copy()
	good_loot_type = GLOB.treasure_loot_table.Copy()

/obj/structure/loot/shelf
	name = "shelf"
	desc = "A sturdy wooden shelf to store a variety of items on."
	icon = 'modular_bandastation/expedition/icons/furniture.dmi'
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
	icon = 'modular_bandastation/expedition/icons/supermart.dmi'
	icon_state = "longrack1"
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
	icon = 'modular_bandastation/expedition/icons/cabinets.dmi'
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
	icon = 'modular_bandastation/expedition/icons/miscellaneous.dmi'
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
