/datum/outfit/job/ussp_chairman
	name = "Председатель"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/ussp_chairman
	uniform = /obj/item/clothing/under/suit/navy
	ears = null
	shoes = /obj/item/clothing/shoes/laceup
	head = null
	belt = null
	pda_slot = null
	l_pocket = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_chairman
	title = "Председатель"
	supervisors = "ЦК КССП"
	description = "Руководите посёлком, проводите собрания совета и избегайте кляуз партработника."
	departments_list = list(
		/datum/job_department/command,
	)
	outfit = /datum/outfit/job/ussp_chairman
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_CREW
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/captain
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_chairman
	assignment = "Председатель"
	trim_state = "trim_captain"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_CAPTAIN
	minimal_access = list(
ACCESS_AI_UPLOAD,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_AUX_BASE,
		ACCESS_BAR,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CARGO,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CHANGE_IDS,
		ACCESS_CREMATORIUM,
		ACCESS_COMMAND,
		ACCESS_COURT,
		ACCESS_ENGINEERING,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_KEYCARD_AUTH,
		ACCESS_KITCHEN,
		ACCESS_LAWYER,
		ACCESS_LIBRARY,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
		ACCESS_NANOTRASEN_REPRESENTATIVE,
		ACCESS_PSYCHOLOGY,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SCIENCE,
		ACCESS_SERVICE,
		ACCESS_TELEPORTER,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
		)
	job = /datum/job/ussp_chairman
