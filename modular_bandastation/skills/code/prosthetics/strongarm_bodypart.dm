// Протез руки "Strongarm" - боевая модификация протеза
// Особенности:
// - Повышенный урон при ударах (unarmed_damage_low = 10, unarmed_damage_high = 18)
// - Отбрасывание (knockback) при ударах рукой
// - Улучшенное толкание (shove) с валением на землю и отбрасыванием
// - Невозможно выбраться из захвата (unarmed_grab_state_bonus = 10, unarmed_grab_escape_chance_bonus = -100)
// - Увеличенная сила броска (через trait TRAIT_THROWINGARM и кастомный элемент)

/// Элемент для усиленного броска мобов
/datum/element/strongarm_throw

/datum/element/strongarm_throw/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_THROWINGARM, "strongarm_prosthesis")

/datum/element/strongarm_throw/Detach(datum/target)
	REMOVE_TRAIT(target, TRAIT_THROWINGARM, "strongarm_prosthesis")
	return ..()

/// Компонент для боевых способностей протеза Strongarm
/// Обрабатывает knockback при ударах и улучшенное толкание
/datum/component/strongarm_combat
	/// Дистанция отбрасывания при ударе
	var/knockback_distance = 3
	/// Дистанция отбрасывания при толкании (shove)
	var/shove_throw_distance = 5
	/// Скорость отбрасывания при толкании
	var/shove_throw_speed = 3
	/// Время knockdown при толкании
	var/shove_knockdown_time = 3 SECONDS

/datum/component/strongarm_combat/Initialize(_knockback_distance, _shove_throw_distance, _shove_throw_speed, _shove_knockdown_time)
	. = ..()
	if(_knockback_distance)
		knockback_distance = _knockback_distance
	if(_shove_throw_distance)
		shove_throw_distance = _shove_throw_distance
	if(_shove_throw_speed)
		shove_throw_speed = _shove_throw_speed
	if(_shove_knockdown_time)
		shove_knockdown_time = _shove_knockdown_time

/datum/component/strongarm_combat/RegisterWithParent()
	. = ..()
	// Регистрируем сигнал для ударов (когда владелец бьёт кого-то)
	RegisterSignal(parent, COMSIG_HUMAN_PUNCHED, PROC_REF(on_punch))
	// Регистрируем сигнал для unarmed атаки (включая disarm/shove через правый клик)
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

/datum/component/strongarm_combat/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HUMAN_PUNCHED, COMSIG_LIVING_UNARMED_ATTACK))

/// Обработчик ударов - добавляет knockback
/datum/component/strongarm_combat/proc/on_punch(mob/living/carbon/human/source, mob/living/carbon/human/target, damage, attack_type, obj/item/bodypart/affecting, final_armor_block, kicking, limb_sharpness)
	SIGNAL_HANDLER

	// Не применяем knockback если бьём ногой или если цель уже лежит
	if(kicking || target.body_position == LYING_DOWN)
		return

	// Проверяем, что удар был нанесён рукой с протезом strongarm
	var/obj/item/bodypart/arm/active_arm = source.get_active_hand()
	if(!istype(active_arm, /obj/item/bodypart/arm/left/robot/strongarm) && !istype(active_arm, /obj/item/bodypart/arm/right/robot/strongarm))
		return

	// Применяем knockback
	var/throw_dir = get_dir(source, target)
	var/turf/throw_target = get_edge_target_turf(target, throw_dir)
	target.safe_throw_at(throw_target, knockback_distance, 1, source, gentle = FALSE)

	// Визуальный эффект
	target.visible_message(
		span_danger("[capitalize(target.declent_ru(NOMINATIVE))] отлетает от мощного удара!"),
		span_userdanger("Мощный удар отбрасывает вас!"),
		span_hear("Вы слышите глухой удар!"),
		COMBAT_MESSAGE_RANGE,
		source
	)
	to_chat(source, span_danger("Ваш удар отбрасывает [target.declent_ru(ACCUSATIVE)]!"))

/// Обработчик unarmed атаки - перехватывает disarm/shove (правый клик)
/datum/component/strongarm_combat/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	// Проверяем, что это правый клик (disarm/shove)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE

	// Проверяем, что цель - живой моб
	if(!isliving(target))
		return NONE

	var/mob/living/living_target = target

	// Проверяем, что атакующий - человек
	var/mob/living/carbon/human/human_source = source
	if(!istype(human_source))
		return NONE

	// Проверяем, что толкание было выполнено рукой с протезом strongarm
	var/obj/item/bodypart/arm/active_arm = human_source.get_active_hand()
	if(!istype(active_arm, /obj/item/bodypart/arm/left/robot/strongarm) && !istype(active_arm, /obj/item/bodypart/arm/right/robot/strongarm))
		return NONE

	// Применяем усиленное отбрасывание с валением на землю
	var/throw_dir = get_dir(source, living_target)
	var/turf/throw_target = get_edge_target_turf(living_target, throw_dir)

	// Звук толкания
	playsound(living_target, 'sound/items/weapons/shove.ogg', 50, TRUE, -1)
	human_source.do_attack_animation(living_target, ATTACK_EFFECT_DISARM)

	// Валит на землю
	living_target.Knockdown(shove_knockdown_time, daze_amount = 3 SECONDS)

	// Отбрасывает цель
	living_target.safe_throw_at(throw_target, shove_throw_distance, shove_throw_speed, source, gentle = FALSE)

	// Выбивание оружия если цель staggered или лежит
	var/obj/item/target_held_item = living_target.get_active_held_item()
	if(target_held_item && (living_target.has_status_effect(/datum/status_effect/staggered) || living_target.body_position == LYING_DOWN))
		living_target.dropItemToGround(target_held_item)
		living_target.visible_message(
			span_danger("[capitalize(living_target.declent_ru(NOMINATIVE))] роняет [target_held_item.declent_ru(ACCUSATIVE)]!"),
			span_warning("Вы роняете [target_held_item.declent_ru(ACCUSATIVE)]!"),
			null,
			COMBAT_MESSAGE_RANGE
		)

	// Визуальный эффект
	living_target.visible_message(
		span_danger("[capitalize(source.declent_ru(NOMINATIVE))] с силой толкает [living_target.declent_ru(ACCUSATIVE)], сбивая с ног!"),
		span_userdanger("[capitalize(source.declent_ru(NOMINATIVE))] с огромной силой толкает вас, сбивая с ног!"),
		span_hear("Вы слышите глухой удар!"),
		COMBAT_MESSAGE_RANGE,
		source
	)
	to_chat(source, span_danger("Вы с силой толкаете [living_target.declent_ru(ACCUSATIVE)], сбивая с ног!"))

	log_combat(source, living_target, "strongarm shoved")

	// Отменяем стандартную обработку чтобы избежать дублирования
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/bodypart/arm/left/robot/strongarm
	name = "протез левой руки 'Strongarm'"
	desc = "Боевой протез руки с усиленной гидравликой для сокрушительных ударов, захватов и бросков. \
		Удары этой рукой отбрасывают противников, а толкание валит их на землю. \
		Создан по технологиям, схожим с имплантом Strongarm, но реализован как полноценный протез."
	// Используем стандартные иконки роботизированных рук
	// При необходимости можно создать кастомные иконки

	// === ПРОЧНОСТЬ И ЗАЩИТА ===
	// Сверхпрочная конструкция - сниженный входящий урон
	brute_modifier = 0.5 // 50% урона от физических атак
	burn_modifier = 0.5 // 50% урона от огня/энергии
	wound_resistance = 20 // Высокое сопротивление ранам
	max_damage = 80 // Увеличенная прочность (стандартно 50)

	// Нельзя отключить конечность через урон
	can_be_disabled = FALSE

	// === СКОРОСТЬ ===
	// Ускоренные действия и атаки
	interaction_modifier = -0.5 // На 50% быстрее do_after действия
	click_cd_modifier = 0.7 // На 30% быстрее атаки

	// === БОЕВЫЕ ХАРАКТЕРИСТИКИ ===
	// Повышенные характеристики урона для боевого протеза
	unarmed_damage_low = 20
	unarmed_damage_high = 45
	unarmed_effectiveness = 35 // Высокая точность и пробивание брони

	// Урон при захвате (дополнительный урон когда цель пытается выбраться)
	unarmed_grab_damage_bonus = 35

	// КРИТИЧЕСКИ ВАЖНО: делает захват практически невозможным для побега
	// unarmed_grab_state_bonus добавляет к эффективному уровню захвата
	// Каждая единица = +1 уровень захвата для расчёта шанса побега
	unarmed_grab_state_bonus = 10

	// unarmed_grab_escape_chance_bonus - модификатор шанса побега (отрицательный = сложнее)
	// Базовый шанс побега = BASE_GRAB_RESIST_CHANCE (60) / effective_grab_state
	// С -100 шанс становится 0 до деления, делая побег невозможным
	unarmed_grab_escape_chance_bonus = -100

	// Множитель урона по схваченной цели
	unarmed_pummeling_bonus = 2.0

	// === TRAITS ДЛЯ ВЛАДЕЛЬЦА ===
	// TRAIT_THROWINGARM - усиленные броски
	// TRAIT_SHOCKIMMUNE - иммунитет к электричеству/тазеру
	// TRAIT_PIERCEIMMUNE - иммунитет к проникающему урону (осколки, шипы)
	// TRAIT_NODISMEMBER - невозможно оторвать конечность
	// TRAIT_PUSHIMMUNE - иммунитет к толканию
	// TRAIT_GRABRESISTANCE - сопротивление захвату
	bodypart_traits = list(
		TRAIT_THROWINGARM,
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_PUSHIMMUNE,
		TRAIT_GRABRESISTANCE,
	)

/// Защита от EMP - протез имеет экранирование
/obj/item/bodypart/arm/left/robot/strongarm/emp_effect(severity, protection)
	// Сверхпрочный протез имеет защиту от ЭМИ
	// Только искры, без урона и паралича
	do_sparks(number = 2, cardinal_only = FALSE, source = owner || src)
	if(owner)
		to_chat(owner, span_notice("Ваш [plaintext_zone] слегка искрит, но защита от ЭМИ срабатывает!"))
	return TRUE

/obj/item/bodypart/arm/left/robot/strongarm/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		new_owner.AddElement(/datum/element/strongarm_throw)
		new_owner.AddComponent(/datum/component/strongarm_combat, 3, 5, 3, 3 SECONDS)

/obj/item/bodypart/arm/left/robot/strongarm/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		old_owner.RemoveElement(/datum/element/strongarm_throw)
		var/datum/component/strongarm_combat/combat_component = old_owner.GetComponent(/datum/component/strongarm_combat)
		if(combat_component)
			qdel(combat_component)
	return ..()

/obj/item/bodypart/arm/right/robot/strongarm
	name = "протез правой руки 'Strongarm'"
	desc = "Боевой протез руки с усиленной гидравликой для сокрушительных ударов, захватов и бросков. \
		Удары этой рукой отбрасывают противников, а толкание валит их на землю. \
		Создан по технологиям, схожим с имплантом Strongarm, но реализован как полноценный протез."
	// Используем стандартные иконки роботизированных рук
	// При необходимости можно создать кастомные иконки

	// === ПРОЧНОСТЬ И ЗАЩИТА ===
	// Сверхпрочная конструкция - сниженный входящий урон
	brute_modifier = 0.5 // 50% урона от физических атак
	burn_modifier = 0.5 // 50% урона от огня/энергии
	wound_resistance = 20 // Высокое сопротивление ранам
	max_damage = 80 // Увеличенная прочность (стандартно 50)

	// Нельзя отключить конечность через урон
	can_be_disabled = FALSE

	// === СКОРОСТЬ ===
	// Ускоренные действия и атаки
	interaction_modifier = -0.5 // На 50% быстрее do_after действия
	click_cd_modifier = 0.7 // На 30% быстрее атаки

	// === БОЕВЫЕ ХАРАКТЕРИСТИКИ ===
	// Повышенные характеристики урона для боевого протеза
	unarmed_damage_low = 20
	unarmed_damage_high = 45
	unarmed_effectiveness = 35 // Высокая точность и пробивание брони

	// Урон при захвате (дополнительный урон когда цель пытается выбраться)
	unarmed_grab_damage_bonus = 35

	// КРИТИЧЕСКИ ВАЖНО: делает захват практически невозможным для побега
	unarmed_grab_state_bonus = 10
	unarmed_grab_escape_chance_bonus = -100

	// Множитель урона по схваченной цели
	unarmed_pummeling_bonus = 2.0

	// === TRAITS ДЛЯ ВЛАДЕЛЬЦА ===
	// TRAIT_THROWINGARM - усиленные броски
	// TRAIT_SHOCKIMMUNE - иммунитет к электричеству/тазеру
	// TRAIT_PIERCEIMMUNE - иммунитет к проникающему урону (осколки, шипы)
	// TRAIT_NODISMEMBER - невозможно оторвать конечность
	// TRAIT_PUSHIMMUNE - иммунитет к толканию
	// TRAIT_GRABRESISTANCE - сопротивление захвату
	bodypart_traits = list(
		TRAIT_THROWINGARM,
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_PUSHIMMUNE,
		TRAIT_GRABRESISTANCE,
	)

/// Защита от EMP - протез имеет экранирование
/obj/item/bodypart/arm/right/robot/strongarm/emp_effect(severity, protection)
	// Сверхпрочный протез имеет защиту от ЭМИ
	// Только искры, без урона и паралича
	do_sparks(number = 2, cardinal_only = FALSE, source = owner || src)
	if(owner)
		to_chat(owner, span_notice("Ваш [plaintext_zone] слегка искрит, но защита от ЭМИ срабатывает!"))
	return TRUE

/obj/item/bodypart/arm/right/robot/strongarm/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		new_owner.AddElement(/datum/element/strongarm_throw)
		new_owner.AddComponent(/datum/component/strongarm_combat, 3, 5, 3, 3 SECONDS)

/obj/item/bodypart/arm/right/robot/strongarm/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		old_owner.RemoveElement(/datum/element/strongarm_throw)
		var/datum/component/strongarm_combat/combat_component = old_owner.GetComponent(/datum/component/strongarm_combat)
		if(combat_component)
			qdel(combat_component)
	return ..()
