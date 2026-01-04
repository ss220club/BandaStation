/datum/outfit/job/ussp_base_comendant
	name = "Комендант"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/job/ussp_base_comendant
	uniform = /obj/item/clothing/under/rank/ussp/commander
	suit = /obj/item/clothing/suit/armor/centcom_formal/ussp_commander
	back = /obj/item/storage/backpack/ussp
	head = /obj/item/clothing/head/hats/ussp_command
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	pda_slot = null
	belt = null
	mask = /obj/item/cigarette/pipe
	backpack_contents = list(
		/obj/item/stamp/ussp,
		/obj/item/gun/ballistic/revolver/nagant,
		/obj/item/ammo_box/speedloader/n762_cylinder,
		/obj/item/ammo_box/speedloader/n762_cylinder,
		/obj/item/ammo_box/speedloader/n762_cylinder,
	)

/datum/job/ussp_base_comendant
	title = "Комендант"
	supervisors = "Верховной властью СССП"
	description = "Будьте самой грозной шишкой на ближайшие пару световых лет."
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/job/ussp_base_comendant
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_base_comendant
	assignment = "Комендант"
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_ussp_rank3"

	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_PARAMEDIC,
		ACCESS_PLUMBING,
		)
	job = /datum/job/ussp_base_comendant
