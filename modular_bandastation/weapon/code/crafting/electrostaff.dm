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
		/obj/item/melee/baton/security = 2,
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/weaponcrafting/gunkit/electrostaff = 1,
	)
	blacklist = list(
		/obj/item/melee/baton/security/electrostaff,
		/obj/item/melee/baton/security/stunsword,
		/obj/item/melee/baton/security/stunsword/loaded,
		/obj/item/melee/baton/security/cattleprod,
		/obj/item/melee/baton/security/cattleprod/loaded,
		/obj/item/melee/baton/security/cattleprod/teleprod,
		/obj/item/melee/baton/security/cattleprod/telecrystalprod,
		/obj/item/melee/baton/security/boomerang,
		/obj/item/melee/baton/security/boomerang/loaded,
	)
	crafting_flags = CRAFT_SKIP_MATERIALS_PARITY
	time = 10 SECONDS
	category = CAT_WEAPON_MELEE
