/datum/outfit/centcom/ert/security
	l_hand = /obj/item/gun/energy/disabler/smg
	backpack_contents = list(
		/obj/item/melee/baton/telescopic/gold = 1,
		/obj/item/storage/box/handcuffs = 2,
	)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/tackler

/datum/outfit/centcom/ert/security/alert
	l_hand = /obj/item/gun/energy/e_gun

/datum/outfit/centcom/ert/engineer
	l_hand = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/construction/rcd/loaded/upgraded = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/stack/sheet/iron = 50,
		/obj/item/stack/sheet/glass = 50,
		/obj/item/stack/sheet/plasteel = 50
	)

/datum/outfit/centcom/ert/engineer/alert
	l_hand = /obj/item/gun/energy/e_gun
	backpack_contents = list(
		/obj/item/construction/rcd/loaded/upgraded = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/stack/sheet/iron = 50,
		/obj/item/stack/sheet/glass = 50,
		/obj/item/stack/sheet/plasteel = 50
		/obj/item/melee/baton/security/boomerang = 1
	)

/datum/outfit/centcom/ert/medic
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/reagent_containers/hypospray = 1,
		/obj/item/storage/box/hug/plushes = 1,
	)
	r_hand = /obj/item/gun/energy/disabler

/datum/outfit/centcom/ert/medic/alert
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/reagent_containers/hypospray = 1,
		/obj/item/storage/box/hug/plushes = 1,
		/obj/item/storage/box/medipens = 1,
		/obj/item/storage/medkit/advanced = 1,
	)
	r_hand = /obj/item/gun/energy/e_gun

/datum/outfit/centcom/ert/commander
	backpack_contents = list(
		/obj/item/megaphone/command = 1,
		/obj/item/ammo_box/magazine/wt550m9 = 3,
	)
	l_hand = /obj/item/gun/ballistic/automatic/wt550

/datum/outfit/centcom/ert/commander/alert
	l_hand = /obj/item/gun/energy/e_gun/nuclear
	l_pocket = /obj/item/melee/energy/sword/blue

/datum/outfit/centcom/ert/janitor
	backpack_contents = list(
		/obj/item/grenade/clusterbuster/cleaner = 1,
		/obj/item/mop/advanced = 1,
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/construction/rtd = 1,
		/obj/item/lightreplacer = 1,
	)
	l_hand = /obj/item/storage/bag/trash

/datum/outfit/centcom/ert/janitor/heavy
	backpack_contents = list(
		/obj/item/grenade/clusterbuster/cleaner = 3,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/construction/rtd = 1,
		/obj/item/lightreplacer/blue = 1,
	)

/datum/outfit/centcom/ert/commander/gamma

/datum/antagonist/ert/security/gamma

/datum/antagonist/ert/medic/gamma

/datum/antagonist/ert/engineer/gamma

/datum/outfit/centcom/ert/commander/epsilon

/datum/antagonist/ert/security/epsilon

/datum/antagonist/ert/medic/epsilon

/datum/antagonist/ert/engineer/epsilon
