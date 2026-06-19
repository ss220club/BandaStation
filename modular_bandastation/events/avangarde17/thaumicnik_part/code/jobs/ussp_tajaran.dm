/datum/outfit/job/ussp_tajaran
	name = "Бандит 'Чёрной Таяры'"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_tajaran
	uniform = /obj/item/clothing/under/suit/charcoal
	suit = /obj/item/clothing/suit/toggle/jacket/trenchcoat
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/fedora
	gloves = /obj/item/clothing/gloves/fingerless
	backpack_contents = list(
		/obj/item/clothing/mask/bandana/skull,
	)
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_tajaran
	title = "Бандит 'Чёрной Таяры'"
	supervisors = "понятиями"
	description = "Занимайтесь рекетом, бандитизмом, ведите умеренную борьбу с милицией."
	departments_list = list(
		/datum/job_department/assistant,
	)
	outfit = /datum/outfit/job/ussp_tajaran
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/assistant
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	event_description = "Вы слушаетесь своего пахана и уважаете своих братков. Недавно вы бежали из соседнего городка и решили залечь на дно после неудачной облавы. Теперь ваше временное прибежище - заброшенная будка вахтовиков на севере от ПГТ 'Зорька'! Добраться до поселка можно напрямую по лесу или по склону восточной горы. Ваша основная задача - крышевать местные заведения и магазины. Опасайтесь мусоров - они не побрезгуют использовать все средства, чтобы остановить вас! Самый лакомый кусочек для вас - большой склад на севере ПГТ. Как только вы наберетесь достаточной смелости и обзаведетесь всеми необходимыми инструментами, попробуйте вскрыть его!"

/datum/id_trim/job/ussp_tajaran
	assignment = "Житель ПГТ \"Зорька\""
	trim_state = "trim_mime"
	department_color = COLOR_ASSISTANT_GRAY
	subdepartment_color = COLOR_ASSISTANT_GRAY
	sechud_icon_state = SECHUD_USSP
	job = /datum/job/ussp_tajaran
