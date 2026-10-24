/obj/effect/mob_spawn/corpse/human/skeleton/no_name
	name = "skeleton"
	mob_species = /datum/species/skeleton
	brute_damage = 100
	burn_damage = 100
	mob_name = "Скелет"


/mob/living/basic/faithless/old
	name = "The Old Faithless"
	desc = "The Wish Granter's faith in humanity, incarnate."
	icon = 'modular_bandastation/expedition/icons/faithlessold.dmi'
	icon_state = "faithlessold"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	gender = MALE
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	speed = 0.2
	maxHealth = 150
	health = 150
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	attack_sound = 'sound/effects/hallucinations/growl1.ogg'
	melee_attack_cooldown = 0.5 SECONDS
	speak_emote = list("growls")

//DO NOT FORGET TO SORT OUT


/mob/living/basic/trooper
	var/list/phrases = list()

/mob/living/basic/trooper/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	faction = list(ROLE_SYNDICATE)
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatesoldier
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatesoldier
	phrases = list(
		"ЗА СИНДИКАТ!",
		"Уничтожить цель!",
		"Противник!",
		"Корпораты!",
		"Работаем!",
		"Кепка!",
		"Эй, служивый!",
		"Пиздец тебе!",
		"Ликвидируем угрозу.",
	)
	melee_attack_cooldown = 1 SECONDS

/mob/living/basic/trooper/syndicate/Initialize(mapload)
	. = ..()
	shuffle_inplace(phrases)
	var/list/display_emote = list(
		BB_EMOTE_SAY = phrases,
		BB_SPEAK_CHANCE = 15, //CHANGE
	)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)

/mob/living/basic/trooper/syndicate/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	corpse = /obj/effect/gibspawner/human
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/space/corpse
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/space/stormtrooper/corpse
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/melee
	melee_damage_lower = 15
	melee_damage_upper = 15
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatesoldier

/mob/living/basic/trooper/syndicate/melee/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/melee/space/corpse
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/melee/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/melee/sword
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration = 35
	projectile_deflect_chance = 50
	r_hand = /obj/item/melee/energy/sword/saber/red
	l_hand = /obj/item/shield/energy

/mob/living/basic/trooper/syndicate/melee/sword/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	projectile_deflect_chance = 50
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/melee/sword/space/corpse
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	projectile_deflect_chance = 75
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper/corpse
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatecommando

///////////////Guns////////////
/mob/living/basic/trooper/syndicate/ranged
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatesoldier
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	ranged_cooldown = 5 DECISECONDS

/mob/living/basic/trooper/syndicate/ranged/infiltrator
	projectilesound = 'sound/items/weapons/gun/smg/shot_suppressed.ogg'
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatesoldier

/mob/living/basic/trooper/syndicate/ranged/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando
	corpse = /obj/effect/gibspawner/human

/mob/living/basic/trooper/syndicate/ranged/space
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/ranged/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper
	corpse = /obj/effect/gibspawner/human

/mob/living/basic/trooper/syndicate/ranged/space/stormtrooper
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/ranged/smg
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/items/weapons/gun/smg/shot.ogg'
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst
	burst_shots = 3
	r_hand = /obj/item/gun/ballistic/automatic/c20r
	ranged_cooldown = 5 DECISECONDS

/mob/living/basic/trooper/syndicate/ranged/smg/pilot
	name = "Syndicate Salvage Pilot"
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatepilot
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatepilot

/mob/living/basic/trooper/syndicate/ranged/smg/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando
	corpse = /obj/effect/gibspawner/human

/mob/living/basic/trooper/syndicate/ranged/smg/space
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/ranged/smg/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper
	corpse = /obj/effect/gibspawner/human

/mob/living/basic/trooper/syndicate/ranged/smg/space/stormtrooper
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/ranged/shotgun
	casingtype = /obj/item/ammo_casing/shotgun/buckshot //buckshot (up to 72.5 brute) fired in a two-round burst
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/shotgunner
	burst_shots = 2
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog
	ranged_cooldown = 5 DECISECONDS

/mob/living/basic/trooper/syndicate/ranged/shotgun/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando
	corpse = /obj/effect/gibspawner/human

/mob/living/basic/trooper/syndicate/ranged/shotgun/space
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/ranged/shotgun/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper
	corpse = /obj/effect/gibspawner/human

/mob/living/basic/trooper/syndicate/ranged/shotgun/space/stormtrooper
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/ranged/full_auto/smg9mm
	casingtype = /obj/item/ammo_casing/c9mm
	projectilesound = 'sound/items/weapons/gun/smg/shot.ogg'
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	burst_shots = 3
	r_hand = /obj/item/gun/ballistic/automatic/c20r

/mob/living/basic/trooper/pirate
	melee_attack_cooldown = 1 SECONDS
	phrases = list(//CHANGE
		"ЯРРР!",
		"ЯРРР!",
		"ЯРРР!",
		"ЯРРР!",
		"ЯРРР!",
		"ЯРРР!",
		"ЯРРР!",
		"ЯРРР!",
		"ЯЯРРР!",
	)

/mob/living/basic/trooper/pirate/Initialize(mapload)
	. = ..()
	shuffle_inplace(phrases)
	var/list/display_emote = list(
		BB_EMOTE_SAY = phrases,
		BB_SPEAK_CHANCE = 15, //CHANGE
	)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)

/mob/living/basic/trooper/pirate/melee/space
	loot = list(
		/obj/item/melee/energy/sword/pirate,
	)

/mob/living/basic/trooper/pirate/ranged
	ranged_cooldown = 5 DECISECONDS
	loot = list(/obj/item/gun/energy/laser/retro)

/mob/living/basic/trooper/assistant
	name = "Tider Assistant"
	desc = "У него явно не все хорошо с головой... А еще он хочет вас убить своим копьем, удивительно, не правда ли?"
	faction = list(FACTION_HOSTILE)
	melee_damage_lower = 15
	melee_damage_upper = 15
	mob_spawner = /obj/effect/mob_spawn/corpse/human/assistant/tider
	corpse = /obj/effect/mob_spawn/corpse/human/assistant/tider
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	r_hand = /obj/item/spear
	maxHealth = 100
	health = 100
	speed = 1.2
	melee_attack_cooldown = 1.1 SECONDS
	combat_mode = TRUE
	obj_damage = 20
	loot = list(/obj/item/spear)
	sharpness = SHARP_POINTY
	phrases = list(
		"ТЕБЕ КОНЕЦ!",
		"ВИВА!",
		"ТАЙД!",
		"УБЬЕМ!",
		"А НУ ИДИ СЮДА!",
		"ААААААААА!",
		"Я НАСАЖУ ТВОЮ ГОЛОВУ НА СВОЕ КОПЬЕ!",
		"ЗА БЕЗУДЕЛЬНЫХ!",
		"Я НЕ БУДУ РАБОТАТЬ!",
	)

	/// Male screams
	var/static/list/male_screams = list(
		'sound/mobs/humanoids/human/scream/malescream_1.ogg',
		'sound/mobs/humanoids/human/scream/malescream_2.ogg',
		'sound/mobs/humanoids/human/scream/malescream_3.ogg',
		'sound/mobs/humanoids/human/scream/malescream_4.ogg',
		'sound/mobs/humanoids/human/scream/malescream_5.ogg',
	)
	/// Female screams
	var/static/list/female_screams = list(
		'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
	)

/mob/living/basic/trooper/assistant/Initialize(mapload)
	. = ..()
	shuffle_inplace(phrases)
	var/list/display_emote = list(
		BB_EMOTE_SAY = phrases,
		BB_SPEAK_CHANCE = 15,
	)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)

	gender = pick(MALE, FEMALE, PLURAL)
	var/first_name
	switch(gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
			death_sound = pick(male_screams)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
			death_sound = pick(female_screams)
		if(PLURAL)
			first_name = pick(GLOB.first_names)
			death_sound = pick(male_screams + female_screams)
	fully_replace_character_name(name, "[first_name] [pick(GLOB.last_names)]")

/mob/living/basic/trooper/assistant/ranged
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	/// Type of bullet we use
	var/projectiletype = /obj/projectile/bullet/c9mm
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/items/weapons/gun/pistol/shot.ogg'
	/// number of burst shots
	var/burst_shots
	/// Time between taking shots
	var/ranged_cooldown = 1 SECONDS

/mob/living/basic/trooper/assistant/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = projectiletype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
	)
	if (ranged_cooldown <= 1 SECONDS)
		AddComponent(/datum/component/ranged_mob_full_auto)

/mob/living/basic/trooper/assistant/ranged/laser
	r_hand = /obj/item/gun/energy/laser/retro
	l_hand = /obj/item/spear
	burst_shots = 1
	ranged_cooldown = 5 DECISECONDS
	projectilesound = 'sound/items/weapons/laser.ogg'
	loot = list(/obj/item/gun/energy/laser/retro, /obj/item/spear)
	projectiletype = /obj/projectile/beam/laser

/obj/effect/mob_spawn/corpse/human/assistant/tider
	outfit = /datum/outfit/job/assistant/tider

/datum/outfit/job/assistant/tider
	belt = null
	mask = /obj/item/clothing/mask/gas
	pda_slot = null

/obj/projectile/neurotoxin
	damage_type = BURN

/mob/living/basic/alien
	melee_attack_cooldown = 7 DECISECONDS

/mob/living/basic/alien/sentinel
	health = 200
	maxHealth = 200
	melee_damage_lower = 25
	melee_damage_upper = 25
	projectiletype = /obj/projectile/neurotoxin/damaging

/mob/living/basic/alien/queen/large
	health = 700
	maxHealth = 700
	melee_damage_lower = 30
	melee_damage_upper = 30
	projectiletype = /obj/projectile/neurotoxin

/mob/living/basic/creature
	health = 100
	maxHealth = 100

/mob/living/basic/creature/hatchling
	health = 75
	maxHealth = 75

/mob/living/basic/living_limb_flesh
	melee_damage_lower = 15
	melee_damage_upper = 15

/mob/living/basic/zombie
	var/corpse = /obj/effect/mob_spawn/corpse/human/zombie
	var/mob_spawner = /obj/effect/mob_spawn/corpse/human/zombie
	var/list/loot
	melee_attack_cooldown = 1 SECONDS

/mob/living/basic/zombie/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, outfit, mob_spawn_path = mob_spawner, bloody_slots = ITEM_SLOT_OCLOTHING)
	if(LAZYLEN(loot) || corpse)
		LAZYOR(loot, corpse)
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)

/mob/living/basic/zombie/rotten
	ai_controller = /datum/ai_controller/basic_controller/zombie
	melee_damage_lower = 15
	melee_damage_upper = 15
	mob_spawner = /obj/effect/mob_spawn/corpse/human/zombie/assistant
	corpse = /obj/effect/mob_spawn/corpse/human/zombie/assistant

/mob/living/basic/zombie/syndie
	name = "Shambling Syndicate Corpse"
	melee_damage_lower = 20
	melee_damage_upper = 20
	maxHealth = 150
	health = 150
	speed = 3
	mob_spawner = /obj/effect/mob_spawn/corpse/human/zombie/syndie
	corpse = /obj/effect/mob_spawn/corpse/human/zombie/syndie

/obj/effect/mob_spawn/corpse/human/zombie/assistant
	outfit = /datum/outfit/job/assistant/tider
	mob_species = /datum/species/zombie

/obj/effect/mob_spawn/corpse/human/zombie/syndie
	outfit = /datum/outfit/syndicatecommandocorpse/lessenedgear
	mob_species = /datum/species/zombie

/obj/effect/mob_spawn/corpse/human/zombie
	outfit = /datum/outfit/corpse_doctor
	mob_species = /datum/species/zombie

/mob/living/basic/hivebot

/mob/living/basic/hivebot/rapid

/mob/living/basic/hivebot/range

/mob/living/basic/hivebot/strong

/mob/living/basic/hivebot/mechanic

/mob/living/basic/spider/giant

/mob/living/basic/statue/mannequin/suspicious

/mob/living/basic/statue
