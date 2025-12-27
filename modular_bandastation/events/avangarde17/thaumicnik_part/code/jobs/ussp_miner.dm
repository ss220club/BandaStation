/datum/outfit/job/ussp_miner
	name = "Шахтёр"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_miner
	uniform = /obj/item/clothing/under/misc/overalls
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/workboots
	suit = /obj/item/clothing/suit/apron/overalls
	gloves = /obj/item/clothing/gloves/fingerless
	head = /obj/item/clothing/head/utility/hardhat
	belt = null
	pda_slot = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_miner
	title = "Шахтёр"
	supervisors = "заведующим складом"
	description = "Копайте. Пейте водку. Гордитесь тем что являетесь пролетарием."
	departments_list = list(
		/datum/job_department/cargo,
	)
	outfit = /datum/outfit/job/ussp_miner
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/cargo
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_miner
	assignment = "Шахтёр"
	trim_state = "trim_shaftminer"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_CARGO_BROWN
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CARGO,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		)
	job = /datum/job/ussp_miner
