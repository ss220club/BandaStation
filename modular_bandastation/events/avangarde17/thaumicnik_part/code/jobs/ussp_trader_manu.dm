/datum/outfit/job/ussp_trader_manu
	name = "Продавец промтоваров"
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_trader_manu
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/apron/overalls
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = null
	pda_slot = null
	ears = null

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger

/datum/job/ussp_trader_manu
	title = "Продавец промтоваров"
	supervisors = "правительством СССП"
	description = "Продавайте оборудование и материалы. Являйтесь единственным способным инженером во всём посёлке."
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/job/ussp_trader_manu
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	event_description = "В вашем распоряжении все доступные товары промтоваров и склада на заднем дворе. У вас и ваших товарищей из гастронома есть туда доступ. При необходимости, вы можете запросить заказ товаров у военной базы по телефону, но только в случае крайнего дефицита или острой нужды. Товары общего пользования для жителей идут по талоному тарифу - один товар за один талон. Может случится, что что-то обязательно сломается в ПГТ - ваша обязанность отреагировать и помочь товарищам с починкой. Работникам фельдшерско-акушерского пункта полагается выдача товаров без талонов, по запросу! Скорее всего, вам стоит предложить работу помощника кому-нибудь из жителей ПГТ, исключительно на добровольческой основе. Будьте бдительны - не допускайте расхищения общественной собственности! Обязательно посетите собрание в местном райкоме на площади Революции."

/datum/id_trim/job/ussp_trader_manu
	assignment = "Продавец промтоваров"
	trim_state = "trim_stationengineer"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		)
	job = /datum/job/ussp_trader_manu
