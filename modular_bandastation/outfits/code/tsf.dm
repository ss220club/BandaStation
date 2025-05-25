// MARK: Trans-Solar Federation //

// TSF default
/datum/outfit/tsf
	name = "TSF Base"

/datum/outfit/tsf/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/obj/item/card/id/advanced/tsf
	name = "\improper CentCom ID"
	desc = "An ID straight from TSF."
	icon_state = "card_black"
	assigned_icon_state = "assigned"
	trim = /datum/id_trim/tsf
	wildcard_slots = WILDCARD_LIMIT_CENTCOM


/datum/id_trim/tsf
	access = list(ACCESS_CENT_GENERAL)
	assignment = "TSF"
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_explorer"
	trim_state = "trim_tsf"
	sechud_icon_state = SECHUD_TSF
	department_color = COLOR_UNION_JACK_BLUE
	subdepartment_color = COLOR_UNION_JACK_BLUE
	big_pointer = TRUE
	pointer_color = COLOR_UNION_JACK_BLUE

// TSF Commander
/datum/outfit/tsf/commander
	name = "TSF - Commander"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/commander
	uniform = /obj/item/clothing/under/rank/tsf/commander
	suit = /obj/item/clothing/suit/armor/centcom_formal/tsf_commander
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/security,
		/obj/item/reagent_containers/hypospray/combat/nanites,
		/obj/item/storage/fancy/cigarettes/cigars/havana,
		/obj/item/stamp/tsf,
	)
	belt = /obj/item/storage/belt/holster/detective/full/ert/tsf_commander
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/beret/tsf_commander
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/thermal/eyepatch/tsf_commander
	r_pocket = /obj/item/lighter

/datum/id_trim/tsf/commander
	assignment = "TSF - Commander Officer"
	trim_state = "trim_tsf_command"

/datum/id_trim/tsf/commander/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)) + ACCESS_COMMAND)

/obj/item/storage/belt/holster/detective/full/ert/tsf_commander
	name = "TSF commander's holster"
	desc = "Wearing this makes you feel badass."

/obj/item/storage/belt/holster/detective/full/ert/tsf_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/r10mm = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle/regal = 1,
	),src)

/obj/item/radio/headset/heads/captain/alt/tsf
	name = "\proper TSF's bowman headset"
	keyslot = /obj/item/encryptionkey/headset_cent
	keyslot2 = /obj/item/encryptionkey/heads/captain

/obj/item/clothing/glasses/thermal/eyepatch/tsf_commander
	clothing_traits = list(TRAIT_SECURITY_HUD)
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS

// TSF Marine (Unarmed)
/datum/outfit/tsf/marine_unarmed
	name = "TSF - Marine (Unarmed)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine
	uniform = /obj/item/clothing/under/rank/tsf/marine
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
	)
	head = /obj/item/clothing/head/beret/tsf_marine
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/sunglasses

/datum/id_trim/tsf/marine
	assignment = "TSF - Marine"
	big_pointer = FALSE

/datum/id_trim/tsf/marine/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)))

// TSF Marine Officer (Unarmed)
/datum/outfit/tsf/marine_officer
	name = "TSF - Marine Officer (Unarmed)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/officer
	uniform = /obj/item/clothing/under/rank/tsf/marine_officer
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
		/obj/item/binoculars
	)
	head = /obj/item/clothing/head/beret/tsf_marine_officer
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/military/army/tsf/full
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf

/datum/id_trim/tsf/marine/officer
	assignment = "TSF - Marine Officer"
	trim_state = "trim_tsf_officer"

/obj/item/storage/belt/military/army/tsf
	name = "army belt"
	desc = "A belt used by military forces."
	icon_state = "military"
	inhand_icon_state = "security"
	worn_icon_state = "military"
	storage_type = /datum/storage/military_belt/tsf

/datum/storage/military_belt/tsf
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 5

/obj/item/storage/belt/military/army/tsf/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/knife/combat(src)

/datum/storage/military_belt/tsf
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 8

/obj/item/clothing/glasses/hud/security/sunglasses/tsf
	name = "HUDSunglasses"
	icon_state = "sunhudmed"

// TSF Marine - это новые /datum/outfit/centcom/ert/marine, а те будут переделаны под СРТ.
//Officer
/datum/outfit/tsf/marine
	name = "TSF - Marine Officer"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/officer
	suit = /obj/item/clothing/suit/armor/vest/marine
	suit_store = /obj/item/gun/ballistic/automatic/wt550
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/box/zipties,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/shield/riot/tele,
		/obj/item/melee/baton/telescopic/silver,
		/obj/item/gun/ballistic/automatic/pistol/m1911,
	)
	belt = /obj/item/storage/belt/military/assault/full
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	glasses = /obj/item/clothing/glasses/hud/security/night
	l_pocket = /obj/item/knife/combat
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	uniform = /obj/item/clothing/under/rank/tsf/marine_officer
	mask = /obj/item/clothing/mask/gas/sechailer
	neck = /obj/item/binoculars
	head = /obj/item/clothing/head/helmet/marine

//Rifleman
/datum/outfit/tsf/marine/rifleman
	name = "TSF - Marine Rifleman"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine
	suit = /obj/item/clothing/suit/armor/vest/marine
	suit_store = /obj/item/gun/ballistic/automatic/wt550
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/emergency,
		/obj/item/grenade/smokebomb,
		/obj/item/gun/ballistic/automatic/pistol/m1911
	)
	belt = /obj/item/storage/belt/military/assault/full
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	uniform = /obj/item/clothing/under/rank/tsf/marine
	mask = /obj/item/clothing/mask/gas/sechailer
	head = /obj/item/clothing/head/helmet/marine/security

//Medic
/datum/outfit/tsf/marine/medic
	name = "TSF - Marine Corpsman"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/corpsman
	suit = /obj/item/clothing/suit/armor/vest/marine
	suit_store = /obj/item/gun/energy/e_gun/lethal
	back = /obj/item/storage/backpack/tsf
	l_pocket = /obj/item/healthanalyzer
	head = /obj/item/clothing/head/helmet/marine/medic
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/medkit/tactical = 1,
	)
	belt = /obj/item/storage/belt/medical/paramedic
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	uniform = /obj/item/clothing/under/rank/tsf/marine

	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/id_trim/tsf/marine/corpsman
	assignment = "TSF - Marine Corpsman"

//Engineer
/datum/outfit/tsf/marine/engineer
	name = "TSF - Marine Weapon Specialist"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/engineer
	suit = /obj/item/clothing/suit/armor/vest/marine/engineer
	suit_store = /obj/item/gun/ballistic/shotgun/lethal
	head = /obj/item/clothing/head/helmet/marine/engineer
	back = /obj/item/deployable_turret_folded
	backpack_contents = null
	uniform = /obj/item/clothing/under/rank/tsf/marine
	belt = /obj/item/storage/belt/military/army/tsf/full
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	l_pocket = /obj/item/wrench

/datum/id_trim/tsf/marine/engineer
	assignment = "TSF - Marine Weapon Specialist"

//Riot
/datum/outfit/tsf/marine/riot
	name = "TSF - Riot Specialist"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/riot
	uniform = /obj/item/clothing/under/rank/tsf/marine
	suit = /obj/item/clothing/suit/armor/riot
	suit_store = /obj/item/gun/ballistic/shotgun/riot_one_hand
	head = /obj/item/clothing/head/helmet/toggleable/riot
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	belt = /obj/item/storage/belt/security/full
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/emergency,
		/obj/item/storage/box/teargas,
		/obj/item/grenade/flashbang = 2,
		/obj/item/megaphone/sec,
		/obj/item/storage/box/rubbershot,
		/obj/item/storage/box/rubbershot,
		/obj/item/storage/box/rubbershot,
	)
	r_hand = /obj/item/shield/riot/flash
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/restraints/handcuffs

/obj/item/gun/ballistic/shotgun/riot_one_hand
	name = "one-hand riot shotgun"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot
	weapon_weight = WEAPON_MEDIUM

/datum/id_trim/tsf/marine/riot
	assignment = "TSF - Riot Specialist"

// TSF MARSOC - будут допилены иконки модов, оружие будет как зальют стволы Ингакема
// TSF MARSOC (Unarmed)
/datum/outfit/tsf/marsoc_unarmed
	name = "TSF - MARSOC (Unarmed)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marsoc
	uniform = /obj/item/clothing/under/rank/tsf/marsoc
	back = /obj/item/storage/backpack/tsf
	belt = /obj/item/storage/belt/military/army/tsf/full
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
	)
	head = /obj/item/clothing/head/beret/tsf_marsoc
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf

/datum/id_trim/tsf/marsoc
	assignment = "TSF - MARSOC"

/datum/id_trim/tsf/marsoc/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)) + ACCESS_COMMAND)

// TSF MARSOC Officer (Unarmed)
/datum/outfit/tsf/marsoc_officer_unarmed
	name = "TSF - MARSOC Officer (Unarmed)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marsoc/officer
	uniform = /obj/item/clothing/under/rank/tsf/marsoc_officer
	back = /obj/item/storage/backpack/tsf
	belt = /obj/item/storage/belt/military/army/tsf/full
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
	)
	head = /obj/item/clothing/head/beret/tsf_marsoc_officer
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf

/datum/id_trim/tsf/marsoc/officer
	assignment = "TSF - MARSOC Officer"
	trim_state = "trim_tsf_officer"

// TSF MARSOC (MOD)
/datum/outfit/tsf/marsoc
	name = "TSF - MARSOC"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marsoc
	uniform = /obj/item/clothing/under/rank/tsf/marsoc
	back = /obj/item/mod/control/pre_equipped/tsf_standart
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/clothing/head/beret/tsf_marsoc,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/c4 = 2,
		/obj/item/ammo_box/magazine/m223 = 4,
	)
	suit_store = /obj/item/gun/ballistic/automatic/m90/unrestricted
	belt = /obj/item/storage/belt/military/army/tsf/full
	r_pocket = /obj/item/flashlight/seclite
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/night
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots

// TSF MARSOC Officer (MOD)
/datum/outfit/tsf/marsoc_officer
	name = "TSF - MARSOC Officer"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marsoc/officer
	uniform = /obj/item/clothing/under/rank/tsf/marsoc_officer
	back = /obj/item/mod/control/pre_equipped/tsf_elite
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/c4 = 2,
		/obj/item/ammo_box/magazine/m223 = 4,
		/obj/item/shield/riot/tele,
		/obj/item/clothing/under/rank/tsf/marsoc_officer,
	)
	suit_store = /obj/item/gun/ballistic/automatic/ar
	belt = /obj/item/storage/belt/military/army/tsf/full
	r_pocket = /obj/item/flashlight/seclite
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/night
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	neck = /obj/item/binoculars

// TSF infiltrator
/datum/outfit/tsf/infiltrator
	name = "TSF - Infiltrator"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/infiltrator
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/hooded/stealth_cloak
	suit_store = /obj/item/gun/ballistic/automatic/c20r/unrestricted
	belt = /obj/item/storage/belt/military/army/tsf_infiltrator/full
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/medkit/emergency,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/c4 = 2,
		/obj/item/suppressor,
		/obj/item/clothing/head/beret/tsf_infiltrator
	)
	implants = list(/obj/item/implant/emp, /obj/item/implant/cqc)
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/breath/breathscarf/tsf_infiltrator
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	neck = /obj/item/binoculars
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double

/obj/item/storage/belt/military/army/tsf_infiltrator
	name = "army belt"
	desc = "A belt used by military forces."
	icon_state = "military"
	inhand_icon_state = "security"
	worn_icon_state = "military"
	storage_type = /datum/storage/military_belt/tsf

/obj/item/storage/belt/military/army/tsf_infiltrator/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/suppressed(src)
	new /obj/item/knife/combat(src)
	new /obj/item/ammo_box/magazine/m9mm/ap(src)
	new /obj/item/ammo_box/magazine/m9mm/ap(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/ammo_box/magazine/smgm45/ap(src)
	new /obj/item/ammo_box/magazine/smgm45/ap(src)

/obj/item/clothing/mask/breath/breathscarf/tsf_infiltrator
	greyscale_colors = COLOR_OLIVE

/datum/storage/military_belt/tsf
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 8

/datum/id_trim/tsf/infiltrator
	assignment = "TSF - Infiltrator"
	trim_state = "trim_tsf_officer"
	sechud_icon_state = SECHUD_TSF
	big_pointer = FALSE

/datum/id_trim/tsf/infiltrator/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

// TSF representative
/datum/outfit/tsf/representative
	name = "TSF - Representative"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/representative
	uniform = /obj/item/clothing/under/rank/tsf/representative
	suit = /obj/item/clothing/suit/armor/vest/tsf_overcoat
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/lighter/greyscale,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba,
		/obj/item/stamp/tsf,
		/obj/item/folder/blue,
		/obj/item/pen/fourcolor,
	)
	head = /obj/item/clothing/head/hats/tsf_fedora
	gloves = /obj/item/clothing/gloves/color/white
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/stack/spacecash/c1000

/datum/id_trim/tsf/representative
	assignment = "Trans-Solar Federation Representative"

/datum/id_trim/tsf/representative/New()
	. = ..()
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_SECURITY - ACCESS_CAPTAIN - ACCESS_AI_UPLOAD)

// TSF diplomat
/datum/outfit/tsf/diplomat
	name = "TSF - Diplomat"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/diplomat
	uniform = /obj/item/clothing/under/rank/tsf/formal
	suit = /obj/item/clothing/suit/tsf_suitjacket
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba,
		/obj/item/stamp/tsf,
		/obj/item/folder/blue,
		/obj/item/pen/fourcolor,
	)
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/beret/tsf_diplomat
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase
	neck = /obj/item/clothing/neck/tsf_fancy_cloak
	l_pocket = /obj/item/stack/spacecash/c1000
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf

/datum/id_trim/tsf/diplomat
	assignment = "Trans-Solar Federation Diplomat"
	trim_state = "trim_tsf_command"

/datum/id_trim/tsf/diplomat/New()
	. = ..()
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_SECURITY - ACCESS_CAPTAIN - ACCESS_AI_UPLOAD)
s
