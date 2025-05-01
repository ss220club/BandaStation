/datum/outfit/skrell_sdtf
	name = "Skrell Base"

/datum/id_trim/skrell
	access = list(ACCESS_CENT_GENERAL)
	assignment = "SDTF"
	trim_state = "trim_ert_commander"
	sechud_icon_state = SECHUD_UNKNOWN
	department_color = COLOR_HEALING_CYAN
	subdepartment_color = COLOR_HEALING_CYAN
	threat_modifier = -10
	big_pointer = TRUE
	pointer_color = COLOR_HEALING_CYAN

/datum/outfit/skrell_sdtf/raskinta
	name = "Skrell - Raskinta"
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/skrell/raskinta
	uniform = /obj/item/clothing/under/syndicate/combat
	back = /obj/item/mod/control/pre_equipped/skrell_raskinta
	backpack_contents = list(
		/obj/item/storage/medkit/tactical,
		/obj/item/storage/box/zipties,
		/obj/item/clothing/glasses/hud/health/night,
	)
	belt = /obj/item/storage/belt/vibroblade
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer
	shoes = /obj/item/clothing/shoes/jackboots
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/radio
	r_hand = /obj/item/gun/energy/pulse/carbine

/datum/id_trim/skrell/raskinta
	assignment = "SDTF - Raskinta Katish"

/datum/outfit/skrell_sdtf/emperor_guard
	name = "Skrell - Emperor Guard"
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/skrell/emperor_guard
	uniform = /obj/item/clothing/under/syndicate/combat
	neck = /obj/item/clothing/neck/cloak/emperor_guard
	back = /obj/item/mod/control/pre_equipped/skrell_emperor_guard
	backpack_contents = list(
		/obj/item/gun/energy/pulse/carbine,
		/obj/item/storage/medkit/tactical,
		/obj/item/grenade/c4 = 2,
		/obj/item/clothing/glasses/hud/health/night,
	)
	belt = /obj/item/storage/belt/vibroblade_guard
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer
	shoes = /obj/item/clothing/shoes/jackboots
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/radio

/datum/id_trim/skrell/emperor_guard
	assignment = "Emperor Guard - Kverr'voal Raskinta"

/datum/outfit/skrell_sdtf/emperor_guard/post_equip(mob/living/carbon/human/skrell_guard, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/implant/cqc/cqc_implant = new/obj/item/implant/cqc(skrell_guard)
	cqc_implant.implant(skrell_guard)
	skrell_guard.faction |= ROLE_EMPEROR_GUARD
	skrell_guard.update_icons()
