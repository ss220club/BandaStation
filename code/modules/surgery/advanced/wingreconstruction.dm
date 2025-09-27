/datum/surgery/advanced/wing_reconstruction
	name = "Реконструкция крыльев"
	desc = "Экспериментальная хирургическая процедура по восстановлению повреждённых крыльев молей. Требуется синтплоть."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/wing_reconstruction,
	)

/datum/surgery/advanced/wing_reconstruction/can_start(mob/user, mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	var/obj/item/organ/wings/moth/wings = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(!istype(wings, /obj/item/organ/wings/moth))
		return FALSE
	return ..() && wings?.burnt

/datum/surgery_step/wing_reconstruction
	name = "начать реконструкцию крыльев (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 85,
		TOOL_SCREWDRIVER = 35,
		/obj/item/pen = 15)
	time = 20 SECONDS
	chems_needed = list(/datum/reagent/medicine/c2/synthflesh)
	require_all_chems = FALSE

/datum/surgery_step/wing_reconstruction/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете восстанавливать обугленные мембраны крыльев [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает чинить обугленные мембраны крыльев [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает проводить операцию на обугленных мембранах крыльев [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Ваши крылья жжет, как в аду!")

/datum/surgery_step/wing_reconstruction/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		display_results(
			user,
			target,
			span_notice("Вам удалось восстановить крылья [target.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает крылья [target.declent_ru(GENITIVE)]!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию на крыльях [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Вы снова чувствуете свои крылья!")
		var/obj/item/organ/wings/moth/wings = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
		if(istype(wings, /obj/item/organ/wings/moth)) //make sure we only heal moth wings.
			wings.heal_wings(user, ALL)

		var/obj/item/organ/antennae/antennae = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE) //i mean we might aswell heal their antennae too
		antennae?.heal_antennae(user, ALL)

		human_target.update_body_parts()
	return ..()
