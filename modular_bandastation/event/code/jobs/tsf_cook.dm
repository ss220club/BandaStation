/datum/outfit/tsf/marine_unarmed/cook
	name = "TSF - Cook"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/cook
	uniform = /obj/item/clothing/under/rank/tsf/marine
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
		/obj/item/knife/kitchen,
		/obj/item/choice_beacon/ingredient = 1,
		/obj/item/sharpener = 1,
	)
	head = /obj/item/clothing/head/hats/tsf_cap
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/sunglasses
	belt = null

/datum/job/tsf_cook
	title = "Повар посольства ТСФ"
	supervisors = "дипломатом"
	description = "Занимайтесь готовкой еды для резервистов и персонала посольства."
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/tsf/marine_unarmed/cook
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	event_description = "Готовьте самые вкусные блюда, закуски и перекусы по запросу бойцов или гостей посольства!"

/datum/id_trim/tsf/marine/cook
	assignment = "TSF - Cook"
