/datum/outfit/job/ussp_base_medic
	name = "Военный врач"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/job/ussp_base_medic
	uniform = /obj/item/clothing/under/rank/ussp/soldier
	suit = /obj/item/clothing/suit/armor/vest/marine/medic/ussp_medic
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/ussp
	head = /obj/item/clothing/head/hats/ussp
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	pda_slot = null
	belt = null

/datum/job/ussp_base_medic
	title = "Военный врач"
	supervisors = "прапором"
	description = "Будьте спасителем жизни срочников. Воруйте медикаменты у посёлка."
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/job/ussp_base_medic
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	event_description = "Вы отучились в местном медицинском училище и поступили на службу для оказания помощи солдатам и офицерам! В вашем распоряжении небольшой госпиталь с операционной и палатами. Обязательно посетите политпросвет в основном здании военной базы и получите задачи у коменданта или замполита. Все необходимые медицинские расходники, лекарства или оборудование вы можете запросить заказать у офицеров через диспетчерскую по факсу, на втором этаже склада. Или, при необходимости - сделать это самим."

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_base_medic
	assignment = "Военный врач"
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
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
	job = /datum/job/ussp_base_medic
