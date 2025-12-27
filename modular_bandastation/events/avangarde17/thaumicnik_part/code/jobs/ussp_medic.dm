/datum/outfit/job/ussp_medic
	name = "Врач посёлка"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_medic
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	suit = /obj/item/clothing/suit/toggle/labcoat
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/latex
	belt = null
	pda_slot = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_medic
	title = "Врач посёлка"
	supervisors = "правительством СССП"
	description = "Лечите сограждан, импровизируйте при нехватке медикаментов, старайтесь не быть фигурантом уголовного дела."
	departments_list = list(
		/datum/job_department/medical,
	)
	outfit = /datum/outfit/job/ussp_medic
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/medical
	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom, /obj/item/scalpel, /obj/item/hemostat, /obj/item/circular_saw, /obj/item/retractor, /obj/item/cautery, /obj/item/statuebust/hippocratic)
	job_flags = STATION_JOB_FLAGS

	mind_traits = list(MEDICAL_MIND_TRAITS)
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

/datum/id_trim/job/ussp_medic
	assignment = "Врач посёлка"
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_USSP
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
	job = /datum/job/ussp_medic
