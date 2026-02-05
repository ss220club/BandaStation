// ============================================
// БАЗОВЫЕ ЧАСТИ ТЕЛА IPC С ПРАВИЛЬНЫМИ ИКОНКАМИ
// ============================================

/obj/item/bodypart/chest/ipc
	name = "IPC chassis"
	desc = "Основной корпус IPC, содержащий все жизненно важные системы."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_chest_m"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	is_dimorphic = TRUE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 120

	var/chassis_type = "Unbranded"

	// Модификаторы урона от шасси
	var/brute_reduction = 0  // Процент редукции brute урона (0.3 = 30% меньше урона)
	var/burn_reduction = 0   // Процент редукции burn урона (0.3 = 30% меньше урона)

/obj/item/bodypart/chest/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)

/obj/item/bodypart/chest/ipc/examine(mob/user)
	. = ..()
	var/datum/component/ipc_panel/panel = GetComponent(/datum/component/ipc_panel)
	if(panel)
		if(panel.panel_state == 1) // IPC_PANEL_OPEN
			. += span_notice("Панель доступа открыта.")
		else
			. += span_notice("Панель доступа закрыта.")

/obj/item/bodypart/chest/ipc/drop_organs(mob/user, violent_removal)
	. = ..()
	var/atom/drop_location = get_atom_on_turf(src)
	for(var/obj/item/organ/internal_organ in contents)
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)

// ============================================
// ГОЛОВА
// ============================================

/obj/item/bodypart/head/ipc
	name = "IPC head"
	desc = "Голова IPC с оптическими и аудио сенсорами."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_head"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	head_flags = HEAD_LIPS|HEAD_DEBRAIN
	is_dimorphic = FALSE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 80

	var/screen_icon = "BSOD"
	var/antenna_type = "None"

	// Модификаторы урона от шасси
	var/brute_reduction = 0
	var/burn_reduction = 0

/obj/item/bodypart/head/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)

/obj/item/bodypart/head/ipc/examine(mob/user)
	. = ..()
	var/datum/component/ipc_panel/panel = GetComponent(/datum/component/ipc_panel)
	if(panel)
		if(panel.panel_state == 1)
			. += span_notice("Панель доступа открыта.")
		else
			. += span_notice("Панель доступа закрыта.")

/obj/item/bodypart/head/ipc/drop_organs(mob/user, violent_removal)
	. = ..()
	var/atom/drop_location = get_atom_on_turf(src)
	for(var/obj/item/organ/internal_organ in contents)
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)

// ============================================
// ЛЕВАЯ РУКА
// ============================================

/obj/item/bodypart/arm/left/ipc
	name = "IPC left arm"
	desc = "Левая рука IPC."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_l_arm"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	var/grip_strength = 1.0

	// Модификаторы урона от шасси
	var/brute_reduction = 0
	var/burn_reduction = 0

// ============================================
// ПРАВАЯ РУКА
// ============================================

/obj/item/bodypart/arm/right/ipc
	name = "IPC right arm"
	desc = "Правая рука IPC."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_r_arm"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	var/grip_strength = 1.0

	// Модификаторы урона от шасси
	var/brute_reduction = 0
	var/burn_reduction = 0

// ============================================
// ЛЕВАЯ НОГА
// ============================================

/obj/item/bodypart/leg/left/ipc
	name = "IPC left leg"
	desc = "Левая нога IPC."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_l_leg"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	// Модификаторы урона от шасси
	var/brute_reduction = 0
	var/burn_reduction = 0

// ============================================
// ПРАВАЯ НОГА
// ============================================

/obj/item/bodypart/leg/right/ipc
	name = "IPC right leg"
	desc = "Правая нога IPC."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_r_leg"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	// Модификаторы урона от шасси
	var/brute_reduction = 0
	var/burn_reduction = 0

// ============================================
// УРОН И СПАРКИ
// ============================================

/obj/item/bodypart/chest/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	// Применяем редукцию урона от шасси
	if(brute_reduction > 0)
		brute = brute * (1 - brute_reduction)
	if(burn_reduction > 0)
		burn = burn * (1 - burn_reduction)

	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/head/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	// Применяем редукцию урона от шасси
	if(brute_reduction > 0)
		brute = brute * (1 - brute_reduction)
	if(burn_reduction > 0)
		burn = burn * (1 - burn_reduction)

	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/arm/left/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	// Применяем редукцию урона от шасси
	if(brute_reduction > 0)
		brute = brute * (1 - brute_reduction)
	if(burn_reduction > 0)
		burn = burn * (1 - burn_reduction)

	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/arm/right/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	// Применяем редукцию урона от шасси
	if(brute_reduction > 0)
		brute = brute * (1 - brute_reduction)
	if(burn_reduction > 0)
		burn = burn * (1 - burn_reduction)

	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/leg/left/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	// Применяем редукцию урона от шасси
	if(brute_reduction > 0)
		brute = brute * (1 - brute_reduction)
	if(burn_reduction > 0)
		burn = burn * (1 - burn_reduction)

	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/leg/right/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	// Применяем редукцию урона от шасси
	if(brute_reduction > 0)
		brute = brute * (1 - brute_reduction)
	if(burn_reduction > 0)
		burn = burn * (1 - burn_reduction)

	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

// ============================================
// ПРИСОЕДИНЕНИЕ КОНЕЧНОСТЕЙ
// ============================================

/obj/item/bodypart/chest/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	playsound(get_turf(H), 'sound/items/deconstruct.ogg', 50, TRUE)
	do_sparks(2, TRUE, H)
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/head/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	playsound(get_turf(H), 'sound/items/deconstruct.ogg', 50, TRUE)
	do_sparks(2, TRUE, H)
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/arm/left/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	playsound(get_turf(H), 'sound/items/deconstruct.ogg', 50, TRUE)
	do_sparks(2, TRUE, H)
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/arm/right/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	playsound(get_turf(H), 'sound/items/deconstruct.ogg', 50, TRUE)
	do_sparks(2, TRUE, H)
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/leg/left/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	playsound(get_turf(H), 'sound/items/deconstruct.ogg', 50, TRUE)
	do_sparks(2, TRUE, H)
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/leg/right/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	playsound(get_turf(H), 'sound/items/deconstruct.ogg', 50, TRUE)
	do_sparks(2, TRUE, H)
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE
