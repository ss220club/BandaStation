/datum/outfit/job/ussp_trader_deli
	name = "Продавец гастронома"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_trader_deli
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/apron/chef
	gloves = /obj/item/clothing/gloves/color/white
	belt = null
	pda_slot = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_trader_deli
	title = "Продавец гастронома"
	supervisors = "правительством СССП"
	description = "Занимайтесь продажей продуктов гражданам посёлка. Крадите все списанные продукты себе домой."
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/job/ussp_trader_deli
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_trader_deli
	assignment = "Продавец гастронома"
	trim_state = "trim_psychologist"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		)
	job = /datum/job/ussp_trader_deli
