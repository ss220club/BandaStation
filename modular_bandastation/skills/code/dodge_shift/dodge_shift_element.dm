#define COOLDOWN_DODGE_SHIFT "dodge_shift_cooldown"

/*
 * Элемент для уклонения с визуальными эффектами
 * При успешном уклонении смещает куклу попиксельно в сторону с эффектом блюра/миража
 */

/datum/element/dodge_shift
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// Шанс уклонения (0-100)
	var/dodge_chance = 30
	/// Дистанция смещения в пикселях
	var/shift_distance = 24
	/// Время в децисекундах до возврата на место
	var/return_delay = 0.4 SECONDS
	/// Время анимации смещения
	var/shift_time = 0.15 SECONDS
	/// Время анимации возврата
	var/return_time = 0.25 SECONDS
	/// Кулдаун между уклонениями
	var/cooldown_time = 2 SECONDS
	/// Типы атак, от которых можно уклониться (битовые флаги)
	var/dodge_attack_types = MELEE_ATTACK | UNARMED_ATTACK | THROWN_PROJECTILE_ATTACK
	/// Звук при уклонении
	var/dodge_sound = 'sound/items/weapons/punchmiss.ogg'
	/// Создавать ли afterimage (мираж)
	var/create_afterimage = TRUE
	/// Прозрачность afterimage
	var/afterimage_alpha = 128
	/// Время жизни afterimage
	var/afterimage_duration = 0.5 SECONDS

/datum/element/dodge_shift/Attach(datum/target, _dodge_chance = null, _shift_distance = null, _return_delay = null, _cooldown_time = null, _dodge_attack_types = null)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	// Применяем только переданные аргументы, сохраняя значения подтипа
	if(_dodge_chance != null)
		src.dodge_chance = _dodge_chance
	if(_shift_distance != null)
		src.shift_distance = _shift_distance
	if(_return_delay != null)
		src.return_delay = _return_delay
	if(_cooldown_time != null)
		src.cooldown_time = _cooldown_time
	if(_dodge_attack_types != null)
		src.dodge_attack_types = _dodge_attack_types

	RegisterSignal(target, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_check_block))
	// Для проектайлов нужен отдельный сигнал, так как COMSIG_LIVING_CHECK_BLOCK не перехватывает их
	if(dodge_attack_types & (PROJECTILE_ATTACK | THROWN_PROJECTILE_ATTACK))
		RegisterSignal(target, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(on_pre_bullet_act))

/datum/element/dodge_shift/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_CHECK_BLOCK, COMSIG_ATOM_PRE_BULLET_ACT))
	return ..()

/// Обработчик сигнала проверки блока
/datum/element/dodge_shift/proc/on_check_block(mob/living/source, atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER

	// Проверяем тип атаки
	if(!(attack_type & dodge_attack_types))
		return FAILED_BLOCK

	// Проверяем кулдаун через таймер (только если cooldown_time > 0)
	if(cooldown_time > 0 && !TIMER_COOLDOWN_FINISHED(source, COOLDOWN_DODGE_SHIFT))
		return FAILED_BLOCK

	// Проверяем шанс уклонения
	if(!prob(dodge_chance))
		return FAILED_BLOCK

	// Проверяем, может ли моб двигаться
	if(!(source.mobility_flags & MOBILITY_MOVE))
		return FAILED_BLOCK

	// Успешное уклонение!
	perform_dodge(source, hit_by, attack_text)

	// Запускаем кулдаун только если он задан
	if(cooldown_time > 0)
		TIMER_COOLDOWN_START(source, COOLDOWN_DODGE_SHIFT, cooldown_time)

	return SUCCESSFUL_BLOCK

/// Обработчик проектайлов (COMSIG_ATOM_PRE_BULLET_ACT)
/// Этот сигнал срабатывает ДО bullet_act и позволяет полностью избежать попадания
/datum/element/dodge_shift/proc/on_pre_bullet_act(mob/living/source, obj/projectile/hitting_projectile, def_zone, piercing_hit)
	SIGNAL_HANDLER

	// Проверяем, включены ли проектайлы в типы атак для уклонения
	if(!(dodge_attack_types & PROJECTILE_ATTACK))
		return NONE

	// Проверяем кулдаун через таймер (только если cooldown_time > 0)
	if(cooldown_time > 0 && !TIMER_COOLDOWN_FINISHED(source, COOLDOWN_DODGE_SHIFT))
		return NONE

	// Проверяем шанс уклонения
	if(!prob(dodge_chance))
		return NONE

	// Проверяем, может ли моб двигаться
	if(!(source.mobility_flags & MOBILITY_MOVE))
		return NONE

	// Успешное уклонение от проектайла!
	perform_dodge(source, hitting_projectile, hitting_projectile.name)

	// Запускаем кулдаун только если он задан
	if(cooldown_time > 0)
		TIMER_COOLDOWN_START(source, COOLDOWN_DODGE_SHIFT, cooldown_time)

	// COMPONENT_BULLET_PIERCED означает, что пуля "прошла сквозь" - это по сути уклонение
	return COMPONENT_BULLET_PIERCED

/// Выполняет визуальное уклонение
/datum/element/dodge_shift/proc/perform_dodge(mob/living/dodger, atom/hit_by, attack_text)
	// Определяем направление уклонения
	var/dodge_dir = get_dodge_direction(dodger, hit_by)

	// Вычисляем смещение
	var/shift_x = 0
	var/shift_y = 0

	if(dodge_dir & NORTH)
		shift_y = shift_distance
	else if(dodge_dir & SOUTH)
		shift_y = -shift_distance

	if(dodge_dir & EAST)
		shift_x = shift_distance
	else if(dodge_dir & WEST)
		shift_x = -shift_distance

	// Если направление не определено, уклоняемся в случайную сторону
	if(!shift_x && !shift_y)
		shift_x = pick(-shift_distance, shift_distance)
		if(prob(50))
			shift_y = pick(-shift_distance, shift_distance)
			shift_x = 0

	// Создаём afterimage на старой позиции
	if(create_afterimage)
		create_afterimage_effect(dodger)

	// Добавляем фильтр motion blur
	var/blur_x = shift_x > 0 ? 2 : (shift_x < 0 ? -2 : 0)
	var/blur_y = shift_y > 0 ? 2 : (shift_y < 0 ? -2 : 0)
	dodger.add_filter("dodge_blur", 1, motion_blur_filter(x = blur_x, y = blur_y))

	// Запоминаем исходную позицию
	var/original_pixel_x = dodger.pixel_x
	var/original_pixel_y = dodger.pixel_y

	// Анимация смещения
	animate(dodger, pixel_x = original_pixel_x + shift_x, pixel_y = original_pixel_y + shift_y, time = shift_time, easing = CIRCULAR_EASING | EASE_OUT)

	// Визуальное сообщение
	dodger.visible_message(
		span_danger("[dodger] уклоняется от [attack_text]!"),
		span_userdanger("Вы уклоняетесь от [attack_text]!"),
	)

	// Звук уклонения
	if(dodge_sound)
		playsound(dodger, dodge_sound, 25, TRUE, -1)

	// Планируем возврат
	addtimer(CALLBACK(src, PROC_REF(return_to_position), dodger, original_pixel_x, original_pixel_y), return_delay)

/// Определяет направление уклонения на основе позиции атакующего
/datum/element/dodge_shift/proc/get_dodge_direction(mob/living/dodger, atom/attacker)
	if(!attacker)
		return pick(GLOB.cardinals)

	// Уклоняемся перпендикулярно направлению атаки
	var/attack_dir = get_dir(attacker, dodger)

	// Выбираем случайное перпендикулярное направление
	if(attack_dir & (NORTH|SOUTH))
		return pick(EAST, WEST)
	else if(attack_dir & (EAST|WEST))
		return pick(NORTH, SOUTH)
	else
		// Для диагональных атак
		return pick(GLOB.cardinals)

/// Возвращает куклу на исходную позицию
/datum/element/dodge_shift/proc/return_to_position(mob/living/dodger, original_x, original_y)
	if(QDELETED(dodger))
		return

	// Плавный возврат
	animate(dodger, pixel_x = original_x, pixel_y = original_y, time = return_time, easing = CIRCULAR_EASING | EASE_IN)

	// Убираем фильтр blur после возврата
	addtimer(CALLBACK(src, PROC_REF(remove_blur_filter), dodger), return_time)

/// Убирает фильтр blur
/datum/element/dodge_shift/proc/remove_blur_filter(mob/living/dodger)
	if(QDELETED(dodger))
		return
	dodger.remove_filter("dodge_blur")

/// Создаёт эффект afterimage (миража)
/datum/element/dodge_shift/proc/create_afterimage_effect(mob/living/dodger)
	var/obj/effect/temp_visual/dodge_afterimage/afterimage = new(get_turf(dodger))
	afterimage.copy_appearance_from(dodger)
	afterimage.pixel_x = dodger.pixel_x
	afterimage.pixel_y = dodger.pixel_y
	afterimage.alpha = afterimage_alpha
	afterimage.duration = afterimage_duration

	QDEL_IN(afterimage, afterimage_duration)

/*
 * Временный визуальный эффект - afterimage (мираж)
 */
/obj/effect/temp_visual/dodge_afterimage
	name = "afterimage"
	desc = "Призрачный след от быстрого движения."
	duration = 0.5 SECONDS
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/dodge_afterimage/Initialize(mapload)
	. = ..()
	// Анимация исчезновения
	animate(src, alpha = 0, time = duration, easing = CIRCULAR_EASING | EASE_IN)

/// Копирует внешний вид с моба
/obj/effect/temp_visual/dodge_afterimage/proc/copy_appearance_from(mob/living/source)
	if(!source)
		return

	appearance = source.appearance
	// Убираем эффекты, которые не нужны для миража
	overlays.Cut()
	underlays.Cut()

	// Добавляем синеватый оттенок для эффекта миража
	color = list(
		1, 0, 0,
		0, 0.8, 0,
		0, 0, 1,
		0, 0, 0
	)

/*
 * Предопределённые варианты элемента уклонения
 */

/// Базовое уклонение - 20% шанс, короткий кулдаун
/datum/element/dodge_shift/basic
	dodge_chance = 20
	shift_distance = 16
	return_delay = 0.3 SECONDS
	cooldown_time = 1.5 SECONDS

/// Продвинутое уклонение - 35% шанс, средний кулдаун
/datum/element/dodge_shift/advanced
	dodge_chance = 35
	shift_distance = 24
	return_delay = 0.4 SECONDS
	cooldown_time = 2 SECONDS

/// Мастер уклонения - 50% шанс, но длинный кулдаун
/datum/element/dodge_shift/master
	dodge_chance = 50
	shift_distance = 32
	return_delay = 0.5 SECONDS
	cooldown_time = 4 SECONDS
	create_afterimage = TRUE
	afterimage_alpha = 100

/// У вас есть 7 минут
/datum/element/dodge_shift/ultimate
	dodge_chance = 100
	shift_distance = 24
	return_delay = 0.3 SECONDS
	cooldown_time = 0
	dodge_attack_types = MELEE_ATTACK | UNARMED_ATTACK | PROJECTILE_ATTACK | THROWN_PROJECTILE_ATTACK | LEAP_ATTACK | OVERWHELMING_ATTACK
	create_afterimage = TRUE
	afterimage_alpha = 100

/// Уклонение от проектайлов (требует отдельной обработки через COMSIG_ATOM_PRE_BULLET_ACT)
/datum/element/dodge_shift/projectile
	dodge_chance = 25
	dodge_attack_types = PROJECTILE_ATTACK | THROWN_PROJECTILE_ATTACK
	cooldown_time = 3 SECONDS

