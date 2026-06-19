/datum/outfit/job/ussp_base_zampolit
	name = "Замполит"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/job/ussp_base_zampolit
	uniform = /obj/item/clothing/under/rank/ussp/officer
	suit = /obj/item/clothing/suit/jacket/oversized
	back = /obj/item/storage/backpack/ussp
	head = /obj/item/clothing/head/hats/ussp_officer
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/eyepatch
	pda_slot = null
	belt = null
	backpack_contents = list(
		/obj/item/gun/ballistic/revolver/nagant,
		/obj/item/ammo_box/speedloader/n762_cylinder,
		/obj/item/ammo_box/speedloader/n762_cylinder,
		/obj/item/ammo_box/speedloader/n762_cylinder,
	)

/datum/job/ussp_base_zampolit
	title = "Замполит"
	supervisors = "прапором"
	description = "Следите за политическими взглядами солдат. Убивайте предателей, сжигайте ерети... всмысле ревизионеров."
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/job/ussp_base_zampolit
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_base_zampolit
	assignment = "Замполит"
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_ussp_rank2"

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
	job = /datum/job/ussp_base_zampolit
