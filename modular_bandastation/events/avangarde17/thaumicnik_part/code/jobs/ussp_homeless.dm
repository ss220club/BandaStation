/datum/outfit/job/ussp_homeless
	name = "Бездомный"
	uniform = /obj/item/clothing/under/pants/slacks
	suit = /obj/item/clothing/suit/toggle/jacket/sweater
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/costume/ushanka
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_homeless
	title = "Бездомный"
	supervisors = "правительством СССП"
	description = "Ройтесь в помойках, собирайте бутылки и танцуйте диско."
	departments_list = list(
		/datum/job_department/assistant,
	)
	outfit = /datum/outfit/job/ussp_homeless
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/assistant
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	event_description = "Несмотря на тяжелую житуху, вы не отчаиваетесь! Ваш дом повсюду - подвалы, заброшки, теплотрассы. Перебивайтесь случайными подработками, находками и помощью сограждан. Вы не можете получить талоны на товары, поэтому выменяйте их, выпросите или украдите! Хороший повод начать заниматься этим - у райкома на площади Революции! Если дела пойдут совсем туго, попробуйте договориться о работе у шахтёров, в промтоварах или на складе. Милиция относится к вам очень настороженно, поэтому не лезьте в конфликты и не привлекайте внимание. Ваша цель - выжить, вкусно бахнуть водочки и не загреметь в участок."

/datum/id_trim/job/ussp_homeless
	assignment = "Житель ПГТ \"Зорька\""
	trim_state = "trim_mime"
	department_color = COLOR_ASSISTANT_GRAY
	subdepartment_color = COLOR_ASSISTANT_GRAY
	sechud_icon_state = SECHUD_USSP
	job = /datum/job/ussp_homeless
