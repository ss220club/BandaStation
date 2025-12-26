/datum/outfit/job/ussp_paramedic
	name = "Фельдшер"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/job/ussp_paramedic
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	suit = /obj/item/clothing/suit/toggle/labcoat
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/mask/bandana/white
	belt = null
	pda_slot = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_paramedic
	title = "Фельдшер"
	supervisors = "правительством СССП"
	description = "Выезжайте на вызовы, приторговывайте опиатами и промышляйте мелкими кражами."
	departments_list = list(
		/datum/job_department/medical,
	)
	outfit = /datum/outfit/job/ussp_paramedic
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

/datum/id_trim/job/ussp_paramedic
	assignment = "Фельдшер"
	trim_state = "trim_paramedic"
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
	job = /datum/job/ussp_paramedic
