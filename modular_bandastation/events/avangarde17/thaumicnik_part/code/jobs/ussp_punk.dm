/datum/outfit/job/ussp_punk
	name = "Шпана"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_punk
	uniform = /obj/item/clothing/under/rank/ussp/gopnik
	mask = /obj/item/clothing/mask/bandana/skull
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/soft/ussp/gopnik
	backpack_contents = list(
		/obj/item/food/semki,
	)
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_punk
	title = "Шпана"
	supervisors = "понятиями"
	description = "Бухайте, деритесь, занимайтесь разбоем. В перерывах сидите в обезьяннике."
	departments_list = list(
		/datum/job_department/assistant,
	)
	outfit = /datum/outfit/job/ussp_punk
	faction = FACTION_STATION
	total_positions = 4
	spawn_positions = 4
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/assistant
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	event_description = "Ваш удел - разводить лохов на талоны, мобилы и все, что можно сдать в ломбард или толкнуть в магазине. Реальные пацаны всегда слушаются своего пахана, который в свою очередь выбирается на особом пацанском совете. Помните, что мусорнуться - значит предать саму идею свободной пацанской житухи. Бойтесь ментов, уважайте четких ребят и щелкайте семки."

/datum/id_trim/job/ussp_punk
	assignment = "Житель ПГТ \"Зорька\""
	trim_state = "trim_mime"
	department_color = COLOR_ASSISTANT_GRAY
	subdepartment_color = COLOR_ASSISTANT_GRAY
	sechud_icon_state = SECHUD_USSP
	job = /datum/job/ussp_punk
