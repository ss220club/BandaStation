// Electrostaff construction kit printed by the Security Protolathe.
/obj/item/weaponcrafting/gunkit/electrostaff
	name = "electrostaff"
	desc = "Комплект деталей для сборки электро-посоха."
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.5,
	)


/datum/crafting_recipe/electrostaff
	name = "electrostaff"
	result = /obj/item/melee/baton/security/electrostaff/loaded
	reqs = list(
		/obj/item/melee/baton/security/loaded = 2,
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/weaponcrafting/gunkit/electrostaff = 1,
	)
	crafting_flags = CRAFT_SKIP_MATERIALS_PARITY
	time = 10 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/electrostaff/New()
	LAZYADD(blacklist, typecacheof(
		/obj/item/melee/baton/security,
		ignore_root_path = TRUE,
	))
	blacklist -= /obj/item/melee/baton/security/loaded
	return ..()
