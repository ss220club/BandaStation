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
/// Флаг передозировки Earthsblood: удерживает статус пацифизма до полного выведения вещества (0u)
	var/earthsblood_pacifism = FALSE

/obj/item/organ/liver/skrell/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!owner)
		return

	// Если скрелл передозировался Кровью Земли, но реагент уже ПОЛНОСТЬЮ вывелся из крови (0u)
	if(earthsblood_pacifism && !owner.reagents?.has_reagent(/datum/reagent/medicine/earthsblood))
		earthsblood_pacifism = FALSE
		var/datum/brain_trauma/severe/pacifism/trauma = owner.has_trauma_type(/datum/brain_trauma/severe/pacifism)
		if(trauma)
			qdel(trauma)
			to_chat(owner, span_notice("Действие Крови Земли полностью рассеялось, пацифизм отступает."))

// Вспомогательный прок: блокирует нанесение урона органу от вещества, не исцеляя старые повреждения
/obj/item/organ/liver/skrell/proc/prevent_organ_damage(obj/item/organ/target_organ, prev_damage)
	if(target_organ && target_organ.damage > prev_damage)
		target_organ.set_organ_damage(prev_damage)

/obj/item/organ/liver/skrell/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, metabolization_rate)
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

		var/datum/reagent/toxin/toxin_chem = chem
		toxin_chem.toxpwr = 0
		toxin_chem.liver_damage_multiplier = 0
		toxin_chem.liver_tolerance_multiplier = 1000

		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	// 1.2. Питательные токсины: Тетродотоксин, Карпотоксин и Грибной порошок дают +2 к сытости
	if(istype(chem, /datum/reagent/toxin/tetrodotoxin) \
		|| istype(chem, /datum/reagent/toxin/carpotoxin) \
		|| istype(chem, /datum/reagent/toxin/mushroom_powder))

		var/datum/reagent/toxin/toxin_chem = chem
		toxin_chem.toxpwr = 0
		toxin_chem.liver_damage_multiplier = 0
		toxin_chem.liver_tolerance_multiplier = 1000

		organ_owner.adjust_nutrition(0.5 * metabolization_rate * seconds_per_tick)
		var/metabolized = chem.compute_metabolization(organ_owner, seconds_per_tick)
		organ_owner.reagents.remove_reagent(chem.type, metabolized)
		return COMSIG_MOB_STOP_REAGENT_TICK

	// 1.3. Полная замена стандартного эффекта на уникальный
	if(istype(chem, /datum/reagent/uranium/radium))
		organ_owner.adjust_tox_loss(0.25 * metabolization_rate * seconds_per_tick, updating_health = FALSE)
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

	// Обнуляем токсичность кураре до вызова ..(), оставляя его только паралитиком
	if(istype(chem, /datum/reagent/toxin/curare))
		var/datum/reagent/toxin/curare_chem = chem
		curare_chem.toxpwr = 0

	var/prev_liver_damage = damage
	. = ..()
	// Блокируем нанесение урона печени от самогона в своем (обход штрафа ALCOHOL_RATE * 4) и кураре
	if(istype(chem, /datum/reagent/consumable/ethanol/fyrsskar_tears) \
		|| istype(chem, /datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture) \
		|| istype(chem, /datum/reagent/consumable/ethanol/aliose_velvet_cordial) \
		|| istype(chem, /datum/reagent/consumable/ethanol/omega_glow_cocktail) \
		|| istype(chem, /datum/reagent/consumable/ethanol/moonshine) \
		|| istype(chem, /datum/reagent/toxin/curare))

		if(damage > prev_liver_damage)
			set_organ_damage(prev_liver_damage)

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
		chem.overdose_threshold = 25
		if(chem.overdose_crit_threshold && chem.overdose_crit_threshold == initial(chem.overdose_crit_threshold))
			chem.overdose_crit_threshold = 50

		chem.addiction_types = null

		// МЕХАНИЗМ ВОЗВРАТА КОНТРОЛЯ: при падении до 20u и ниже мгновенно восстанавливаем координацию
		if(chem.volume <= 20)
			if(chem.overdosed)
				chem.overdosed = FALSE
				to_chat(organ_owner, span_notice("Дрожь в мышцах утихает, к вам возвращается полный контроль над движениями."))

			// Мгновенно обнуляем накопившуюся инверсию шагов и тремор
			organ_owner.adjust_confusion(-1000 SECONDS)
			organ_owner.set_jitter_if_lower(0 SECONDS)

		// ЭФФЕКТ ПЕРЕДОЗИРОВКИ: действует ТОЛЬКО пока концентрация строго выше 20u
		else if(chem.overdosed)
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
			addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_tox_loss), -2 * metabolization_rate * seconds_per_tick, FALSE), 0)

			if(SPT_PROB(5, seconds_per_tick))
				to_chat(organ_owner, span_userdanger("Нервная система перегружена стимуляторами — тело дергается само по себе!"))

	// 3.3. Отключение только привыкания для уличной химии (пороги передозировки остаются штатными)
	if(istype(chem, /datum/reagent/drug/maint/tar) \
		|| istype(chem, /datum/reagent/drug/maint/sludge) \
		|| istype(chem, /datum/reagent/drug/aranesp))

		chem.addiction_types = null

	// 3.4. Порог передозировки 45u (критический 90u)
	if(istype(chem, /datum/reagent/drug/bath_salts) || istype(chem, /datum/reagent/medicine/earthsblood))
		chem.overdose_threshold = 45
		if(chem.overdose_crit_threshold && chem.overdose_crit_threshold == initial(chem.overdose_crit_threshold))
			chem.overdose_crit_threshold = 90

		if(istype(chem, /datum/reagent/drug/bath_salts))
			var/datum/reagent/drug/bath_salts/salts = chem
			if(salts.rage)
				QDEL_NULL(salts.rage)

		if(istype(chem, /datum/reagent/medicine/earthsblood))
			chem.addiction_types = null
			if(chem.overdosed)
				earthsblood_pacifism = TRUE

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
		if(chem.overdose_crit_threshold && chem.overdose_crit_threshold == initial(chem.overdose_crit_threshold))
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

	// 4.1. Защита мозга (ГЭБ скрелла блокирует нейротоксичность)
	if(istype(chem, /datum/reagent/drug/cocaine) \
		|| istype(chem, /datum/reagent/drug/methamphetamine) \
		|| istype(chem, /datum/reagent/drug/bath_salts) \
		|| istype(chem, /datum/reagent/drug/krokodil) \
		|| istype(chem, /datum/reagent/drug/happiness) \
		|| istype(chem, /datum/reagent/drug/maint/powder) \
		|| istype(chem, /datum/reagent/drug/blastoff) \
		|| istype(chem, /datum/reagent/drug/pumpup) \
		|| istype(chem, /datum/reagent/drug/saturnx) \
		|| istype(chem, /datum/reagent/drug/syndol) \
		|| istype(chem, /datum/reagent/toxin/fentanyl) \
		|| istype(chem, /datum/reagent/medicine/earthsblood) \
		|| istype(chem, /datum/reagent/toxin/mindbreaker) \
		|| istype(chem, /datum/reagent/mercury))

		var/obj/item/organ/brain/brain = organ_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(brain)
			var/prev_brain_damage = brain.damage
			addtimer(CALLBACK(src, PROC_REF(prevent_organ_damage), brain, prev_brain_damage), 0)

	// 4.2. Защита сердца (кронкаин и блокировка повреждения сердца от овердоза кокаина)
	if(istype(chem, /datum/reagent/drug/kronkaine) || istype(chem, /datum/reagent/drug/cocaine))
		var/obj/item/organ/heart/heart = organ_owner.get_organ_slot(ORGAN_SLOT_HEART)
		if(heart)
			var/prev_heart_damage = heart.damage
			addtimer(CALLBACK(src, PROC_REF(prevent_organ_damage), heart, prev_heart_damage), 0)

	// =========================================================================
	// ЭТАП 5. ДОПОЛНИТЕЛЬНЫЕ ЭФФЕКТЫ И КОМПЕНСАЦИЯ ПОБОЧНЫХ ДЕЙСТВИЙ
	// =========================================================================

	// Защита от мумификации (некроза кожи) при приеме крокодила
	if(istype(chem, /datum/reagent/drug/krokodil))
		if(HAS_TRAIT(organ_owner, TRAIT_HUSK))
			organ_owner.cure_husk()

	// Компенсация удушья от кураре (паралич сохраняется, но легкие не страдают)
	if(istype(chem, /datum/reagent/toxin/curare))
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_oxy_loss), -2 * metabolization_rate * seconds_per_tick, FALSE), 0)

	// Снижение токсического урона от синаптизина
	if(istype(chem, /datum/reagent/medicine/synaptizine))
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_tox_loss), -0.5 * metabolization_rate * seconds_per_tick, FALSE), 0)

	// Эйфория от майндбрейкера
	if(istype(chem, /datum/reagent/toxin/mindbreaker))
		organ_owner.adjust_drugginess(20 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.add_mood_event("mindbreaker_high", /datum/mood_event/high)

	// Эйфория и частичное снижение токсичности самогона
	if(istype(chem, /datum/reagent/consumable/ethanol/moonshine))
		organ_owner.adjust_drugginess(25 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.adjust_hallucinations(5 SECONDS * metabolization_rate * seconds_per_tick)
		organ_owner.add_mood_event("moonshine_high", /datum/mood_event/high)
		addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/mob/living, adjust_tox_loss), -1 * metabolization_rate * seconds_per_tick, FALSE), 0)
