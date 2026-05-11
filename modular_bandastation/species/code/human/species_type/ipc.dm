/datum/species/ipc
	name = "IPC"
	id = SPECIES_IPC
	sexes = TRUE

	meat = null
	inherent_biotypes = MOB_ROBOTIC
	exotic_bloodtype = BLOOD_TYPE_OIL
	species_language_holder = /datum/language_holder/synthetic
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN

	mutantstomach = null
	mutantliver = null
	mutantappendix = null
	mutantlungs = /obj/item/organ/lungs/ipc
	mutantbrain = /obj/item/organ/brain/positronic
	mutantheart = /obj/item/organ/heart/ipc_battery
	mutanteyes = /obj/item/organ/eyes/robotic/ipc
	mutanttongue = /obj/item/organ/tongue/robot/ipc
	mutantears = /obj/item/organ/ears/robot/ipc

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ipc,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ipc,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ipc,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ipc,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ipc,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ipc,
	)

	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_GENELESS,
		TRAIT_NOCRITDAMAGE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_LIMBATTACHMENT,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NOBLOOD,
	)

	// ЭМП уязвимость
	var/emp_vulnerability = 2

/datum/species/ipc/get_species_description()
	return "IPC (Integrated Positronic Construct) — синтетические гуманоидные формы жизни, управляемые позитронным вычислительным блоком (КПБ). \
	В отличие от обычных роботов, КПБ способны обеспечивать различный уровень автономии и самосознания, \
	благодаря чему IPC занимают промежуточное положение между машиной и личностью."

/datum/species/ipc/get_species_lore()
	return list(
		"Хотя крупнейшие корпорации остаются основными производителями позитронных процессоров и шасси, технология создания КПБ со временем \
		распространилась далеко за пределы корпоративных лабораторий. Сегодня такие системы могут быть собраны не только промышленными предприятиями, \
		но и независимыми инженерами, на частных верфях и даже в небольших мастерских. IPC широко используются в космической индустрии — \
		от технического персонала станций до экипажей кораблей и автономных экспедиционных групп.",
	)

/datum/species/ipc/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load)
	. = ..()
	replace_body(H, src)
	H.update_body()
	H.update_body_parts()

	// Зарядка на станции боргов
	RegisterSignal(H, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	// HUD батареи
	RegisterSignal(H, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	// Обновление HUD при изменении заряда батареи — сигнал от органа
	// override = TRUE защищает от дублирования если on_species_gain вызван повторно
	RegisterSignal(H, COMSIG_IPC_BATTERY_UPDATED, PROC_REF(on_battery_updated), override = TRUE)
	// Отслеживание повреждений корпуса для снятия/восстановления защиты от давления
	RegisterSignal(H, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_updated), override = TRUE)
	check_chassis_integrity(H)
	if(H.hud_used)
		add_ipc_battery_hud(H)

	// Нейтральный муд
	if(H.mob_mood)
		QDEL_NULL(H.mob_mood)
	H.mob_mood = new /datum/mood/ipc_neutral(H)

/datum/species/ipc/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(H, list(
		COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
		COMSIG_MOB_HUD_CREATED,
		COMSIG_IPC_BATTERY_UPDATED,
		COMSIG_LIVING_HEALTH_UPDATE,
	))
	REMOVE_TRAIT(H, TRAIT_IPC_CHASSIS_BREACHED, TRAIT_SOURCE_IPC_CHASSIS)
	REMOVE_TRAIT(H, TRAIT_RESISTHIGHPRESSURE, IPC_PRESSURE_SOURCE)
	REMOVE_TRAIT(H, TRAIT_RESISTLOWPRESSURE, IPC_PRESSURE_SOURCE)
	remove_ipc_battery_hud(H)
	if(istype(H.mob_mood, /datum/mood/ipc_neutral))
		QDEL_NULL(H.mob_mood)
		H.setup_mood()

/// Зарядка IPC на станции боргов — аналог зарядки борга.
/datum/species/ipc/proc/on_borg_charge(mob/living/carbon/human/H, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER
	var/obj/item/organ/heart/ipc_battery/bat = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!bat || !bat.proxy_cell)
		return
	charge_cell.Invoke(bat.proxy_cell, seconds_per_tick)

/datum/species/ipc/proc/handle_emp(mob/living/carbon/human/H, severity)
	var/emp_damage = 0
	switch(severity)
		if(EMP_HEAVY)
			emp_damage = rand(20, 40) * emp_vulnerability
			to_chat(H, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Электромагнитный импульс! Системы повреждены!"))
			H.Paralyze(6 SECONDS)
		if(EMP_LIGHT)
			emp_damage = rand(10, 20) * emp_vulnerability
			to_chat(H, span_danger("ПРЕДУПРЕЖДЕНИЕ: Электромагнитный импульс!"))
			H.Paralyze(3 SECONDS)

	H.adjust_brute_loss(emp_damage * 0.5, forced = TRUE, required_bodytype = BODYTYPE_ROBOTIC)
	H.adjust_fire_loss(emp_damage * 0.5, forced = TRUE, required_bodytype = BODYTYPE_ROBOTIC)

// Разрешаем цифры в именах для IPC (типа ARC-908), не затрагивая остальные расы
/datum/preference/name/real_name/deserialize(input, datum/preferences/preferences)
	if(preferences?.read_preference(/datum/preference/choiced/species) == /datum/species/ipc)
		return reject_bad_name(input, TRUE)
	return ..()

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	if(preferences.read_preference(/datum/preference/choiced/species) == /datum/species/ipc)
		return pick(GLOB.ipc_names)
	return ..()


/datum/dynamic_ruleset/roundstart/changeling/is_valid_candidate(mob/living/candidate, client/candidate_client)
	if(!..())
		return FALSE
	var/species_type = candidate_client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	if(species?.inherent_biotypes & MOB_ROBOTIC)
		return FALSE
	return TRUE

/datum/component/cult_ritual_item/can_scribe_rune(obj/item/tool, mob/living/cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		if(istype(H.dna?.species, /datum/species/ipc))
			to_chat(cultist, span_warning("Масло КПБ не является жертвенной субстанцией — руна не может быть начертана."))
			return FALSE
	return ..()

/datum/quirk/is_species_appropriate(datum/species/mob_species)
	if(ispath(mob_species, /datum/species/ipc))
		return FALSE
	return ..()


/datum/mood/ipc_neutral

/datum/mood/ipc_neutral/process()
	return

/datum/mood/ipc_neutral/add_mood_event()
	return

/datum/mood/ipc_neutral/check_area_mood()
	return

/datum/mood/ipc_neutral/update_nutrition_moodlets()
	return FALSE

/datum/mood/ipc_neutral/modify_hud()
	return

/datum/mood/ipc_neutral/unmodify_hud()
	return


/atom/movable/screen/ipc_battery_hud
	name = "battery charge"
	icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	icon_state = "cell_full"
	screen_loc = ui_mood
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ipc_battery_hud/Click()
	if(!ismob(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	var/obj/item/organ/heart/ipc_battery/bat = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!bat)
		to_chat(H, span_notice("ОШИБКА: Источник питания не обнаружен."))
		return
	var/pct = round((bat.charge / bat.maxcharge) * 100)
	to_chat(H, span_notice("Заряд источника питания: [pct]% ([round(bat.charge)]/[bat.maxcharge])"))


/datum/species/ipc/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return
	add_ipc_battery_hud(H)


/datum/species/ipc/proc/on_battery_updated(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	update_ipc_battery_hud(H)

/datum/species/ipc/proc/on_health_updated(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	check_chassis_integrity(H)

/datum/species/ipc/proc/check_chassis_integrity(mob/living/carbon/human/A)
	if(!A || !isipc(A))
		return

	var/is_breached = FALSE
	for(var/obj/item/bodypart/B in A.bodyparts)
		if(B.brute_dam >= (B.max_damage * IPC_CHASSIS_BREACH_THRESHOLD))
			is_breached = TRUE
			break

	// При пробитии корпуса IPC теряет защиту от давления,
	// при восстановлении — возвращает ее.
	if(is_breached)
		REMOVE_TRAIT(A, TRAIT_RESISTHIGHPRESSURE, IPC_PRESSURE_SOURCE)
		REMOVE_TRAIT(A, TRAIT_RESISTLOWPRESSURE, IPC_PRESSURE_SOURCE)
		ADD_TRAIT(A, TRAIT_IPC_CHASSIS_BREACHED, TRAIT_SOURCE_IPC_CHASSIS)
	else
		ADD_TRAIT(A, TRAIT_RESISTHIGHPRESSURE, IPC_PRESSURE_SOURCE)
		ADD_TRAIT(A, TRAIT_RESISTLOWPRESSURE, IPC_PRESSURE_SOURCE)
		REMOVE_TRAIT(A, TRAIT_IPC_CHASSIS_BREACHED, TRAIT_SOURCE_IPC_CHASSIS)

/datum/species/ipc/handle_environment_pressure(mob/living/carbon/human/H, datum/gas_mixture/environment, seconds_per_tick)
	if(!HAS_TRAIT(H, TRAIT_IPC_CHASSIS_BREACHED))
		H.clear_alert(ALERT_PRESSURE)
		H.seconds_in_low_pressure = 0
		return

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure)

	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			var/pressure_damage = min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod * H.physiology.brute_mod * seconds_per_tick
			H.adjust_brute_loss(pressure_damage, required_bodytype = BODYTYPE_ROBOTIC)
			H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 2)
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert(ALERT_PRESSURE)
			H.seconds_in_low_pressure = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 1)
			H.seconds_in_low_pressure = 0
		else
			var/pressure_damage = min(round(1 + (H.seconds_in_low_pressure / 80 SECONDS), 0.05) * BASE_LOW_PRESSURE_DAMAGE, MAX_LOW_PRESSURE_DAMAGE) * H.physiology.pressure_mod * H.physiology.brute_mod * seconds_per_tick
			H.adjust_brute_loss(pressure_damage, required_bodytype = BODYTYPE_ROBOTIC)
			H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 2)
			H.seconds_in_low_pressure += seconds_per_tick

/datum/species/ipc/proc/add_ipc_battery_hud(mob/living/carbon/human/H)
	if(!H.hud_used)
		return
	var/datum/hud/hud = H.hud_used
	if(hud.screen_objects[HUD_MOB_IPC_BATTERY])
		return
	// Убираем иконку голода — IPC не едят
	hud.remove_screen_object(HUD_MOB_HUNGER, update = FALSE)
	hud.add_screen_object(/atom/movable/screen/ipc_battery_hud, HUD_MOB_IPC_BATTERY, HUD_GROUP_INFO, update_screen = TRUE)
	update_ipc_battery_hud(H)

/datum/species/ipc/proc/remove_ipc_battery_hud(mob/living/carbon/human/H)
	if(!H?.hud_used)
		return
	var/datum/hud/hud = H.hud_used
	hud.remove_screen_object(HUD_MOB_IPC_BATTERY, update = FALSE)
	// Возвращаем голод, если его ещё нет (например, смена вида)
	if(!hud.screen_objects[HUD_MOB_HUNGER])
		hud.add_screen_object(/atom/movable/screen/hunger, HUD_MOB_HUNGER, HUD_GROUP_INFO, update_screen = TRUE)

/datum/species/ipc/proc/update_ipc_battery_hud(mob/living/carbon/human/H)
	if(!H.hud_used)
		return
	var/atom/movable/screen/ipc_battery_hud/indicator = H.hud_used.screen_objects[HUD_MOB_IPC_BATTERY]
	if(!indicator)
		return
	var/obj/item/organ/heart/ipc_battery/bat = H.get_organ_slot(ORGAN_SLOT_HEART)
	var/pct = bat ? round((bat.charge / bat.maxcharge) * 100) : 0
	var/new_state
	switch(pct)
		if(0)
			new_state = "no_cell"
		if(1 to 10)
			new_state = "empty_cell"
		if(11 to 30)
			new_state = "low_cell3"
		if(31 to 50)
			new_state = "low_cell2"
		if(51 to 75)
			new_state = "low_cell1"
		else
			new_state = "cell_full"
	indicator.icon_state = new_state
