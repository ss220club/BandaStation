/datum/outfit/job/ussp_base_conscript
	name = "Призывник СССП"

	id = /obj/item/card/id/advanced/ussp
	id_trim = /datum/id_trim/ussp/soldier
	uniform = /obj/item/clothing/under/rank/ussp/soldier
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/radio,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
	)
	head = /obj/item/clothing/head/hats/ussp
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	shoes = /obj/item/clothing/shoes/jackboots
	pda_slot = null

/datum/job/ussp_base_conscript
	title = "Призывник"
	supervisors = "Офицеры Базы"
	description = "Ивентовая роль"
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/job/ussp_base_conscript
	faction = FACTION_STATION
	total_positions = 20
	spawn_positions = 20

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)

	mail_goodies = list(
		/obj/effect/spawner/random/food_or_drink/donkpockets = 10,
		/obj/item/clothing/mask/gas = 10,
		/obj/item/clothing/gloves/color/fyellow = 7,
		/obj/item/choice_beacon/music = 5,
		/obj/item/toy/sprayoncan = 3,
		/obj/item/crowbar/large = 1
	)

	rpg_title = "Lout"
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/ussp_base_conscript
	assignment = "Призывник"
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_ussp"

	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_USSP
	minimal_access = list(
	)
	template_access = list(
	)
	job = /datum/job/ussp_base_officer
