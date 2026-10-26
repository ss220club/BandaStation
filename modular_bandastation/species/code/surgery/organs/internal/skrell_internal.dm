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

/obj/item/organ/liver/skrell
	name = "skrell liver"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 4
	toxTolerance = 5
	/// Ссылка на временную травму пацифизма, полученную от передозировки Earthsblood
	var/datum/brain_trauma/severe/pacifism/earthsblood_trauma
	/// Флаг: был ли у владельца пацифизм еще до начала передозировки Кровью Земли
	var/preexisting_earthsblood_pacifism = FALSE
	/// Точный снимок урона мозга перед тиком защищенного реагента
	var/expected_brain_damage = null
	/// Точный снимок урона сердца перед тиком защищенного реагента
	var/expected_heart_damage = null
	/// Точный снимок урона печени перед тиком защищенного алкоголя
	var/expected_liver_damage = null

/// Синхронный сброс урона мозгу и сердцу после тика конкретного защищенного реагента
/obj/item/organ/liver/skrell/proc/flush_organ_protection(mob/living/carbon/organ_owner)
	if(!organ_owner)
		expected_brain_damage = null
		expected_heart_damage = null
		expected_liver_damage = null
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

/obj/item/organ/liver/skrell/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!owner)
		return

	var/datum/reagent/earthsblood = owner.reagents?.has_reagent(/datum/reagent/medicine/earthsblood)

	// Если реагент полностью вывелся (0u) или упал ниже порога передозировки (45u)
	if(!earthsblood || earthsblood.volume < 45)
		if(earthsblood)
			earthsblood.overdosed = FALSE
		if(earthsblood_trauma)
			QDEL_NULL(earthsblood_trauma)
			var/reagent_name = earthsblood ? earthsblood.name : "Крови Земли"
			to_chat(owner, span_notice("Действие передозировки от [reagent_name] рассеялось, пацифизм отступил."))
		// Пока реагента нет в передозировке, отслеживаем наличие врожденного пацифизма
		if(!earthsblood)
			preexisting_earthsblood_pacifism = !!(owner.has_trauma_type(/datum/brain_trauma/severe/pacifism))

/obj/item/organ/liver/skrell/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, metabolization_rate)
	// Сначала синхронно закрываем защиту от предыдущего реагента в списке reagent_list
	flush_organ_protection(organ_owner)

	if((organ_flags & ORGAN_FAILING) || !organ_owner)
		return ..()

	// =========================================================================
	// ЭТАП 1. ПОЛНЫЙ ПЕРЕХВАТ МЕТАБОЛИЗМА (ДО ВЫЗОВА БАЗОВОЙ ЛОГИКИ ПЕЧЕНИ)
	// =========================================================================

	// 1.1. Полный иммунитет к споровым и растительным ядам (0 урона, 0 вреда печени)
	if(istype(chem, /datum/reagent/toxin/amatoxin) \
		|| istype(chem, /datum/reagent/toxin/amanitin) \
		|| istype(chem, /datum/reagent/toxin/coniine) \
		|| istype(chem, /datum/reagent/toxin/bungotoxin) \
		|| istype(chem, /datum/reagent/toxin/spore))

		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	// 1.2. Питательные токсины: Тетродотоксин, Карпотоксин и Грибной порошок дают сытость
	if(istype(chem, /datum/reagent/toxin/tetrodotoxin) \
		|| istype(chem, /datum/reagent/toxin/carpotoxin) \
		|| istype(chem, /datum/reagent/toxin/mushroom_powder))

		organ_owner.adjust_nutrition(0.5 * metabolization_rate * seconds_per_tick)
		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	// 1.3. Полная замена стандартного эффекта на уникальный
	if(istype(chem, /datum/reagent/uranium/radium))
		organ_owner.adjust_tox_loss(0.25 * metabolization_rate * seconds_per_tick)
		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	if(istype(chem, /datum/reagent/toxin/lipolicide))
		organ_owner.adjust_nutrition(-3 * metabolization_rate * seconds_per_tick)
		organ_owner.overeatduration = 0
		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	if(istype(chem, /datum/reagent/teslium))
		organ_owner.set_jitter_if_lower(10 SECONDS)
		if(SPT_PROB(20, seconds_per_tick))
			organ_owner.drop_all_held_items()
		if(SPT_PROB(12, seconds_per_tick))
			organ_owner.Paralyze(2 SECONDS)
			to_chat(organ_owner, span_warning("Ваше тело пронзает электрический спазм, сковывая мышцы!"))
			playsound(organ_owner, SFX_SPARKS, 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	if(istype(chem, /datum/reagent/consumable/liquidelectricity))
		organ_owner.set_light(2, 2, "#97ee63")
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/atom, set_light), 0), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

		if(istype(organ_owner.loc, /turf/open/water) && SPT_PROB(20, seconds_per_tick))
			do_sparks(2, FALSE, organ_owner)
			playsound(organ_owner, SFX_SPARKS, 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			to_chat(organ_owner, span_notice("Вода вокруг вас мягко искрит биозарядом..."))

		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	// =========================================================================
	// ЭТАП 2. БАЗОВАЯ ОБРАБОТКА ПЕЧЕНИ И ЗАЩИТА САМОГО ОРГАНА ПЕЧЕНИ
	// =========================================================================

	// Фиксируем чистый урон печени ДО того, как сработает ..() и on_mob_life()
	if(istype(chem, /datum/reagent/consumable/ethanol/fyrsskar_tears) \
		|| istype(chem, /datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture) \
		|| istype(chem, /datum/reagent/consumable/ethanol/aliose_velvet_cordial) \
		|| istype(chem, /datum/reagent/consumable/ethanol/omega_glow_cocktail) \
		|| istype(chem, /datum/reagent/consumable/ethanol/moonshine) \
		|| istype(chem, /datum/reagent/toxin/curare))

		expected_liver_damage = damage
		addtimer(CALLBACK(src, PROC_REF(flush_organ_protection), organ_owner), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

	. = ..()

	if(. & COMSIG_MOB_STOP_REAGENT_TICK)
		return

	// =========================================================================
	// ЭТАП 3. МОДИФИКАЦИЯ ПОРОГОВ ПЕРЕДОЗИРОВКИ, ЗАВИСИМОСТИ И ЭФФЕКТОВ
	// =========================================================================

	// 3.1. Полное отключение передозировки и привыкания (органика)
	if(istype(chem, /datum/reagent/drug/space_drugs) \
		|| istype(chem, /datum/reagent/drug/cannabis) \
		|| istype(chem, /datum/reagent/drug/mushroomhallucinogen) \
		|| istype(chem, /datum/reagent/drug/nicotine) \
		|| istype(chem, /datum/reagent/drug/kronkaine) \
		|| istype(chem, /datum/reagent/medicine/coagulant/seraka_extract))

		chem.overdose_threshold = 0
		chem.overdosed = FALSE
		chem.overdosed_crit = FALSE
		chem.addiction_types = null

	// 3.2. Кокаин и Метамфетамин: порог 25u, без привыкания, без урона, моторный хаос с возвратом контроля на 20u
	if(istype(chem, /datum/reagent/drug/cocaine) || istype(chem, /datum/reagent/drug/methamphetamine))
		// Если add_reagent сработал по человеческому порогу (15-20u) до первого тика печени — сбрасываем
		if(chem.overdose_threshold != 25)
			chem.overdose_threshold = 25
			chem.overdose_crit_threshold = 50
			if(chem.volume < 25)
				chem.overdosed = FALSE
			if(chem.volume < 50)
				chem.overdosed_crit = FALSE

		chem.addiction_types = null

		// МЕХАНИЗМ ВОЗВРАТА КОНТРОЛЯ: при падении до 20u и ниже мгновенно восстанавливаем координацию
		if(chem.volume <= 20)
			if(chem.overdosed)
				chem.overdosed = FALSE
				organ_owner.adjust_hallucinations(-1000 SECONDS)
				organ_owner.adjust_drowsiness(-1000 SECONDS)
				to_chat(organ_owner, span_notice("Дрожь в мышцах утихает, к вам возвращается полный контроль над движениями."))

			// Мгновенно обнуляем накопившуюся инверсию шагов и тремор
			organ_owner.adjust_confusion(-1000 SECONDS)
			organ_owner.adjust_jitter(-1000 SECONDS)

		// ЭФФЕКТ ПЕРЕДОЗИРОВКИ: действует ТОЛЬКО пока концентрация строго выше 20u
		else if(chem.overdosed || chem.volume >= 25)
			if(!chem.overdosed)
				chem.overdosed = TRUE
				chem.overdose_start(organ_owner)

			// Сбиваем ориентацию: галлюцинации и поддержка инверсии шагов
			organ_owner.adjust_hallucinations(5 SECONDS * metabolization_rate * seconds_per_tick)
			organ_owner.adjust_confusion(2 SECONDS * metabolization_rate * seconds_per_tick)
			organ_owner.set_jitter_if_lower(4 SECONDS)

			// Хаотичное движение: непроизвольные шаги в случайные стороны
			if(!HAS_TRAIT(organ_owner, TRAIT_IMMOBILIZED) && !ismovable(organ_owner.loc))
				for(var/i in 1 to round(2 * metabolization_rate * seconds_per_tick, 1))
					step(organ_owner, pick(GLOB.cardinals))

			// Судороги в конечностях: выпадение предметов
			if(SPT_PROB(12, seconds_per_tick))
				organ_owner.drop_all_held_items()

			// Компенсируем базовый урон токсинами от передозировки
			addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_tox_loss), -2 * REM * seconds_per_tick, FALSE), 0)

			if(SPT_PROB(5, seconds_per_tick))
				to_chat(organ_owner, span_userdanger("Нервная система перегружена стимуляторами - тело дёргается само по себе!"))

	// 3.3. Отключение только привыкания для уличной химии (пороги передозировки остаются штатными)
	if(istype(chem, /datum/reagent/drug/maint/tar) \
		|| istype(chem, /datum/reagent/drug/maint/sludge) \
		|| istype(chem, /datum/reagent/drug/aranesp))

		chem.addiction_types = null

	// 3.4. Порог передозировки 45u (критический 90u): Соли для ванн и Кровь Земли
	if(istype(chem, /datum/reagent/drug/bath_salts) || istype(chem, /datum/reagent/medicine/earthsblood))
		chem.overdose_threshold = 45
		chem.overdose_crit_threshold = 90

		if(istype(chem, /datum/reagent/drug/bath_salts))
			if(chem.volume >= 45 && !chem.overdosed)
				chem.overdosed = TRUE
				chem.overdose_start(organ_owner)
			var/datum/reagent/drug/bath_salts/salts = chem
			if(salts.rage)
				QDEL_NULL(salts.rage)

		if(istype(chem, /datum/reagent/medicine/earthsblood))
			chem.addiction_types = null

			// Если ещё нет передоза и травмы от реагента — обновляем флаг врожденного пацифизма
			if(!chem.overdosed && !earthsblood_trauma && chem.volume < 45)
				preexisting_earthsblood_pacifism = !!(organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism))

			// При достижении 45u контролируемо запускаем передоз и сразу перехватываем созданную травму
			if(chem.volume >= 45)
				if(!chem.overdosed)
					preexisting_earthsblood_pacifism = !!(organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism))
					chem.overdosed = TRUE
					chem.overdose_start(organ_owner)
				if(!preexisting_earthsblood_pacifism && !earthsblood_trauma)
					earthsblood_trauma = organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism)
			else
				// Если объем ниже 45u (в т.ч. если add_reagent выдал передоз на 25-44u) — немедленно снимаем!
				if(!preexisting_earthsblood_pacifism && !earthsblood_trauma && chem.overdosed)
					earthsblood_trauma = organ_owner.has_trauma_type(/datum/brain_trauma/severe/pacifism)
				chem.overdosed = FALSE
			if(earthsblood_trauma)
				QDEL_NULL(earthsblood_trauma)
				var/reagent_name = chem ? chem.name : "Крови Земли"
				to_chat(organ_owner, span_notice("Концентрация реагента [reagent_name] снизилась до безопасного уровня, пацифизм отступил."))

	// 3.5. Порог передозировки 60u (критический 120u)
	if(istype(chem, /datum/reagent/drug/krokodil) \
		|| istype(chem, /datum/reagent/drug/happiness) \
		|| istype(chem, /datum/reagent/drug/maint/powder) \
		|| istype(chem, /datum/reagent/drug/blastoff) \
		|| istype(chem, /datum/reagent/drug/pumpup) \
		|| istype(chem, /datum/reagent/drug/saturnx) \
		|| istype(chem, /datum/reagent/drug/syndol) \
		|| istype(chem, /datum/reagent/medicine/omnizine))

		chem.overdose_threshold = 60
		chem.overdose_crit_threshold = 120

	// 3.6. Удвоенный порог передозировки (x2 от стандартного)
	if(istype(chem, /datum/reagent/medicine/morphine) \
		|| istype(chem, /datum/reagent/medicine/atropine) \
		|| istype(chem, /datum/reagent/medicine/ephedrine) \
		|| istype(chem, /datum/reagent/medicine/c2/musiver))

		if(chem.overdose_threshold && chem.overdose_threshold == initial(chem.overdose_threshold))
			chem.overdose_threshold = initial(chem.overdose_threshold) * 2
		if(chem.overdose_crit_threshold && chem.overdose_crit_threshold == initial(chem.overdose_crit_threshold))
			chem.overdose_crit_threshold = initial(chem.overdose_crit_threshold) * 2

	// 3.7. Универсальное снятие передозировки при падении объема ниже порога
	if(chem.overdose_threshold && chem.volume < chem.overdose_threshold)
		// Для кокаина и мета действует отдельный механизм выхода на 20u
		if(!istype(chem, /datum/reagent/drug/cocaine) && !istype(chem, /datum/reagent/drug/methamphetamine))
			chem.overdosed = FALSE

	if(chem.overdose_crit_threshold && chem.volume < chem.overdose_crit_threshold)
		chem.overdosed_crit = FALSE

	// =========================================================================
	// ЭТАП 4. ЗАЩИТА ВНУТРЕННИХ ОРГАНОВ (МОЗГ И СЕРДЦЕ) ОТ УРОНА
	// =========================================================================

	// 4.1. Защита мозга: фиксируем состояние мозга перед вызовом on_mob_life / overdose_process
	if(istype(chem, /datum/reagent/medicine/earthsblood) \
		|| istype(chem, /datum/reagent/mercury) \
		|| istype(chem, /datum/reagent/drug/bath_salts) \
		|| istype(chem, /datum/reagent/drug/maint/powder) \
		|| istype(chem, /datum/reagent/drug/happiness) \
		|| istype(chem, /datum/reagent/drug/krokodil) \
		|| istype(chem, /datum/reagent/drug/methamphetamine) \
		|| istype(chem, /datum/reagent/drug/cocaine) \
		|| istype(chem, /datum/reagent/toxin/fentanyl))

		var/obj/item/organ/brain/brain = organ_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(brain)
			expected_brain_damage = brain.damage

	// 4.2. Защита сердца: кронкаин, кокаин и метамфетамин
	if(istype(chem, /datum/reagent/drug/kronkaine) \
		|| istype(chem, /datum/reagent/drug/cocaine) \
		|| istype(chem, /datum/reagent/drug/methamphetamine))

		var/obj/item/organ/heart/heart = organ_owner.get_organ_slot(ORGAN_SLOT_HEART)
		if(heart)
			expected_heart_damage = heart.damage

	if(!isnull(expected_brain_damage) || !isnull(expected_heart_damage))
		addtimer(CALLBACK(src, PROC_REF(flush_organ_protection), organ_owner), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

	// =========================================================================
	// ЭТАП 5. ДОПОЛНИТЕЛЬНЫЕ ЭФФЕКТЫ И КОМПЕНСАЦИЯ ПОБОЧНЫХ ДЕЙСТВИЙ
	// =========================================================================

	// Защита от мумификации (некроза кожи) при приеме крокодила
	if(istype(chem, /datum/reagent/drug/krokodil))
		if(HAS_TRAIT(organ_owner, TRAIT_HUSK))
			organ_owner.cure_husk()

	// Компенсация побочного урона от кураре (паралич сохраняется, но токсины и легкие не страдают)
	if(istype(chem, /datum/reagent/toxin/curare))
		var/datum/reagent/toxin/curare_chem = chem
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_tox_loss), -curare_chem.toxpwr * REM * seconds_per_tick, FALSE), 0)
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_oxy_loss), -2 * REM * seconds_per_tick, FALSE), 0)

	// Снижение токсического урона от синаптизина
	if(istype(chem, /datum/reagent/medicine/synaptizine))
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_tox_loss), -0.5 * REM * seconds_per_tick, FALSE), 0)

	// Эйфория от майндбрейкера
	if(istype(chem, /datum/reagent/toxin/mindbreaker))
		organ_owner.adjust_drugginess(20 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.add_mood_event("mindbreaker_high", /datum/mood_event/high)

	// Эйфория и частичное снижение токсичности самогона
	if(istype(chem, /datum/reagent/consumable/ethanol/moonshine))
		organ_owner.adjust_drugginess(25 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.adjust_hallucinations(5 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.add_mood_event("moonshine_high", /datum/mood_event/high)
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_tox_loss), -1 * REM * seconds_per_tick, FALSE), 0)

/obj/item/organ/liver/skrell/Destroy()
	expected_brain_damage = null
	expected_heart_damage = null
	expected_liver_damage = null
	if(earthsblood_trauma)
		qdel(earthsblood_trauma)
	earthsblood_trauma = null
	return ..()
