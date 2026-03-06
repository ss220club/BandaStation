// ============================================
// MMI CORE
// Ядро сознания, хранящееся внутри MMI.
// Является мозговым органом — работает со
// стандартной логикой MMI:
//   - Вставка: кликнуть MMI с mmi_core в руке
//   - Извлечение: attack_self() на MMI (ПКМ по себе)
// ============================================

/obj/item/organ/brain/mmi_core
	name = "MMI core"
	desc = "Компактный носитель оцифрованного сознания, извлечённый из MMI. Содержит загруженный разум существа. Может быть вставлен в MMI или установлен в подходящий корпус."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "mmi_core"
	w_class = WEIGHT_CLASS_SMALL
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/brain/mmi_core/Initialize(mapload)
	. = ..()
	icon_state = "mmi_core"
