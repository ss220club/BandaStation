/*
 * Примеры использования элемента dodge_shift
 * Этот файл демонстрирует различные способы применения системы уклонения
 */

/*
 * ПРИМЕР 1: Добавление элемента мобу через код
 */

// Добавление базового уклонения мобу
/mob/living/simple_animal/hostile/example_dodger
	name = "shadow stalker"
	desc = "Быстрое существо, которое умеет уклоняться от атак."

/mob/living/simple_animal/hostile/example_dodger/Initialize(mapload)
	. = ..()
	// Добавляем элемент уклонения: 30% шанс, смещение на 20 пикселей
	AddElement(/datum/element/dodge_shift, dodge_chance = 30, shift_distance = 20)

/*
 * ПРИМЕР 2: Добавление уклонения через трейты
 */

// Трейт, который даёт способность уклонения
#define TRAIT_DODGE_SHIFT "dodge_shift_ability"

// Предмет, дающий способность уклонения при ношении
/obj/item/clothing/suit/armor/dodge_cloak
	name = "shadow cloak"
	desc = "Плащ, который позволяет уклоняться от атак."
	icon_state = "goliath_cloak"

	/// Ссылка на элемент уклонения
	var/datum/element/dodge_shift/dodge_element

/obj/item/clothing/suit/armor/dodge_cloak/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		// Добавляем элемент при надевании
		user.AddElement(/datum/element/dodge_shift/advanced)
		ADD_TRAIT(user, TRAIT_DODGE_SHIFT, CLOTHING_TRAIT)

/obj/item/clothing/suit/armor/dodge_cloak/dropped(mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_DODGE_SHIFT))
		// Убираем элемент при снятии
		user.RemoveElement(/datum/element/dodge_shift/advanced)
		REMOVE_TRAIT(user, TRAIT_DODGE_SHIFT, CLOTHING_TRAIT)

/*
 * ПРИМЕР 3: Способность через spell/action
 */

/datum/action/cooldown/spell/dodge_mode
	name = "Dodge Mode"
	desc = "Активирует режим уклонения на короткое время."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	cooldown_time = 30 SECONDS

	/// Длительность режима уклонения
	var/dodge_duration = 10 SECONDS

/datum/action/cooldown/spell/dodge_mode/cast(mob/living/cast_on)
	. = ..()

	// Добавляем временное уклонение
	cast_on.AddElement(/datum/element/dodge_shift/master)
	to_chat(cast_on, span_notice("Вы входите в режим уклонения!"))

	// Убираем через время
	addtimer(CALLBACK(src, PROC_REF(remove_dodge), cast_on), dodge_duration)

/datum/action/cooldown/spell/dodge_mode/proc/remove_dodge(mob/living/target)
	if(QDELETED(target))
		return
	target.RemoveElement(/datum/element/dodge_shift/master)
	to_chat(target, span_warning("Режим уклонения закончился."))

/*
 * ПРИМЕР 4: Статус-эффект с уклонением
 */

/datum/status_effect/dodge_buff
	id = "dodge_buff"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/dodge_buff

/datum/status_effect/dodge_buff/on_apply()
	. = ..()
	owner.AddElement(/datum/element/dodge_shift/advanced)
	return TRUE

/datum/status_effect/dodge_buff/on_remove()
	. = ..()
	owner.RemoveElement(/datum/element/dodge_shift/advanced)

/atom/movable/screen/alert/status_effect/dodge_buff
	name = "Dodge Buff"
	desc = "Вы чувствует прилив ловкости!"
	icon_state = "template"

/*
 * ПРИМЕР 5: Расширенный элемент с уклонением от проектайлов
 * ВАЖНО: Для проектайлов требуется дополнительная обработка через COMSIG_ATOM_PRE_BULLET_ACT
 */

/datum/element/dodge_shift/projectile/Attach(datum/target, ...)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return

	// Дополнительно регистрируем сигнал для проектайлов
	RegisterSignal(target, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(on_projectile_act))

/datum/element/dodge_shift/projectile/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_PRE_BULLET_ACT)
	return ..()

/datum/element/dodge_shift/projectile/proc/on_projectile_act(mob/living/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	// Проверяем кулдаун
	if(!TIMER_COOLDOWN_FINISHED(source, COOLDOWN_DODGE_SHIFT))
		return

	// Проверяем шанс
	if(!prob(dodge_chance))
		return

	// Проверяем мобильность
	if(!(source.mobility_flags & MOBILITY_MOVE))
		return

	// Успешное уклонение от проектайла!
	perform_dodge(source, hitting_projectile, hitting_projectile.name)
	TIMER_COOLDOWN_START(source, COOLDOWN_DODGE_SHIFT, cooldown_time)

	// Возвращаем специальный флаг,	return COMPONENT_BULLET_PIERCED

/*
 * ПРИМЕР 6: Реагент, дающий уклонение
 */

/datum/reagent/medicine/dodge_serum
	name = "Dodge Serum"
	description = "Химический коктейль, временно увеличивающий рефлексы."
	color = "#00FFFF"
	overdose_threshold = 15

/datum/reagent/medicine/dodge_serum/on_mob_add(mob/living/source)
	. = ..()
	source.AddElement(/datum/element/dodge_shift/basic)

/datum/reagent/medicine/dodge_serum/on_mob_delete(mob/living/source)
	. = ..()
	source.RemoveElement(/datum/element/dodge_shift/basic)

/datum/reagent/medicine/dodge_serum/overdose_process(mob/living/source, seconds_per_tick)
	. = ..()
	// Передозировка вызывает головокружение
	source.adjust_dizzy(5)
