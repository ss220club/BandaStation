/datum/surgery/advanced/pacify
	name = "Пацификация"
	desc = "Хирургическая процедура, которая навсегда подавляет центр агрессии в мозге, лишая пациента желания причинять прямой вред."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/pacify,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/pacify/mechanic
	name = "Программирование подавления агрессии"
	desc = "Вредоносное ПО, которое навсегда подавляет агрессивное программирование нейронной сети пациента, лишая его желания причинять прямой вред."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/pacify/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/advanced/pacify/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	var/obj/item/organ/brain/target_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE

/datum/surgery_step/pacify
	name = "перепрограммирование мозга (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_SCREWDRIVER = 35,
		/obj/item/pen = 15,
	)
	time = 4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_step/pacify/mechanic
	name = "программирование удаления агрессии (мультитул)"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 35,
		TOOL_SCREWDRIVER = 35,
		/obj/item/pen = 15,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_step/pacify/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете умиротворять [target.declent_ru(ACCUSATIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает восстанавливать мозг у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваша голова раскалывается от невыразимой боли!")

/datum/surgery_step/pacify/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("Вам удается неврологически успокоить [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает функции мозга у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Голова раскалывается... мысль о насилии вспыхивает в вашей голове, и вас чуть не стошнило!")
	target.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY)
	return ..()

/datum/surgery_step/pacify/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы ошибаетесь, перепрограммировав мозг у [target.declent_ru(GENITIVE)] неправильно..."),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, нанеся повреждения мозгу!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Голова раскалывается, и кажется, что становится все хуже!")
	target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	return FALSE
