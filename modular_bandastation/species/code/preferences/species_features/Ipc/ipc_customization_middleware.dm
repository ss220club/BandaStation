// ============================================
// MIDDLEWARE: IPC CUSTOMIZATION
// ============================================
// Обрабатывает actions из IPC customization UI:
//   - set_chassis_brand
//   - set_brain_type
//   - set_hef_part (для поштучных HEF выборов)
// ============================================

/datum/preference_middleware/ipc_customization
	action_delegations = list(
		"set_chassis_brand" = PROC_REF(set_chassis_brand),
		"set_brain_type" = PROC_REF(set_brain_type),
		"set_hef_part" = PROC_REF(set_hef_part),
	)

/// Append data to ui_data
/datum/preference_middleware/ipc_customization/get_ui_data(mob/user)
	var/list/data = list()
	var/list/customization = preferences.read_preference(/datum/preference/ipc_customization)

	data["ipc_customization"] = customization

	// Проверяем является ли персонаж IPC через preferences, а не через mob.dna
	// (т.к. в lobby mob = /mob/dead/new_player без dna)
	var/selected_species = preferences.read_preference(/datum/preference/choiced/species)
	data["is_ipc"] = (selected_species == SPECIES_IPC)

	return data

/// Append constant data to ui_static_data
/datum/preference_middleware/ipc_customization/get_constant_data(mob/user)
	var/list/data = list()

	// Список всех доступных chassis brands
	data["chassis_brands"] = list(
		list("key" = "unbranded", "name" = "Unbranded", "description" = "Без конкретного производителя. Без специализированных бонусов."),
		list("key" = "morpheus", "name" = "Morpheus Cyberkinetics", "description" = "Специализация: когнитивные системы и нейроинтерфейсы."),
		list("key" = "etamin", "name" = "Etamin Industry", "description" = "Специализация: термальные системы, охлаждение ядра."),
		list("key" = "bishop", "name" = "Bishop Cybernetics", "description" = "Специализация: медицинские модули, точные манипуляторы."),
		list("key" = "hesphiastos", "name" = "Hesphiastos Industries", "description" = "Специализация: бронированные конечности для тяжёлой среды."),
		list("key" = "ward_takahashi", "name" = "Ward-Takahashi", "description" = "Специализация: кинематические системы, оптимизация подвижности."),
		list("key" = "xion", "name" = "Xion Manufacturing Group", "description" = "Специализация: лёгкие высокопроизводительные каркасы."),
		list("key" = "zeng_hu", "name" = "Zeng-Hu Pharmaceuticals", "description" = "Специализация: биосинтетические оболочки."),
		list("key" = "shellguard", "name" = "Shellguard Munitions", "description" = "Специализация: бронированные корпуса для боевого применения."),
		list("key" = "cybersun", "name" = "Cybersun Industries", "description" = "Специализация: энергоэффективные компоненты."),
		list("key" = "hef", "name" = "HEF (Frankensteinian)", "description" = "Шасси из деталей разных производителей. Можно настроить каждую часть тела отдельно. Без геймплейных бонусов."),
	)

	// Список типов мозга
	data["brain_types"] = list(
		list("key" = "positronic", "name" = "Позитронное ядро (стандарт)", "description" = "Стандартное позитронное ядро — искусственный интеллект на позитронной основе."),
		list("key" = "mmi", "name" = "MMI-based Core", "description" = "Позитронный блок с установленным MMI. Содержит оцифрованное органическое сознание."),
		list("key" = "borg", "name" = "Borg Module Core", "description" = "Позитронный блок с платой из киборга. Содержит ИИ-личность."),
	)

	// Список производителей для HEF частей
	data["hef_manufacturers"] = list(
		list("key" = "unbranded", "name" = "Unbranded"),
		list("key" = "morpheus", "name" = "Morpheus Cyberkinetics"),
		list("key" = "etamin", "name" = "Etamin Industry"),
		list("key" = "bishop", "name" = "Bishop Cybernetics"),
		list("key" = "hesphiastos", "name" = "Hesphiastos Industries"),
		list("key" = "ward_takahashi", "name" = "Ward-Takahashi"),
		list("key" = "xion", "name" = "Xion Manufacturing Group"),
		list("key" = "zeng_hu", "name" = "Zeng-Hu Pharmaceuticals"),
		list("key" = "shellguard", "name" = "Shellguard Munitions"),
		list("key" = "cybersun", "name" = "Cybersun Industries"),
	)

	return data

/datum/preference_middleware/ipc_customization/proc/set_chassis_brand(list/params, mob/user)
	var/brand = params["brand"]
	if(!brand)
		return FALSE

	var/list/valid_brands = list("unbranded", "morpheus", "etamin", "bishop", "hesphiastos", "ward_takahashi", "xion", "zeng_hu", "shellguard", "cybersun", "hef")
	if(!(brand in valid_brands))
		return FALSE

	var/list/customization = preferences.read_preference(/datum/preference/ipc_customization)
	customization["chassis_brand"] = brand

	preferences.update_preference(GLOB.preference_entries[/datum/preference/ipc_customization], customization)
	return TRUE

/datum/preference_middleware/ipc_customization/proc/set_brain_type(list/params, mob/user)
	var/brain_type = params["brain_type"]
	if(!brain_type)
		return FALSE

	var/list/valid_types = list("positronic", "mmi", "borg")
	if(!(brain_type in valid_types))
		return FALSE

	var/list/customization = preferences.read_preference(/datum/preference/ipc_customization)
	customization["brain_type"] = brain_type

	preferences.update_preference(GLOB.preference_entries[/datum/preference/ipc_customization], customization)
	return TRUE

/datum/preference_middleware/ipc_customization/proc/set_hef_part(list/params, mob/user)
	var/part = params["part"]  // "hef_head", "hef_chest", etc.
	var/manufacturer = params["manufacturer"]

	if(!part || !manufacturer)
		return FALSE

	var/list/valid_parts = list("hef_head", "hef_chest", "hef_l_arm", "hef_r_arm", "hef_l_leg", "hef_r_leg")
	if(!(part in valid_parts))
		return FALSE

	var/list/valid_manufacturers = list("unbranded", "morpheus", "etamin", "bishop", "hesphiastos", "ward_takahashi", "xion", "zeng_hu", "shellguard", "cybersun")
	if(!(manufacturer in valid_manufacturers))
		return FALSE

	var/list/customization = preferences.read_preference(/datum/preference/ipc_customization)
	customization[part] = manufacturer

	preferences.update_preference(GLOB.preference_entries[/datum/preference/ipc_customization], customization)
	return TRUE
