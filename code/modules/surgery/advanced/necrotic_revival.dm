/datum/surgery/advanced/necrotic_revival
	name = "Некротическое возрождение"
	desc = "Экспериментальная хирургическая процедура, стимулирующая рост опухоли ромерола в мозге пациента. Требуется зомби-порошок или резадон."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/bionecrosis,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/necrotic_revival/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	var/obj/item/organ/zombie_infection/z_infection = target.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(z_infection)
		return FALSE

/datum/surgery_step/bionecrosis
	name = "начать бионекроз (шприц)"
	implements = list(
		/obj/item/reagent_containers/syringe = 100,
		/obj/item/pen = 30)
	time = 5 SECONDS
	chems_needed = list(/datum/reagent/toxin/zombiepowder, /datum/reagent/medicine/rezadone)
	require_all_chems = FALSE

/datum/surgery_step/bionecrosis/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете выращивать опухоль ромерола в мозге у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает возиться с мозгом у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваша голова раскалывается от невыразимой боли!") // Same message as other brain surgeries

/datum/surgery_step/bionecrosis/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("Вам удалось вырастить опухоль ромерола в мозге у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно выращивает опухоль ромерола в мозге у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на мозге у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Голова на мгновение полностью немеет, боль невыносима!")
	if(!target.get_organ_slot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/z_infection = new()
		z_infection.Insert(target)
	return ..()
