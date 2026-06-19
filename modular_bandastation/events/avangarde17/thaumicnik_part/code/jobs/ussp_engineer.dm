/datum/outfit/job/ussp_engineer
	name = "Инженерный техник"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/ussp_engineer
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/apron/overalls
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_engineer
	title = "Инженерный техник"
	supervisors = "главным инженером"
	description = "Работайте над безопасностью реактора суперматерии и занимайтесь ремонтом посёлка. А, и да, забудьте про разгермы."
	departments_list = list(
		/datum/job_department/engineering,
	)
	outfit = /datum/outfit/job/ussp_engineer
	faction = FACTION_STATION
	total_positions = 4
	spawn_positions = 4
	paycheck = PAYCHECK_CREW
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/engineering
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_engineer
	assignment = "Инженерный техник"
	trim_state = "trim_stationengineer"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_STATION_ENGINEER
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_TCOMMS,
		ACCESS_TECH_STORAGE,
		)
	extra_access = list(
		ACCESS_ATMOSPHERICS,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CE,
		)
	job = /datum/job/ussp_engineer
