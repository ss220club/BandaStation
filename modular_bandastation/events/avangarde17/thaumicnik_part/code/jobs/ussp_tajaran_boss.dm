/datum/outfit/job/ussp_tajaran_boss
	name = "Босс 'Чёрной Таяры'"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_tajaran
	uniform = /obj/item/clothing/under/suit/burgundy
	suit = /obj/item/clothing/suit/toggle/jacket/trenchcoat
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/fedora
	gloves = /obj/item/clothing/gloves/fingerless
	mask = /obj/item/clothing/mask/fakemoustache
	backpack_contents = list(
		/obj/item/clothing/mask/bandana/skull,
		/obj/item/gun/ballistic/revolver/nagant,
		/obj/item/clothing/mask/fakemoustache,
		/obj/item/clothing/mask/fakemoustache,
		/obj/item/clothing/mask/fakemoustache,
	)
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_tajaran
	title = "Босс 'Чёрной Таяры'"
	supervisors = "понятиями"
	description = "Будьте главным врагом, или главным другом оперуполномоченного."
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
	event_description = "Вы, пусть и пахан, но уважаете своих братков. Недавно вы бежали из соседнего городка и решили залечь на дно после неудачной облавы. Теперь ваше временное прибежище - заброшенная будка вахтовиков на севере от ПГТ 'Зорька'! Добраться до поселка можно напрямую по лесу или по склону восточной горы. Ваша основная задача - крышевать местные заведения и магазины. Опасайтесь мусоров - они не побрезгуют использовать все средства, чтобы остановить вас! Самый лакомый кусочек для вас - большой склад на севере ПГТ. Как только вы наберетесь достаточной смелости и обзаведетесь всеми необходимыми инструментами, попробуйте вскрыть его!"

/datum/id_trim/job/ussp_tajaran
	assignment = "Житель ПГТ \"Зорька\""
	trim_state = "trim_mime"
	department_color = COLOR_ASSISTANT_GRAY
	subdepartment_color = COLOR_ASSISTANT_GRAY
	sechud_icon_state = SECHUD_USSP
	job = /datum/job/ussp_tajaran
