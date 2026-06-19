/datum/outfit/job/ussp_barman
	name = "Владелец кабака"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/ussp_barman
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_barman
	title = "Владелец кабака"
	supervisors = "управдомом"
	description = "Управляйте кабаком под номинальным руководством муниципалитета. Гоните самогон из под полы."
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/job/ussp_barman
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_CREW
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_barman
	assignment = "Владелец кабака"
	trim_state = "trim_bartender"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_BARTENDER
	minimal_access = list(
		ACCESS_KITCHEN,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SERVICE,
		ACCESS_BAR,
		ACCESS_HYDROPONICS,
		)
	job = /datum/job/ussp_barman
