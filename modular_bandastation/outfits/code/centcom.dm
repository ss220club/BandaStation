// MARK: Nanotrasen CentCom //

/datum/outfit/centcom/post_equip(mob/living/carbon/human/centcom_member, visuals_only = FALSE)
	. = ..() // Now centcom staff have mindshield implants
	if(centcom_member.mind)
		centcom_member.mind.centcom_role = CENTCOM_ROLE_OFFICER

// Old Fashion CentCom Commander
/datum/outfit/centcom/spec_ops/old
	name = "Old Fashion Special Ops Officer"

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/specops_officer
	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/space/officer/browntrench
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom,
		/obj/item/ammo_box/speedloader/c357 = 3,
		/obj/item/storage/fancy/cigarettes/cigars
	)
	belt = /obj/item/gun/ballistic/revolver/mateba
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/soo
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/space/beret/soo
	mask = /obj/item/cigarette/cigar/havana
	shoes = /obj/item/clothing/shoes/jackboots/centcom
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites

// CentCom Junior-Officer
/datum/outfit/centcom/centcom_intern
	name = "Nanotrasen Navy Junior Officer"

	id_trim = /datum/id_trim/centcom/intern

/datum/outfit/centcom/centcom_intern/unarmed
	name = "Nanotrasen Navy Junior Officer (Unarmed)"

/datum/outfit/centcom/centcom_intern/leader
	name = "Nanotrasen Navy Junior Officer Chief"

	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/automatic/pistol/cm23
	belt = /obj/item/melee/baton/security/loaded
	head = /obj/item/clothing/head/beret/cent_intern
	l_hand = /obj/item/megaphone

/datum/outfit/centcom/centcom_intern/leader/unarmed
	name = "Nanotrasen Navy Junior Officer Chief (Unarmed)"

/datum/id_trim/centcom/intern
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = "Nanotrasen Navy Junior Officer"
	big_pointer = FALSE

/datum/id_trim/centcom/intern/head
	assignment = "Nanotrasen Navy Junior Officer Chief"

// CentCom Navy Officer
/datum/outfit/centcom/commander
	name = "Nanotrasen Navy Officer"

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/commander
	uniform = /obj/item/clothing/under/rank/centcom/official
	suit = /obj/item/clothing/suit/armor/centcom_formal
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom,
		/obj/item/stamp/centcom,
		/obj/item/lighter,
		/obj/item/door_remote/omni,
	)
	belt = /obj/item/gun/energy/pulse/pistol/m1911
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/centcom_officer
	gloves = /obj/item/clothing/gloves/combat/centcom
	head = /obj/item/clothing/head/helmet/space/beret
	mask = /obj/item/cigarette/cigar/cohiba
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/modular_computer/pda/heads/centcom
	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites

/datum/id_trim/centcom/commander
	assignment = "Nanotrasen Navy Officer"

// CentCom Field Officer
/datum/outfit/centcom/commander/field
	name = "Nanotrasen Navy Field Officer"

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/commander/field
	uniform = /obj/item/clothing/under/rank/centcom/official
	suit = /obj/item/clothing/suit/armor/centcom_formal/field
	back = /obj/item/storage/backpack/satchel/leather
	belt = /obj/item/storage/belt/centcom_sabre
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/centcom_officer
	gloves = /obj/item/clothing/gloves/combat/centcom
	head = /obj/item/clothing/head/helmet/space/beret
	mask = /obj/item/cigarette/cigar/cohiba
	shoes = /obj/item/clothing/shoes/jackboots/centcom
	r_pocket = /obj/item/modular_computer/pda/heads/centcom

/datum/id_trim/centcom/commander/field
	assignment = "Nanotrasen Navy Field Officer"

// CentCom Diplomat
/datum/outfit/centcom/diplomat
	name = "Nanotrasen Diplomat"

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/diplomat
	uniform = /obj/item/clothing/under/rank/centcom/diplomat
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom,
		/obj/item/stack/spacecash/c10000,
		/obj/item/pen/fourcolor,
		/obj/item/stamp/centcom,
		/obj/item/stamp/denied,
		/obj/item/stamp/granted,
		/obj/item/folder/blue,
		/obj/item/folder/red,
		/obj/item/storage/lockbox/medal
	)
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/combat/centcom/diplomat
	head = /obj/item/clothing/head/beret/cent_diplomat
	mask = /obj/item/cigarette/cigar/cohiba
	shoes = /obj/item/clothing/shoes/laceup/centcom
	r_pocket = /obj/item/lighter
	l_hand = /obj/item/storage/briefcase

/datum/outfit/centcom/diplomat/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/datum/id_trim/centcom/diplomat
	assignment = "Nanotrasen Diplomat"

/datum/id_trim/centcom/diplomat/New()
	. = ..()
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

// ERT & Marine Commander ID Access
/datum/id_trim/centcom/ert/commander/New()
	. = ..()
	access = access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

// DeathSquad outifit
/datum/outfit/centcom/death_commando/officer
	backpack_contents = list(
		/obj/item/ammo_box/speedloader/c357 = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/grenade/c4/x4 = 1,
		/obj/item/storage/box/syndie_kit/frag_grenades = 1,
		/obj/item/storage/medkit/tactical/premium = 1,
		/obj/item/disk/nuclear/death_commando = 1,
	)

/obj/item/disk/nuclear/death_commando
	fake = TRUE

/obj/item/disk/nuclear/death_commando/Initialize(mapload)
	. = ..()
	// So, functionality is dictated by var/fake
	// By making it TRUE on init, we don't give it roundstart nuke disk safety measures, etc.
	// So, this disk is just good for making bomb go boom
	fake = FALSE
	SSpoints_of_interest.make_point_of_interest(src)

/obj/item/storage/box/survival/centcom
	mask_type = /obj/item/clothing/mask/gas/sechailer
	medipen_type =  /obj/item/reagent_containers/hypospray/medipen/atropine

// NTCI Operatives
/datum/outfit/centcom/ntci
	name = "NTCI - Operative (Base)"
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/centcom/ntci
	uniform = /obj/item/clothing/under/rank/centcom/military
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom/ntci,
		/obj/item/lighter/skull,
		/obj/item/door_remote/omni,
	)
	belt = /obj/item/storage/belt/military/holster/ntci/full
	ears = /obj/item/radio/headset/headset_cent/alt/leader
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/beret/ert/ntci
	mask = /obj/item/clothing/mask/breath/breathscarf
	shoes = /obj/item/clothing/shoes/combat/swat
	r_pocket = /obj/item/knife/combat
	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites

/datum/id_trim/centcom/ntci
	assignment = "NTCI Operative"
	honorifics = list("Оперативник")
	honorific_positions = HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_NONE
	trim_state = "trim_deathcommando"

/obj/item/storage/box/survival/centcom/ntci/PopulateContents()
	. = ..()
	new /obj/item/extinguisher/mini(src)
	new /obj/item/radio/off(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/food/rationpack(src)

/datum/outfit/centcom/ntci/equipped
	name = "NTCI - Operative (Rifleman)"
	back = /obj/item/storage/backpack/duffelbag/syndie/centcom/ammo
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom,
		/obj/item/clothing/head/beret/ert/ntci,
		/obj/item/storage/medkit/tactical,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/c4,
		/obj/item/grenade/c4/x4,
		/obj/item/ammo_box/magazine/c762x39mm/ap,
		/obj/item/ammo_box/magazine/c762x39mm/ap,
		/obj/item/ammo_box/magazine/c762x39mm/incendiary,
		/obj/item/ammo_box/magazine/c762x39mm/emp,
	)
	suit = /obj/item/clothing/suit/armor/vest/ntci_chestplate
	suit_store = /obj/item/gun/ballistic/automatic/sabel/auto/gauss/tactical
	belt = /obj/item/storage/belt/military/holster/ntci/full_rifleman
	head = /obj/item/clothing/head/helmet/ntci_helmet

/datum/outfit/centcom/ntci/equipped/unmarked
	name = "NTCI - Unknown Operative (Rifleman)"
	id_trim = /datum/id_trim/centcom/ntci/unmarked
	uniform = /obj/item/clothing/under/shirt_black

/datum/id_trim/centcom/ntci/unmarked
	assignment = "Operative"

/datum/outfit/centcom/ntci/equipped/medic
	name = "NTCI - Operative (Medic)"
	id_trim = /datum/id_trim/centcom/ntci/medic
	back = /obj/item/storage/backpack/duffelbag/syndie/centcom/med
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom/ntci,
		/obj/item/clothing/head/beret/ert/ntci,
		/obj/item/storage/medkit/tactical/premium,
		/obj/item/defibrillator/compact/combat/loaded/nanotrasen,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/ammo_box/magazine/c762x39mm/ap,
		/obj/item/ammo_box/magazine/c762x39mm/ap,
		/obj/item/ammo_box/magazine/c762x39mm/incendiary,
		/obj/item/ammo_box/magazine/c762x39mm/emp,
	)

/datum/id_trim/centcom/ntci/medic
	assignment = "NTCI Operative Medic"

/datum/outfit/centcom/ntci/equipped/medic/unmarked
	name = "NTCI - Unknown Operative (Medic)"
	id_trim = /datum/id_trim/centcom/ntci/unmarked
	uniform = /obj/item/clothing/under/shirt_white

/datum/outfit/centcom/ntci/equipped/machinegunner
	name = "NTCI - Operative (Machinegunner)"
	id_trim = /datum/id_trim/centcom/ntci/machinegunner
	back = /obj/item/storage/backpack/duffelbag/syndie/centcom/ammo
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom/ntci,
		/obj/item/clothing/head/beret/ert/ntci,
		/obj/item/storage/medkit/tactical,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/c4,
		/obj/item/grenade/c4/x4,
		/obj/item/ammo_box/magazine/cm40/ap,
		/obj/item/ammo_box/magazine/cm40/ap,
		/obj/item/ammo_box/magazine/cm40/incendiary,
		/obj/item/ammo_box/magazine/cm40/hp,
		/obj/item/gun/ballistic/rocketlauncher/oneuse,
	)
	suit = /obj/item/clothing/suit/armor/vest/ntci_chestplate // Make heavy armor
	suit_store = /obj/item/gun/ballistic/automatic/cm40
	belt = /obj/item/storage/belt/military/holster/ntci/full_machinegun

/datum/id_trim/centcom/ntci/machinegunner
	assignment = "NTCI Operative Machinegunner"

/datum/outfit/centcom/ntci/equipped/machinegunner/unmarked
	name = "NTCI - Unknown Operative (Machinegunner)"
	id_trim = /datum/id_trim/centcom/ntci/unmarked
	uniform = /obj/item/clothing/under/tshirt_black

/datum/outfit/centcom/ntci/equipped/sniper
	name = "NTCI - Operative (Sniper)"
	id_trim = /datum/id_trim/centcom/ntci/sniper
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom/ntci,
		/obj/item/clothing/head/beret/ert/ntci,
		/obj/item/storage/medkit/tactical,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/c4,
		/obj/item/grenade/c4/x4,
		/obj/item/ammo_box/magazine/c338/extended,
		/obj/item/ammo_box/magazine/c338/extended/hp,
		/obj/item/ammo_box/magazine/c338/extended/ap,
		/obj/item/ammo_box/magazine/c338/extended/incendiary,
	)
	suit_store = /obj/item/gun/ballistic/automatic/f90
	belt = /obj/item/storage/belt/military/holster/ntci/full_sniper

/datum/id_trim/centcom/ntci/sniper
	assignment = "NTCI Operative Sniper"

/datum/outfit/centcom/ntci/equipped/sniper/unmarked
	name = "NTCI - Unknown Operative (Sniper)"
	id_trim = /datum/id_trim/centcom/ntci/unmarked
	uniform = /obj/item/clothing/under/hoodie_black
