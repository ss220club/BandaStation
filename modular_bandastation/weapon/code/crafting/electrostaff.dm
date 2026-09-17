// Assemble the Electrostaff from two stun batons, 10 Cable coil, and a flux anomaly.
/datum/crafting_recipe/electrostaff
	name = "Electrostaff"
	result = /obj/item/melee/baton/security/electrostaff/loaded
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	reqs = list(
		/obj/item/melee/baton/security = 2,
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/stack/cable_coil = 10,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_MELEE
