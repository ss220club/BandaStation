// ============================================
// БРЕНДЫ ШАССИ IPC
// ============================================
// Каждый бренд = визуальный комплект спрайтов + набор эффектов.
// Визуал: каждый бренд имеет свои icon_state для chest/head/arms/legs
//         в 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
// Формат icon_state: "[brand]_chest_[m/f]", "[brand]_head", "[brand]_l_arm", и т.д.
//
// HEF — специальный бренд без эффектов, визуал берётся из отдельной фичи.
// ============================================

// ============================================
// БАЗОВЫЙ DATUM БРЕНДА
// ============================================

/datum/ipc_brand
	/// Полное имя бренда для отображения
	var/name = ""
	/// Краткое описание бренда и его эффектов
	var/desc = ""
	/// Ключ бренда (совпадает со значением фичи)
	var/brand_key = ""

	// --- Визуальные ключи ---
	// Префикс для icon_state в bodyparts.dmi
	// Итог: "[visual_prefix]_chest_m", "[visual_prefix]_head", и т.д.
	var/visual_prefix = ""

	// --- Кастомный файл иконок ---
	// Путь к отдельному файлу .dmi для этого бренда (если есть)
	// Если пустой — используется 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	var/custom_icon_file = null

	// --- Ограничения по профессии ---
	// Пустой список = нет ограничений, доступен всем
	// Иначе — список department bitflags или job titles
	var/list/allowed_departments = list()

	// --- Требует модуля? ---
	// Если TRUE — бренд требует установки специального модуля для полной функциональности
	var/requires_module = FALSE

// ============================================
// КОНКРЕТНЫЕ БРЕНДЫ
// ============================================

// 1. MORPHEUS CYBERKINETICS
/datum/ipc_brand/morpheus
	name = "Morpheus Cyberkinetics"
	desc = "Расширенные слоты для имплантов и органов."
	brand_key = "morpheus"
	visual_prefix = "morpheus"

// 2. ETAMIN INDUSTRY
/datum/ipc_brand/etamin
	name = "Etamin Industry"
	desc = "+10% скорости взаимодействия, +точность. Рейдж раз в раунд (требует спец модуль). Термическая релаксация понижена."
	brand_key = "etamin"
	visual_prefix = "etamin"
	allowed_departments = list(DEPARTMENT_BITFLAG_SECURITY)
	requires_module = TRUE

// 3. BISHOP CYBERNETICS
/datum/ipc_brand/bishop
	name = "Bishop Cybernetics"
	desc = "Мед-худ встроенно. Имплант для операционной раундстартом. +10% успеха операций."
	brand_key = "bishop"
	visual_prefix = "ipc"
	custom_icon_file = 'icons/bandastation/mob/species/ipc/bodyparts_bishop.dmi'
	allowed_departments = list(DEPARTMENT_BITFLAG_MEDICAL, DEPARTMENT_BITFLAG_SCIENCE)

// 4. HESPHIASTOS INDUSTRIES
/datum/ipc_brand/hesphiastos
	name = "Hesphiastos Industries"
	desc = "120% здоровья. Имплант щита раундстартом в случайной руке. 110% melee damage."
	brand_key = "hesphiastos"
	visual_prefix = "hesphiastos"
	allowed_departments = list(DEPARTMENT_BITFLAG_SECURITY)

// 5. WARD-TAKAHASHI
/datum/ipc_brand/ward_takahashi
	name = "Ward-Takahashi"
	desc = "Ускоренный саморемонт. Увеличенный срок работы батарейки. Уменьшенное количество слотов имплантов."
	brand_key = "ward_takahashi"
	visual_prefix = "ward"

// 6. XION MANUFACTURING GROUP
/datum/ipc_brand/xion
	name = "Xion Manufacturing Group"
	desc = "Резист к берн урону (30%). Медленнее перегревается (80%). Лечение занимает больше времени."
	brand_key = "xion"
	visual_prefix = "xion"  // В bodyparts_xion.dmi спрайты называются xion_head, xion_chest_m, и т.д.
	custom_icon_file = 'icons/bandastation/mob/species/ipc/bodyparts_xion.dmi'

// 7. ZENG-HU PHARMACEUTICALS
/datum/ipc_brand/zeng_hu
	name = "Zeng-Hu Pharmaceuticals"
	desc = "Биогенератор раундстартом. Синт кожа с особенностями лечения. При ожогах синт плоть менее эффективна НаноПастой. При брут — швы с синтплотью + нанопастой."
	brand_key = "zeng_hu"
	visual_prefix = "zenghu"

// 8. SHELLGUARD MUNITIONS
/datum/ipc_brand/shellguard
	name = "Shellguard Munitions"
	desc = "Резист к бруту 2x от стандарта. Берн резист 1.5x. Одноразовый ЭМП-протектор (вытащить и заменить нельзя нельзя)."
	brand_key = "shellguard"
	visual_prefix = "shellguard"
	allowed_departments = list(DEPARTMENT_BITFLAG_SECURITY)

// 9. UNBRANDED
/datum/ipc_brand/unbranded
	name = "Unbranded"
	desc = "Повышенный резист к бруту. Увеличенные слоты имплантов (-2). Глюки при речи. Магнетик джоинтс. НИКАКИХ БОЕВЫХ ИМПЛАНТОВ."
	brand_key = "unbranded"
	visual_prefix = "unbranded"

// 10. CYBERSUN INDUSTRIES
/datum/ipc_brand/cybersun
	name = "Cybersun Industries"
	desc = "Если облатель — антаг, может купить апгрейд в аплинке. Удалённый эмаг и абилка смены визуала деталей. +слот инвентаря (2 маленьких / 1 средний). Тихие шаги. 10% скорости. Повышена цена починок. -слот имплантов."
	brand_key = "cybersun"
	visual_prefix = "cybersun"
	requires_module = TRUE

// 11. HEF
// HEF не имеет собственного визуала — он берётся из фичи ipc_hef_visual
// Визуал подставляется в apply через visual_brand отдельно
/datum/ipc_brand/hef
	name = "HEF"
	desc = "Визуально выбрать любой другой бренд. Без плюсов и минусов."
	brand_key = "hef"
	visual_prefix = ""  // Пустой — берётся из ipc_hef_visual

// ============================================
// РЕЕСТР: СПИСОК ВСЕХ БРЕНД-КЛЮЧЕЙ
// ============================================

/// Возвращает новый datum бренда по ключу
/proc/get_ipc_brand(brand_key)
	switch(brand_key)
		if("morpheus")
			return new /datum/ipc_brand/morpheus()
		if("etamin")
			return new /datum/ipc_brand/etamin()
		if("bishop")
			return new /datum/ipc_brand/bishop()
		if("hesphiastos")
			return new /datum/ipc_brand/hesphiastos()
		if("ward_takahashi")
			return new /datum/ipc_brand/ward_takahashi()
		if("xion")
			return new /datum/ipc_brand/xion()
		if("zeng_hu")
			return new /datum/ipc_brand/zeng_hu()
		if("shellguard")
			return new /datum/ipc_brand/shellguard()
		if("unbranded")
			return new /datum/ipc_brand/unbranded()
		if("cybersun")
			return new /datum/ipc_brand/cybersun()
		if("hef")
			return new /datum/ipc_brand/hef()
	return null

/// Все допустимые ключи брендов (для валидации фичей)
/proc/get_ipc_brand_keys()
	return list(
		"morpheus", "etamin", "bishop", "hesphiastos",
		"ward_takahashi", "xion", "zeng_hu", "shellguard",
		"unbranded", "cybersun", "hef"
	)

/// Все ключи брендов кроме HEF (для выбора визуала у HEF)
/proc/get_ipc_visual_brand_keys()
	return list(
		"morpheus", "etamin", "bishop", "hesphiastos",
		"ward_takahashi", "xion", "zeng_hu", "shellguard",
		"unbranded", "cybersun"
	)
