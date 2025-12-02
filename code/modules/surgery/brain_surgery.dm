/datum/surgery/brain_surgery
	name = "Операция на мозге"
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/fix_brain,
		/datum/surgery_step/close,
	)

/datum/surgery/brain_surgery/mechanic
	name = "Диагностика Wetware OS"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/fix_brain/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/fix_brain
	name = "проведите коррекцию мозговой функции (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 85,
		TOOL_SCREWDRIVER = 35,
		/obj/item/pen = 15) //don't worry, pouring some alcohol on their open brain will get that chance to 100
	repeatable = TRUE
	time = 100 //long and complicated
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_step/fix_brain/mechanic
	name = "проведите нейрологическую отладку (гемостат или мультитул)"
	implements = list(
		TOOL_HEMOSTAT = 85,
		TOOL_MULTITOOL = 85,
		TOOL_SCREWDRIVER = 35,
		/obj/item/pen = 15)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery/brain_surgery/can_start(mob/user, mob/living/carbon/target)
	return target.get_organ_slot(ORGAN_SLOT_BRAIN) && ..()

/datum/surgery_step/fix_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете восстанавливать мозг у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает восстанавливать мозг у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваша голова раскалывается от невыразимой боли!")

/datum/surgery_step/fix_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("Вы успешно восстанавливаете функции мозга у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает функции мозга у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Боль в голове утихает, мыслить становится немного легче!")
	if(target.mind?.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	target.set_organ_loss(ORGAN_SLOT_BRAIN, target.get_organ_loss(ORGAN_SLOT_BRAIN) - 50) //we set damage in this case in order to clear the "failing" flag
	target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	if(target.get_organ_loss(ORGAN_SLOT_BRAIN) > 0)
		to_chat(user, "Мозг у [target.declent_ru(GENITIVE)] выглядит так, будто его дальнейшее восстановление возможно.")
	return ..()

/datum/surgery_step/fix_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.get_organ_slot(ORGAN_SLOT_BRAIN))
		display_results(
			user,
			target,
			span_warning("Вы ошибаетесь, нанеся ещё больше повреждений!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, нанеся повреждения мозгу!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Голова раскалывается от ужасной боли; от одной мысли об этом уже начинает болеть голова!")
		target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] внезапно замечает, что мозг над которым велась операция, более не здесь."), span_warning("Вы вдруг замечаете, что мозг, над которым вы работали, более не здесь."))
	return FALSE
