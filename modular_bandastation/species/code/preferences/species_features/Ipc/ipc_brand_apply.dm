// ============================================
// ПРИМЕНЕНИЕ ВИЗУАЛА БРЕНДА НА BODYPARTS
// ============================================
// Вызывается при раундстарте после того как моб создан.
// Определяет actual_visual_brand (для HEF это отдельная фиче,
// для всех остальных = brand_key).
// Затем устанавливает icon_state на всех частях тела.
// ============================================

/// Главная точка входа для применения бренда при раундстарте
/// brand_key — выбранный бренд из фичи ipc_chassis_brand
/// hef_visual_key — deprecated, не используется (поштучный выбор через species vars)
/proc/apply_ipc_brand(mob/living/carbon/human/H, brand_key, hef_visual_key = null)
	if(!H || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE

	// Валидация brand_key
	if(!(brand_key in get_ipc_brand_keys()))
		brand_key = "unbranded"

	var/datum/species/ipc/S = H.dna.species
	S.ipc_brand_key = brand_key

	// Обновляем тему ОС если уже инициализирована (ОС создаётся до применения бренда)
	if(S.ipc_os)
		S.ipc_os.brand_key = brand_key
		S.ipc_os.os_name = get_ipc_os_name(brand_key)
		S.ipc_os.theme_color = get_ipc_os_theme_color(brand_key)

	if(brand_key == "hef")
		// HEF: каждая часть тела может быть от разного производителя.
		// Читаем поштучные выборы с species и применяем индивидуально.
		// Бонусов нет — только визуал, компоненты работают в базовом режиме.
		apply_ipc_hef_visual(H, S)
	else
		// Обычный бренд: один визуальный префикс на всё тело
		var/datum/ipc_brand/visual_brand = get_ipc_brand(brand_key)
		if(!visual_brand)
			return FALSE
		S.ipc_visual_brand_key = brand_key
		apply_ipc_visual_prefix(H, visual_brand.visual_prefix, visual_brand.custom_icon_file, brand_key)
		qdel(visual_brand)

	return TRUE

/// HEF: применяем визуал поштучно — каждая часть может быть разного бренда
/proc/apply_ipc_hef_visual(mob/living/carbon/human/H, datum/species/ipc/S)
	// Список частей тела и соответствующих var на species
	// Для каждой части: берём ключ бренда → получаем brand datum → берём visual_prefix
	apply_ipc_part_visual(H, BODY_ZONE_HEAD, S.hef_head)
	apply_ipc_part_visual(H, BODY_ZONE_CHEST, S.hef_chest)
	apply_ipc_part_visual(H, BODY_ZONE_L_ARM, S.hef_l_arm)
	apply_ipc_part_visual(H, BODY_ZONE_R_ARM, S.hef_r_arm)
	apply_ipc_part_visual(H, BODY_ZONE_L_LEG, S.hef_l_leg)
	apply_ipc_part_visual(H, BODY_ZONE_R_LEG, S.hef_r_leg)

	H.update_body()
	H.update_body_parts()

/// Применяет визуал одной части тела по ключу бренда
/proc/apply_ipc_part_visual(mob/living/carbon/human/H, zone, brand_key)
	if(!(brand_key in get_ipc_brand_keys()))
		brand_key = "unbranded"

	var/datum/ipc_brand/brand = get_ipc_brand(brand_key)
	if(!brand)
		return
	var/custom_icon = brand.custom_icon_file
	qdel(brand)

	// Все файлы брендированных спрайтов используют ipc_* имена состояний.
	// Меняем icon файл если есть custom_icon, icon_state всегда ipc_*.
	switch(zone)
		if(BODY_ZONE_HEAD)
			var/obj/item/bodypart/head/ipc/head = H.get_bodypart(BODY_ZONE_HEAD)
			if(head && custom_icon)
				head.icon = custom_icon
				head.icon_static = custom_icon
				head.icon_greyscale = null
				head.icon_state = "ipc_head"
				// ipc_visual_state определяет реальный стейт в get_limb_icon()
				head.ipc_visual_state = (brand_key in GLOB.ipc_brands_with_monitor) ? "monitor" : null
		if(BODY_ZONE_CHEST)
			var/obj/item/bodypart/chest/ipc/chest = H.get_bodypart(BODY_ZONE_CHEST)
			if(chest && custom_icon)
				chest.icon = custom_icon
				chest.icon_static = custom_icon
				chest.icon_greyscale = null
				var/gender_suffix = (H.gender == FEMALE) ? "f" : "m"
				chest.icon_state = "ipc_chest_[gender_suffix]"
		if(BODY_ZONE_L_ARM)
			var/obj/item/bodypart/arm/left/ipc/l_arm = H.get_bodypart(BODY_ZONE_L_ARM)
			if(l_arm && custom_icon)
				l_arm.icon = custom_icon
				l_arm.icon_static = custom_icon
				l_arm.icon_greyscale = null
				l_arm.icon_state = "ipc_l_arm"
		if(BODY_ZONE_R_ARM)
			var/obj/item/bodypart/arm/right/ipc/r_arm = H.get_bodypart(BODY_ZONE_R_ARM)
			if(r_arm && custom_icon)
				r_arm.icon = custom_icon
				r_arm.icon_static = custom_icon
				r_arm.icon_greyscale = null
				r_arm.icon_state = "ipc_r_arm"
		if(BODY_ZONE_L_LEG)
			var/obj/item/bodypart/leg/left/ipc/l_leg = H.get_bodypart(BODY_ZONE_L_LEG)
			if(l_leg && custom_icon)
				l_leg.icon = custom_icon
				l_leg.icon_static = custom_icon
				l_leg.icon_greyscale = null
				l_leg.icon_state = "ipc_l_leg"
		if(BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg/right/ipc/r_leg = H.get_bodypart(BODY_ZONE_R_LEG)
			if(r_leg && custom_icon)
				r_leg.icon = custom_icon
				r_leg.icon_static = custom_icon
				r_leg.icon_greyscale = null
				r_leg.icon_state = "ipc_r_leg"

/// Устанавливает icon/icon_state на всех частях тела по визуальному пресету бренда.
/// Все файлы брендированных спрайтов используют ipc_* имена состояний.
/// Для брендов без custom_icon_file уникальных спрайтов нет — визуал не меняется.
/proc/apply_ipc_visual_prefix(mob/living/carbon/human/H, prefix, custom_icon_file = null, brand_key = null)
	// Без кастомного файла спрайтов — менять нечего
	if(!custom_icon_file)
		H.update_body()
		H.update_body_parts()
		return

	// Грудь — зависит от пола
	var/obj/item/bodypart/chest/ipc/chest = H.get_bodypart(BODY_ZONE_CHEST)
	if(chest)
		chest.icon = custom_icon_file
		chest.icon_static = custom_icon_file
		chest.icon_greyscale = null
		var/gender_suffix = (H.gender == FEMALE) ? "f" : "m"
		chest.icon_state = "ipc_chest_[gender_suffix]"

	// Голова
	var/obj/item/bodypart/head/ipc/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.icon = custom_icon_file
		head.icon_static = custom_icon_file
		head.icon_greyscale = null
		head.icon_state = "ipc_head"
		// ipc_visual_state определяет реальный стейт в get_limb_icon()
		head.ipc_visual_state = (brand_key && (brand_key in GLOB.ipc_brands_with_monitor)) ? "monitor" : null

	// Левая рука
	var/obj/item/bodypart/arm/left/ipc/l_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	if(l_arm)
		l_arm.icon = custom_icon_file
		l_arm.icon_static = custom_icon_file
		l_arm.icon_greyscale = null
		l_arm.icon_state = "ipc_l_arm"

	// Правая рука
	var/obj/item/bodypart/arm/right/ipc/r_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	if(r_arm)
		r_arm.icon = custom_icon_file
		r_arm.icon_static = custom_icon_file
		r_arm.icon_greyscale = null
		r_arm.icon_state = "ipc_r_arm"

	// Левая нога
	var/obj/item/bodypart/leg/left/ipc/l_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	if(l_leg)
		l_leg.icon = custom_icon_file
		l_leg.icon_static = custom_icon_file
		l_leg.icon_greyscale = null
		l_leg.icon_state = "ipc_l_leg"

	// Правая нога
	var/obj/item/bodypart/leg/right/ipc/r_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if(r_leg)
		r_leg.icon = custom_icon_file
		r_leg.icon_static = custom_icon_file
		r_leg.icon_greyscale = null
		r_leg.icon_state = "ipc_r_leg"

	H.update_body()
	H.update_body_parts()

// ============================================
// ОПРЕДЕЛЕНИЕ БРЕНДА ПРИ СБОРКЕ ШАССИ
// ============================================
// Вызывается автоматически при прикреплении любой
// небашенной конечности IPC (рука/нога).
// Если все 5 небашенных частей (грудь + 2 руки + 2 ноги)
// принадлежат одному бренду — применяем этот бренд.
// ============================================

/// Конвертирует chassis_type из bodypart в brand_key для apply_ipc_brand
/proc/chassis_type_to_brand_key(chassis_type)
	switch(chassis_type)
		if("Morpheus")      return "morpheus"
		if("Etamin")        return "etamin"
		if("Bishop")        return "bishop"
		if("Hesphiastos")   return "hesphiastos"
		if("Ward-Takahashi") return "ward_takahashi"
		if("Xion")          return "xion"
		if("Zeng-Hu")       return "zeng_hu"
		if("Shellguard")    return "shellguard"
		if("Cybersun")      return "cybersun"
	return "unbranded"

/// Возвращает chassis_type для IPC-конечности (null если не IPC bodypart)
/proc/ipc_get_bodypart_chassis_type(obj/item/bodypart/part)
	if(istype(part, /obj/item/bodypart/chest/ipc))
		var/obj/item/bodypart/chest/ipc/P = part
		return P.chassis_type
	if(istype(part, /obj/item/bodypart/arm/left/ipc))
		var/obj/item/bodypart/arm/left/ipc/P = part
		return P.chassis_type
	if(istype(part, /obj/item/bodypart/arm/right/ipc))
		var/obj/item/bodypart/arm/right/ipc/P = part
		return P.chassis_type
	if(istype(part, /obj/item/bodypart/leg/left/ipc))
		var/obj/item/bodypart/leg/left/ipc/P = part
		return P.chassis_type
	if(istype(part, /obj/item/bodypart/leg/right/ipc))
		var/obj/item/bodypart/leg/right/ipc/P = part
		return P.chassis_type
	return null

/// Проверяет собранное шасси IPC и применяет бренд если все небашенные части совпадают.
/// Вызывается из try_attach_limb у каждой небашенной конечности IPC.
/proc/ipc_check_assembly_brand(mob/living/carbon/human/H)
	if(!H || !istype(H.dna?.species, /datum/species/ipc))
		return

	var/list/required_zones = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)

	var/detected_brand = null
	var/all_match = TRUE

	for(var/zone in required_zones)
		var/obj/item/bodypart/part = H.get_bodypart(zone)
		if(!part)
			return  // Не все части ещё установлены

		var/part_chassis_type = ipc_get_bodypart_chassis_type(part)
		if(isnull(part_chassis_type))
			return  // Не IPC bodypart

		if(isnull(detected_brand))
			detected_brand = part_chassis_type
		else if(detected_brand != part_chassis_type)
			all_match = FALSE
			break

	// Все 5 частей установлены — применяем бренд
	var/brand_key = (all_match && detected_brand) ? chassis_type_to_brand_key(detected_brand) : "unbranded"
	apply_ipc_brand(H, brand_key)
	apply_ipc_brand_effects(H, brand_key)


