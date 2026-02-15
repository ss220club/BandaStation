// ============================================
// BODY MODIFICATIONS: IPC CHASSIS
// ============================================
// Интеграция IPC брендов в систему body_modifications.
// Вместо отдельных preferences, chassis brand становится
// модификацией тела с выбором производителя (manufacturer).
// ============================================

/datum/body_modification/ipc_chassis
	abstract_type = /datum/body_modification/ipc_chassis
	category = "IPC Chassis"
	cost = 0  // Бесплатно для IPC, недоступно для других

/datum/body_modification/ipc_chassis/can_be_applied(mob/living/carbon/target)
	if(!..())
		return FALSE
	// Доступно только для IPC
	if(!istype(target.dna?.species, /datum/species/ipc))
		return FALSE
	return TRUE

// ============================================
// ОСНОВНЫЕ БРЕНДЫ (с геймплейными бонусами)
// ============================================
// Каждый бренд — отдельная body_modification.
// При apply_to_human: сохраняет brand_key на species,
// применяет визуал и эффекты.
// ============================================

/datum/body_modification/ipc_chassis/morpheus
	key = "ipc_chassis_morpheus"
	name = "Morpheus Cyberkinetics Chassis"

/datum/body_modification/ipc_chassis/morpheus/get_description()
	return "Шасси от Morpheus Cyberkinetics. Специализация: когнитивные системы и нейроинтерфейсы."

/datum/body_modification/ipc_chassis/morpheus/apply_to_human(mob/living/carbon/human/target)
	to_chat(target, span_boldwarning("DEBUG BODYMOD: Morpheus apply_to_human ВЫЗВАН!"))
	if(!..())
		to_chat(target, span_warning("DEBUG BODYMOD: parent apply_to_human вернул FALSE"))
		return FALSE
	to_chat(target, span_notice("DEBUG BODYMOD: Получаем species..."))
	var/datum/species/ipc/S = target.dna.species
	to_chat(target, span_notice("DEBUG BODYMOD: Устанавливаем brand_key = morpheus"))
	S.ipc_brand_key = "morpheus"
	to_chat(target, span_notice("DEBUG BODYMOD: Вызываем apply_ipc_brand(target, morpheus)"))
	apply_ipc_brand(target, "morpheus")
	to_chat(target, span_notice("DEBUG BODYMOD: Вызываем apply_ipc_brand_effects(target, morpheus)"))
	apply_ipc_brand_effects(target, "morpheus")
	to_chat(target, span_boldnotice("DEBUG BODYMOD: Morpheus apply_to_human ЗАВЕРШЁН!"))
	return TRUE

/datum/body_modification/ipc_chassis/etamin
	key = "ipc_chassis_etamin"
	name = "Etamin Industry Chassis"

/datum/body_modification/ipc_chassis/etamin/get_description()
	return "Шасси от Etamin Industry. Специализация: термальные системы, охлаждение ядра."

/datum/body_modification/ipc_chassis/etamin/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "etamin"
	apply_ipc_brand(target, "etamin")
	apply_ipc_brand_effects(target, "etamin")
	return TRUE

/datum/body_modification/ipc_chassis/bishop
	key = "ipc_chassis_bishop"
	name = "Bishop Cybernetics Chassis"

/datum/body_modification/ipc_chassis/bishop/get_description()
	return "Шасси от Bishop Cybernetics. Специализация: медицинские модули, точные манипуляторы."

/datum/body_modification/ipc_chassis/bishop/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "bishop"
	apply_ipc_brand(target, "bishop")
	apply_ipc_brand_effects(target, "bishop")
	return TRUE

/datum/body_modification/ipc_chassis/hesphiastos
	key = "ipc_chassis_hesphiastos"
	name = "Hesphiastos Industries Chassis"

/datum/body_modification/ipc_chassis/hesphiastos/get_description()
	return "Шасси от Hesphiastos Industries. Специализация: бронированные конечности для тяжёлой среды."

/datum/body_modification/ipc_chassis/hesphiastos/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "hesphiastos"
	apply_ipc_brand(target, "hesphiastos")
	apply_ipc_brand_effects(target, "hesphiastos")
	return TRUE

/datum/body_modification/ipc_chassis/ward_takahashi
	key = "ipc_chassis_ward_takahashi"
	name = "Ward-Takahashi Chassis"

/datum/body_modification/ipc_chassis/ward_takahashi/get_description()
	return "Шасси от Ward-Takahashi. Специализация: кинематические системы, оптимизация подвижности."

/datum/body_modification/ipc_chassis/ward_takahashi/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "ward_takahashi"
	apply_ipc_brand(target, "ward_takahashi")
	apply_ipc_brand_effects(target, "ward_takahashi")
	return TRUE

/datum/body_modification/ipc_chassis/xion
	key = "ipc_chassis_xion"
	name = "Xion Manufacturing Group Chassis"

/datum/body_modification/ipc_chassis/xion/get_description()
	return "Шасси от Xion Manufacturing Group. Специализация: лёгкие высокопроизводительные каркасы."

/datum/body_modification/ipc_chassis/xion/apply_to_human(mob/living/carbon/human/target)
	to_chat(target, span_boldwarning("DEBUG BODYMOD: Xion apply_to_human ВЫЗВАН!"))
	if(!..())
		to_chat(target, span_warning("DEBUG BODYMOD: parent apply_to_human вернул FALSE"))
		return FALSE
	to_chat(target, span_notice("DEBUG BODYMOD: Получаем species..."))
	var/datum/species/ipc/S = target.dna.species
	to_chat(target, span_notice("DEBUG BODYMOD: Устанавливаем brand_key = xion"))
	S.ipc_brand_key = "xion"
	to_chat(target, span_notice("DEBUG BODYMOD: Вызываем apply_ipc_brand(target, xion)"))
	apply_ipc_brand(target, "xion")
	to_chat(target, span_notice("DEBUG BODYMOD: Вызываем apply_ipc_brand_effects(target, xion)"))
	apply_ipc_brand_effects(target, "xion")
	to_chat(target, span_boldnotice("DEBUG BODYMOD: Xion apply_to_human ЗАВЕРШЁН!"))
	return TRUE

/datum/body_modification/ipc_chassis/zeng_hu
	key = "ipc_chassis_zeng_hu"
	name = "Zeng-Hu Pharmaceuticals Chassis"

/datum/body_modification/ipc_chassis/zeng_hu/get_description()
	return "Шасси от Zeng-Hu Pharmaceuticals. Специализация: биосинтетические оболочки."

/datum/body_modification/ipc_chassis/zeng_hu/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "zeng_hu"
	apply_ipc_brand(target, "zeng_hu")
	apply_ipc_brand_effects(target, "zeng_hu")
	return TRUE

/datum/body_modification/ipc_chassis/shellguard
	key = "ipc_chassis_shellguard"
	name = "Shellguard Munitions Chassis"

/datum/body_modification/ipc_chassis/shellguard/get_description()
	return "Шасси от Shellguard Munitions. Специализация: бронированные корпуса для боевого применения."

/datum/body_modification/ipc_chassis/shellguard/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "shellguard"
	apply_ipc_brand(target, "shellguard")
	apply_ipc_brand_effects(target, "shellguard")
	return TRUE

/datum/body_modification/ipc_chassis/cybersun
	key = "ipc_chassis_cybersun"
	name = "Cybersun Industries Chassis"

/datum/body_modification/ipc_chassis/cybersun/get_description()
	return "Шасси от Cybersun Industries. Специализация: энергоэффективные компоненты."

/datum/body_modification/ipc_chassis/cybersun/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "cybersun"
	apply_ipc_brand(target, "cybersun")
	apply_ipc_brand_effects(target, "cybersun")
	return TRUE

/datum/body_modification/ipc_chassis/unbranded
	key = "ipc_chassis_unbranded"
	name = "Unbranded Chassis"

/datum/body_modification/ipc_chassis/unbranded/get_description()
	return "Шасси без конкретного производителя. Без специализированных бонусов."

/datum/body_modification/ipc_chassis/unbranded/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "unbranded"
	apply_ipc_brand(target, "unbranded")
	apply_ipc_brand_effects(target, "unbranded")
	return TRUE

// ============================================
// HEF: FRANKENSTEINIAN CHASSIS
// ============================================
// HEF — это НЕ bodypart_prosthesis (т.к. у нас свои переменные).
// Вместо этого делаем свою реализацию с поддержкой manufacturers
// через middleware data.
// ============================================

/datum/body_modification/ipc_hef_part
	abstract_type = /datum/body_modification/ipc_hef_part
	category = "IPC Chassis (HEF)"
	cost = 0
	// Список доступных производителей для этой части
	var/list/manufacturers = list("unbranded", "morpheus", "etamin", "bishop", "hesphiastos", "ward_takahashi", "xion", "zeng_hu", "shellguard", "cybersun")
	// Выбранный производитель (по умолчанию)
	var/selected_manufacturer = "unbranded"
	// Зона тела
	var/body_zone = null

/datum/body_modification/ipc_hef_part/can_be_applied(mob/living/carbon/target)
	if(!..())
		return FALSE
	if(!istype(target.dna?.species, /datum/species/ipc))
		return FALSE
	// Доступна только если основной chassis == HEF
	var/datum/species/ipc/S = target.dna.species
	return (S.ipc_brand_key == "hef")

/datum/body_modification/ipc_hef_part/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	// selected_manufacturer будет установлен через middleware
	// когда игрок выберет в dropdown
	// Здесь мы читаем его из body_modifications preference
	var/list/prefs = target.client?.prefs?.read_preference(/datum/preference/body_modifications)
	if(prefs && islist(prefs[key]) && prefs[key]["selected_manufacturer"])
		selected_manufacturer = prefs[key]["selected_manufacturer"]

	// Применяем визуал
	var/datum/species/ipc/S = target.dna.species
	switch(body_zone)
		if(BODY_ZONE_HEAD)
			S.hef_head = selected_manufacturer
		if(BODY_ZONE_CHEST)
			S.hef_chest = selected_manufacturer
		if(BODY_ZONE_L_ARM)
			S.hef_l_arm = selected_manufacturer
		if(BODY_ZONE_R_ARM)
			S.hef_r_arm = selected_manufacturer
		if(BODY_ZONE_L_LEG)
			S.hef_l_leg = selected_manufacturer
		if(BODY_ZONE_R_LEG)
			S.hef_r_leg = selected_manufacturer

	apply_ipc_part_visual(target, body_zone, selected_manufacturer)
	return TRUE

// --- ГОЛОВА ---
/datum/body_modification/ipc_hef_part/head
	key = "ipc_hef_head"
	name = "HEF — Голова"
	body_zone = BODY_ZONE_HEAD

/datum/body_modification/ipc_hef_part/head/get_description()
	return "HEF головной модуль. Выберите производителя — только визуал, без бонусов. \
	Morpheus: когнитивные системы. Shellguard: бронированная защита ядра."

// --- ГРУДЬ ---
/datum/body_modification/ipc_hef_part/chest
	key = "ipc_hef_chest"
	name = "HEF — Грудь"
	body_zone = BODY_ZONE_CHEST

/datum/body_modification/ipc_hef_part/chest/get_description()
	return "HEF торс. Выберите производителя — только визуал, без бонусов. \
	Etamin: термальная архитектура. Zeng-Hu: биосинтетические оболочки. Shellguard: бронированный корпус."

// --- ЛЕВАЯ РУКА ---
/datum/body_modification/ipc_hef_part/l_arm
	key = "ipc_hef_l_arm"
	name = "HEF — Левая рука"
	body_zone = BODY_ZONE_L_ARM

/datum/body_modification/ipc_hef_part/l_arm/get_description()
	return "HEF левая рука. Выберите производителя — только визуал, без бонусов. \
	Bishop: медицинские манипуляторы. Xion: лёгкие высокопроизводительные каркасы."

// --- ПРАВАЯ РУКА ---
/datum/body_modification/ipc_hef_part/r_arm
	key = "ipc_hef_r_arm"
	name = "HEF — Правая рука"
	body_zone = BODY_ZONE_R_ARM

/datum/body_modification/ipc_hef_part/r_arm/get_description()
	return "HEF правая рука. Выберите производителя — только визуал, без бонусов."

// --- ЛЕВАЯ НОГА ---
/datum/body_modification/ipc_hef_part/l_leg
	key = "ipc_hef_l_leg"
	name = "HEF — Левая нога"
	body_zone = BODY_ZONE_L_LEG

/datum/body_modification/ipc_hef_part/l_leg/get_description()
	return "HEF левая нога. Выберите производителя — только визуал, без бонусов. \
	Hesphiastos: бронированные конечности. Ward-Takahashi: кинематические системы."

// --- ПРАВАЯ НОГА ---
/datum/body_modification/ipc_hef_part/r_leg
	key = "ipc_hef_r_leg"
	name = "HEF — Правая нога"
	body_zone = BODY_ZONE_R_LEG

/datum/body_modification/ipc_hef_part/r_leg/get_description()
	return "HEF правая нога. Выберите производителя — только визуал, без бонусов."

// ============================================
// SPECIAL: HEF CHASSIS BASE
// ============================================
// Это основная модификация "HEF" которую нужно выбрать
// ПЕРЕД тем как появятся 6 поштучных выборов.
// Она incompatible со всеми остальными chassis brands.
// ============================================

/datum/body_modification/ipc_chassis/hef
	key = "ipc_chassis_hef"
	name = "HEF (Frankensteinian) Chassis"
	// Несовместима со всеми другими chassis
	incompatible_body_modifications = list(
		"ipc_chassis_morpheus",
		"ipc_chassis_etamin",
		"ipc_chassis_bishop",
		"ipc_chassis_hesphiastos",
		"ipc_chassis_ward_takahashi",
		"ipc_chassis_xion",
		"ipc_chassis_zeng_hu",
		"ipc_chassis_shellguard",
		"ipc_chassis_cybersun",
		"ipc_chassis_unbranded",
	)

/datum/body_modification/ipc_chassis/hef/get_description()
	return "Frankensteinian шасси из деталей разных производителей. \
	После выбора этой опции можно будет настроить каждую часть тела отдельно. \
	Без геймплейных бонусов — только визуал."

/datum/body_modification/ipc_chassis/hef/apply_to_human(mob/living/carbon/human/target)
	if(!..())
		return FALSE
	var/datum/species/ipc/S = target.dna.species
	S.ipc_brand_key = "hef"
	// Визуал будет применён через 6 поштучных модификаций HEF
	return TRUE
