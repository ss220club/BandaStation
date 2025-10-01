/datum/surgery/stomach_pump
	name = "Очистка желудка"
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/stomach_pump,
		/datum/surgery_step/close,
	)

/datum/surgery/stomach_pump/mechanic
	name = "Очистка обработчика нутриментов"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/stomach_pump,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/stomach_pump/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/stomach/target_stomach = target.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(HAS_TRAIT(target, TRAIT_HUSK))
		return FALSE
	if(!target_stomach)
		return FALSE
	return ..()

//Working the stomach by hand in such a way that you induce vomiting.
/datum/surgery_step/stomach_pump
	name = "промойте желудок (рука)"
	accept_hand = TRUE
	repeatable = TRUE
	time = 2 SECONDS
	success_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_step/stomach_pump/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете промывать желудок у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает промывать желудок у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает нажимать на грудь [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете жуткое бурление в желудке! Вас сейчас вырвет!")

/datum/surgery_step/stomach_pump/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		display_results(
			user,
			target,
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] вызывает рвоту у [target_human.declent_ru(GENITIVE)], избавляя желудок от некоторых химикатов!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] вызывает рвоту у [target_human.declent_ru(GENITIVE)], избавляя желудок от некоторых химикатов!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] вызывает рвоту у [target_human.declent_ru(GENITIVE)]!"),
		)
		target_human.vomit((MOB_VOMIT_MESSAGE | MOB_VOMIT_STUN), lost_nutrition = 20, purge_ratio = 0.67) //higher purge ratio than regular vomiting
	return ..()

/datum/surgery_step/stomach_pump/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		display_results(
			user,
			target,
			span_warning("Вы ошибаетесь, оставляя ушиб на груди [target_human.declent_ru(GENITIVE)]!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, оставляя ушиб на груди [target_human.declent_ru(GENITIVE)]!"),
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается!"),
		)
		target_human.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		target_human.adjustBruteLoss(5)
