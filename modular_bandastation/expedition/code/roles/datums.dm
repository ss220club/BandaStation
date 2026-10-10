#define JOB_MERCENARY "Наёмник"
#define JOB_MERCENARY_LEADER "Лидер Наёмников"

/datum/job/assistant
	title = JOB_MERCENARY
	supervisors = "лидером отряда"
	description = "Пора за работу. Выполняйте задания которые вам выдадут. Работайте в команде."
	departments_list = list(
		/datum/job_department/assistant,
	)
	department_for_prefs = /datum/job_department/assistant
	faction = FACTION_STATION
	bounty_types = CIV_JOB_BASIC
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	outfit = /datum/outfit/job/merc
	paycheck = PAYCHECK_ZERO

/datum/outfit/job/merc
	name = "Mercenary"
	uniform = /obj/item/clothing/under/hoodie_black
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/ert/merc
	belt = /obj/item/storage/belt/military/army/tsf/full_pistol
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/holochip/sotnya = 1
	)
	pda_slot = null

/obj/item/holochip/sotnya
	credits = 100

/datum/id_trim/ert/merc
	assignment = "Наёмник"
	trim_state = "trim_deathcommando"
	job = /datum/job/assistant
	honorifics = list("Оперативник")
	honorific_positions = HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_NONE

/obj/effect/landmark/start/mercenary
	name = JOB_MERCENARY
	icon_state = "Assistant"

/datum/outfit/job/merc/leader
	name = "Mercenary Leader"
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/ert/commander/merc_leader
	backpack_contents = list(
		/obj/item/holochip/sotnya = 2
	)
	head = /obj/item/clothing/head/beret/militia

/datum/id_trim/ert/commander/merc_leader
	assignment = "Лидер Наёмников"
	job = /datum/job/merc_leader
	honorifics = list("Лидер-Оперативник")
	big_pointer = TRUE

/datum/id_trim/ert/commander/merc_leader/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/datum/job/merc_leader
	title = JOB_MERCENARY_LEADER
	supervisors = "более влиятельными персонами, чем вы."
	description = "Возьмите огузков под свое командование. Выполняйте задания которые вам выдадут. Решайте что будет ценнее, жизнь вашей команды или награда?"
	departments_list = list(
		/datum/job_department/captain,
	)
	department_for_prefs = /datum/job_department/captain
	faction = FACTION_STATION
	bounty_types = CIV_JOB_BASIC
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	outfit = /datum/outfit/job/merc/leader
	total_positions = 1
	spawn_positions = 1

/obj/effect/landmark/start/mercenary/leader
	name = JOB_MERCENARY_LEADER
