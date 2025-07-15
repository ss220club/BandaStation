/datum/surgery/prosthetic_replacement
	name = "Замена протеза"
	surgery_flags = NONE
	requires_bodypart_type = NONE
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/add_prosthetic,
	)

/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(!carbon_target.get_bodypart(user.zone_selected) && carbon_target.should_have_limb(user.zone_selected)) //can only start if limb is missing
		return TRUE
	return FALSE



/datum/surgery_step/add_prosthetic
	name = "установите протез"
	implements = list(
		/obj/item/bodypart = 100,
		/obj/item/borg/apparatus/organ_storage = 100,
		/obj/item = 100,
	)
	time = 3.2 SECONDS
	/// Toxin damage incurred by the target if an organic limb is attached
	VAR_FINAL/organ_rejection_dam = 0
	/// List of items that are always allowed to be an arm replacement, even if they fail another requirement.
	var/list/always_accepted_prosthetics = list(
		/obj/item/chainsaw, // the OG, too large otherwise
		/obj/item/melee/synthetic_arm_blade, // also too large otherwise
		/obj/item/food/pizzaslice, // he's turning her into a papa john's
	)

/datum/surgery_step/add_prosthetic/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		if(!length(tool.contents))
			return FALSE
		tool = tool.contents[1]
	if(tool.item_flags & (ABSTRACT|HAND_ITEM|DROPDEL))
		return FALSE
	if(isbodypart(tool))
		return TRUE // auto pass - "intended" use case
	if(is_type_in_list(tool, always_accepted_prosthetics))
		return TRUE // auto pass - soulful prosthetics
	if(tool.w_class < WEIGHT_CLASS_NORMAL || tool.w_class > WEIGHT_CLASS_BULKY)
		return FALSE // too large or too small items don't make sense as a limb replacement
	if(HAS_TRAIT(tool, TRAIT_WIELDED))
		return FALSE // prevents exploits from weird edge cases - either unwield or get out
	return TRUE

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		if(!tool.contents.len)
			to_chat(user, span_warning("Внутри [tool.declent_ru(GENITIVE)] ничего нет!"))
			return SURGERY_STEP_FAIL
		var/obj/item/organ_storage_contents = tool.contents[1]
		if(!isbodypart(organ_storage_contents))
			to_chat(user, span_warning("Нельзя прикрепить [organ_storage_contents.declent_ru(NOMINATIVE)]!"))
			return SURGERY_STEP_FAIL
		tool = organ_storage_contents
	if(isbodypart(tool))
		var/obj/item/bodypart/bodypart_to_attach = tool
		if(IS_ORGANIC_LIMB(bodypart_to_attach))
			organ_rejection_dam = 10
			if(ishuman(target))
				var/mob/living/carbon/human/human_target = target
				var/obj/item/bodypart/chest/target_chest = human_target.get_bodypart(BODY_ZONE_CHEST)
				if((!(bodypart_to_attach.bodyshape & target_chest.acceptable_bodyshape)) && (!(bodypart_to_attach.bodytype & target_chest.acceptable_bodytype)))
					to_chat(user, span_warning("[capitalize(bodypart_to_attach.declent_ru(NOMINATIVE))] не соответствует патологии пациента."))
					return SURGERY_STEP_FAIL
				if(bodypart_to_attach.check_for_frankenstein(target))
					organ_rejection_dam = 30

		if(!bodypart_to_attach.can_attach_limb(target))
			target.balloon_alert(user, "это не подходит к [target.parse_zone_with_bodypart(target_zone, declent = DATIVE)]!")
			return SURGERY_STEP_FAIL

		if(target_zone == bodypart_to_attach.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
			display_results(
				user,
				target,
				span_notice("Вы начинаете заменять [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)] на [tool.declent_ru(ACCUSATIVE)]..."),
				span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает заменять [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)] на [tool.declent_ru(ACCUSATIVE)]."),
				span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает заменять [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]."),
			)
		else
			to_chat(user, span_warning("[capitalize(tool.declent_ru(NOMINATIVE))] не подходит для [target.parse_zone_with_bodypart(target_zone, declent = GENITIVE)]."))
			return SURGERY_STEP_FAIL
	else if(target_zone == BODY_ZONE_L_ARM || target_zone == BODY_ZONE_R_ARM)
		display_results(
			user,
			target,
			span_notice("Вы начинаете прикреплять [tool.declent_ru(ACCUSATIVE)] к [target.declent_ru(GENITIVE)]..."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает прикреплять [tool.declent_ru(ACCUSATIVE)] к [target.parse_zone_with_bodypart(target_zone, declent = DATIVE)] у [target.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает прикреплять что-то к [target.parse_zone_with_bodypart(target_zone, declent = DATIVE)] у [target.declent_ru(GENITIVE)]."),
		)
	else
		to_chat(user, span_warning("[capitalize(tool.declent_ru(NOMINATIVE))] устанавливается только в руку."))
		return SURGERY_STEP_FAIL

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
		tool = tool.contents[1]
	else if(!user.temporarilyRemoveItemFromInventory(tool))
		to_chat(user, span_warning("You can't seem to part with [tool]!"))
		return FALSE

	. = ..()
	if(isbodypart(tool))
		handle_bodypart(user, target, tool, target_zone)
		return
	handle_arbitrary_prosthetic(user, target, tool, target_zone)
	surgery.steps += /datum/surgery_step/secure_arbitrary_prosthetic

/datum/surgery_step/add_prosthetic/proc/handle_bodypart(mob/user, mob/living/carbon/target, obj/item/bodypart/bodypart_to_attach, target_zone)
	bodypart_to_attach.try_attach_limb(target)
	if(bodypart_to_attach.check_for_frankenstein(target))
		bodypart_to_attach.bodypart_flags |= BODYPART_IMPLANTED
	if(organ_rejection_dam)
		target.adjustToxLoss(organ_rejection_dam)
	display_results(
		user, target,
		span_notice("Вы успешно заменяете [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно заменяет [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)] на [bodypart_to_attach.declent_ru(ACCUSATIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно заменяет [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)] у [target.declent_ru(GENITIVE)]!"),
	)
	display_pain(target, "Вы наполняетесь позитивными ощущениями, потому что вы снова чувствуете вашу [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)]!", TRUE)

/datum/surgery_step/add_prosthetic/proc/handle_arbitrary_prosthetic(mob/user, mob/living/carbon/target, obj/item/thing_to_attach, target_zone)
	SSblackbox.record_feedback("tally", "arbitrary_prosthetic", 1, initial(thing_to_attach.name))
	target.make_item_prosthetic(thing_to_attach, target_zone, 80)
	display_results(
		user, target,
		span_notice("Вы прикрепляете [thing_to_attach.declent_ru(ACCUSATIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] прикрепляет [thing_to_attach.declent_ru(ACCUSATIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию по прикреплению!"),
	)
	display_pain(target, "Вы испытываете странные ощущения от присоединения вашей [target.parse_zone_with_bodypart(target_zone, declent = GENITIVE)].", TRUE)

/datum/surgery_step/secure_arbitrary_prosthetic
	name = "secure prosthetic (suture/tape)"
	implements = list(
		/obj/item/stack/medical/suture = 100,
		/obj/item/stack/sticky_tape/surgical = 80,
		/obj/item/stack/sticky_tape = 50,
	)
	time = 4.8 SECONDS

/datum/surgery_step/secure_arbitrary_prosthetic/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/limb = target.get_bodypart(target_zone)
	var/obj/item/stack/thing = tool
	display_results(
		user, target,
		span_notice("You begin to [thing.singular_name] [limb] to [target]'s body."),
		span_notice("[user] begins to [thing.singular_name] [limb] to [target]'s body."),
		span_notice("[user] begins to [thing.singular_name] something to [target]'s body."),
	)
	display_pain(target, "[user] begins to [thing.singular_name] [limb] to your body!", TRUE)

/datum/surgery_step/secure_arbitrary_prosthetic/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/limb = target.get_bodypart(target_zone)
	var/obj/item/stack/thing = tool
	thing.use(1)
	limb.AddComponent(/datum/component/item_as_prosthetic_limb, null, 0) // updates drop probability to zero
	display_results(
		user, target,
		span_notice("You [thing.singular_name] [limb] to [target]'s body."),
		span_notice("[user] [thing.singular_name] [limb] to [target]'s body!"),
		span_notice("[user] [thing.singular_name][plural_s(thing.singular_name)] something to [target]'s body!"),
	)
	display_pain(target, "[user] [thing.singular_name][plural_s(thing.singular_name)] [limb] to your body!", TRUE)
	return TRUE
