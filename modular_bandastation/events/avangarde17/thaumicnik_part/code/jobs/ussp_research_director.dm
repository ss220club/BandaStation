/datum/job/research_director
	title = "Научрук"
	description = "Распределяйте своё внимание между научными сотрудниками, стараясь при этом угодить начальству"

/datum/outfit/job/rd
	name = "Научрук"
	jobtype = /datum/job/research_director

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/research_director
	uniform = /obj/item/clothing/under/carnival/formal
	suit = /obj/item/clothing/suit/toggle/labcoat
	backpack_contents = list()
	belt = null
	head = null
	ears = null
	shoes = /obj/item/clothing/shoes/laceup
	gloves = null
	l_pocket = /obj/item/laser_pointer/purple
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/id_trim/job/research_director
	assignment = "Научрук"

