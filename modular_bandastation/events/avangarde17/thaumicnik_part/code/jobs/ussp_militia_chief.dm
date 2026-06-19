/datum/outfit/job/ussp_militia_chief
	name = "Начальник участка"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/ussp_militia_chief
	uniform = /obj/item/clothing/under/rank/ussp/militsioner
	suit = /obj/item/clothing/suit/armor/hos
	ears = null
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/hats/ussp_officer
	belt = /obj/item/storage/belt/military/army/militsia
	mask = /obj/item/clothing/mask/breath/breathscarf
	pda_slot = null
	l_pocket = /obj/item/radio

	backpack_contents = list(
		/obj/item/gun/ballistic/revolver/nagant,
		/obj/item/ammo_box/speedloader/n762_cylinder,
		/obj/item/ammo_box/speedloader/n762_cylinder,
		/obj/item/ammo_box/speedloader/n762_cylinder,
	)

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_militia_chief
	title = "Начальник участка"
	supervisors = "Председателем"
	description = "Будьте плохим корумпированным боссом. Воруйте, упивайтесь властью, но соблюдайте осторожность."
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/job/ussp_militia_chief
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_CREW
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_militia_chief
	assignment = "Начальник участка"
	trim_state = "trim_securityofficer"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_COMMAND_BLUE
	sechud_icon_state = SECHUD_HEAD_OF_SECURITY
	minimal_access = list(
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_ARMORY,
		ACCESS_AUX_BASE,
		ACCESS_BIT_DEN,
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_BUDGET,
		ACCESS_CARGO,
		ACCESS_COMMAND,
		ACCESS_CONSTRUCTION,
		ACCESS_COURT,
		ACCESS_DETECTIVE,
		ACCESS_ENGINEERING,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_SECURITY,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SCIENCE,
		ACCESS_SECURITY,
		ACCESS_SERVICE,
		ACCESS_SHIPPING,
		ACCESS_WEAPONS,
		)
	job = /datum/job/ussp_militia_chief
