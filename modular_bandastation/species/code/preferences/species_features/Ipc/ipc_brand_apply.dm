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
		apply_ipc_visual_prefix(H, visual_brand.visual_prefix, visual_brand.custom_icon_file)
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
	var/prefix = brand.visual_prefix
	var/custom_icon = brand.custom_icon_file
	qdel(brand)

	switch(zone)
		if(BODY_ZONE_HEAD)
			var/obj/item/bodypart/head/ipc/head = H.get_bodypart(BODY_ZONE_HEAD)
			if(head)
				if(custom_icon)
					head.icon = custom_icon
					head.icon_static = custom_icon  // Важно для bodyparts!
					head.icon_greyscale = null
				head.icon_state = "[prefix]_head"
		if(BODY_ZONE_CHEST)
			var/obj/item/bodypart/chest/ipc/chest = H.get_bodypart(BODY_ZONE_CHEST)
			if(chest)
				if(custom_icon)
					chest.icon = custom_icon
					chest.icon_static = custom_icon
					chest.icon_greyscale = null
				var/gender_suffix = (H.gender == FEMALE) ? "f" : "m"
				chest.icon_state = "[prefix]_chest_[gender_suffix]"
		if(BODY_ZONE_L_ARM)
			var/obj/item/bodypart/arm/left/ipc/l_arm = H.get_bodypart(BODY_ZONE_L_ARM)
			if(l_arm)
				if(custom_icon)
					l_arm.icon = custom_icon
					l_arm.icon_static = custom_icon
					l_arm.icon_greyscale = null
				l_arm.icon_state = "[prefix]_l_arm"
		if(BODY_ZONE_R_ARM)
			var/obj/item/bodypart/arm/right/ipc/r_arm = H.get_bodypart(BODY_ZONE_R_ARM)
			if(r_arm)
				if(custom_icon)
					r_arm.icon = custom_icon
					r_arm.icon_static = custom_icon
					r_arm.icon_greyscale = null
				r_arm.icon_state = "[prefix]_r_arm"
		if(BODY_ZONE_L_LEG)
			var/obj/item/bodypart/leg/left/ipc/l_leg = H.get_bodypart(BODY_ZONE_L_LEG)
			if(l_leg)
				if(custom_icon)
					l_leg.icon = custom_icon
					l_leg.icon_static = custom_icon
					l_leg.icon_greyscale = null
				l_leg.icon_state = "[prefix]_l_leg"
		if(BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg/right/ipc/r_leg = H.get_bodypart(BODY_ZONE_R_LEG)
			if(r_leg)
				if(custom_icon)
					r_leg.icon = custom_icon
					r_leg.icon_static = custom_icon
					r_leg.icon_greyscale = null
				r_leg.icon_state = "[prefix]_r_leg"

/// Устанавливает icon_state на всех частях тела по визуальному префиксу бренда
/proc/apply_ipc_visual_prefix(mob/living/carbon/human/H, prefix, custom_icon_file = null)
	// Грудь — зависит от пола
	var/obj/item/bodypart/chest/ipc/chest = H.get_bodypart(BODY_ZONE_CHEST)
	if(chest)
		if(custom_icon_file)
			chest.icon = custom_icon_file
			chest.icon_static = custom_icon_file  // Важно для bodyparts!
			chest.icon_greyscale = null  // Отключаем greyscale систему для кастомных иконок
		var/gender_suffix = (H.gender == FEMALE) ? "f" : "m"
		chest.icon_state = "[prefix]_chest_[gender_suffix]"

	// Голова
	var/obj/item/bodypart/head/ipc/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		if(custom_icon_file)
			head.icon = custom_icon_file
			head.icon_static = custom_icon_file
			head.icon_greyscale = null
		head.icon_state = "[prefix]_head"

	// Левая рука
	var/obj/item/bodypart/arm/left/ipc/l_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	if(l_arm)
		if(custom_icon_file)
			l_arm.icon = custom_icon_file
			l_arm.icon_static = custom_icon_file
			l_arm.icon_greyscale = null
		l_arm.icon_state = "[prefix]_l_arm"

	// Правая рука
	var/obj/item/bodypart/arm/right/ipc/r_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	if(r_arm)
		if(custom_icon_file)
			r_arm.icon = custom_icon_file
			r_arm.icon_static = custom_icon_file
			r_arm.icon_greyscale = null
		r_arm.icon_state = "[prefix]_r_arm"

	// Левая нога
	var/obj/item/bodypart/leg/left/ipc/l_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	if(l_leg)
		if(custom_icon_file)
			l_leg.icon = custom_icon_file
			l_leg.icon_static = custom_icon_file
			l_leg.icon_greyscale = null
		l_leg.icon_state = "[prefix]_l_leg"

	// Правая нога
	var/obj/item/bodypart/leg/right/ipc/r_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if(r_leg)
		if(custom_icon_file)
			r_leg.icon = custom_icon_file
			r_leg.icon_static = custom_icon_file
			r_leg.icon_greyscale = null
		r_leg.icon_state = "[prefix]_r_leg"

	// Обновляем внешность моба целиком
	H.update_body()
	H.update_body_parts()

// ============================================
// ВАЛИДАЦИЯ БРЕНДА ПО ПРОФЕССИИ
// ============================================
// Проверяем что профессия позволяет выбранный бренд.
// Если нет — сбрасываем на unbranded.
// Вызывать ДО apply_ipc_brand.

/proc/validate_ipc_brand_for_job(brand_key, mob/living/carbon/human/H)
	var/datum/ipc_brand/brand = get_ipc_brand(brand_key)
	if(!brand)
		return "unbranded"

	// Если ограничений нет — пропускаем
	if(!length(brand.allowed_departments))
		qdel(brand)
		return brand_key

	// Проверяем профессию
	// FIX: В этом форке H.job — это plain string (название профессии),
	// а не /datum/job. Доказательство: все попытки обращения к переменным
	// (.department_bitflags, .department_bitflag, .department, .name)
	// дали "undefined var". /datum не имеет встроенных var — значит это
	// не datum вообще. Используем H.job напрямую как строку.
	if(!H.job)
		qdel(brand)
		return "unbranded"

	var/job_title = H.job  // это уже строка, например "Security Officer"

	// Маппинг: каждый DEPARTMENT_BITFLAG → список названий профессий
	var/list/security_jobs = list("Security Officer", "Warden", "HoS", "Head of Security", "Brig Physician", "Pilot", "IAA", "Detective", "Bounty Hunter", "Parole Officer")
	var/list/medical_jobs = list("Paramedic", "Medical Doctor", "Surgeon", "CMO", "Chief Medical Officer", "Psychologist", "Chemist", "Virologist", "Geneticist", "Brig Physician", "Research Scientist")
	var/list/science_jobs = list("Scientist", "Research Scientist", "RD", "Research Director", "Roboticist", "Quartermaster", "Mining Prospector", "Xenobiologist", "Toxicologist", "Virologist", "Geneticist")

	var/allowed = FALSE
	for(var/flag in brand.allowed_departments)
		var/list/jobs_for_flag = null
		if(flag == DEPARTMENT_BITFLAG_SECURITY)
			jobs_for_flag = security_jobs
		else if(flag == DEPARTMENT_BITFLAG_MEDICAL)
			jobs_for_flag = medical_jobs
		else if(flag == DEPARTMENT_BITFLAG_SCIENCE)
			jobs_for_flag = science_jobs

		if(jobs_for_flag && (job_title in jobs_for_flag))
			allowed = TRUE
			break

	qdel(brand)
	return allowed ? brand_key : "unbranded"
