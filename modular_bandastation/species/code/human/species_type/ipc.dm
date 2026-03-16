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

	// Зарядка на станции боргов
	RegisterSignal(H, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	// HUD батареи
	RegisterSignal(H, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	if(H.hud_used)
		add_ipc_battery_hud(H)

	// Нейтральный муд
	if(H.mob_mood)
		QDEL_NULL(H.mob_mood)
	H.mob_mood = new /datum/mood/ipc_neutral(H)

/datum/species/ipc/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(H, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(H, COMSIG_MOB_HUD_CREATED)
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

	H.apply_damage(emp_damage * 0.5, BRUTE, forced = TRUE)
	H.apply_damage(emp_damage * 0.5, BURN, forced = TRUE)

/obj/item/organ/brain/positronic/emp_act(severity)
	. = ..()
	if(owner && istype(owner.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = owner.dna.species
		S.handle_emp(owner, severity)

// ============================================
// ВНЕШНИЙ РЕМОНТ: сваркой и кабелем
// ============================================

/datum/species/ipc/proc/try_repair_brute(mob/living/carbon/human/H, obj/item/tool, mob/user)
	if(!istype(tool, /obj/item/weldingtool))
		return FALSE
	var/obj/item/weldingtool/welder = tool
	if(!welder.isOn())
		to_chat(user, span_warning("[welder] не включен!"))
		return FALSE
	if(H.get_brute_loss() <= 0)
		to_chat(user, span_notice("[H] не имеет механических повреждений."))
		return FALSE
	if(!welder.use_tool(H, user, 0, volume = 50, amount = 1))
		return FALSE
	user.visible_message(
		span_notice("[user] начинает заваривать повреждения [H]."),
		span_notice("Вы начинаете заваривать повреждения [H].")
	)
	if(!do_after(user, 3 SECONDS, target = H))
		return FALSE
	if(!welder.use_tool(H, user, 0, volume = 50, amount = 1))
		return FALSE
	var/heal_amount = rand(15, 25)
	H.heal_overall_damage(brute = heal_amount, forced = TRUE)
	user.visible_message(
		span_notice("[user] заваривает повреждения [H]."),
		span_notice("Вы заварили повреждения [H]. Восстановлено [heal_amount] HP.")
	)
	return TRUE

/datum/species/ipc/proc/try_repair_burn(mob/living/carbon/human/H, obj/item/tool, mob/user)
	if(!istype(tool, /obj/item/stack/cable_coil))
		return FALSE
	var/obj/item/stack/cable_coil/cable = tool
	if(H.get_fire_loss() <= 0)
		to_chat(user, span_notice("[H] не имеет электрических повреждений."))
		return FALSE
	if(cable.get_amount() < 1)
		to_chat(user, span_warning("Недостаточно кабеля!"))
		return FALSE
	user.visible_message(
		span_notice("[user] начинает чинить проводку [H]."),
		span_notice("Вы начинаете чинить проводку [H].")
	)
	if(!do_after(user, 3 SECONDS, target = H))
		return FALSE
	if(!cable.use(1))
		return FALSE
	var/heal_amount = rand(10, 20)
	H.heal_overall_damage(burn = heal_amount, forced = TRUE)
	user.visible_message(
		span_notice("[user] чинит проводку [H]."),
		span_notice("Вы починили проводку [H]. Восстановлено [heal_amount] HP.")
	)
	return TRUE

/mob/living/carbon/human/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = dna.species
		var/obj/item/bodypart/target_part = get_bodypart(check_zone(user.zone_selected))
		if(target_part)
			var/datum/component/ipc_panel/panel = target_part.GetComponent(/datum/component/ipc_panel)
			if(panel)
				if(istype(tool, /obj/item/screwdriver))
					panel.toggle_panel(user, tool)
					return ITEM_INTERACT_SUCCESS
				if(panel.is_panel_open())
					var/surgery_ret = user.perform_surgery(src, tool, LAZYACCESS(modifiers, RIGHT_CLICK))
					if(surgery_ret)
						return surgery_ret
		if(istype(tool, /obj/item/weldingtool))
			if(S.try_repair_brute(src, tool, user))
				return ITEM_INTERACT_SUCCESS
		else if(istype(tool, /obj/item/stack/cable_coil))
			if(S.try_repair_burn(src, tool, user))
				return ITEM_INTERACT_SUCCESS
	return ..()

// Разрешаем цифры в именах (нужно для IPC-имён типа ARC-908)
/datum/preference/name/real_name
	allow_numbers = TRUE

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	if(preferences.read_preference(/datum/preference/choiced/species) == /datum/species/ipc)
		return pick(GLOB.ipc_names)
	return ..()

// ============================================
// СОВМЕСТИМОСТЬ С АНТАГОНИСТАМИ
// ============================================

// Чейнджлинг не может взять IPC — нет ДНК
/datum/dynamic_ruleset/roundstart/changeling/is_valid_candidate(mob/living/candidate, client/candidate_client)
	if(!..())
		return FALSE
	var/species_type = candidate_client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	if(istype(species, /datum/species/ipc))
		return FALSE
	return TRUE

// Культ: масло не является жертвенной субстанцией
/datum/component/cult_ritual_item/do_scribe_rune(obj/item/tool, mob/living/cultist)
	if(HAS_TRAIT(cultist, TRAIT_NOBLOOD))
		to_chat(cultist, span_warning("Масло КПБ не является жертвенной субстанцией — руна не может быть начертана."))
		return FALSE
	return ..()

/datum/component/ipc_panel
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// 0 = закрыта, 1 = открыта
	var/panel_state = 0

/datum/component/ipc_panel/Initialize(mapload)
	. = ..()
	if(!istype(parent, /obj/item/bodypart))
		return COMPONENT_INCOMPATIBLE

/datum/component/ipc_panel/proc/is_panel_open()
	return panel_state == 1

/datum/component/ipc_panel/proc/toggle_panel(mob/living/user, obj/item/tool)
	panel_state = !panel_state
	if(tool)
		tool.play_tool_sound(parent)
	var/obj/item/bodypart/part = parent
	user.visible_message(
		span_notice("[user] [panel_state ? "откручивает болты и открывает" : "закрывает"] панель доступа [part]."),
		span_notice("Вы [panel_state ? "открыли" : "закрыли"] панель доступа [part].")
	)

// ============================================
// НАСТРОЕНИЕ IPC — нейтральное (без эмоций)
// ============================================

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

// ============================================
// HUD ИНДИКАТОР БАТАРЕИ IPC
// ============================================

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

// ============================================
// УПРАВЛЕНИЕ HUD НА ВИДЕ IPC
// ============================================

/datum/species/ipc/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return
	add_ipc_battery_hud(H)

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
	if(pct <= 0)
		new_state = "no_cell"
	else if(pct <= 10)
		new_state = "empty_cell"
	else if(pct <= 30)
		new_state = "low_cell3"
	else if(pct <= 50)
		new_state = "low_cell2"
	else if(pct <= 75)
		new_state = "low_cell1"
	else
		new_state = "cell_full"
	for(var/atom/movable/screen/ipc_battery_hud/indicator in H.hud_used.infodisplay)
		indicator.icon_state = new_state
