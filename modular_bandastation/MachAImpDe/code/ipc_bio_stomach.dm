// ============================================
// ВИРТУАЛЬНЫЙ ЖЕЛУДОК ДЛЯ IPC С BIO-GENERATOR
// ============================================
// Этот organ вставляется автоматически при установке bio-generator импланта
// Позволяет IPC есть еду, но сам не перерабатывает её - это делает bio-generator

/obj/item/organ/stomach/ipc_bio
	name = "bio-generator stomach"
	desc = "Виртуальный желудок IPC, работающий на основе bio-generator импланта. Перерабатывает органическую пищу в энергию для батарейки."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "stomach-ipc"

	// Настройки для IPC
	metabolism_efficiency = 0 // Не перерабатываем reagents - это делает bio-generator
	hunger_modifier = 0 // Не влияем на голод - IPC с bio-generator не голодают

	// Organ flags
	organ_flags = ORGAN_ROBOTIC | ORGAN_UNREMOVABLE // Синтетический и несъемный (пока есть bio-generator)

// Отключаем стандартную обработку желудка - всё делает bio-generator через сигналы
/obj/item/organ/stomach/ipc_bio/on_life(seconds_per_tick)
	// Не вызываем родительский метод - не нужно переваривание
	// Bio-generator сам обработает еду через COMSIG_LIVING_EAT_FOOD

	// Только очищаем reagents если их больше 100u (защита от переполнения)
	if(reagents && reagents.total_volume > 100)
		reagents.clear_reagents()

	return

// Этот желудок не управляет голодом
/obj/item/organ/stomach/ipc_bio/handle_hunger(mob/living/carbon/human/human, seconds_per_tick)
	return // IPC с bio-generator не голодают
