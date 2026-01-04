/datum/outfit/job/ussp_base_conscript
	name = "Призывник"
	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/job/ussp_base_conscript
	uniform = /obj/item/clothing/under/rank/ussp/soldier
	suit = /obj/item/clothing/suit/armor/vest/ussp
	back = /obj/item/storage/backpack/ussp
	head = /obj/item/clothing/head/hats/ussp
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	pda_slot = null
	belt = null

/datum/job/ussp_base_conscript
	title = "Призывник"
	supervisors = "офицером военной базы"
	description = "Красьте снег в белый, стройтесь по струнке, отыгрывайте роль рядового табуретки."
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/job/ussp_base_conscript
	faction = FACTION_STATION
	total_positions = 25
	spawn_positions = 25
	event_description = "В ваши обязанности входит следование приказам офицеров, исполнение коммунистического долга и служение Родине! Вам запрещено покидать пределы ГРК-4 без разрешение офицеров. Обязательно посетите политпросвет в основном здании военной базы, после - получите свои задачи у прапора, офицеров, замполита или лично коменданта. Помните - Родина всегда в опасности, поэтому будьте бдительны и верны долгу!"

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_base_conscript
	assignment = "Призывник"
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_ussp"
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
		)
	job = /datum/job/ussp_base_conscript
