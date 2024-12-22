/datum/body_modification/limb_amputation
	name = "Body Part Amputation"
	abstract_type = /datum/body_modification/limb_amputation
	var/limb_body_zone = null

/datum/body_modification/limb_amputation/apply_to_carbon(mob/living/carbon/target)
	. = ..()
	if(!.)
		return

	var/obj/item/bodypart/limb_to_remove = target.get_bodypart(limb_body_zone)
	if(!limb_to_remove)
		return FALSE

	limb_to_remove.drop_limb(special = TRUE)
	return TRUE

/datum/body_modification/limb_amputation/arm
	abstract_type = /datum/body_modification/limb_amputation/arm

/datum/body_modification/limb_amputation/arm/left
	key = "left arm amputation"
	name = "Ампутация левой руки"
	limb_body_zone = BODY_ZONE_L_ARM

/datum/body_modification/limb_amputation/arm/right
	key = "right arm amputation"
	name = "Ампутация правой руки"
	limb_body_zone = BODY_ZONE_R_ARM

/datum/body_modification/limb_amputation/leg
	abstract_type = /datum/body_modification/limb_amputation/leg

/datum/body_modification/limb_amputation/leg/left
	key = "left leg amputation"
	name = "Ампутация левой ноги"
	limb_body_zone = BODY_ZONE_L_LEG

/datum/body_modification/limb_amputation/leg/right
	key = "Right leg amputation"
	name = "Ампутация правой ноги"
	limb_body_zone = BODY_ZONE_R_LEG
