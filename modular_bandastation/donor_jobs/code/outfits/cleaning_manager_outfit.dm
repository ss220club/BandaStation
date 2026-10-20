/datum/outfit/job/donor/cleaning_manager
	name = "Cleaning Manager"
	jobtype = /datum/job/donor/cleaning_manager
	id_trim = /datum/id_trim/job/donor_cleaning_manager
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	shoes = /obj/item/clothing/shoes/galoshes/dry
	suit = /obj/item/clothing/suit/apron/overalls
	gloves = /obj/item/clothing/gloves/color/purple
	mask = /obj/item/clothing/mask/bandana/purple
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor
	belt_contents = list(
		/obj/item/lightreplacer = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/soap/nanotrasen = 1,
		/obj/item/holosign_creator = 1,
		/obj/item/melee/flyswatter = 1,
	)
	r_pocket = /obj/item/access_key
	l_pocket = /obj/item/modular_computer/pda/crew/janitor
	pda_slot = ITEM_SLOT_LPOCKET
	l_hand = /obj/item/clipboard

/datum/outfit/job/donor/cleaning_manager/apprentice
	name = "Cleaning Manager (apprentice)"
	id_trim = /datum/id_trim/job/donor_cleaning_manager/apprentice
	l_pocket = /obj/item/modular_computer/pda/crew
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/workboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/grey
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/utility/welding
	belt = /obj/item/storage/belt/utility
	belt_contents = list(
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
		/obj/item/weldingtool = 1,
		/obj/item/crowbar = 1,
		/obj/item/wirecutters = 1,
		/obj/item/multitool = 1,
		/obj/item/stack/cable_coil = 1,
	)
	l_hand = null
	backpack_contents = list(/obj/item/flashlight = 1)
