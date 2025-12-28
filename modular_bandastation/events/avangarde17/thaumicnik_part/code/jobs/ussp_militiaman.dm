/datum/outfit/job/ussp_militiaman
	name = "Милиционер"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_militiaman
	uniform = /obj/item/clothing/under/rank/ussp/militsioner
	suit = /obj/item/clothing/suit/armor/vest/ussp/militsia
	ears = null
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/hats/ussp_militsia
	belt = /obj/item/storage/belt/military/army/militsia
	pda_slot = null
	l_pocket = /obj/item/radio

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_militiaman
	title = "Милиционер"
	supervisors = "оперуполномоченным"
	description = "Боритесь с преступностью, берите взятки, являйтесь героем 90% отечественных сериалов."
	departments_list = list(
		/datum/job_department/command,
	)
	outfit = /datum/outfit/job/ussp_militiaman
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/command
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_militiaman
	assignment = "Милиционер"
	trim_state = "trim_mime"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_COMMAND_BLUE
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		)
	job = /datum/job/ussp_militiaman
