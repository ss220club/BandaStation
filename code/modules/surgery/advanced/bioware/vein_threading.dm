/datum/surgery/advanced/bioware/vein_threading
	name = "Венозная нить"
	desc = "Хирургическая процедура, которая значительно уменьшает количество крови, теряемой в случае травмы."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/thread_veins,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/heart/threaded_veins

/datum/surgery/advanced/bioware/vein_threading/mechanic
	name = "Оптимизация маршрутизации гидравлики"
	desc = "Роботизированная модернизация, которая значительно сокращает количество гидравлической жидкости, теряемой в случае травмы."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/thread_veins,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/apply_bioware/thread_veins
	name = "нитевидные вены (рука)"

/datum/surgery_step/apply_bioware/thread_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете плести кровеносную систему [target.declent_ru(GENITIVE)]"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает плести кровеносную систему [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает манипулировать кровеносной системой [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Все твое тело горит в агонии!")

/datum/surgery_step/apply_bioware/thread_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("Вы сплетаете кровеносную систему [target.declent_ru(GENITIVE)] в прочную сеть!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] сплетает кровеносную систему [target.declent_ru(GENITIVE)] в прочную сеть!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает манипуляцию кровеносной системой [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы можете почувствовать, как кровь движется по усиленным венам!")
