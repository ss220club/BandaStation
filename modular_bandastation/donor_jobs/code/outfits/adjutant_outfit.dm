/datum/outfit/job/donor/adjutant
	name = "Adjutant"
	jobtype = /datum/job/donor/adjutant
	id_trim = /datum/id_trim/job/donor_adjutant
	belt = /obj/item/modular_computer/pda/crew/lawyer
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/blue
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/white
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	l_hand = /obj/item/storage/briefcase/empty
	ears = /obj/item/radio/headset/heads/hop
	backpack_contents = list(
		/obj/item/folder/blue = 1,
		/obj/item/clipboard = 1,
		/obj/item/pen = 1,
	)
	implants = list(/obj/item/implant/mindshield)
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

/datum/outfit/job/donor/adjutant/butler
	name = "Adjutant (butler)"
	id_trim = /datum/id_trim/job/donor_adjutant/butler
	belt = /obj/item/modular_computer/pda/crew/bar
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/black
	glasses = /obj/item/clothing/glasses/monocle
	head = /obj/item/clothing/head/hats/tophat
	r_pocket = /obj/item/rag

/datum/outfit/job/donor/adjutant/maid
	name = "Adjutant (maid)"
	id_trim = /datum/id_trim/job/donor_adjutant/maid
	belt = /obj/item/modular_computer/pda/crew/bar
	uniform = /obj/item/clothing/under/costume/maid
	suit = null
	l_hand = /obj/item/mop
	r_pocket = /obj/item/rag
