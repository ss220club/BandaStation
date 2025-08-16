//Head surgery to fix the ears organ
/datum/surgery/ear_surgery
	name = "Операция на ушах"
	requires_bodypart_type = NONE
	organ_to_manipulate = ORGAN_SLOT_EARS
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/fix_ears,
		/datum/surgery_step/close,
	)

//fix ears
/datum/surgery_step/fix_ears
	name = "вылечите уши (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_SCREWDRIVER = 45,
		/obj/item/pen = 25)
	time = 6.4 SECONDS

/datum/surgery/ear_surgery/can_start(mob/user, mob/living/carbon/target)
	return target.get_organ_slot(ORGAN_SLOT_EARS) && ..()

/datum/surgery_step/fix_ears/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете лечить уши у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает лечить уши у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на ушах у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете острую боль в голове!")

/datum/surgery_step/fix_ears/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/item/organ/ears/target_ears = target.get_organ_slot(ORGAN_SLOT_EARS)
	display_results(
		user,
		target,
		span_notice("Вы успешно вылечиваете уши у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно вылечивает уши у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на ушах у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Голова кружится, но кажется, что к вам возвращается слух!")
	target_ears.deaf = (20) //deafness works off ticks, so this should work out to about 30-40s
	target_ears.set_organ_damage(0)
	return ..()

/datum/surgery_step/fix_ears/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
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
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] отвлекается, случайно задев мозг у [target.declent_ru(GENITIVE)]! Либо, задел бы его, был бы у [target.declent_ru(GENITIVE)] мозг."),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] отвлекается, случайно задев мозг у [target.declent_ru(GENITIVE)]!"),
		)
		display_pain(target, "Вы чувствуете сильную колющую боль в голове!") // dunno who can feel pain w/o a brain but may as well be consistent.
	return FALSE
