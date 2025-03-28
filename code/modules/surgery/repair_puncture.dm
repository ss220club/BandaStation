
/////BURN FIXING SURGERIES//////

//the step numbers of each of these two, we only currently use the first to switch back and forth due to advancing after finishing steps anyway
#define REALIGN_INNARDS 1
#define WELD_VEINS 2

///// Repair puncture wounds
/datum/surgery/repair_puncture
	name = "Обработка сквозного ранения"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/pierce/bleed
	target_mobtypes = list(/mob/living/carbon)
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/repair_innards,
		/datum/surgery_step/seal_veins,
		/datum/surgery_step/close,
	)

/datum/surgery/repair_puncture/can_start(mob/living/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return .

	var/datum/wound/pierce/bleed/pierce_wound = target.get_bodypart(user.zone_selected).get_wound_type(targetable_wound)
	ASSERT(pierce_wound, "[type] on [target] has no pierce wound when it should have been guaranteed to have one by can_start")
	return pierce_wound.blood_flow > 0

//SURGERY STEPS

///// realign the blood vessels so we can reweld them
/datum/surgery_step/repair_innards
	name = "восстановление кровеносных сосудов (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_SCALPEL = 85,
		TOOL_WIRECUTTER = 40)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	surgery_effects_mood = TRUE

/datum/surgery_step/repair_innards/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/wound/pierce/bleed/pierce_wound = surgery.operated_wound
	if(!pierce_wound)
		user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] ищет у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]."), span_notice("Вы ищете у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]..."))
		return

	if(pierce_wound.blood_flow <= 0)
		to_chat(user, span_notice("У [target.declent_ru(GENITIVE)] нет на [target.ru_p_theirs()] [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] сквозного ранения, которое нуждается в обработке!"))
		surgery.status++
		return

	display_results(
		user,
		target,
		span_notice("Вы начинаете приводить в порядок поврежденные кровеносные сосуды в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает приводить в порядок поврежденные кровеносные сосуды в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает приводить в порядок поврежденные кровеносные сосуды в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете ужасную колющую боль в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]!")

/datum/surgery_step/repair_innards/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/pierce/bleed/pierce_wound = surgery.operated_wound
	if(!pierce_wound)
		to_chat(user, span_warning("У [target.declent_ru(GENITIVE)] нет на [target.ru_p_theirs()] [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] сквозного ранения, которое нуждается в обработке!"))
		return ..()

	display_results(
		user,
		target,
		span_notice("Вы успешно восстанавливаете некоторые кровеносные сосуды в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает некоторые кровеносные сосуды в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает некоторые кровеносные сосуды в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]!"),
	)
	log_combat(user, target, "realigned blood vessels in", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
	target.apply_damage(3, BRUTE, surgery.operated_bodypart, wound_bonus = CANT_WOUND, sharpness = SHARP_EDGED, attacking_item = tool)
	pierce_wound.adjust_blood_flow(-0.25)
	return ..()

/datum/surgery_step/repair_innards/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	. = ..()
	display_results(
		user,
		target,
		span_notice("Вы повреждаете некоторые кровеносные сосуды в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] повреждает некоторые кровеносные сосуды в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] повреждает некоторые кровеносные сосуды в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]!"),
	)
	target.apply_damage(rand(4, 8), BRUTE, surgery.operated_bodypart, wound_bonus = 10, sharpness = SHARP_EDGED, attacking_item = tool)

///// Sealing the vessels back together
/datum/surgery_step/seal_veins
	name = "проведите венозное сваривание (каутеризатор)" // if your doctor says they're going to weld your blood vessels back together, you're either A) on SS13, or B) in grave mortal peril
	implements = list(
		TOOL_CAUTERY = 100,
		/obj/item/gun/energy/laser = 90,
		TOOL_WELDER = 70,
		/obj/item = 30)
	time = 4 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'

/datum/surgery_step/seal_veins/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.get_temperature()

	return TRUE

/datum/surgery_step/seal_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/wound/pierce/bleed/pierce_wound = surgery.operated_wound
	if(!pierce_wound)
		user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] ищет у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]."), span_notice("Вы ищете у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]..."))
		return
	display_results(
		user,
		target,
		span_notice("Вы начинаете восстанавливать некоторые из поврежденных кровеносных сосудов в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает восстанавливать некоторые из поврежденных кровеносных сосудов в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает восстанавливать некоторые из поврежденных кровеносных сосудов в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] все горит!")

/datum/surgery_step/seal_veins/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/pierce/bleed/pierce_wound = surgery.operated_wound
	if(!pierce_wound)
		to_chat(user, span_warning("У [target.declent_ru(GENITIVE)] нет на [target.ru_p_theirs()] [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] сквозного ранения!"))
		return ..()

	display_results(
		user,
		target,
		span_notice("Вы успешно восстанавливаете некоторые из поврежденных кровеносных сосудов в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает некоторые из поврежденных кровеносных сосудов в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает некоторые из поврежденных кровеносных сосудов в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]!"),
	)
	log_combat(user, target, "dressed burns in", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
	pierce_wound.adjust_blood_flow(-0.5)
	if(!QDELETED(pierce_wound) && pierce_wound.blood_flow > 0)
		surgery.status = REALIGN_INNARDS
		to_chat(user, span_notice("<i>Кажется, что кровеносные сосуды все еще смещены...</i>"))
	else
		to_chat(user, span_green("Вы восстанавливаете все внутренние повреждения в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]!"))
	return ..()

#undef REALIGN_INNARDS
#undef WELD_VEINS
