/** Физическая планка RAM для ручной сборки серверного модуля. */
/obj/item/ai_ram
	name = "Standard Memory"
	desc = "Планка оперативной памяти для серверного модуля ИИ. Изготавливается на протолате; устанавливается в открытый корпус модуля."
	icon = 'modular_bandastation/ai_overhaul/icons/module.dmi'
	icon_state = "ram"
	w_class = WEIGHT_CLASS_SMALL
	/// Объём оперативной памяти этой планки в ТБ.
	var/capacity = 1

/obj/item/ai_ram/examine(mob/user)
	. = ..()
	. += span_notice("Объём RAM: [capacity] ТБ.")

/** Планка RAM на 2 ТБ. */
/obj/item/ai_ram/high_capacity
	name = "High-capacity Memory"
	capacity = 2

/** Планка RAM на 3 ТБ. */
/obj/item/ai_ram/hyper_capacity
	name = "Hyper-capacity Memory"
	capacity = 3

/** Блюспейс-планка RAM на 4 ТБ. */
/obj/item/ai_ram/bluespace
	name = "Bluespace Memory"
	capacity = 4
