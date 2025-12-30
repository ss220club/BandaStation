/datum/outfit/job/ussp_detective
	name = "Следователь"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_detective
	uniform = /obj/item/clothing/under/rank/ussp/militsioner
	suit = /obj/item/clothing/suit/toggle/jacket/det_trench/noir
	ears = null
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/hats/ussp_militsia
	belt = /obj/item/storage/belt/military/army/militsia
	mask = /obj/item/clothing/mask/breath/breathscarf
	pda_slot = null
	l_pocket = /obj/item/radio

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
	)

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_detective
	title = "Следователь"
	supervisors = "оперуполномоченным"
	description = "Берите след, теряйтесь в амнезии, обнаруживайте в себе 24 альтернативные личности. Танцуйте диско."
	departments_list = list(
		/datum/job_department/justice,
	)
	outfit = /datum/outfit/job/ussp_detective
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/justice
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_detective
	assignment = "Следователь"
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
	job = /datum/job/ussp_detective
