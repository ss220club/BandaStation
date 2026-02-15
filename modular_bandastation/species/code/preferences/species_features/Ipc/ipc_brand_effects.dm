// ============================================
// ЭФФЕКТЫ БРЕНДОВ IPC — ЗАГОТОВКИ
// ============================================
// Каждый бренд имеет свой набор эффектов.
// Здесь — прокс-заготовки для каждого эффекта.
// Некоторые простые (модифицируют переменные напрямую),
// некоторые требуют дополнительной реализации (имплантов, модулей).
//
// Вызвать apply_ipc_brand_effects() после apply_ipc_brand().
// ============================================

// FIX: Определяем констант трейта, который используется в apply_effect_unbranded.
// Должен быть в своём #define файле проекта, но для компиляции определяем здесь.
#define TRAIT_IPC_NO_COMBAT_IMPLANTS "ipc_no_combat_implants"

/// Главная точка входа — применяет эффекты бренда
/proc/apply_ipc_brand_effects(mob/living/carbon/human/H, brand_key)
	if(!H || !istype(H.dna?.species, /datum/species/ipc))
		return

	switch(brand_key)
		if("morpheus")
			apply_effect_morpheus(H)
		if("etamin")
			apply_effect_etamin(H)
		if("bishop")
			apply_effect_bishop(H)
		if("hesphiastos")
			apply_effect_hesphiastos(H)
		if("ward_takahashi")
			apply_effect_ward_takahashi(H)
		if("xion")
			apply_effect_xion(H)
		if("zeng_hu")
			apply_effect_zeng_hu(H)
		if("shellguard")
			apply_effect_shellguard(H)
		if("unbranded")
			apply_effect_unbranded(H)
		if("cybersun")
			apply_effect_cybersun(H)
		if("hef")
			// HEF не имеет эффектов — тело пустое, pass не нужен
			return

// ============================================
// 1. MORPHEUS CYBERKINETICS
// ============================================
// Расширенные слоты для имплантов и органов
/proc/apply_effect_morpheus(mob/living/carbon/human/H)
	// TODO: Реализовать расширение слотов имплантов и органов
	// Предположительно через увеличение max слотов на species или через trait
	// FIX: убран bare `pass` — пустое тело proc и без него компилируется корректно
	return

// ============================================
// 2. ETAMIN INDUSTRY
// ============================================
// +10% скорости взаимодействия, +точность
// Рейдж раз в раунд (требует спец модуль — отдельная реализация)
// Термическая релаксация понижена
/proc/apply_effect_etamin(mob/living/carbon/human/H)
	// +10% скорости взаимодействия
	// TODO: Реализовать через модификатор do_after или аналогичный
	// Термическая релаксация понижена
	var/datum/species/ipc/S = H.dna.species
	if(S)
		S.ipc_thermal_relaxation_mod = -0.2  // TODO: добавить эту переменную на species и использовать в температурной логике

// ============================================
// 3. BISHOP CYBERNETICS
// ============================================
// Встроенный мед-худ
// Имплант для операционной раундстартом
// +10% процентов успеха операций
/proc/apply_effect_bishop(mob/living/carbon/human/H)
	// Мед-худ — добавляем как trait или компонент
	// TODO: Реализовать встроенный мед-худ
	// +10% успеха операций
	// TODO: Реализовать через модификатор к surgery success chance
	// FIX: убран bare `pass`
	return

// ============================================
// 4. HESPHIASTOS INDUSTRIES
// ============================================
// 120% здоровья (уве. health cap)
// Имплант щита раундстартом в случайной руке
// 110% melee damage
/proc/apply_effect_hesphiastos(mob/living/carbon/human/H)
	// 120% здоровья - увеличиваем max_damage всех частей тела
	for(var/obj/item/bodypart/BP in H.bodyparts)
		if(istype(BP, /obj/item/bodypart/chest/ipc) || \
		   istype(BP, /obj/item/bodypart/head/ipc) || \
		   istype(BP, /obj/item/bodypart/arm/left/ipc) || \
		   istype(BP, /obj/item/bodypart/arm/right/ipc) || \
		   istype(BP, /obj/item/bodypart/leg/left/ipc) || \
		   istype(BP, /obj/item/bodypart/leg/right/ipc))
			BP.max_damage *= 1.2

	// 110% melee damage
	var/datum/species/ipc/S = H.dna.species
	if(S)
		if(!S.ipc_chassis_modifiers)
			S.ipc_chassis_modifiers = list()
		S.ipc_chassis_modifiers["melee_damage"] = 1.1

	// Имплант щита в случайной руке - TODO при раундстарте
	// Требует реализации системы имплантов

// ============================================
// 5. WARD-TAKAHASHI
// ============================================
// Ускоренный саморемонт
// Увеличенный срок работы батарейки
// Уменьшенное количество слотов имплантов
/proc/apply_effect_ward_takahashi(mob/living/carbon/human/H)
	// Ускоренный саморемонт
	// TODO: Реализовать через модификатор скорости саморемонта (если есть такой)
	// Увеличенный срок работы батарейки
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		battery.charge_rate *= 0.7  // Медленнее разряжается = дольше работает
	// Уменьшенное количество слотов имплантов
	// TODO: Реализовать через уменьшение max implant slots

// ============================================
// 6. XION MANUFACTURING GROUP
// ============================================
// Резист к берн урону (30%)
// Медленнее перегревается (80% от стандарта)
// Лечение занимает больше времени
/proc/apply_effect_xion(mob/living/carbon/human/H)
	// Резист к берн урону (30%) - применяем к каждой части тела
	for(var/obj/item/bodypart/BP in H.bodyparts)
		// Проверяем и применяем для chest
		if(istype(BP, /obj/item/bodypart/chest/ipc))
			var/obj/item/bodypart/chest/ipc/ipc_bp = BP
			ipc_bp.burn_reduction = 0.3
		// Проверяем и применяем для head
		else if(istype(BP, /obj/item/bodypart/head/ipc))
			var/obj/item/bodypart/head/ipc/ipc_bp = BP
			ipc_bp.burn_reduction = 0.3
		// Проверяем и применяем для left arm
		else if(istype(BP, /obj/item/bodypart/arm/left/ipc))
			var/obj/item/bodypart/arm/left/ipc/ipc_bp = BP
			ipc_bp.burn_reduction = 0.3
		// Проверяем и применяем для right arm
		else if(istype(BP, /obj/item/bodypart/arm/right/ipc))
			var/obj/item/bodypart/arm/right/ipc/ipc_bp = BP
			ipc_bp.burn_reduction = 0.3
		// Проверяем и применяем для left leg
		else if(istype(BP, /obj/item/bodypart/leg/left/ipc))
			var/obj/item/bodypart/leg/left/ipc/ipc_bp = BP
			ipc_bp.burn_reduction = 0.3
		// Проверяем и применяем для right leg
		else if(istype(BP, /obj/item/bodypart/leg/right/ipc))
			var/obj/item/bodypart/leg/right/ipc/ipc_bp = BP
			ipc_bp.burn_reduction = 0.3

	// Медленнее перегревается (80% от стандарта)
	var/datum/species/ipc/S = H.dna.species
	if(S)
		if(!S.ipc_chassis_modifiers)
			S.ipc_chassis_modifiers = list()
		S.ipc_chassis_modifiers["overheat_rate"] = 0.8
		S.ipc_chassis_modifiers["healing_time"] = 1.25  // Лечение на 25% дольше

// ============================================
// 7. ZENG-HU PHARMACEUTICALS
// ============================================
// Биогенератор раундстартом
// Синт кожа с особенностями лечения
/proc/apply_effect_zeng_hu(mob/living/carbon/human/H)
	// Биогенератор — добавляем в инвентарь или встроенно
	// TODO: Реализовать биогенератор как встроенный имплант или предмет раундстарта
	// Синт кожа
	// TODO: Реализовать через trait/модификатор лечения синт плоти
	// FIX: убран bare `pass`
	return

// ============================================
// 8. SHELLGUARD MUNITIONS
// ============================================
// Резист к бруту 2x
// Берн резист 1.5x
// Одноразовый ЭМП-протектор
/proc/apply_effect_shellguard(mob/living/carbon/human/H)
	// Резист к бруту 2x и берн резист 1.5x
	for(var/obj/item/bodypart/BP in H.bodyparts)
		// Проверяем и применяем для chest
		if(istype(BP, /obj/item/bodypart/chest/ipc))
			var/obj/item/bodypart/chest/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.5
			ipc_bp.burn_reduction = 0.33
		// Проверяем и применяем для head
		else if(istype(BP, /obj/item/bodypart/head/ipc))
			var/obj/item/bodypart/head/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.5
			ipc_bp.burn_reduction = 0.33
		// Проверяем и применяем для left arm
		else if(istype(BP, /obj/item/bodypart/arm/left/ipc))
			var/obj/item/bodypart/arm/left/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.5
			ipc_bp.burn_reduction = 0.33
		// Проверяем и применяем для right arm
		else if(istype(BP, /obj/item/bodypart/arm/right/ipc))
			var/obj/item/bodypart/arm/right/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.5
			ipc_bp.burn_reduction = 0.33
		// Проверяем и применяем для left leg
		else if(istype(BP, /obj/item/bodypart/leg/left/ipc))
			var/obj/item/bodypart/leg/left/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.5
			ipc_bp.burn_reduction = 0.33
		// Проверяем и применяем для right leg
		else if(istype(BP, /obj/item/bodypart/leg/right/ipc))
			var/obj/item/bodypart/leg/right/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.5
			ipc_bp.burn_reduction = 0.33

	// Одноразовый ЭМП-протектор - TODO при раундстарте
	// Требует реализации системы имплантов

// ============================================
// 9. UNBRANDED
// ============================================
// Повышенный резист к бруту
// Увеличенные слоты имплантов (-2 = больше слотов)
// Глюки при речи
// Магнетик джоинтс
// НИКАКИХ БОЕВЫХ ИМПЛАНТОВ
/proc/apply_effect_unbranded(mob/living/carbon/human/H)
	// Повышенный резист к бруту
	for(var/obj/item/bodypart/BP in H.bodyparts)
		// Проверяем и применяем для chest
		if(istype(BP, /obj/item/bodypart/chest/ipc))
			var/obj/item/bodypart/chest/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.2
		// Проверяем и применяем для head
		else if(istype(BP, /obj/item/bodypart/head/ipc))
			var/obj/item/bodypart/head/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.2
		// Проверяем и применяем для left arm
		else if(istype(BP, /obj/item/bodypart/arm/left/ipc))
			var/obj/item/bodypart/arm/left/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.2
		// Проверяем и применяем для right arm
		else if(istype(BP, /obj/item/bodypart/arm/right/ipc))
			var/obj/item/bodypart/arm/right/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.2
		// Проверяем и применяем для left leg
		else if(istype(BP, /obj/item/bodypart/leg/left/ipc))
			var/obj/item/bodypart/leg/left/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.2
		// Проверяем и применяем для right leg
		else if(istype(BP, /obj/item/bodypart/leg/right/ipc))
			var/obj/item/bodypart/leg/right/ipc/ipc_bp = BP
			ipc_bp.brute_reduction = 0.2

	var/datum/species/ipc/S = H.dna.species
	if(S)
		if(!S.ipc_chassis_modifiers)
			S.ipc_chassis_modifiers = list()
		// Увеличенные слоты имплантов (+2 слота)
		S.ipc_chassis_modifiers["implant_slots"] = 2
		// Глюки при речи - трейт
		if(!(TRAIT_IPC_NO_COMBAT_IMPLANTS in S.inherent_traits))
			S.inherent_traits += TRAIT_IPC_NO_COMBAT_IMPLANTS
		// TODO: Добавить глюки речи через speech filter
		// TODO: Магнетик джоинтс - притяжение к металлам

// ============================================
// 10. CYBERSUN INDUSTRIES
// ============================================
// +слот инвентаря (2 маленьких / 1 средний)
// Тихие шаги
// 10% скорости
// Повышена цена починок
// -слот имплантов
// Антаг-функции (реализуются отдельно через аплинк)
/proc/apply_effect_cybersun(mob/living/carbon/human/H)
	// Тихие шаги
	// TODO: Реализовать через trait
	// 10% скорости (быстрее)
	// FIX: get_movespeed_modifier не существует в tg/station.
	// Правильный паттерн: создаём модификатор с нужным значением ПЕРЕД добавлением,
	// либо добавляем и сразу ищем в списке H.movespeed_modifiers.
	// Простейший и надёжный способ — предопределить значение на самом datum:
	var/datum/movespeed_modifier/ipc_cybersun/mod = new()
	mod.multiplicative_slowdown = -0.2  // 10% быстрее
	H.add_movespeed_modifier(mod, update = TRUE)

	// Повышена цена починок
	var/datum/species/ipc/S = H.dna.species
	if(S)
		S.ipc_repair_cost_mod = 1.5  // TODO: добавить эту переменную и использовать при ремонте
	// -слот имплантов
	// TODO: Реализовать через уменьшение max implant slots
	// +слот инвентаря
	// TODO: Реализовать через расширение инвентаря

/datum/movespeed_modifier/ipc_cybersun
	variable = TRUE
	multiplicative_slowdown = 0
