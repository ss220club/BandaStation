/obj/item/organ/brain/skrell
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/obj/item/organ/eyes/skrell
	name = "skrell eyeballs"
	desc = "Глаза синеватого оттенка, но по своей структуре - глаза обычного гуманоида."
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'
	synchronized_blinking = FALSE
	eye_icon_state = "skrell_eyes"

/obj/item/organ/tongue/skrell
	name = "skrell tongue"
	desc = "Склизкий язык скрелла."
	languages_native = list(/datum/language/qurvolious)
	liked_foodtypes = VEGETABLES | FRUIT | MUSHROOM
	disliked_foodtypes = SEAFOOD
	toxic_foodtypes = ALCOHOL | MEAT

/obj/item/organ/tongue/get_possible_languages()
	return ..() + /datum/language/qurvolious

/obj/item/organ/heart/skrell
	name = "skrell heart"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/obj/item/organ/lungs/skrell
	name = "skrell lungs"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/obj/item/organ/stomach/skrell
	name = "skrell stomach"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/// Хук базовой печени: освобождает ли печень от штатного урона данным токсином в metabolize()
/obj/item/organ/liver/proc/can_filter_toxin(datum/reagent/toxin/T)
	return FALSE

/// Хук базовой печени: нужно ли пропускать удаление малых доз (<= toxTolerance), чтобы сработал handle_chemical()
/obj/item/organ/liver/proc/has_custom_toxin_metabolism(datum/reagent/toxin/T)
	return FALSE

/obj/item/organ/liver/skrell
	name = "skrell liver"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 4
	toxTolerance = 5
	/// Ссылка на временную травму пацифизма, полученную от передозировки Earthsblood
	var/datum/brain_trauma/severe/pacifism/earthsblood_trauma
	/// Флаг: был ли у владельца пацифизм еще до начала передозировки Кровью Земли
	var/preexisting_earthsblood_pacifism = FALSE
	/// Флаг: находился ли скрелл в состоянии реальной передозировки Earthsblood (>= 45u)
	var/earthsblood_overdose_active = FALSE
	/// Точный снимок урона мозга перед тиком защищенного реагента
	var/expected_brain_damage = null
	/// Точный снимок урона сердца перед тиком защищенного реагента
	var/expected_heart_damage = null
	/// Точный снимок урона печени перед тиком защищенного алкоголя
	var/expected_liver_damage = null
	/// Точный снимок токсического урона перед тиком передозировки Earthsblood
	var/expected_tox_damage = null

// MARK: Global Reagent Typecaches for Skrell Metabolism

/// Токсины, к которым у скреллов полный иммунитет (выводятся без эффектов и вреда печени)
GLOBAL_LIST_INIT(skrell_harmless_toxins, typecacheof(list(
	/datum/reagent/toxin/amatoxin,
	/datum/reagent/toxin/amanitin,
	/datum/reagent/toxin/coniine,
	/datum/reagent/toxin/bungotoxin,
	/datum/reagent/toxin/spore,
)))

/// Токсины, которые метаболизируются скреллами в питательные вещества
GLOBAL_LIST_INIT(skrell_nutritious_toxins, typecacheof(list(
	/datum/reagent/toxin/tetrodotoxin,
	/datum/reagent/toxin/carpotoxin,
	/datum/reagent/toxin/mushroom_powder,
)))

/// Все токсины с нестандартным метаболизмом (не должны удаляться в малых дозах до вызова handle_chemical)
GLOBAL_LIST_INIT(skrell_custom_toxins, typecacheof(list(
	/datum/reagent/toxin/tetrodotoxin,
	/datum/reagent/toxin/carpotoxin,
	/datum/reagent/toxin/mushroom_powder,
	/datum/reagent/toxin/lipolicide,
	/datum/reagent/toxin/curare,
	/datum/reagent/toxin/mindbreaker,
)))

/// Реагенты (этанол и Кровь Земли), не наносящие урона печени скрелла
GLOBAL_LIST_INIT(skrell_liver_protected_reagents, typecacheof(list(
	/datum/reagent/consumable/ethanol/fyrsskar_tears,
	/datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture,
	/datum/reagent/consumable/ethanol/aliose_velvet_cordial,
	/datum/reagent/consumable/ethanol/omega_glow_cocktail,
	/datum/reagent/consumable/ethanol/moonshine,
	/datum/reagent/medicine/earthsblood,
)))

/// Реагенты, не наносящие урона мозгу скрелла
GLOBAL_LIST_INIT(skrell_brain_protected_reagents, typecacheof(list(
	/datum/reagent/medicine/earthsblood,
	/datum/reagent/mercury,
	/datum/reagent/drug/bath_salts,
	/datum/reagent/drug/maint/powder,
	/datum/reagent/drug/happiness,
	/datum/reagent/drug/krokodil,
	/datum/reagent/drug/methamphetamine,
	/datum/reagent/drug/cocaine,
	/datum/reagent/toxin/fentanyl,
)))

/// Реагенты, не наносящие урона сердцу скрелла
GLOBAL_LIST_INIT(skrell_heart_protected_reagents, typecacheof(list(
	/datum/reagent/drug/kronkaine,
	/datum/reagent/drug/cocaine,
	/datum/reagent/drug/methamphetamine,
)))

/// Все вещества, не вызывающие привыкания (зависимости) у скреллов
GLOBAL_LIST_INIT(skrell_non_addictive_reagents, typecacheof(list(
	/datum/reagent/drug/space_drugs,
	/datum/reagent/drug/cannabis,
	/datum/reagent/drug/mushroomhallucinogen,
	/datum/reagent/drug/nicotine,
	/datum/reagent/drug/kronkaine,
	/datum/reagent/medicine/coagulant/seraka_extract,
	/datum/reagent/drug/cocaine,
	/datum/reagent/drug/methamphetamine,
	/datum/reagent/drug/maint/tar,
	/datum/reagent/drug/maint/sludge,
	/datum/reagent/drug/aranesp,
	/datum/reagent/medicine/earthsblood,
)))

/// Тяжелые стимуляторы с особым моторным передозом (порог 25u, возврат контроля на <= 20u)
GLOBAL_LIST_INIT(skrell_hard_stimulants, typecacheof(list(
	/datum/reagent/drug/cocaine,
	/datum/reagent/drug/methamphetamine,
)))

/// Медикаменты с удвоенным порогом передозировки (x2 от стандартного)
GLOBAL_LIST_INIT(skrell_doubled_overdose_reagents, typecacheof(list(
	/datum/reagent/medicine/morphine,
	/datum/reagent/medicine/atropine,
	/datum/reagent/medicine/ephedrine,
	/datum/reagent/medicine/c2/musiver,
)))

/// Таблица кастомных порогов передозировки для скреллов (0 = передозировка отключена, >0 = новый порог, крит = порог * 2)
GLOBAL_LIST_INIT(skrell_overdose_thresholds, list(
	// 0u: Полное отключение передозировки
	/datum/reagent/drug/space_drugs = 0,
	/datum/reagent/drug/cannabis = 0,
	/datum/reagent/drug/mushroomhallucinogen = 0,
	/datum/reagent/drug/nicotine = 0,
	/datum/reagent/drug/kronkaine = 0,
	/datum/reagent/medicine/coagulant/seraka_extract = 0,
	// 25u: Тяжелые стимуляторы (критический 50u)
	/datum/reagent/drug/cocaine = 25,
	/datum/reagent/drug/methamphetamine = 25,
	// 45u: Соли для ванн и Кровь Земли (критический 100u и 90u)
	/datum/reagent/drug/bath_salts = 50,
	/datum/reagent/medicine/earthsblood = 45,
	// 60u: Синтетика и омнизин (критический 160u)
	/datum/reagent/drug/krokodil = 80,
	/datum/reagent/drug/happiness = 80,
	/datum/reagent/drug/maint/powder = 80,
	/datum/reagent/drug/blastoff = 80,
	/datum/reagent/drug/pumpup = 80,
	/datum/reagent/drug/saturnx = 80,
	/datum/reagent/drug/syndol = 80,
	/datum/reagent/medicine/omnizine = 80,
))

// MARK: Skrell Liver Procs

/obj/item/organ/liver/skrell/can_filter_toxin(datum/reagent/toxin/T)
	if(organ_flags & ORGAN_FAILING)
		return FALSE
	return is_type_in_typecache(T, GLOB.skrell_harmless_toxins) || has_custom_toxin_metabolism(T)

/obj/item/organ/liver/skrell/has_custom_toxin_metabolism(datum/reagent/toxin/T)
	if(organ_flags & ORGAN_FAILING)
		return FALSE
	return is_type_in_typecache(T, GLOB.skrell_custom_toxins)

/// Вспомогательная процедура: поглощает порцию реагента за тик и останавливает стандартный метаболизм
/obj/item/organ/liver/skrell/proc/consume_and_stop_tick(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick)
	var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
	organ_owner.reagents.remove_reagent(chem.type, metabolized)
	return COMSIG_MOB_STOP_REAGENT_TICK

/// Безопасная частичная компенсация урона токсинами (не лечит чужой урон ниже порога до тика)
/obj/item/organ/liver/skrell/proc/refund_reagent_tox_loss(mob/living/carbon/organ_owner, amount_to_refund, min_tox_floor)
	if(!organ_owner || amount_to_refund <= 0)
		return
	var/current_tox = organ_owner.toxloss
	if(current_tox <= min_tox_floor)
		return
	var/actual_refund = min(amount_to_refund, current_tox - min_tox_floor)
	organ_owner.adjust_tox_loss(-actual_refund, FALSE, TRUE)

/// Безопасная частичная компенсация урона удушьем (не лечит чужое удушье ниже порога до тика)
/obj/item/organ/liver/skrell/proc/refund_reagent_oxy_loss(mob/living/carbon/organ_owner, amount_to_refund, min_oxy_floor)
	if(!organ_owner || amount_to_refund <= 0)
		return
	var/current_oxy = organ_owner.oxyloss
	if(current_oxy <= min_oxy_floor)
		return
	var/actual_refund = min(amount_to_refund, current_oxy - min_oxy_floor)
	organ_owner.adjust_oxy_loss(-actual_refund, FALSE)

/// Планирует отложенную компенсацию токсического урона после завершения тика реагента
/obj/item/organ/liver/skrell/proc/schedule_tox_refund(mob/living/carbon/organ_owner, amount)
	addtimer(CALLBACK(src, PROC_REF(refund_reagent_tox_loss), organ_owner, amount, organ_owner.toxloss), 0)

/// Планирует отложенную компенсацию кислородного урона после завершения тика реагента
/obj/item/organ/liver/skrell/proc/schedule_oxy_refund(mob/living/carbon/organ_owner, amount)
	addtimer(CALLBACK(src, PROC_REF(refund_reagent_oxy_loss), organ_owner, amount, organ_owner.oxyloss), 0)

/// Надежное снятие передозировки и временной травмы пацифизма от Earthsblood
/obj/item/organ/liver/skrell/proc/clear_earthsblood_overdose(mob/living/carbon/organ_owner, datum/reagent/earthsblood_chem, show_message = TRUE)
	if(earthsblood_chem)
		earthsblood_chem.overdosed = FALSE
		earthsblood_chem.overdosed_crit = FALSE

	if(!organ_owner)
		earthsblood_trauma = null
		earthsblood_overdose_active = FALSE
		return

	var/datum/brain_trauma/severe/pacifism/trauma_to_remove = earthsblood_trauma
	if(!trauma_to_remove && !preexisting_earthsblood_pacifism)
		trauma_to_remove = organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism)

	earthsblood_trauma = null
	var/was_active_overdose = earthsblood_overdose_active
	earthsblood_overdose_active = FALSE

	if(trauma_to_remove && !preexisting_earthsblood_pacifism)
		qdel(trauma_to_remove)
		if(show_message && was_active_overdose)
			var/reagent_name = earthsblood_chem ? earthsblood_chem.name : "Крови Земли"
			to_chat(organ_owner, span_notice("Концентрация реагента [reagent_name] снизилась до безопасного уровня, пацифизм отступил."))

/// Синхронный сброс урона мозгу, сердцу, печени и токсинам после тика защищенного реагента
/obj/item/organ/liver/skrell/proc/flush_organ_protection(mob/living/carbon/organ_owner)
	if(!organ_owner)
		expected_brain_damage = null
		expected_heart_damage = null
		expected_liver_damage = null
		expected_tox_damage = null
		return

	if(!isnull(expected_liver_damage))
		if(damage > expected_liver_damage)
			set_organ_damage(expected_liver_damage)
		expected_liver_damage = null

	if(!isnull(expected_brain_damage))
		var/obj/item/organ/brain/brain = organ_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(brain && brain.damage > expected_brain_damage)
			brain.set_organ_damage(expected_brain_damage)
		expected_brain_damage = null

	if(!isnull(expected_heart_damage))
		var/obj/item/organ/heart/heart = organ_owner.get_organ_slot(ORGAN_SLOT_HEART)
		if(heart && heart.damage > expected_heart_damage)
			heart.set_organ_damage(expected_heart_damage)
		expected_heart_damage = null

	if(!isnull(expected_tox_damage))
		var/current_tox = organ_owner.toxloss
		if(current_tox > expected_tox_damage)
			organ_owner.adjust_tox_loss(expected_tox_damage - current_tox, FALSE, TRUE)
		expected_tox_damage = null

/obj/item/organ/liver/skrell/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!owner)
		return

	var/datum/reagent/earthsblood
	if(owner.reagents)
		earthsblood = locate(/datum/reagent/medicine/earthsblood) in owner.reagents.reagent_list
	// Если реагент полностью вывелся (null) или упал ниже порога передозировки (45u)
	if(!earthsblood || earthsblood.volume < 45)
		if(earthsblood_overdose_active || earthsblood_trauma || earthsblood?.overdosed)
			clear_earthsblood_overdose(owner, earthsblood, show_message = TRUE)
		// Пока реагента нет в передозировке, отслеживаем наличие врожденного пацифизма
		if(!earthsblood)
			preexisting_earthsblood_pacifism = !!(owner.has_trauma_type(/datum/brain_trauma/severe/pacifism))

/obj/item/organ/liver/skrell/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, metabolization_rate)
	// Сначала синхронно закрываем защиту от предыдущего реагента в списке reagent_list
	flush_organ_protection(organ_owner)

	if((organ_flags & ORGAN_FAILING) || !organ_owner)
		return ..()

	// MARK: Stage 1 - Full Metabolism Interception

	// 1.1. Полный иммунитет к споровым и растительным ядам (0 урона, 0 вреда печени)
	if(is_type_in_typecache(chem, GLOB.skrell_harmless_toxins))
		return consume_and_stop_tick(organ_owner, chem, seconds_per_tick)

	// 1.2. Питательные токсины: Тетродотоксин, Карпотоксин и Грибной порошок дают сытость
	if(is_type_in_typecache(chem, GLOB.skrell_nutritious_toxins))
		organ_owner.adjust_nutrition(0.5 * metabolization_rate * seconds_per_tick)
		return consume_and_stop_tick(organ_owner, chem, seconds_per_tick)

	// 1.3. Полная замена стандартного эффекта на уникальный
	if(istype(chem, /datum/reagent/uranium/radium))
		organ_owner.adjust_tox_loss(0.25 * metabolization_rate * seconds_per_tick)
		return consume_and_stop_tick(organ_owner, chem, seconds_per_tick)

	if(istype(chem, /datum/reagent/toxin/lipolicide))
		organ_owner.adjust_nutrition(-3 * metabolization_rate * seconds_per_tick)
		organ_owner.overeatduration = 0
		return consume_and_stop_tick(organ_owner, chem, seconds_per_tick)

	if(istype(chem, /datum/reagent/teslium))
		organ_owner.set_jitter_if_lower(10 SECONDS)
		if(SPT_PROB(20, seconds_per_tick))
			organ_owner.drop_all_held_items()
		if(SPT_PROB(12, seconds_per_tick))
			organ_owner.Paralyze(2 SECONDS)
			to_chat(organ_owner, span_warning("Ваше тело пронзает электрический спазм, сковывая мышцы!"))
			playsound(organ_owner, /datum/sound_effect/sparks, 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return consume_and_stop_tick(organ_owner, chem, seconds_per_tick)

	if(istype(chem, /datum/reagent/consumable/liquidelectricity))
		organ_owner.set_light(2, 2, "#97ee63")
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/atom, set_light), 0), 3 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE)

		if(istype(organ_owner.loc, /turf/open/water) && SPT_PROB(20, seconds_per_tick))
			do_sparks(2, FALSE, organ_owner)
			playsound(organ_owner, /datum/sound_effect/sparks, 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			to_chat(organ_owner, span_notice("Вода вокруг вас мягко искрит биозарядом..."))
		return consume_and_stop_tick(organ_owner, chem, seconds_per_tick)

	// MARK: Stage 2 - Base Liver Processing & Liver Protection

	// Фиксируем чистый урон печени ДО того, как сработает ..() и ethanol/on_mob_life()
	if(is_type_in_typecache(chem, GLOB.skrell_liver_protected_reagents))
		expected_liver_damage = damage
		addtimer(CALLBACK(src, PROC_REF(flush_organ_protection), organ_owner), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

	. = ..()

	if(. & COMSIG_MOB_STOP_REAGENT_TICK)
		return

	// MARK: Stage 3 - Overdose & Addiction Modifications

	// 3.1. Отключение привыкания для всех неаддиктивных для скреллов веществ
	if(is_type_in_typecache(chem, GLOB.skrell_non_addictive_reagents))
		chem.addiction_types = null

	// 3.2. Установка кастомных порогов передозировки из глобальной таблицы (0u, 25u, 45u, 60u)
	var/custom_od_threshold = GLOB.skrell_overdose_thresholds[chem.type]
	if(!isnull(custom_od_threshold))
		if(custom_od_threshold == 0)
			chem.overdose_threshold = 0
			chem.overdosed = FALSE
			chem.overdosed_crit = FALSE
		else if(chem.overdose_threshold != custom_od_threshold)
			var/custom_crit_threshold = custom_od_threshold * 2
			chem.overdose_threshold = custom_od_threshold
			chem.overdose_crit_threshold = custom_crit_threshold
			if(chem.volume < custom_od_threshold)
				chem.overdosed = FALSE
			if(chem.volume < custom_crit_threshold)
				chem.overdosed_crit = FALSE

	// 3.3. Удвоенный порог передозировки (x2 от стандартного) для ряда медикаментов
	else if(is_type_in_typecache(chem, GLOB.skrell_doubled_overdose_reagents))
		if(chem.overdose_threshold && chem.overdose_threshold == initial(chem.overdose_threshold))
			chem.overdose_threshold = initial(chem.overdose_threshold) * 2
		if(chem.overdose_crit_threshold && chem.overdose_crit_threshold == initial(chem.overdose_crit_threshold))
			chem.overdose_crit_threshold = initial(chem.overdose_crit_threshold) * 2

	// 3.4. Специфическая логика тяжелых стимуляторов (Кокаин и Метамфетамин: порог 25u, возврат контроля на <= 20u)
	var/is_hard_stimulant = is_type_in_typecache(chem, GLOB.skrell_hard_stimulants)
	if(is_hard_stimulant)
		if(chem.volume <= 20)
			if(chem.overdosed)
				chem.overdosed = FALSE
				organ_owner.adjust_hallucinations(-1000 SECONDS)
				organ_owner.adjust_drowsiness(-1000 SECONDS)
				to_chat(organ_owner, span_notice("Дрожь в мышцах утихает, к вам возвращается полный контроль над движениями."))

			organ_owner.adjust_confusion(-1000 SECONDS)
			organ_owner.adjust_jitter(-1000 SECONDS)

		else if(chem.overdosed || chem.volume >= 25)
			if(!chem.overdosed)
				chem.overdosed = TRUE
				chem.overdose_start(organ_owner)

			organ_owner.adjust_hallucinations(5 SECONDS * metabolization_rate * seconds_per_tick)
			organ_owner.adjust_confusion(2 SECONDS * metabolization_rate * seconds_per_tick)
			organ_owner.set_jitter_if_lower(4 SECONDS)

			if(!HAS_TRAIT(organ_owner, TRAIT_IMMOBILIZED) && !ismovable(organ_owner.loc))
				for(var/i in 1 to round(2 * metabolization_rate * seconds_per_tick, 1))
					step(organ_owner, pick(GLOB.cardinals))

			if(SPT_PROB(12, seconds_per_tick))
				organ_owner.drop_all_held_items()

			expected_tox_damage = organ_owner.toxloss

			if(SPT_PROB(5, seconds_per_tick))
				to_chat(organ_owner, span_userdanger("Нервная система перегружена стимуляторами - тело дёргается само по себе!"))

	// 3.5. Специфическая логика Солей для ванн и Крови Земли (порог 45u)
	if(istype(chem, /datum/reagent/drug/bath_salts))
		if(chem.volume >= 45 && !chem.overdosed)
			chem.overdosed = TRUE
			chem.overdose_start(organ_owner)
		var/datum/reagent/drug/bath_salts/salts = chem
		if(salts.rage)
			QDEL_NULL(salts.rage)

	else if(istype(chem, /datum/reagent/medicine/earthsblood))
		if(chem.volume >= 45)
			if(!earthsblood_overdose_active)
				if(!chem.overdosed)
					preexisting_earthsblood_pacifism = !!(organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism))
					chem.overdosed = TRUE
					chem.overdose_start(organ_owner)
				earthsblood_overdose_active = TRUE
			if(!preexisting_earthsblood_pacifism && !earthsblood_trauma)
				earthsblood_trauma = organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism)
		else
			if(earthsblood_overdose_active || earthsblood_trauma || chem.overdosed)
				clear_earthsblood_overdose(organ_owner, chem, show_message = earthsblood_overdose_active)
			else
				preexisting_earthsblood_pacifism = !!(organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism))

	// 3.6. Универсальное снятие передозировки при падении объема ниже порога
	if(chem.overdose_threshold && chem.volume < chem.overdose_threshold && !is_hard_stimulant)
		chem.overdosed = FALSE

	if(chem.overdose_crit_threshold && chem.volume < chem.overdose_crit_threshold)
		chem.overdosed_crit = FALSE

	// MARK: Stage 4 - Internal Organ & Toxin Damage Protection

	// 4.1. Защита мозга
	if(is_type_in_typecache(chem, GLOB.skrell_brain_protected_reagents))
		var/obj/item/organ/brain/brain = organ_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(brain)
			expected_brain_damage = brain.damage

	// 4.2. Защита от токсического урона при передозировке Earthsblood
	if(istype(chem, /datum/reagent/medicine/earthsblood))
		expected_tox_damage = organ_owner.toxloss

	// 4.3. Защита сердца
	if(is_type_in_typecache(chem, GLOB.skrell_heart_protected_reagents))
		var/obj/item/organ/heart/heart = organ_owner.get_organ_slot(ORGAN_SLOT_HEART)
		if(heart)
			expected_heart_damage = heart.damage

	if(!isnull(expected_brain_damage) || !isnull(expected_heart_damage) || !isnull(expected_tox_damage))
		addtimer(CALLBACK(src, PROC_REF(flush_organ_protection), organ_owner), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

	// MARK: Stage 5 - Side Effect Compensation & Extra Effects

	// Защита от мумификации (некроза кожи) при приеме крокодила: пропускаем 36-й такт некроза
	if(istype(chem, /datum/reagent/drug/krokodil) && chem.current_cycle == 35)
		chem.current_cycle = 36

	// Компенсация побочного урона от кураре (паралич сохраняется, но токсины и легкие не страдают)
	if(istype(chem, /datum/reagent/toxin/curare))
		var/datum/reagent/toxin/curare_chem = chem
		schedule_tox_refund(organ_owner, curare_chem.toxpwr * metabolization_rate * seconds_per_tick)
		schedule_oxy_refund(organ_owner, 2 * metabolization_rate * seconds_per_tick)

	// Снижение токсического урона от синаптизина вдвое (без лечения чужого отравления)
	if(istype(chem, /datum/reagent/medicine/synaptizine))
		schedule_tox_refund(organ_owner, 0.5 * metabolization_rate * seconds_per_tick)

	// Эйфория от майндбрейкера
	if(istype(chem, /datum/reagent/toxin/mindbreaker))
		organ_owner.adjust_drugginess(20 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.add_mood_event("mindbreaker_high", /datum/mood_event/high)

	// Эйфория и частичное снижение токсичности самогона (без лечения чужого отравления)
	if(istype(chem, /datum/reagent/consumable/ethanol/moonshine))
		organ_owner.adjust_drugginess(25 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.adjust_hallucinations(5 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.add_mood_event("moonshine_high", /datum/mood_event/high)
		schedule_tox_refund(organ_owner, 1 * metabolization_rate * seconds_per_tick)

/obj/item/organ/liver/skrell/Destroy()
	expected_brain_damage = null
	expected_heart_damage = null
	expected_liver_damage = null
	expected_tox_damage = null
	if(earthsblood_trauma)
		qdel(earthsblood_trauma)
	earthsblood_trauma = null
	return ..()
