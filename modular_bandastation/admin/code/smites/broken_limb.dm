#define CHOICE_SEVERE_TYPE "Severe"
#define CHOICE_MODERATE_TYPE "Moderate"
#define CHOICE_CRITICAL_TYPE "Critical"
#define ALL_BODYTYPES list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
#define ALL_LIMBS list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)

/datum/smite/broken_limb
	name = "Broken limb"
	var/targeted_limb
	var/blunt_type

/datum/smite/broken_limb/configure(client/user)
	var/blunt_choice = tgui_input_list(user,
		"Какой тип перелома необходим?",
		"Тип перелома?",
		list(CHOICE_SEVERE_TYPE, CHOICE_CRITICAL_TYPE, CHOICE_MODERATE_TYPE))
	blunt_type = blunt_choice

	if(!blunt_choice)
		return FALSE
	var/limb_selection_choice = tgui_input_list(user,
		"Какую конечность ломаем?",
		"Нужная конечность?",
		blunt_choice != CHOICE_MODERATE_TYPE ? ALL_BODYTYPES : ALL_LIMBS)
	if(!limb_selection_choice)
		return FALSE
	targeted_limb = limb_selection_choice
	return TRUE

/datum/smite/broken_limb/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/bodypart = carbon_target.get_bodypart(targeted_limb)
	if(!IS_ORGANIC_LIMB(bodypart))
		return FALSE
	var/severity = blunt_type == CHOICE_SEVERE_TYPE ? 2 : \
					blunt_type == CHOICE_MODERATE_TYPE ? 1 : 3
	carbon_target.cause_wound_of_type_and_severity(WOUND_BLUNT, bodypart, severity)

#undef CHOICE_SEVERE_TYPE
#undef CHOICE_MODERATE_TYPE
#undef CHOICE_CRITICAL_TYPE
#undef ALL_BODYTYPES
#undef ALL_LIMBS
