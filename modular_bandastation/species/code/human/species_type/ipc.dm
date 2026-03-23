// ============================================
// ХЕЛПЕР
// ============================================
/mob/living/carbon/human/proc/is_ipc()
	return istype(dna?.species, /datum/species/ipc)

/datum/species/ipc
	name = "IPC"
	id = SPECIES_IPC
	sexes = TRUE

	meat = null
	inherent_biotypes = MOB_ROBOTIC
	exotic_bloodtype = BLOOD_TYPE_OIL
	species_language_holder = /datum/language_holder/synthetic

	mutantstomach = null
	mutantliver = null
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

	// Защита от давления
	ADD_TRAIT(H, TRAIT_RESISTHIGHPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
	ADD_TRAIT(H, TRAIT_RESISTLOWPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)

	// Зарядка на станции боргов
	RegisterSignal(H, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	// HUD батареи
	RegisterSignal(H, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	// Обновление HUD при изменении заряда батареи — сигнал от органа
	// override = TRUE защищает от дублирования если on_species_gain вызван повторно
	RegisterSignal(H, COMSIG_IPC_BATTERY_UPDATED, PROC_REF(on_battery_updated), override = TRUE)
	// Отслеживание повреждений корпуса для снятия/восстановления защиты от давления
	RegisterSignal(H, COMSIG_CARBON_LIMB_DAMAGED, PROC_REF(on_limb_damaged), override = TRUE)
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
		COMSIG_CARBON_LIMB_DAMAGED,
	))
	REMOVE_TRAIT(H, TRAIT_RESISTHIGHPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
	REMOVE_TRAIT(H, TRAIT_RESISTLOWPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
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

// ВЗАИМОДЕЙСТВИЕ ИНСТРУМЕНТОВ С IPC

/mob/living/carbon/human/screwdriver_act(mob/living/user, obj/item/tool)
	if(!is_ipc())
		return ..()
	var/obj/item/bodypart/BP = get_bodypart(user.zone_selected)
	if(!BP || !(BP.bodytype & BODYTYPE_IPC))
		return ..()
	var/datum/component/ipc_panel/panel = BP.GetComponent(/datum/component/ipc_panel)
	if(!panel)
		return ..()
	return panel.try_toggle_panel(BP, user)

/mob/living/carbon/human/wirecutter_act(mob/living/user, obj/item/tool)
	if(!is_ipc())
		return ..()
	var/obj/item/bodypart/BP = get_bodypart(user.zone_selected)
	if(!BP || !(BP.bodytype & BODYTYPE_IPC))
		return ..()
	var/datum/component/ipc_panel/panel = BP.GetComponent(/datum/component/ipc_panel)
	if(!panel)
		return ..()
	return panel.try_prepare_electronics(BP, user)

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

	H.apply_damage(emp_damage * 0.5, BRUTE, forced = TRUE)
	H.apply_damage(emp_damage * 0.5, BURN, forced = TRUE)

/obj/item/organ/brain/positronic/emp_act(severity)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(istype(H) && H.is_ipc())
		var/datum/species/ipc/S = H.dna.species
		S.handle_emp(H, severity)

// Разрешаем цифры в именах для IPC (типа ARC-908), не затрагивая остальные расы
/datum/preference/name/real_name/deserialize(input, datum/preferences/preferences)
	if(preferences?.read_preference(/datum/preference/choiced/species) == /datum/species/ipc)
		return reject_bad_name(input, TRUE)
	return ..()

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	if(preferences.read_preference(/datum/preference/choiced/species) == /datum/species/ipc)
		return pick(GLOB.ipc_names)
	return ..()

// СОВМЕСТИМОСТЬ С АНТАГОНИСТАМИ

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

// КОМПОНЕНТ ПАНЕЛИ IPC

/datum/component/ipc_panel
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/panel_state = IPC_PANEL_CLOSED

/datum/component/ipc_panel/Initialize(mapload)
	. = ..()
	var/obj/item/bodypart/BP = parent
	if(!istype(BP))
		return COMPONENT_INCOMPATIBLE
	if(!(BP.bodytype & BODYTYPE_IPC))
		return COMPONENT_INCOMPATIBLE

/datum/component/ipc_panel/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interact))

/datum/component/ipc_panel/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION)

/datum/component/ipc_panel/proc/is_panel_open()
	return panel_state == IPC_PANEL_OPEN

/datum/component/ipc_panel/proc/is_electronics_prepared()
	return panel_state == IPC_ELECTRONICS_PREPARED

/datum/component/ipc_panel/proc/on_item_interact(obj/item/bodypart/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(!user || !tool)
		return
	if(tool.tool_behaviour == TOOL_SCREWDRIVER)
		return try_toggle_panel(source, user)
	if(tool.tool_behaviour == TOOL_WIRECUTTER)
		return try_prepare_electronics(source, user)
	if(istype(tool, /obj/item/weldingtool))
		INVOKE_ASYNC(src, PROC_REF(try_repair_brute), source, user, tool)
		return ITEM_INTERACT_BLOCKING
	if(istype(tool, /obj/item/stack/cable_coil))
		INVOKE_ASYNC(src, PROC_REF(try_repair_burn), source, user, tool)
		return ITEM_INTERACT_BLOCKING

/// Ремонт повреждений (brute) сваркой.
/datum/component/ipc_panel/proc/try_repair_brute(obj/item/bodypart/BP, mob/living/user, obj/item/weldingtool/welder)
	if(!welder.welding)
		BP.balloon_alert(user, "сварка не включена")
		return
	if(BP.brute_dam <= 0)
		BP.balloon_alert(user, "нет механических повреждений")
		return
	var/heal_amount = rand(15, 25)
	BP.heal_damage(heal_amount, 0)
	BP.balloon_alert(user, "механические повреждения восстановлены")
	playsound(BP, 'sound/items/tools/welder2.ogg', 50, TRUE)
	if(BP.owner)
		to_chat(BP.owner, span_notice("Системная диагностика: Механические повреждения [BP.plaintext_zone] частично восстановлены."))
	do_sparks(3, TRUE, BP)

/// Ремонт  повреждений (burn) кабелем.
/datum/component/ipc_panel/proc/try_repair_burn(obj/item/bodypart/BP, mob/living/user, obj/item/stack/cable_coil/cable)
	if(cable.get_amount() < 1)
		BP.balloon_alert(user, "недостаточно кабеля")
		return
	if(BP.burn_dam <= 0)
		BP.balloon_alert(user, "нет burn повреждений")
		return
	cable.use(1)
	var/heal_amount = rand(10, 20)
	BP.heal_damage(0, heal_amount)
	BP.balloon_alert(user, "проводка восстановлена")
	playsound(BP, 'sound/items/deconstruct.ogg', 50, TRUE)
	if(BP.owner)
		to_chat(BP.owner, span_notice("Системная диагностика: Электрические системы [BP.plaintext_zone] частично восстановлены."))
	do_sparks(3, TRUE, BP)

/datum/component/ipc_panel/proc/try_toggle_panel(obj/item/bodypart/BP, mob/living/user)
	if(!is_panel_open())
		panel_state = IPC_PANEL_OPEN
		BP.balloon_alert(user, "панель открыта")
		playsound(BP, 'sound/items/tools/screwdriver2.ogg', 50, TRUE)
		if(BP.owner)
			to_chat(BP.owner, span_notice("Системная диагностика: Панель [BP.plaintext_zone] открыта."))
		do_sparks(2, TRUE, BP)
		return ITEM_INTERACT_BLOCKING
	panel_state = IPC_PANEL_CLOSED
	BP.balloon_alert(user, "панель закрыта")
	playsound(BP, 'sound/items/tools/screwdriver.ogg', 50, TRUE)
	if(BP.owner)
		to_chat(BP.owner, span_notice("Системная диагностика: Панель [BP.plaintext_zone] закрыта."))
	return ITEM_INTERACT_BLOCKING

/datum/component/ipc_panel/proc/try_prepare_electronics(obj/item/bodypart/BP, mob/living/user)
	if(BP.body_zone != BODY_ZONE_CHEST && BP.body_zone != BODY_ZONE_HEAD)
		return
	if(!is_panel_open() || is_electronics_prepared())
		return
	panel_state = IPC_ELECTRONICS_PREPARED
	BP.balloon_alert(user, "электроника готова")
	playsound(BP, 'sound/items/taperecorder/taperecorder_close.ogg', 50, TRUE)
	if(BP.owner)
		to_chat(BP.owner, span_notice("Системная диагностика: Электроника готова к манипуляциям."))
	do_sparks(2, TRUE, BP)
	return ITEM_INTERACT_BLOCKING

// НАСТРОЕНИЕ IPC — нейтральное (без эмоций)

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

// HUD ИНДИКАТОР БАТАРЕИ IPC

/// Иконка заряда батареи в слоте ui_mood. Нажмите для точного процента.
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

// УПРАВЛЕНИЕ HUD НА ВИДЕ IPC

/datum/species/ipc/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return
	add_ipc_battery_hud(H)

/// Вызывается по COMSIG_IPC_BATTERY_UPDATED — орган сообщает об изменении заряда.
/// Вид обновляет HUD и проверяет целостность корпуса (для отслеживания восстановления).
/datum/species/ipc/proc/on_battery_updated(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	update_ipc_battery_hud(H)
	check_chassis_integrity(H)

/// Вызывается по COMSIG_CARBON_LIMB_DAMAGED — любая часть тела получила урон.
/// Проверяет, не был ли вскрыт корпус, и немедленно снимает защиту от давления.
/datum/species/ipc/proc/on_limb_damaged(mob/living/carbon/human/H, obj/item/bodypart/limb, brute, burn)
	SIGNAL_HANDLER
	if(!(limb.bodytype & BODYTYPE_IPC))
		return
	check_chassis_integrity(H)

/// Проверяет целостность всех частей тела КПБ.
/// Если любая превышает порог брут-повреждений — снимает защиту от давления.
/// Если все ниже порога — восстанавливает защиту.
/datum/species/ipc/proc/check_chassis_integrity(mob/living/carbon/human/H)
	var/any_breached = FALSE
	for(var/obj/item/bodypart/BP in H.bodyparts)
		if(!(BP.bodytype & BODYTYPE_IPC))
			continue
		if(BP.brute_dam >= BP.max_damage * IPC_CHASSIS_BREACH_THRESHOLD)
			any_breached = TRUE
			break

	var/currently_intact = HAS_TRAIT_FROM(H, TRAIT_RESISTLOWPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
	if(any_breached && currently_intact)
		REMOVE_TRAIT(H, TRAIT_RESISTHIGHPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
		REMOVE_TRAIT(H, TRAIT_RESISTLOWPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
		to_chat(H, span_warning("СИСТЕМНОЕ ПРЕДУПРЕЖДЕНИЕ: Целостность корпуса нарушена. Внешняя среда может повредить внутренние компоненты."))
	else if(!any_breached && !currently_intact)
		ADD_TRAIT(H, TRAIT_RESISTHIGHPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
		ADD_TRAIT(H, TRAIT_RESISTLOWPRESSURE, TRAIT_SOURCE_IPC_CHASSIS)
		to_chat(H, span_notice("Системная диагностика: Целостность корпуса восстановлена. Защита от давления активна."))

/datum/species/ipc/proc/add_ipc_battery_hud(mob/living/carbon/human/H)
	if(!H.hud_used)
		return
	var/datum/hud/hud = H.hud_used
	if(locate(/atom/movable/screen/ipc_battery_hud) in hud.infodisplay)
		return
	// Убираем иконку голода — IPC не едят
	if(hud.hunger)
		hud.infodisplay -= hud.hunger
		H.client?.screen -= hud.hunger
		QDEL_NULL(hud.hunger)
	var/atom/movable/screen/ipc_battery_hud/indicator = new(null, hud)
	hud.infodisplay += indicator
	H.client?.screen += indicator
	update_ipc_battery_hud(H)

/datum/species/ipc/proc/remove_ipc_battery_hud(mob/living/carbon/human/H)
	if(!H?.hud_used)
		return
	var/datum/hud/hud = H.hud_used
	for(var/atom/movable/screen/ipc_battery_hud/indicator in hud.infodisplay)
		hud.infodisplay -= indicator
		H.client?.screen -= indicator
		qdel(indicator)
	// Возвращаем голод, если новый вид его использует
	if(!hud.hunger)
		hud.hunger = new /atom/movable/screen/hunger(null, hud)
		hud.infodisplay += hud.hunger
		H.client?.screen += hud.hunger

/datum/species/ipc/proc/update_ipc_battery_hud(mob/living/carbon/human/H)
	if(!H.hud_used)
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
	for(var/atom/movable/screen/ipc_battery_hud/indicator in H.hud_used.infodisplay)
		indicator.icon_state = new_state
