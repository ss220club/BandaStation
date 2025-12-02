/obj/item/disk/surgery/brainwashing
	name = "Диск для операции по промыванию мозгов"
	desc = "Диск содержит инструкции о том, как запечатлеть приказ в мозгу, что делает его основной задачей пациента."
	surgeries = list(
		/datum/surgery/advanced/brainwashing,
		/datum/surgery/advanced/brainwashing/mechanic,
	)

/datum/surgery/advanced/brainwashing
	name = "Промывание мозгов"
	desc = "Хирургическая процедура, которая непосредственно внедряет директиву в мозг пациента, делая её абсолютно приоритетной. Её можно удалить с помощью импланта защиты разума."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/brainwash,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/brainwashing/mechanic
	name = "Перепрограммирование"
	desc = "Вредоносное ПО, которое напрямую внедряет директиву в операционную систему робота-пациента, делая её абсолютным приоритетом. Его можно удалить с помощью импланта защиты разума."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/brainwash/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/advanced/brainwashing/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/target_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return TRUE

/datum/surgery_step/brainwash
	name = "промывание мозгов (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 85,
		TOOL_WIRECUTTER = 50,
		/obj/item/stack/package_wrap = 35,
		/obj/item/stack/cable_coil = 15)
	time = 20 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	var/objective

/datum/surgery_step/brainwash/mechanic
	name = "перепрограммирование (мультитул)"
	implements = list(
		TOOL_MULTITOOL = 85,
		TOOL_HEMOSTAT = 50,
		TOOL_WIRECUTTER = 50,
		/obj/item/stack/package_wrap = 35,
		/obj/item/stack/cable_coil = 15)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_step/brainwash/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	objective = tgui_input_text(user, "Выберите цель, которую вы хотите запечатлеть в мозгу жертвы.", "Промывание мозгов", max_length = MAX_MESSAGE_LEN)
	if(!objective)
		return SURGERY_STEP_FAIL
	display_results(
		user,
		target,
		span_notice("Вы начинаете промывать мозги [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает восстанавливать мозг у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваша голова раскалывается от невыразимой боли!") // Same message as other brain surgeries

/datum/surgery_step/brainwash/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(!target.mind)
		to_chat(user, span_warning("[target.declent_ru(GENITIVE)] не реагирует на промывание мозгов, как будто [target.p_they()] лишен разума..."))
		return FALSE
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE))
		to_chat(user, span_warning("Вы слышите слабое жужжание от устройства внутри мозга [target.declent_ru(GENITIVE)], и результаты промывание мозгов стираются."))
		return FALSE
	display_results(
		user,
		target,
		span_notice("Вам удалось промыть мозги [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает мозг у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	to_chat(target, span_userdanger("Новое побуждение заполняет ваш разум... вы чувствуете, что вынуждены подчиняться ему!"))
	brainwash(target, objective)
	message_admins("[ADMIN_LOOKUPFLW(user)] хирургически промыл мозги [ADMIN_LOOKUPFLW(target)] с целью '[objective]'.")
	user.log_message("промыл мозги [key_name(target)] с целью '[objective]', используя операцию по промыванию мозгов.", LOG_ATTACK)
	target.log_message("был подвергнут промыванию мозгов с целью '[objective]' пользователем [key_name(user)], применив хирургическую операцию по промыванию мозгов.", LOG_VICTIM, log_globally=FALSE)
	user.log_message("хирургически промытые мозги [key_name(target)] с целью '[objective]'.", LOG_GAME)
	return ..()

/datum/surgery_step/brainwash/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.get_organ_slot(ORGAN_SLOT_BRAIN))
		display_results(
			user,
			target,
			span_warning("Вы ошибаетесь, повреждая мозговую ткань!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, нанеся повреждения мозгу!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Голова раскалывается от ужасной боли!")
		target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 40)
	else
		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] внезапно замечает, что мозг над которым велась операция, более не здесь."), span_warning("Вы вдруг замечаете, что мозг, над которым вы работали, более не здесь."))
	return FALSE
