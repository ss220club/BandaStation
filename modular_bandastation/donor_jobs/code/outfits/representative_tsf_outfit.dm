/datum/outfit/job/donor/representative_tsf
	name = "Representative TSF"
	jobtype = /datum/job/donor/representative_tsf
	id_trim = /datum/id_trim/job/donor_representative_tsf
	uniform = /obj/item/clothing/under/rank/tsf/commander
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/beret/tsf
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/white
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/black
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	box = /obj/item/storage/box/survival/mining
	backpack_contents = list(
		/obj/item/implanter/death_alarm = 1,
		/obj/item/lighter = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/clothing/under/shorts/blue = 1,
	)
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/death_alarm)

/datum/outfit/job/donor/representative_tsf/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/uncommon)
