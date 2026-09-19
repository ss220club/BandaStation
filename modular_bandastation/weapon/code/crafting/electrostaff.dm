// Electrostaff construction kit printed by the Security Protolathe.
/obj/item/weaponcrafting/gunkit/electrostaff
	name = "electrostaff parts kit"
	desc = "Комплект деталей для сборки электростаффа."
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.5,
	)

// Design for printing the Electrostaff construction kit on a Security Protolathe.
/datum/design/electrostaff
	name = "Комплект деталей для электростаффа"
	desc = "Комплект деталей для сборки электростаффа."
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/weaponcrafting/gunkit/electrostaff
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_KITS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

// Assemble the Electrostaff from two stun batons, an Electrostaff parts kit, and a flux anomaly.
/datum/crafting_recipe/electrostaff
	name = "Electrostaff"
	result = /obj/item/melee/baton/security/electrostaff/loaded
	reqs = list(
		/obj/item/melee/baton/security = 2,
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/weaponcrafting/gunkit/electrostaff = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_MELEE
