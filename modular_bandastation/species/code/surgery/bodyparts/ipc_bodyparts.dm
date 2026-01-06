// ============================================
// БАЗОВЫЕ ЧАСТИ ТЕЛА IPC
// ============================================

/obj/item/bodypart/chest/ipc
	name = "IPC chassis"
	desc = "Основной корпус IPC, содержащий все жизненно важные системы."
	icon_greyscale  = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	is_dimorphic = TRUE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC

	max_damage = 120

	var/chassis_type = "Unbranded"

/obj/item/bodypart/chest/ipc/drop_organs(mob/user, violent_removal)
	var/atom/drop_location = drop_location()

	for(var/obj/item/organ/internal_organ in contents)
		if(!istype(internal_organ, /obj/item/organ))
			continue
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)

	return ..()

// ============================================
// ГОЛОВА
// ============================================

/obj/item/bodypart/head/ipc
	name = "IPC head"
	desc = "Голова IPC с оптическими и аудио сенсорами."
	icon_greyscale  = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	head_flags = HEAD_LIPS|HEAD_DEBRAIN
	is_dimorphic = FALSE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC

	max_damage = 80

	var/screen_icon = "BSOD"
	var/antenna_type = "None"

/obj/item/bodypart/head/ipc/drop_organs(mob/user, violent_removal)
	var/atom/drop_location = drop_location()

	for(var/obj/item/organ/internal_organ in contents)
		if(!istype(internal_organ, /obj/item/organ))
			continue
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)

	return ..()

// ============================================
// ЛЕВАЯ РУКА
// ============================================

/obj/item/bodypart/arm/left/ipc
	name = "IPC left arm"
	desc = "Левая рука IPC."
	icon_greyscale  = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC

	max_damage = 70

	var/grip_strength = 1.0

// ============================================
// ПРАВАЯ РУКА
// ============================================

/obj/item/bodypart/arm/right/ipc
	name = "IPC right arm"
	desc = "Правая рука IPC."
	icon_greyscale  = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC

	max_damage = 70

	var/grip_strength = 1.0

// ============================================
// ЛЕВАЯ НОГА
// ============================================

/obj/item/bodypart/leg/left/ipc
	name = "IPC left leg"
	desc = "Левая нога IPC."
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC

	max_damage = 70

// ============================================
// ПРАВАЯ НОГА
// ============================================

/obj/item/bodypart/leg/right/ipc
	name = "IPC right leg"
	desc = "Правая нога IPC."
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC

	max_damage = 70

// ============================================
// ЛЕВАЯ РУКА (АЛЬТ ДЛЯ РУК)
// ============================================

/obj/item/bodypart/arm/left/ipc/update_limb(dropping_limb, is_creating)
	. = ..()

	if(!owner)
		return

	// Обновляем визуал в зависимости от шасси
	if(istype(owner.dna.species, /datum/species/ipc))
		// Здесь будет логика для разных шасси (Приоритет 4)
		return

// ============================================
// СОЗДАНИЕ ТЕЛА IPC
// ============================================

/datum/species/ipc/proc/create_ipc_body(mob/living/carbon/human/H)
	// Заменяем все части тела на IPC версии
	var/obj/item/bodypart/old_part
	var/obj/item/bodypart/new_part

	// Грудь
	old_part = H.get_bodypart(BODY_ZONE_CHEST)
	if(old_part)
		old_part.drop_limb()
		qdel(old_part)
	new_part = new /obj/item/bodypart/chest/ipc()
	new_part.replace_limb(H, TRUE)

	// Голова
	old_part = H.get_bodypart(BODY_ZONE_HEAD)
	if(old_part)
		old_part.drop_limb()
		qdel(old_part)
	new_part = new /obj/item/bodypart/head/ipc()
	new_part.replace_limb(H, TRUE)

	// Левая рука
	old_part = H.get_bodypart(BODY_ZONE_L_ARM)
	if(old_part)
		old_part.drop_limb()
		qdel(old_part)
	new_part = new /obj/item/bodypart/arm/left/ipc()
	new_part.replace_limb(H, TRUE)

	// Правая рука
	old_part = H.get_bodypart(BODY_ZONE_R_ARM)
	if(old_part)
		old_part.drop_limb()
		qdel(old_part)
	new_part = new /obj/item/bodypart/arm/right/ipc()
	new_part.replace_limb(H, TRUE)

	// Левая нога
	old_part = H.get_bodypart(BODY_ZONE_L_LEG)
	if(old_part)
		old_part.drop_limb()
		qdel(old_part)
	new_part = new /obj/item/bodypart/leg/left/ipc()
	new_part.replace_limb(H, TRUE)

	// Правая нога
	old_part = H.get_bodypart(BODY_ZONE_R_LEG)
	if(old_part)
		old_part.drop_limb()
		qdel(old_part)
	new_part = new /obj/item/bodypart/leg/right/ipc()
	new_part.replace_limb(H, TRUE)

// ============================================
// ОСОБЕННОСТИ ПОВРЕЖДЕНИЙ КОНЕЧНОСТЕЙ
// ============================================

/obj/item/bodypart/chest/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	. = ..()

	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)

	if(get_damage() >= max_damage * 0.8)
		if(owner && prob(20))
			to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]! Риск отказа системы!"))

/obj/item/bodypart/head/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/arm/left/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/arm/right/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/leg/left/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

/obj/item/bodypart/leg/right/ipc/receive_damage(brute, burn, blocked, updating_health, required_bodytype, forced, attack_direction, damage_source, wound_clothing, sharpness, wound_bonus, bare_wound_bonus, exposed_wound_bonus)
	. = ..()
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

// ============================================
// ЛЕГКОЕ ПРИСОЕДИНЕНИЕ КОНЕЧНОСТЕЙ
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
