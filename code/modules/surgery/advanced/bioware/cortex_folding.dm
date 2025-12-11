/datum/surgery/advanced/bioware/cortex_folding
	name = "Складывание коры"
	desc = "Хирургическая процедура, которая преобразует кору головного мозга в сложную складку, предоставляя пространство для нестандартных нейронных структур."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/fold_cortex,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/cortex/folded

/datum/surgery/advanced/bioware/cortex_folding/mechanic
	name = "Лабиринтное программирование Wetware OS"
	desc = "Роботизированная модернизация, которая перепрограммирует нейронную сеть пациента на совершенно необычном языке программирования, предоставляя пространство для нестандартных нейронных паттернов."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/fold_cortex,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/advanced/bioware/cortex_folding/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/target_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return ..()

/datum/surgery_step/apply_bioware/fold_cortex
	name = "складка коры (рука)"

/datum/surgery_step/apply_bioware/fold_cortex/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете складывать внешнюю кору головного мозга у [target.declent_ru(GENITIVE)] во фрактальный узор."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает складывать внешнюю кору головного мозга у [target.declent_ru(GENITIVE)] во фрактальный узор."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваша голова раскалывается от ужасной боли, с ней почти невозможно справиться!")

/datum/surgery_step/apply_bioware/fold_cortex/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("Вы складываете внешнюю кору головного мозга у [target.declent_ru(GENITIVE)] во фрактальный узор!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] складывает внешнюю кору головного мозга у [target.declent_ru(GENITIVE)] во фрактальный узор!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваш мозг становится сильнее... более гибким!")

/datum/surgery_step/apply_bioware/fold_cortex/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.get_organ_slot(ORGAN_SLOT_BRAIN))
		display_results(
			user,
			target,
			span_warning("Вы ошибаетесь, повреждая мозг!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, нанеся повреждения мозгу!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Голова раскалывается от ужасной боли; от одной мысли об этом уже начинает болеть голова!")
		target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] внезапно замечает, что мозг над которым велась операция, более не здесь."), span_warning("Вы вдруг замечаете, что мозг, над которым вы работали, более не здесь."))
	return FALSE
