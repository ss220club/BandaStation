/datum/outfit/job/donor/representative_ussp
	name = "Representative USSP"
	jobtype = /datum/job/donor/representative_ussp
	id_trim = /datum/id_trim/job/donor_representative_ussp
	uniform = /obj/item/clothing/under/costume/soviet/ussp/officer
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/costume/soviet/ussp/officer
	head = /obj/item/clothing/head/hats/ussp/classic/officer
	gloves = /obj/item/clothing/gloves/color/black
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/red
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	box = /obj/item/storage/box/survival/mining
	backpack_contents = list(
		/obj/item/implanter/death_alarm = 1,
		/obj/item/lighter = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/clothing/under/shorts/red = 1,
		/obj/item/clothing/head/costume/ushanka = 1,
	)
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/death_alarm)

/datum/outfit/job/donor/representative_ussp/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/spinwarder)
