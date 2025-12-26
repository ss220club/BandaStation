/datum/outfit/job/ussp_punk
	name = "Шпана"
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	suit = /obj/item/clothing/suit/toggle/jacket/trenchcoat
	mask = /obj/item/clothing/mask/bandana/skull
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/sneakers/black
	belt = null
	pda_slot = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_punk
	title = "Шпана"
	supervisors = "своей личной совестью"
	description = "Бухайте, деритесь, занимайтесь разбоем. В перерывах сидите в обезьяннике."
	departments_list = list(
		/datum/job_department/assistant,
	)
	outfit = /datum/outfit/job/ussp_punk
	faction = FACTION_STATION
	total_positions = 4
	spawn_positions = 4
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/assistant
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_punk
	assignment = "Безработный"
	trim_state = "trim_mime"
	department_color = COLOR_ASSISTANT_GRAY
	subdepartment_color = COLOR_ASSISTANT_GRAY
	sechud_icon_state = SECHUD_USSP
	job = /datum/job/ussp_punk
