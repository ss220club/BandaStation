/datum/surgery/autopsy
	name = "Вскрытие"
	surgery_flags = SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/autopsy,
		/datum/surgery_step/close,
	)

/datum/surgery/autopsy/mechanic
	name = "Анализ системного сбоя"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/autopsy,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/autopsy/can_start(mob/user, mob/living/patient)
	if(!..())
		return FALSE
	if(patient.stat != DEAD)
		return FALSE
	if(HAS_TRAIT_FROM(patient, TRAIT_DISSECTED, AUTOPSY_TRAIT))
		return FALSE
	return TRUE

/datum/surgery_step/autopsy
	name = "Проведите вскрытие (сканер аутопсии)"
	implements = list(/obj/item/autopsy_scanner = 100)
	time = 10 SECONDS
	success_sound = 'sound/machines/printer.ogg'

/datum/surgery_step/autopsy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы приступаете к вскрытию [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] использует [tool.declent_ru(ACCUSATIVE)] для вскрытия [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] использует [tool.declent_ru(ACCUSATIVE)] на груди у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете жжение в груди!")

/datum/surgery_step/autopsy/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/autopsy_scanner/tool, datum/surgery/surgery, default_display_results = FALSE)
	ADD_TRAIT(target, TRAIT_DISSECTED, AUTOPSY_TRAIT)
	ADD_TRAIT(target, TRAIT_SURGICALLY_ANALYZED, AUTOPSY_TRAIT)
	tool.scan_cadaver(user, target)
	var/obj/machinery/computer/operating/operating_computer = surgery.locate_operating_computer(get_turf(target))
	if (!isnull(operating_computer))
		SEND_SIGNAL(operating_computer, COMSIG_OPERATING_COMPUTER_AUTOPSY_COMPLETE, target)
	if(HAS_MIND_TRAIT(user, TRAIT_MORBID))
		user.add_mood_event("morbid_dissection_success", /datum/mood_event/morbid_dissection_success)
	return ..()

/datum/surgery_step/autopsy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("Вы ошибаетесь, оставляя ушиб на груди у [target.declent_ru(GENITIVE)]!"),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, оставляя ушиб на груди у [target.declent_ru(GENITIVE)]!"),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается!"),
	)
	target.adjust_brute_loss(5)
