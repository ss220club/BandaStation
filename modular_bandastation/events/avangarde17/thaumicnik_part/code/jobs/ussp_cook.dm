/datum/outfit/job/ussp_cook
	name = "Повар рюмочной"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_cook
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	suit = /obj/item/clothing/suit/apron/chef
	head = /obj/item/clothing/head/utility/chefhat
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	belt = null
	pda_slot = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger
	backpack_contents = list(
		/obj/item/choice_beacon/ingredient = 1,
		/obj/item/sharpener = 1,
	)

/datum/job/ussp_cook
	title = "Повар рюмочной"
	supervisors = "правительством СССП"
	description = "Занимайтесь готовкой еды для граждан славного посёлка городского типа"
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/job/ussp_cook
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_cook
	assignment = "Повар рюмочной"
	trim_state = "trim_cook"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_KITCHEN,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SERVICE,
		)
	extra_access = list(
		ACCESS_BAR,
		ACCESS_HYDROPONICS,
		)
	job = /datum/job/ussp_cook
