/datum/surgery/advanced/bioware/ligament_reinforcement
	name = "Укрепление связок"
	desc = "Хирургическая процедура, в ходе которой вокруг соединений туловища и конечностей формируется защитная ткань и костный каркас, предотвращая расчленение. \
		Однако нервные связи в результате этого легче разрываются, что облегчает выведение конечностей из строя при их повреждении."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/reinforce_ligaments,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/ligaments/reinforced

/datum/surgery/advanced/bioware/ligament_reinforcement/mechanic
	name = "Укрепление опорной точки"
	desc = "Хирургическая процедура, в ходе которой к телу пациента добавляются усиленные точки крепления конечностей, предотвращая расчленение. \
		Однако нервные связи в результате этого легче разрываются, что облегчает выведение конечностей из строя при их повреждении."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/reinforce_ligaments,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/apply_bioware/reinforce_ligaments
	name = "укрепить связки (рука)"

/datum/surgery_step/apply_bioware/reinforce_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете укреплять связки [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает укреплять связки [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает манипулировать связками [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваши конечности горят от сильной боли!")

/datum/surgery_step/apply_bioware/reinforce_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("Вы укрепляете связки [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] укрепляет связки [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] заканчивает манипулирование связками [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваши конечности чувствуют себя более защищенными, но также более хрупкими.")
