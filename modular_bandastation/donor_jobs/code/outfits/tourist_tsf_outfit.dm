/datum/outfit/job/donor/tourist_tsf
	name = "Tourist TSF"
	jobtype = /datum/job/donor/tourist_tsf
	id_trim = /datum/id_trim/job/donor_tourist_tsf
	uniform = /obj/item/clothing/under/rank/tsf/marine
	suit = /obj/item/clothing/suit/hooded/wintercoat/zipup/tsf
	head = /obj/item/clothing/head/soft/tsf
	shoes = /obj/item/clothing/shoes/combat
	belt = /obj/item/storage/belt/fannypack/black
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	gloves = /obj/item/clothing/gloves/fingerless
	ears = /obj/item/radio/headset
	backpack_contents = list(/obj/item/clothing/under/shorts/blue = 1)

/datum/outfit/job/donor/tourist_tsf/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/uncommon)
