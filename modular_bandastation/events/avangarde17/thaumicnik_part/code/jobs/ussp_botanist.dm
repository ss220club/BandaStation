/datum/job/botanist
	title = "Агроном"
	description = "Работайте в теплице. Снабжайте продуктами посёлок, наслаждайтесь запахом цветов и укусами пчёл."

/datum/outfit/job/botanist
	name = "Агроном"
	jobtype = /datum/job/botanist

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/botanist
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	suit = /obj/item/clothing/suit/apron/overalls
	backpack_contents = list()
	belt = null
	head = null
	ears = null
	shoes = /obj/item/clothing/shoes/workboots
	gloves = null
	l_pocket = null
	l_hand = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/id_trim/job/botanist
	assignment = "Агроном"

