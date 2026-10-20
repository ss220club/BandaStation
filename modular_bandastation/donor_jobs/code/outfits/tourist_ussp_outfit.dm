/datum/outfit/job/donor/tourist_ussp
	name = "Tourist USSP"
	jobtype = /datum/job/donor/tourist_ussp
	id_trim = /datum/id_trim/job/donor_tourist_ussp
	uniform = /obj/item/clothing/under/costume/soviet/ussp
	suit = /obj/item/clothing/suit/costume/soviet/ussp
	head = /obj/item/clothing/head/hats/ussp/classic
	shoes = /obj/item/clothing/shoes/combat
	belt = /obj/item/storage/belt/fannypack/red
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	glasses = /obj/item/clothing/glasses/sunglasses/big
	gloves = /obj/item/clothing/gloves/fingerless
	ears = /obj/item/radio/headset
	backpack_contents = list(
		/obj/item/clothing/under/shorts/red = 1,
		/obj/item/clothing/head/costume/ushanka = 1,
	)

/datum/outfit/job/donor/tourist_ussp/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/spinwarder)
