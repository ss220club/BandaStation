/datum/surgery/advanced/bioware/cortex_imprint
	name = "Отпечаток коры"
	desc = "Хирургическая процедура, которая преобразует кору головного мозга в избыточную нейронную структуру, позволяя мозгу обходить препятствия, вызванные незначительными травмами головного мозга."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/imprint_cortex,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/cortex/imprinted

/datum/surgery/advanced/bioware/cortex_imprint/mechanic
	name = "Wetware OS Версия 2.0"
	desc = "Роботизированная модернизация, которая обновляет операционную систему пациента до 'последней версии', что бы это ни значило, позволяя мозгу обходить повреждения, вызванные незначительными травмами головного мозга. \
		Жаль, что все это рекламное ПО."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/imprint_cortex,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/advanced/bioware/cortex_imprint/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/target_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return ..()

/datum/surgery_step/apply_bioware/imprint_cortex
	name = "отпечаток коры (рука)"

/datum/surgery_step/apply_bioware/imprint_cortex/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете вырезать на внешней коре головного мозга [target.declent_ru(GENITIVE)] самопечатающийся шаблон."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает вырезать на внешней коре головного мозга [target.declent_ru(GENITIVE)] самопечатающийся шаблон."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на мозге [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваша голова раскалывается от ужасной боли, с ней почти невозможно справиться!")

/datum/surgery_step/apply_bioware/imprint_cortex/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("Вы преобразуете внешнюю кору головного мозга [target.declent_ru(GENITIVE)] в самопечатающийся шаблон!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] перестраивает внешнюю кору головного мозга [target.declent_ru(GENITIVE)] в самопечатающийся шаблон!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваш мозг становится сильнее... более устойчивым!")

/datum/surgery_step/apply_bioware/imprint_cortex/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.get_organ_slot(ORGAN_SLOT_BRAIN))
		display_results(
			user,
			target,
			span_warning("Вы ошибаетесь, повреждая мозг!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, нанеся повреждения мозгу!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Голова раскалывается от ужасной боли; от одной мысли об этом уже начинает болеть голова!")
		target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] внезапно замечает, что мозг над которым велась операция, более не здесь."), span_warning("Вы вдруг замечаете, что мозг, над которым вы работали, более не здесь."))
	return FALSE
