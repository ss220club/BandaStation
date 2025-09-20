/datum/surgery/advanced/bioware/nerve_splicing
	name = "Сращивание нервов"
	desc = "Хирургическая процедура, которая сращивает нервы пациента, делая их более устойчивыми к оглушению."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/splice_nerves,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/nerves/spliced

/datum/surgery/advanced/bioware/nerve_splicing/mechanic
	name = "Подпрограмма автоматического сброса системы"
	desc = "Роботизированное усовершенствование, которое модернизирует автоматические системы роботизированного пациента, делая их более устойчивыми к оглушению."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/splice_nerves,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/apply_bioware/splice_nerves
	name = "сращивание нервов (рука)"
	time = 15.5 SECONDS

/datum/surgery_step/apply_bioware/splice_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете соединять нервы [target.declent_ru(GENITIVE)]"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает соединять нервы [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает манипулировать нервной системой [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Все ваше тело немеет!")

/datum/surgery_step/apply_bioware/splice_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("Вы успешно сращиваете нервную систему [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно сращивает нервную систему [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает манипулирование нервной системой [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы вновь обретаете чувствительность в своем теле; вам кажется, что все происходит вокруг вас в замедлении!")
