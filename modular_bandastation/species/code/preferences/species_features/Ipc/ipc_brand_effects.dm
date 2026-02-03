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
	// 120% здоровья
	// TODO: Реализовать через модификатор к health_threshold или аналогичный
	// 110% melee damage — через trait или модификатор урона
	// TODO: Реализовать через модификатор к melee damage
	// Имплант щита в случайной руке — даётся при раундстарте
	// TODO: Создать и вставить имплант в случайную руку
	// FIX: убран bare `pass`
	return

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
	// Резист к берн урону (30%)
	// TODO: Реализовать через trait или bodypart damage modifier
	// Медленнее перегревается
	var/datum/species/ipc/S = H.dna.species
	if(S)
		S.ipc_overheat_rate_mod = 0.8  // TODO: добавить эту переменную и использовать в температурной логике
	// Лечение занимает больше времени
	// TODO: Реализовать через модификатор к surgery/healing time

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
	// Резист к бруту 2x
	// TODO: Реализовать через damage modifier на bodyparts
	// Берн резист 1.5x
	// TODO: Реализовать через damage modifier на bodyparts
	// Одноразовый ЭМП-протектор
	// TODO: Реализовать как встроенный имплант с одноразовым использованием
	// FIX: убран bare `pass`
	return

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
	// TODO: Реализовать через damage modifier
	// Увеличенные слоты имплантов
	// TODO: Реализовать через увеличение max implant slots (-2 означает +2 слота)
	// Глюки при речи
	// TODO: Реализовать через speech filter/trait
	// Магнетик джоинтс
	// TODO: Реализовать через trait/effect (притяжение к металлам)
	// Запрет боевых имплантов
	// FIX: ни add_trait() ни AddTrait() не существуют в этом форке.
	// Единственный доказанно работающий механизм трейтов — это список
	// inherent_traits на species (он же используется для TRAIT_NOBREATH и т.д.).
	// Добавляем трейт туда во время рантайма.
	var/datum/species/ipc/S = H.dna.species
	if(S && !(TRAIT_IPC_NO_COMBAT_IMPLANTS in S.inherent_traits))
		S.inherent_traits += TRAIT_IPC_NO_COMBAT_IMPLANTS

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
