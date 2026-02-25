// ============================================
// НАНОПАСТА ДЛЯ ПРОТЕЗОВ И IPC
// Лечит роботизированные части тела от brute и burn урона.
// Работает на протезах и любом IPC шасси.
// ============================================

/obj/item/stack/medical/nanopaste
	name = "нанопаста"
	singular_name = "нанопаста"
	desc = "Универсальная нанопаста для ремонта роботизированных частей тела. Восстанавливает механические и термические повреждения протезов, а также КПБ любого бренда."
	icon = 'modular_bandastation/MachAImpDe/icons/stack_medical.dmi'
	icon_state = "nanopaste"
	lefthand_file = 'modular_bandastation/MachAImpDe/icons/implants_lefthand.dmi'
	righthand_file = 'modular_bandastation/MachAImpDe/icons/implants_righthand.dmi'
	worn_icon_state = "nanopaste"
	amount = 5
	max_amount = 5
	w_class = WEIGHT_CLASS_TINY
	heal_brute = 30
	heal_burn = 30
	self_delay = 4 SECONDS
	other_delay = 2 SECONDS
	repeating = TRUE
	apply_verb = "ремонтируем"
	merge_type = /obj/item/stack/medical/nanopaste

/// Нанопаста работает только на роботизированных конечностях
/obj/item/stack/medical/nanopaste/can_heal(mob/living/patient, mob/living/user, healed_zone, silent = FALSE)
	if(!iscarbon(patient))
		return FALSE
	var/mob/living/carbon/C = patient
	var/obj/item/bodypart/affecting = C.get_bodypart(healed_zone)
	if(!affecting)
		if(!silent)
			patient.balloon_alert(user, "нет конечности!")
		return FALSE
	if(IS_ORGANIC_LIMB(affecting))
		if(!silent)
			patient.balloon_alert(user, "только для роботизированных частей!")
		return FALSE
	return TRUE

/// Переопределяем try_heal_checks чтобы принимать роботизированные конечности
/obj/item/stack/medical/nanopaste/try_heal_checks(mob/living/patient, mob/living/user, healed_zone, silent = FALSE)
	if(!(healed_zone in patient.get_all_limbs()))
		healed_zone = BODY_ZONE_CHEST

	if(!can_heal(patient, user, healed_zone, silent))
		return FALSE

	if(!works_on_dead && patient.stat == DEAD)
		if(!silent)
			patient.balloon_alert(user, "мёртв!")
		return FALSE

	if(!iscarbon(patient))
		return FALSE

	var/mob/living/carbon/C = patient
	var/obj/item/bodypart/affecting = C.get_bodypart(healed_zone)
	if(!affecting)
		if(!silent)
			C.balloon_alert(user, "отсутствует [parse_zone(healed_zone, NOMINATIVE)]!")
		return FALSE

	// Роботизированная конечность должна быть повреждена
	if(affecting.brute_dam <= 0 && affecting.burn_dam <= 0)
		if(!silent)
			C.balloon_alert(user, "[affecting.plaintext_zone] не повреждена!")
		return FALSE

	return TRUE

/// Лечение роботизированной конечности нанопастой
/obj/item/stack/medical/nanopaste/heal_carbon(mob/living/carbon/patient, mob/living/user, healed_zone)
	var/obj/item/bodypart/affecting = patient.get_bodypart(healed_zone)
	user.visible_message(
		span_green("[user] наносит [src.declent_ru(ACCUSATIVE)] на [affecting.plaintext_zone] у [patient.declent_ru(GENITIVE)]."),
		span_green("Вы наносите [src.declent_ru(ACCUSATIVE)] на [affecting.plaintext_zone] у [patient.declent_ru(GENITIVE)]."),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)
	if(affecting.heal_damage(heal_brute, heal_burn))
		patient.update_damage_overlays()
	post_heal_effects(0, patient, user)
	return TRUE

/// Не работает на простых мобах (только на частях тела)
/obj/item/stack/medical/nanopaste/heal_simplemob(mob/living/patient, mob/living/user)
	patient.balloon_alert(user, "только для роботизированных частей тела!")
	return FALSE
