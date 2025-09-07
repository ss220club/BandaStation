// MARK: Union of Soviet Socialist Planets //

// USSP default
/datum/outfit/ussp
	name = "USSP Base"

/datum/outfit/ussp/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/obj/item/card/id/advanced/ussp
	name = "\improper USSP ID"
	desc = "An ID straight from USSP."
	icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	icon_state = "card_ussp"
	assigned_icon_state = "assigned_faction"
	trim = /datum/id_trim/ussp
	wildcard_slots = WILDCARD_LIMIT_CENTCOM

/datum/id_trim/ussp
	access = list(ACCESS_CENT_GENERAL)
	assignment = "USSP"
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_ussp"
	sechud_icon_state = SECHUD_USSP
	department_color = COLOR_MAROON
	subdepartment_color = COLOR_MAROON
	big_pointer = TRUE
	pointer_color = COLOR_MAROON

// USSP Commander
/datum/outfit/ussp/commander
	name = "USSP - Commander"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/commander
	uniform = /obj/item/clothing/under/rank/ussp/commander
	suit = /obj/item/clothing/suit/armor/centcom_formal/ussp_commander
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/security,
		/obj/item/reagent_containers/hypospray/combat/nanites,
		/obj/item/storage/fancy/cigarettes/cigars,
		/obj/item/reagent_containers/cup/glass/bottle/vodka,
		/obj/item/stamp/ussp,
	)
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/hats/ussp_command
	mask = /obj/item/cigarette/pipe
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	glasses = /obj/item/clothing/glasses/thermal/eyepatch/tsf_commander
	belt = /obj/item/storage/belt/holster/detective/full/ert/ussp_commander
	r_pocket = /obj/item/storage/box/matches

/datum/id_trim/ussp/commander
	assignment = "USSP - General"
	trim_state = "trim_ussp_rank3"

/datum/id_trim/ussp/commander/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)) + ACCESS_COMMAND)

// USSP Soldier (Unarmed)
/datum/outfit/ussp/soldier_unarmed
	name = "USSP - Red Army Ryadovoy (Unarmed)"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/soldier
	uniform = /obj/item/clothing/under/rank/ussp/soldier
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
	)
	head = /obj/item/clothing/head/hats/ussp
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots

/datum/id_trim/ussp/soldier
	assignment = "USSP - Red Army Ryadovoy"
	big_pointer = FALSE
	trim_state = "trim_ussp_rank1"

/datum/id_trim/ussp/soldier/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)))

// USSP Soldier (Overcoat - Unarmed)
/datum/outfit/ussp/soldier_unarmed/overcoat
	name = "USSP - Red Army Ryadovoy (Overcoat - Unarmed)"
	suit = /obj/item/clothing/suit/armor/vest/ussp
	gloves = /obj/item/clothing/gloves/combat

// USSP Soldier (One Rifle)
/datum/outfit/ussp/soldier_unarmed/overcoat/rifle
	name = "USSP - Red Army Srochnik (One Rifle)"
	id_trim = /datum/id_trim/ussp/soldier/srochnik
	suit = /obj/item/clothing/suit/armor/vest/ussp
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/gun/ballistic/rifle/boltaction
	r_pocket = /obj/item/radio/off
	backpack_contents = null
	ears = null
	belt = /obj/item/storage/belt/military/army/ussp/full_rifle_small

/datum/id_trim/ussp/soldier/srochnik
	assignment = "USSP - Red Army Srochnik"

// USSP Officer (Unarmed)
/datum/outfit/ussp/ussp_officer
	name = "USSP - Red Army Officer (Unarmed)"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/soldier/officer
	uniform = /obj/item/clothing/under/rank/ussp/officer
	suit = /obj/item/clothing/suit/armor/vest/ussp/officer
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
		/obj/item/binoculars
	)
	head = /obj/item/clothing/head/hats/ussp_officer
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/military/army/ussp/full

/datum/id_trim/ussp/soldier/officer
	assignment = "USSP - Red Army Officer"
	trim_state = "trim_ussp_rank2"
	big_pointer = TRUE

// USSP Military
//Rifleman
/datum/outfit/ussp/military
	name = "USSP - Red Army Ryadovoy"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/soldier
	uniform = /obj/item/clothing/under/rank/ussp/soldier
	suit = /obj/item/clothing/suit/armor/vest/marine/security/ussp_security
	suit_store = /obj/item/gun/ballistic/automatic/sabel
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/emergency,
		/obj/item/grenade/smokebomb,
	)
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/balaclava/breath
	head = /obj/item/clothing/head/helmet/marine/security/ussp_kaska
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	belt = /obj/item/storage/belt/military/army/ussp/full_autorifle
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/knife/combat

//Officer
/datum/outfit/ussp/military/officer
	name = "USSP - Red Army Officer"
	id_trim = /datum/id_trim/ussp/soldier/officer
	uniform = /obj/item/clothing/under/rank/ussp/officer
	suit = /obj/item/clothing/suit/armor/vest/marine/ussp_officer
	suit_store = /obj/item/gun/ballistic/automatic/sabel/auto/modern // не уверен
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/box/zipties,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/melee/baton,
	)
	glasses = /obj/item/clothing/glasses/hud/security/night
	neck = /obj/item/binoculars
	head = /obj/item/clothing/head/helmet/marine/ussp_officer_kaska
	mask = /obj/item/clothing/mask/breath/red_gas

//Medic
/datum/outfit/ussp/military/medic
	name = "USSP - Red Army Sanitar"
	id_trim = /datum/id_trim/ussp/soldier/medic
	suit = /obj/item/clothing/suit/armor/vest/marine/medic/ussp_medic
	suit_store = /obj/item/gun/ballistic/rifle/boltaction
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/medkit/tactical = 1,
		/obj/item/defibrillator/compact/loaded
	)
	head = /obj/item/clothing/head/helmet/marine/security/ussp_kaska/medic
	glasses = /obj/item/clothing/glasses/hud/health
	belt = /obj/item/storage/belt/military/army/ussp/full_rifle
	l_pocket = /obj/item/healthanalyzer/advanced

	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/id_trim/ussp/soldier/medic
	assignment = "USSP - Red Army Sanitar"

//Engineer
/datum/outfit/ussp/military/engineer
	name = "USSP - Red Army Stroibat"
	id_trim = /datum/id_trim/ussp/soldier/engineer
	suit = /obj/item/clothing/suit/armor/vest/marine/engineer/ussp_engineer
	suit_store = /obj/item/gun/ballistic/rifle/sks
	back = /obj/item/deployable_turret_folded
	backpack_contents = null
	l_pocket = /obj/item/wrench
	belt = /obj/item/storage/belt/military/army/ussp/full_engineer

/datum/id_trim/ussp/soldier/engineer
	assignment = "USSP - Red Army Stroibat"

//Riot
/datum/outfit/ussp/military/riot
	name = "USSP - OMON"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/soldier/riot
	uniform = /obj/item/clothing/under/rank/ussp/militsiya
	suit = /obj/item/clothing/suit/armor/riot/ussp_riot
	suit_store = /obj/item/gun/ballistic/shotgun/riot_one_hand
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/megaphone/sec,
		/obj/item/storage/medkit/emergency,
		/obj/item/storage/box/zipties,
		/obj/item/storage/box/rubbershot,
		/obj/item/storage/box/rubbershot,
		/obj/item/storage/box/rubbershot,
	)
	head = /obj/item/clothing/head/helmet/toggleable/riot/ussp_riot
	mask = /obj/item/clothing/mask/balaclava/breath
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	glasses = /obj/item/clothing/glasses/hud/security/night
	belt = /obj/item/melee/baton
	r_hand = /obj/item/shield/riot/flash/ussp
	l_pocket = /obj/item/assembly/flash
	r_pocket = /obj/item/grenade/flashbang

/datum/id_trim/ussp/soldier/riot
	assignment = "USSP - OMON"

// USSP SPETSNAZ (Unarmed)
/datum/outfit/ussp/spetsnaz_unarmed
	name = "USSP - SPETSNAZ (Unarmed)"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/spetsnaz
	uniform = /obj/item/clothing/under/rank/ussp/spetsnaz
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
	)
	belt = /obj/item/storage/belt/military/army/ussp/full
	mask = /obj/item/clothing/mask/balaclava/breath
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat

/datum/id_trim/ussp/spetsnaz
	assignment = "USSP - SPETSNAZ"

/datum/id_trim/ussp/spetsnaz/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)) + ACCESS_COMMAND)

// USSP SPETSNAZ Officer (Unarmed)
/datum/outfit/ussp/spetsnaz_unarmed/officer
	name = "USSP - SPETSNAZ Officer (Unarmed)"
	id_trim = /datum/id_trim/ussp/spetsnaz/officer

/datum/id_trim/ussp/spetsnaz/officer
	assignment = "USSP - SPETSNAZ Officer"
	trim_state = "trim_ussp_rank2"

// USSP SPETSNAZ (MOD).
/datum/outfit/ussp/spetsnaz
	name = "USSP - SPETSNAZ"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/spetsnaz
	uniform = /obj/item/clothing/under/rank/ussp/spetsnaz
	suit_store = /obj/item/gun/ballistic/automatic/sabel/auto/upp
	back = /obj/item/mod/control/pre_equipped/ussp_standart
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/c4 = 2,
	)
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/balaclava/breath
	glasses = /obj/item/clothing/glasses/meson/night
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	belt = /obj/item/storage/belt/military/army/ussp/full_autorifle_spetsnaz
	r_pocket = /obj/item/flashlight/seclite
	l_pocket = /obj/item/knife/combat

// USSP SPETSNAZ Officer (MOD)
/datum/outfit/ussp/spetsnaz/officer
	name = "USSP - SPETSNAZ Officer"
	id_trim = /datum/id_trim/ussp/spetsnaz/officer
	suit_store = /obj/item/gun/ballistic/automatic/sabel/auto/gauss
	back = /obj/item/mod/control/pre_equipped/ussp_elite
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/c4 = 2,
	)
	neck = /obj/item/binoculars

// USSP infiltrator
/datum/outfit/ussp/infiltrator
	name = "USSP - Infiltrator"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/infiltrator
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/hooded/stealth_cloak
	suit_store = /obj/item/gun/ballistic/automatic/sabel/auto/upp/suppressed
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/emergency,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/c4 = 2,
	)
	implants = list(/obj/item/implant/emp, /obj/item/implant/cqc)
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/balaclava/breath
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	neck = /obj/item/binoculars
	belt = /obj/item/storage/belt/military/army/ussp/full_infiltrator
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double

/datum/id_trim/ussp/infiltrator
	assignment = "USSP - Razvedka"
	trim_state = "trim_ussp_rank2"
	big_pointer = FALSE

/datum/id_trim/ussp/infiltrator/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

// USSP representative
/datum/outfit/ussp/representative
	name = "USSP - Representative"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/representative
	uniform = /obj/item/clothing/under/rank/ussp/officer
	suit = /obj/item/clothing/suit/armor/vest/ussp/officer
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/box/matches,
		/obj/item/storage/fancy/cigarettes/cigars,
		/obj/item/stamp/ussp,
		/obj/item/folder/red,
		/obj/item/pen/fourcolor,
	)
	head = /obj/item/clothing/head/hats/ussp_officer
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	l_pocket = /obj/item/stack/spacecash/c1000

/datum/id_trim/ussp/representative
	assignment = "Union of Soviet Socialist Planets Representative"

/datum/id_trim/ussp/representative/New()
	. = ..()
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_SECURITY - ACCESS_CAPTAIN - ACCESS_AI_UPLOAD)

// USSP diplomat
/datum/outfit/ussp/diplomat
	name = "USSP - Diplomat"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/diplomat
	uniform = /obj/item/clothing/under/rank/ussp/official
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes/cigars,
		/obj/item/stamp/ussp,
		/obj/item/folder/red,
		/obj/item/pen/fourcolor,
	)
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/hats/ussp_officer
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	l_hand = /obj/item/storage/briefcase
	l_pocket = /obj/item/stack/spacecash/c1000

/datum/id_trim/ussp/diplomat
	assignment = "Union of Soviet Socialist Planets Diplomat"
	trim_state = "trim_ussp_rank3"

/datum/id_trim/ussp/diplomat/New()
	. = ..()
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_SECURITY - ACCESS_CAPTAIN - ACCESS_AI_UPLOAD)
