/obj/effect/mob_spawn/corpse/human/tsf
	name = "TSF Marine Body"
	outfit = /datum/outfit/tsf/marine_unarmed/dead
	brute_damage = 100
	burn_damage = 100
	mob_species = /datum/species/skeleton
	mob_name = "Неизвестный"

/obj/effect/mob_spawn/corpse/human/tsf/marine
	name = "TSF Marine Body"
	outfit = /datum/outfit/tsf/marine/dead

/obj/effect/mob_spawn/corpse/human/tsf/marine_officer
	name = "TSF Marine Squad Leader"
	outfit = /datum/outfit/tsf/marine/officer/dead

/obj/effect/mob_spawn/corpse/human/tsf/marsoc
	name = "TSF MARSOC"
	outfit = /datum/outfit/tsf/marsoc_unarmed/dead

/obj/effect/mob_spawn/corpse/human/ussp
	name = "USSP Ryadovoy"
	outfit = /datum/outfit/ussp/soldier_unarmed/dead
	brute_damage = 100
	burn_damage = 100
	mob_species = /datum/species/skeleton
	mob_name = "Неизвестный"

/obj/effect/mob_spawn/corpse/human/ussp/ryadovoy
	name = "USSP Ryadovoy"
	outfit = /datum/outfit/ussp/military/dead

/obj/effect/mob_spawn/corpse/human/ussp/spetsnaz
	name = "USSP SPETSNAZ"
	outfit = /datum/outfit/ussp/spetsnaz_unarmed/dead

/obj/effect/mob_spawn/corpse/human/ussp/officer
	name = "USSP Officer"
	outfit = /datum/outfit/ussp/ussp_officer/dead

/obj/effect/mob_spawn/corpse/human/irs_agent
	name = "IRS Agent"
	outfit = /datum/outfit/pirate/irs
	brute_damage = 100
	burn_damage = 100
	mob_species = /datum/species/skeleton
	mob_name = "Неизвестный"

/obj/effect/mob_spawn/corpse/human/special(mob/living/carbon/human/spawned_human, mob/mob_possessor, apply_prefs)
	spawned_human.ignore_raid_death = TRUE
	. = ..()

/datum/outfit/tsf/marine_unarmed/dead
	name = "TSF - Dead Marine (Unarmed)"
	back = null
	backpack_contents = null

/datum/outfit/tsf/marine/dead
	name = "TSF - Dead and Looted Marine Rifleman"
	suit = /obj/item/clothing/suit/armor/vest/marine/sulaco
	suit_store = null
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/regular,
		/obj/item/clothing/head/beret/tsf_marine,
	)
	head = /obj/item/clothing/head/helmet/marine/sulaco
	belt = /obj/item/storage/belt/military/army

/datum/outfit/tsf/marine/officer/dead
	name = "TSF - Dead and Looted Marine Officer"
	suit = /obj/item/clothing/suit/armor/vest/marine/sulaco
	suit_store = null
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/clothing/head/beret/tsf_marine_officer,
	)
	belt = /obj/item/storage/belt/military/army
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	neck = /obj/item/binoculars
	head = /obj/item/clothing/head/helmet/marine/sulaco

/datum/outfit/tsf/marsoc_unarmed/dead
	name = "TSF - Dead MARSOC (Unarmed)"
	back = null
	backpack_contents = null
	belt = /obj/item/storage/belt/military/army

/datum/outfit/ussp/soldier_unarmed/dead
	name = "USSP - Dead Red Army Ryadovoy (Unarmed)"
	back = null
	backpack_contents = null

/datum/outfit/ussp/military/dead
	name = "USSP - Dead Red Army Ryadovoy"
	suit = /obj/item/clothing/suit/armor/vest/marine/security/ussp_security/broken
	suit_store = null
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/ussp,
		/obj/item/storage/medkit/emergency,
	)
	head = /obj/item/clothing/head/helmet/marine/security/ussp_kaska/broken
	belt = /obj/item/storage/belt/military/army/ussp

/obj/item/clothing/suit/armor/vest/marine/security/ussp_security/broken
	armor_type = /datum/armor/derelict_marine

/obj/item/clothing/head/helmet/marine/security/ussp_kaska/broken
	armor_type = /datum/armor/derelict_marine

/datum/outfit/ussp/spetsnaz_unarmed/dead
	name = "USSP - Dead SPETSNAZ (Unarmed)"
	back = null
	backpack_contents = null
	belt = /obj/item/storage/belt/military/army/ussp

/datum/outfit/ussp/ussp_officer/dead
	name = "USSP - Dead Red Army Officer (Unarmed)"
	belt = /obj/item/storage/belt/military/army/ussp
