/datum/surgery/hepatectomy
	name = "Гепатэктомия"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	organ_to_manipulate = ORGAN_SLOT_LIVER
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/hepatectomy,
		/datum/surgery_step/close,
	)

/datum/surgery/hepatectomy/mechanic
	name = "Диагностика системы очистки"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/hepatectomy/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/hepatectomy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/liver/target_liver = target.get_organ_slot(ORGAN_SLOT_LIVER)
	if(isnull(target_liver) || target_liver.damage < 50 || target_liver.operated)
		return FALSE
	return ..()

////hepatectomy, removes damaged parts of the liver so that the liver may regenerate properly
//95% chance of success, not 100 because organs are delicate
/datum/surgery_step/hepatectomy
	name = "удалите поврежденный участок печени (скальпель)"
	implements = list(
		TOOL_SCALPEL = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35)
	time = 5.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	surgery_effects_mood = TRUE

/datum/surgery_step/hepatectomy/mechanic
	name = "проведите обслуживание (скальпель или кусачки)"
	implements = list(
		TOOL_SCALPEL = 95,
		TOOL_WRENCH = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/hepatectomy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете вырезать поврежденную часть печени у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает делать надрез у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает делать надрез у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваша брюшная полость горит от ужасной колющей боли!")

/datum/surgery_step/hepatectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/liver/target_liver = target.get_organ_slot(ORGAN_SLOT_LIVER)
	human_target.setOrganLoss(ORGAN_SLOT_LIVER, 10) //not bad, not great
	if(target_liver)
		target_liver.operated = TRUE
		if(target_liver.organ_flags & ORGAN_EMP) //If our organ is failing due to an EMP, fix that
			target_liver.organ_flags &= ~ORGAN_EMP
	display_results(
		user,
		target,
		span_notice("Вы успешно удаляете поврежденную часть печени у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно удаляет поврежденную часть печени у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно удаляет поврежденную часть печени у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Боль немного стихает.")
	return ..()

/datum/surgery_step/hepatectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	var/mob/living/carbon/human/human_target = target
	human_target.adjustOrganLoss(ORGAN_SLOT_LIVER, 15)
	display_results(
		user,
		target,
		span_warning("Вы удаляете не ту часть печени у [target.declent_ru(GENITIVE)]!"),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] удаляет не ту часть печени у [target.declent_ru(GENITIVE)]!"),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] удаляет не ту часть печени у [target.declent_ru(GENITIVE)]!"),
	)
	display_pain(target, "Вы чувствуете острую боль в брюшной полости!")
