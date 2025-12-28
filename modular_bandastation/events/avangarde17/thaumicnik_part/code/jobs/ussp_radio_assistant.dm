/datum/outfit/job/ussp_radio_assistant
	name = "Ассистент радиоведущего"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_radio_assistant
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	suit = /obj/item/clothing/suit/toggle/jacket/sweater
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_radio_assistant
	title = "Ассистент радиоведущего"
	supervisors = "правительством СССП"
	description = "Помогайте вести эфир, зачитывайте монотонный текст, носите чай."
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/job/ussp_radio_assistant
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_radio_assistant
	assignment = "Ассистент радиоведущего"
	trim_state = "trim_psychologist"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_TCOMMS
		)
	job = /datum/job/ussp_radio_assistant
