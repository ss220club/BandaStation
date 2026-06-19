/datum/outfit/job/ussp_cmo
	name = "Главный врач"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/ussp_medic
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	suit = /obj/item/clothing/suit/toggle/labcoat
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/latex
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_cmo
	title = "Главный врач"
	supervisors = "правительством СССП"
	description = "Руководите поликлиникой, обучайте интернов, орите на своих подчинённых."
	departments_list = list(
		/datum/job_department/medical,
	)
	outfit = /datum/outfit/job/ussp_cmo
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_CREW
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/medical
	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom, /obj/item/scalpel, /obj/item/hemostat, /obj/item/circular_saw, /obj/item/retractor, /obj/item/cautery, /obj/item/statuebust/hippocratic)
	job_flags = STATION_JOB_FLAGS
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

/datum/id_trim/job/ussp_cmo
	assignment = "Главный врач"
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_CHIEF_MEDICAL_OFFICER
	minimal_access = list(
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
	job = /datum/job/ussp_cmo
