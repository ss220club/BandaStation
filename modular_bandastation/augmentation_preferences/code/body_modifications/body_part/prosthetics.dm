/datum/body_modification/bodypart_prosthetics
	name = "Body Part Prosthetics"
	abstract_type = /datum/body_modification/bodypart_prosthetics
	var/replacement_bodypart_type = null

/datum/body_modification/bodypart_prosthetics/apply_to_carbon(mob/living/carbon/target)
	. = ..()
	if(!.)
		return

	var/obj/item/bodypart/replacement_bodypart = new replacement_bodypart_type()
	replacement_bodypart.replace_limb(target, TRUE)
	return TRUE

/datum/body_modification/bodypart_prosthetics/head
	key = "head_prosthetics"
	name = "Протез головы"
	replacement_bodypart = /obj/item/bodypart/head/robot

/datum/body_modification/bodypart_prosthetics/chest
	key = "chest_prosthetics"
	name = "Протез торса"
	replacement_bodypart = /obj/item/bodypart/chest/robot

/datum/body_modification/bodypart_prosthetics/arm
	abstract_type = /datum/body_modification/bodypart_prosthetics/arm

/datum/body_modification/bodypart_prosthetics/arm/left
	key = "left_arm_amputation"
	name = "Протез левой руки"
	replacement_bodypart = /obj/item/bodypart/arm/left/robot

/datum/body_modification/bodypart_prosthetics/arm/right
	key = "right_arm_amputation"
	name = "Протез правой руки"
	replacement_bodypart = /obj/item/bodypart/arm/right/robot

/datum/body_modification/bodypart_prosthetics/leg
	abstract_type = /datum/body_modification/bodypart_prosthetics/leg

/datum/body_modification/bodypart_prosthetics/leg/left
	key = "left_leg_amputation"
	name = "Протез левой ноги"
	replacement_bodypart = /obj/item/bodypart/leg/left/robot

/datum/body_modification/bodypart_prosthetics/leg/right
	key = "right_leg_amputation"
	name = "Протез правой ноги"
	replacement_bodypart = /obj/item/bodypart/leg/right/robot
