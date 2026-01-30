#define OPERATION_REJECTION_DAMAGE "tox_damage"

// This surgery is so snowflake that it doesn't use any of the operation subtypes, it forges its own path
/datum/surgery_operation/prosthetic_replacement
	name = "Замена протеза"
	desc = "Замена отсутствующей конечности протезом (или произвольным предметом)."
	implements = list(
		/obj/item/bodypart = 1,
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	operation_flags = OPERATION_STANDING_ALLOWED | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NOTABLE | OPERATION_IGNORE_CLOTHES
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	/// List of items that are always allowed to be an arm replacement, even if they fail another requirement.
	var/list/always_accepted_prosthetics = list(
		/obj/item/chainsaw, // the OG, too large otherwise
		/obj/item/melee/synthetic_arm_blade, // also too large otherwise
		/obj/item/food/pizzaslice, // he's turning her into a papa john's
	)
	/// Radial slice datums for every augment type
	VAR_PRIVATE/list/cached_prosthetic_options

/datum/surgery_operation/prosthetic_replacement/get_default_radial_image()
	return image(/obj/item/bodypart/chest)

/datum/surgery_operation/prosthetic_replacement/get_recommended_tool()
	return "любая конечность / любой предмет"

/datum/surgery_operation/prosthetic_replacement/get_any_tool()
	return "Любой подходящий протез руки"

/datum/surgery_operation/prosthetic_replacement/all_required_strings()
	. = list()
	. += "операция на груди"
	. += ..()
	. += "когда грудная клетка будет готова, нацелитесь на область конечности, которую вы прикрепляете"

/datum/surgery_operation/prosthetic_replacement/any_required_strings()
	return list("руки можно заменить любым подходящим предметом") + ..()

/datum/surgery_operation/prosthetic_replacement/get_radial_options(obj/item/bodypart/chest/chest, obj/item/tool, operating_zone)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_prosthetic_options, tool.type)
	if(!option)
		option = new()
		option.name = "прикрепить [initial(tool.name)]"
		option.info = "Замените отсутствующую конечность пациента на [initial(tool.name)]."
		option.image = image(tool.type)
		LAZYSET(cached_prosthetic_options, tool.type, option)

	return option

/datum/surgery_operation/prosthetic_replacement/get_operation_target(atom/movable/operating_on, body_zone)
	if (!isliving(operating_on))
		return null
	var/mob/living/patient = operating_on
	// We always operate on the chest even if we're targeting left leg or w/e
	return patient.get_bodypart(BODY_ZONE_CHEST)

/datum/surgery_operation/prosthetic_replacement/has_surgery_state(obj/item/bodypart/chest/chest, state)
	return LIMB_HAS_SURGERY_STATE(chest, state)

/datum/surgery_operation/prosthetic_replacement/has_any_surgery_state(obj/item/bodypart/chest/chest, state)
	return LIMB_HAS_ANY_SURGERY_STATE(chest, state)

/datum/surgery_operation/prosthetic_replacement/get_patient(obj/item/bodypart/chest/chest)
	return chest.owner

/datum/surgery_operation/prosthetic_replacement/is_available(obj/item/bodypart/chest/chest, operated_zone)
	var/real_operated_zone = deprecise_zone(operated_zone)
	// Operate on the chest but target another zone
	if(!HAS_TRAIT(chest, TRAIT_READY_TO_OPERATE) || real_operated_zone == BODY_ZONE_CHEST)
		return FALSE
	if(chest.owner.get_bodypart(real_operated_zone))
		return FALSE
	return ..()

/datum/surgery_operation/prosthetic_replacement/snowflake_check_availability(obj/item/bodypart/chest, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	var/real_operated_zone = deprecise_zone(operated_zone)
	// check bodyshape compatibility for real bodyparts
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(real_operated_zone != new_limb.body_zone)
			return FALSE
		if(!new_limb.can_attach_limb(chest.owner))
			return FALSE
	// arbitrary prosthetics can only be used on arms (for now)
	else if(!(real_operated_zone in GLOB.arm_zones))
		return FALSE
	return TRUE

/datum/surgery_operation/prosthetic_replacement/tool_check(obj/item/tool)
	if(tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
		return FALSE
	if(isbodypart(tool))
		return TRUE // auto pass - "intended" use case
	if(is_type_in_list(tool, always_accepted_prosthetics))
		return TRUE // auto pass - soulful prosthetics
	if(tool.w_class < WEIGHT_CLASS_NORMAL || tool.w_class > WEIGHT_CLASS_BULKY)
		return FALSE // too large or too small items don't make sense as a limb replacement
	if(HAS_TRAIT(tool, TRAIT_WIELDED))
		return FALSE
	return TRUE

/datum/surgery_operation/prosthetic_replacement/pre_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	// always operate on absolute body zones
	operation_args[OPERATION_TARGET_ZONE] = deprecise_zone(operation_args[OPERATION_TARGET_ZONE])

/datum/surgery_operation/prosthetic_replacement/on_preop(obj/item/bodypart/chest/chest, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/target_zone_readable = parse_zone(operation_args[OPERATION_TARGET_ZONE])
	display_results(
		surgeon,
		chest.owner,
		span_notice("Вы начинаете заменять отсутствующий [target_zone_readable] в [chest.owner] с помощью [tool]..."),
		span_notice("[surgeon] начинает заменять отсутствующую [target_zone_readable] в [chest.owner] с помощью  [tool]."),
		span_notice("[surgeon] начинает заменять отсуствующую [target_zone_readable] в [chest.owner]."),
	)
	display_pain(chest.owner, "Вы испытываете неприятное ощущение там, где должна быть ваша [target_zone_readable]!")

	operation_args[OPERATION_REJECTION_DAMAGE] = 10
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(IS_ROBOTIC_LIMB(new_limb))
			operation_args[OPERATION_REJECTION_DAMAGE] = 0
		else if(new_limb.check_for_frankenstein(chest.owner))
			operation_args[OPERATION_REJECTION_DAMAGE] = 30

/datum/surgery_operation/prosthetic_replacement/on_success(obj/item/bodypart/chest/chest, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!surgeon.temporarilyRemoveItemFromInventory(tool))
		return // should never happen
	if(operation_args[OPERATION_REJECTION_DAMAGE] > 0)
		chest.owner.apply_damage(operation_args[OPERATION_REJECTION_DAMAGE], TOX)
	if(isbodypart(tool))
		handle_bodypart(chest.owner, surgeon, tool)
		return
	handle_arbitrary_prosthetic(chest.owner, surgeon, tool, operation_args[OPERATION_TARGET_ZONE])

/datum/surgery_operation/prosthetic_replacement/proc/handle_bodypart(mob/living/carbon/patient, mob/living/surgeon, obj/item/bodypart/bodypart_to_attach)
	bodypart_to_attach.try_attach_limb(patient)
	if(bodypart_to_attach.check_for_frankenstein(patient))
		bodypart_to_attach.bodypart_flags |= BODYPART_IMPLANTED
	display_results(
		surgeon, patient,
		span_notice("Вам удалось заменить [bodypart_to_attach.plaintext_zone] у [patient]."),
		span_notice("[surgeon] успешно заменяет [bodypart_to_attach.plaintext_zone] у [patient] на [bodypart_to_attach]!"),
		span_notice("[surgeon] успешно заменяет [bodypart_to_attach.plaintext_zone] у [patient] !"),
	)
	display_pain(patient, "Вы ощущаете синтетическое чувство, которое распространяется от вашей [bodypart_to_attach.plaintext_zone], снова чувствуя её!", TRUE)

/datum/surgery_operation/prosthetic_replacement/proc/handle_arbitrary_prosthetic(mob/living/carbon/patient, mob/living/surgeon, obj/item/thing_to_attach, target_zone)
	SSblackbox.record_feedback("tally", "arbitrary_prosthetic", 1, initial(thing_to_attach.name))
	var/obj/item/bodypart/new_limb = patient.make_item_prosthetic(thing_to_attach, target_zone, 80)
	new_limb.add_surgical_state(SURGERY_PROSTHETIC_UNSECURED)
	display_results(
		surgeon, patient,
		span_notice("Вы прикрепляете [thing_to_attach]."),
		span_notice("[surgeon] завершает прикрепление [thing_to_attach]!"),
		span_notice("[surgeon] заканчивает процедуру прикрепления!"),
	)
	display_pain(patient, "Вы испытываете странное ощущение, когда [thing_to_attach] занимает место вашей руки!", TRUE)

#undef OPERATION_REJECTION_DAMAGE

/datum/surgery_operation/limb/secure_arbitrary_prosthetic
	name = "Закрепление протеза"
	desc = "Убедитесь, что произвольный протез правильно прикреплен к телу пациента."
	implements = list(
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/sticky_tape/surgical = 1.25,
		/obj/item/stack/sticky_tape = 2,
	)
	time = 4.8 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_STANDING_ALLOWED
	all_surgery_states_required = SURGERY_PROSTHETIC_UNSECURED

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/get_default_radial_image()
	return image(/obj/item/stack/medical/suture)

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/stack/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете прикреплять [tool.singular_name] [limb] к телу у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает прикреплять [tool.singular_name] [limb] к телу у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает прикреплять [tool.singular_name] к телу у [limb.owner.declent_ru(GENITIVE)]."),
	)
	var/obj/item/bodypart/chest = limb.owner.get_bodypart(BODY_ZONE_CHEST)
	display_pain(limb.owner, "[surgeon] прикрепляет [tool.singular_name] [limb] к вашему телу!", IS_ROBOTIC_LIMB(chest))

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/stack/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы заканчиваете прикреплять [tool.apply_verb] [limb]  к телу у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] заканчивает прикреплять [tool.apply_verb] [limb] к телу у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] завершает процедуру [tool.apply_verb]!"),
	)
	var/obj/item/bodypart/chest = limb.owner.get_bodypart(BODY_ZONE_CHEST)
	display_pain(limb.owner, "Вы чувствуете себя в большей безопасности, так как ваш протез надежно прикреплен к вашему телу!", IS_ROBOTIC_LIMB(chest))
	limb.remove_surgical_state(SURGERY_PROSTHETIC_UNSECURED)
	limb.AddComponent(/datum/component/item_as_prosthetic_limb, null, 0) // updates drop probability to zero
	tool.use(1)
