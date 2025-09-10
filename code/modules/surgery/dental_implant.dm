#define MARK_TOOTH 1

/datum/surgery/dental_implant
	name = "Зубное имплантирование"
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	steps = list(
		/datum/surgery_step/drill/pill,
		/datum/surgery_step/insert_pill,
		/datum/surgery_step/search_teeth,
		/datum/surgery_step/close,
	)

/datum/surgery_step/drill/pill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	var/count = 0
	var/obj/item/bodypart/head/teeth_receptangle = target.get_bodypart(BODY_ZONE_HEAD)

	ASSERT(teeth_receptangle)

	for(var/obj/item/reagent_containers/applicator/pill/dental in teeth_receptangle)
		count++

	if(teeth_receptangle.teeth_count == 0)
		to_chat(user, span_notice("[capitalize(target.declent_ru(NOMINATIVE))] не имеет зубов, дурашка!"))
		return SURGERY_STEP_FAIL

	if(count >= teeth_receptangle.teeth_count)
		to_chat(user, span_notice("Все зубы [target.declent_ru(GENITIVE)] уже заменены на таблетки!"))
		return SURGERY_STEP_FAIL

/datum/surgery_step/insert_pill
	name = "вставьте таблетку"
	implements = list(/obj/item/reagent_containers/applicator/pill = 100)
	time = 1.6 SECONDS

/datum/surgery_step/insert_pill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	display_results(
		user,
		target,
		span_notice("Вы начинаете вставлять [tool.declent_ru(ACCUSATIVE)] в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает вставлять [tool.declent_ru(ACCUSATIVE)] в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает вставлять что-то в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Что-то засовывают вам в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)]!")

/datum/surgery_step/insert_pill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/reagent_containers/applicator/pill/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(!istype(tool))
		return FALSE

	// Pills go into head
	user.transferItemToLoc(tool, target.get_bodypart(BODY_ZONE_HEAD), TRUE)

	var/datum/action/item_action/activate_pill/pill_action = new(tool)
	pill_action.name = "Активировать [tool.declent_ru(ACCUSATIVE)]"
	pill_action.build_all_button_icons()
	pill_action.target = tool
	pill_action.Grant(target) //The pill never actually goes in an inventory slot, so the owner doesn't inherit actions from it

	display_results(
		user,
		target,
		span_notice("Вы вставляете [tool.declent_ru(ACCUSATIVE)] в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] вставляет [tool.declent_ru(ACCUSATIVE)] в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] вставляет что-то в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]!"),
	)
	return ..()

/datum/action/item_action/activate_pill
	name = "Активировать таблетку"
	check_flags = NONE

/datum/action/item_action/activate_pill/IsAvailable(feedback)
	if(owner.stat > SOFT_CRIT)
		return FALSE
	return ..()

/datum/action/item_action/activate_pill/do_effect(trigger_flags)
	owner.balloon_alert_to_viewers("[owner.declent_ru(NOMINATIVE)] прикусывает зубы!", "Вы прикусываете зубами.")
	if(!do_after(owner, owner.stat * (2.5 SECONDS), owner,  IGNORE_USER_LOC_CHANGE | IGNORE_INCAPACITATED))
		return FALSE
	var/obj/item/item_target = target
	to_chat(owner, span_notice("Вы стискиваете зубы и ломаете вживленный [item_target.name]!"))
	owner.log_message("проглотил вживленную таблетку, [target]", LOG_ATTACK)
	if(item_target.reagents.total_volume)
		item_target.reagents.trans_to(owner, item_target.reagents.total_volume, transferred_by = owner, methods = INGEST)
	qdel(target)
	return TRUE

/datum/surgery_step/search_teeth
	name = "осмотрите зубы (рука)"
	accept_hand = TRUE
	time = 2 SECONDS
	repeatable = TRUE

/datum/surgery_step/search_teeth/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете осматривать рот [target.declent_ru(GENITIVE)] на подходящие для имплантации зубы..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает вглядываться в рот [target.declent_ru(GENITIVE)]"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает осматривать зубы [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете, как рука касается ваших зубов.")

/datum/surgery_step/search_teeth/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] отмечает зуб во рту [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] отмечает зуб во рту [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] касается зуба во рту [target.declent_ru(GENITIVE)]."),
	)
	surgery.status = MARK_TOOTH
	return ..()

#undef MARK_TOOTH
