#define JOB_OPERATIVE "Оперативник"
#define JOB_OPERATIVE_LEADER "Лидер Оперативник"

/datum/job/assistant
	title = JOB_OPERATIVE
	supervisors = "лидером отряда"
	description = "Пора за работу. Выполняйте задания которые вам выдадут. Работайте в команде."
	faction = FACTION_STATION
	bounty_types = CIV_JOB_BASIC
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	outfit = /datum/outfit/job/merc
	paycheck = PAYCHECK_ZERO

/datum/outfit/job/merc
	name = "Operative"
	jobtype = /datum/job/assistant
	uniform = /obj/item/clothing/under/hoodie_black
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/ert/merc
	belt = /obj/item/storage/belt/military/army/tsf/full_pistol
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/holochip/sotnya = 1,
	)
	pda_slot = null

/obj/item/holochip/sotnya
	credits = 100

/datum/id_trim/ert/merc
	assignment = "Оперативник"
	trim_state = "trim_deathcommando"

/obj/effect/landmark/start/mercenary
	name = JOB_OPERATIVE
	icon_state = "Assistant"

/datum/outfit/job/merc/leader
	name = "Operative Leader"
	jobtype = /datum/job/merc_leader
	id_trim = /datum/id_trim/ert/merc/merc_leader
	backpack_contents = list(
		/obj/item/holochip/sotnya = 2,
		/obj/item/modular_computer/pda/crew/heads/captain = 1,
	)
	head = /obj/item/clothing/head/beret/militia

/datum/id_trim/ert/merc/merc_leader
	assignment = "Лидер Оперативник"
	big_pointer = TRUE

/datum/id_trim/ert/merc/merc_leader/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/datum/job/merc_leader
	title = JOB_OPERATIVE_LEADER
	supervisors = "более влиятельными персонами, чем вы."
	description = "Возьмите огузков под свое командование. Выполняйте задания которые вам выдадут. Решайте что будет ценнее, жизнь вашей команды или награда?"
	departments_list = list(
		/datum/job_department/command,
		)
	department_for_prefs = /datum/job_department/captain
	faction = FACTION_STATION
	bounty_types = CIV_JOB_BASIC
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
	outfit = /datum/outfit/job/merc/leader
	total_positions = 1
	spawn_positions = 1
	paycheck = PAYCHECK_ZERO
	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	req_admin_notify = 1
	tgui_icon = FA_ICON_CROWN

/obj/effect/landmark/start/mercenary/leader
	name = JOB_OPERATIVE_LEADER
