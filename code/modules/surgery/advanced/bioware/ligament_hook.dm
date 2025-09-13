/datum/surgery/advanced/bioware/ligament_hook
	name = "Крюк для связок"
	desc = "Хирургическая процедура, которая изменяет форму соединений между туловищем и конечностями, позволяя вручную присоединить конечности в случае их отделения. \
		Однако это ослабляет связь, и конечности также легко отсоединить."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/reshape_ligaments,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/ligaments/hooked

/datum/surgery/advanced/bioware/ligament_hook/mechanic
	name = "Защелкивающиеся точки крепления"
	desc = "Роботизированное усовершенствование, устанавливающее точки быстрого отсоединения, что позволяет вручную прикреплять отсоединенные конечности. \
		Однако это ослабляет соединение, и конечности также легко отсоединить."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/reshape_ligaments,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/apply_bioware/reshape_ligaments
	name = "изменение формы связок (рука)"

/datum/surgery_step/apply_bioware/reshape_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете придавать связкам [target.declent_ru(GENITIVE)] форму крючка."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает перестраивать связки [target.declent_ru(GENITIVE)], придавая им форму крючка."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает манипулировать связками [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваши конечности горят от сильной боли!")

/datum/surgery_step/apply_bioware/reshape_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("Вы придаете связкам [target.declent_ru(GENITIVE)] форму крючка!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] придает связкам [target.declent_ru(GENITIVE)] форму крючка!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] заканчивает манипулирование связками [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваши конечности кажутся... странно свободными.")
