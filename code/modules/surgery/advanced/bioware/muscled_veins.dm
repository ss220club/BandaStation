/datum/surgery/advanced/bioware/muscled_veins
	name = "Мышечная мембрана вены"
	desc = "Хирургическая процедура, в ходе которой к кровеносным сосудам добавляется мышечная мембрана, позволяющая им перекачивать кровь без участия сердца."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/muscled_veins,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/heart/muscled_veins

/datum/surgery/advanced/bioware/muscled_veins/mechanic
	name = "Подпрограмма резервирования гидравлики"
	desc = "Роботизированная модернизация, которая дополняет сложную гидравлику, позволяя пациенту перекачивать гидравлическую жидкость без использования двигателя."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/muscled_veins,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/apply_bioware/muscled_veins
	name = "формирование мышцы вен (рука)"

/datum/surgery_step/apply_bioware/muscled_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете обматывать мышцами кровеносную систему [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает обматывать мышцами кровеносную систему [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает манипулировать кровеносной системой [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Все ваше тело горит в агонии!")

/datum/surgery_step/apply_bioware/muscled_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("Вы изменяете кровеносную систему [target.declent_ru(GENITIVE)], добавляя мышечную мембрану!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] изменяет кровеносную систему [target.declent_ru(GENITIVE)], добавляя мышечную мембрану!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] заканчивает манипулировать кровеносной системой [target.declent_ru(GENITIVE)]"),
	)
	display_pain(target, "Вы можете чувствовать, как мощные удары вашего сердца разносятся по всему телу!")
