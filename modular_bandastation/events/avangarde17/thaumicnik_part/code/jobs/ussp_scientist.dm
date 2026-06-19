/datum/job/scientist
	title = "Научный сотрудник"
	description = "Развивайте науку в этом славном посёлке! (а ещё неплохо бы съехать из этого НИИ куда-нибудь в столицу)"

/datum/outfit/job/scientist
	name = "Научный сотрудник"
	jobtype = /datum/job/scientist

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/scientist
	uniform = /obj/item/clothing/under/carnival/formal
	suit = /obj/item/clothing/suit/toggle/labcoat
	backpack_contents = list()
	belt = null
	head = null
	ears = null
	shoes = /obj/item/clothing/shoes/laceup
	gloves = null
	l_pocket = null
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/id_trim/job/scientist
	assignment = "Научный сотрудник"

