// ============================================
// BODY MODIFICATIONS: IPC BRAIN TYPE
// ============================================
// Тип позитронного ядра для IPC.
// Интегрируется в категорию "Органы" системы body_modifications.
// Использует уже существующие /obj/item/organ/brain/positronic типы.
// ============================================

/datum/body_modification/implants/ipc_brain
	abstract_type = /datum/body_modification/implants/ipc_brain
	category = "Органы"
	cost = 0

/datum/body_modification/implants/ipc_brain/can_be_applied(mob/living/carbon/target)
	if(!..())
		return FALSE
	// Доступно только для IPC
	if(!istype(target.dna?.species, /datum/species/ipc))
		return FALSE
	return TRUE

// ============================================
// СТАНДАРТНОЕ ПОЗИТРОННОЕ ЯДРО
// ============================================
/datum/body_modification/implants/ipc_brain/positronic
	key = "ipc_brain_positronic"
	name = "Позитронное ядро (стандарт)"
	replacement_organ = /obj/item/organ/brain/positronic

/datum/body_modification/implants/ipc_brain/positronic/get_description()
	return "Стандартное позитронное ядро — искусственный интеллект на позитронной основе. \
	Комплексный позитронный блок, содержащий искусственное сознание."

// ============================================
// MMI С ОРГАНИЧЕСКИМ СОЗНАНИЕМ
// ============================================
/datum/body_modification/implants/ipc_brain/mmi
	key = "ipc_brain_mmi"
	name = "MMI-based Positronic Core"
	replacement_organ = /obj/item/organ/brain/positronic/mmi

/datum/body_modification/implants/ipc_brain/mmi/get_description()
	return "Позитронный блок с установленным MMI. \
	Содержит оцифрованное органическое сознание — человеческий или иной разумный мозг, \
	интегрированный в позитронную архитектуру через Man-Machine Interface."

// ============================================
// ПЛАТА ИЗ КИБОРГА
// ============================================
/datum/body_modification/implants/ipc_brain/borg
	key = "ipc_brain_borg"
	name = "Borg Module Positronic Core"
	replacement_organ = /obj/item/organ/brain/positronic/borg

/datum/body_modification/implants/ipc_brain/borg/get_description()
	return "Позитронный блок с платой из киборга. \
	Содержит ИИ-личность, изначально разработанную для синтетического тела. \
	Часто используется для IPC, собранных из утилизированных киборгов."
