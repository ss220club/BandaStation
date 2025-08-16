/datum/surgery/eye_surgery
	name = "Операция на глазах"
	requires_bodypart_type = NONE
	organ_to_manipulate = ORGAN_SLOT_EYES
	possible_locs = list(BODY_ZONE_PRECISE_EYES)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/fix_eyes,
		/datum/surgery_step/close,
	)

//fix eyes
/datum/surgery_step/fix_eyes
	name = "восстановите глаза (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_SCREWDRIVER = 45,
		/obj/item/pen = 25)
	time = 6.4 SECONDS

/datum/surgery/eye_surgery/can_start(mob/user, mob/living/carbon/target)
	return target.get_organ_slot(ORGAN_SLOT_EYES) && ..()

/datum/surgery_step/fix_eyes/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете лечить глаза у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает лечить глаза у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на глазах у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете колющую боль в глазах!")

/datum/surgery_step/fix_eyes/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/item/organ/eyes/target_eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно лечит глаза у [target.declent_ru(GENITIVE)]!"), span_notice("Вы успешно лечите глаза у [target.declent_ru(GENITIVE)]."))
	display_results(
		user,
		target,
		span_notice("Вы успешно вылечиваете глаза у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно излечивает глаза у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на глазах у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваше зрение размыто, но кажется, что теперь вы видите немного лучше!")
	target.remove_status_effect(/datum/status_effect/temporary_blindness)
	target.set_eye_blur_if_lower(70 SECONDS) //this will fix itself slowly.
	target_eyes.set_organ_damage(0) // heals nearsightedness and blindness from eye damage
	return ..()

/datum/surgery_step/fix_eyes/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.get_organ_by_type(/obj/item/organ/brain))
		display_results(
			user,
			target,
			span_warning("Вы отвлекаетесь, случайно задевая мозг у [target.declent_ru(GENITIVE)]!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] отвлекается, случайно задевая мозг у [target.declent_ru(GENITIVE)]!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] отвлекается, случайно задевая мозг у [target.declent_ru(GENITIVE)]!"),
		)
		display_pain(target, "Вы чувствуете сильную колющую боль в голове, прямо в мозгу!")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)
	else
		display_results(
			user,
			target,
			span_warning("Вы отвлекаетесь, случайно задев мозг у [target.declent_ru(GENITIVE)]! Либо, задели бы его, был бы у [target.declent_ru(GENITIVE)] мозг."),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] отвлекается, случайно задевая мозг у [target.declent_ru(GENITIVE)]! Если бы, конечно, у [target.declent_ru(GENITIVE)] был бы мозг."),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] отвлекается, случайно задевая мозг у [target.declent_ru(GENITIVE)]!"),
		)
		display_pain(target, "Вы чувствуете сильную колющую боль в голове!") // dunno who can feel pain w/o a brain but may as well be consistent.
	return FALSE
