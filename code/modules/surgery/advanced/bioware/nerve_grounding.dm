/datum/surgery/advanced/bioware/nerve_grounding
	name = "Заземление нервов"
	desc = "Хирургическая процедура, в ходе которой нервы пациента действуют как заземляющие стержни, защищая их от поражения электрическим током."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/ground_nerves,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/nerves/grounded

/datum/surgery/advanced/bioware/nerve_grounding/mechanic
	name = "Система гашения ударов"
	desc = "Роботизированная модернизация, которая устанавливает заземляющие стержни в систему роботизированного пациента, защищая его от поражения электрическим током."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/ground_nerves,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/apply_bioware/ground_nerves
	name = "заземление нервов (рука)"
	time = 15.5 SECONDS

/datum/surgery_step/apply_bioware/ground_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете перенаправлять нервы [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает перенаправлять нервы [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает манипулировать нервной системой [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Все ваше тело немеет!")

/datum/surgery_step/apply_bioware/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("Вы успешно перенаправляете нервную систему [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно перенаправляет нервную систему [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает манипулирование нервной системой [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы возвращаете своему телу ощущение свежести! Вы чувствуете прилив сил!")
	return ..()
