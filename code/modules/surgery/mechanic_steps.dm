//open shell
/datum/surgery_step/mechanic_open
	name = "открутить корпус (отвертка или скальпель)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75, // med borgs could try to unscrew shell with scalpel
		/obj/item/knife = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете откручивать корпус в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает откручивать корпус в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает откручивать корпус в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы ощущаете, как [target.parse_zone_with_bodypart(target_zone)] немеет по мере откручивания сенсорной панели.", TRUE)

/datum/surgery_step/mechanic_open/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "закрутите корпус (отвертка или скальпель)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75,
		/obj/item/knife = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете закручивать корпус в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает закручивать корпус в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает закручивать корпус в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы ощущаете, как начинаете получать показания датчиков из [target.parse_zone_with_bodypart(target_zone, declent = GENITIVE)], после того, как панель закрутили обратно.", TRUE)

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "подготовьте электронику (мультитул или гемостат)"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 75)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете подготовку электроники в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает подготовку электроники в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает подготовку электроники в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете слабое жужжание в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)], когда электроника перезагружается.", TRUE)

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "выкрутите болты (ключ или ретрактор)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 75)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете откручивать болты в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает откручивать болты в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает откручивать болты в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете вибрацию в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)], когда болты начинают ослабевать.", TRUE)

/datum/surgery_step/mechanic_unwrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//wrench
/datum/surgery_step/mechanic_wrench
	name = "закрутите болты (ключ или ретрактор)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 75)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете закручивать болты в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает закручивать болты в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает закручивать болты в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете вибрацию в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)], когда болты начинают затягиваться.", TRUE)

/datum/surgery_step/mechanic_wrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//open hatch
/datum/surgery_step/open_hatch
	name = "откройте люк (рука)"
	accept_hand = TRUE
	time = 1 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	preop_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете открывать люк в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает открывать люк в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает открывать люк в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы получаете последние показания датчиков из вашей [target.parse_zone_with_bodypart(target_zone, declent = GENITIVE)], когда открывается люк.", TRUE)

/datum/surgery_step/open_hatch/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE
