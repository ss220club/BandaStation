/** Физическая планка RAM для ручной сборки серверного модуля. */
/obj/item/ai_ram
	name = "Standard Memory"
	desc = "Планка оперативной памяти для серверного модуля ИИ. Изготавливается на протолате; устанавливается в открытый корпус модуля."
	icon = 'modular_bandastation/ai_overhaul/icons/module.dmi'
	icon_state = "ram"
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	/// Объём оперативной памяти этой планки в ТБ.
	var/capacity = 1

/obj/item/ai_ram/examine(mob/user)
	. = ..()
	. += span_notice("Объём RAM: [capacity] ТБ.")

/** Планка RAM на 2 ТБ. */
/obj/item/ai_ram/high_capacity
	name = "High-capacity Memory"
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 2

/** Планка RAM на 3 ТБ. */
/obj/item/ai_ram/hyper_capacity
	name = "Hyper-capacity Memory"
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 3

/** Блюспейс-планка RAM на 4 ТБ. */
/obj/item/ai_ram/bluespace
	name = "Bluespace Memory"
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 4
