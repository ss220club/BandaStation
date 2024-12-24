/datum/body_modification/bodypart_prosthesis
	name = "Body Part Prosthesis"
	abstract_type = /datum/body_modification/bodypart_prosthesis
	var/replacement_bodypart_type = null

/datum/body_modification/bodypart_prosthesis/apply_to_human(mob/living/carbon/target)
	. = ..()
	if(!.)
		return

	var/obj/item/bodypart/replacement_bodypart = new replacement_bodypart_type()
	replacement_bodypart.replace_limb(target, TRUE)
	return TRUE

/datum/body_modification/bodypart_prosthesis/arm
	abstract_type = /datum/body_modification/bodypart_prosthesis/arm

/datum/body_modification/bodypart_prosthesis/arm/left
	key = "left_arm_prosthetic"
	name = "Протез левой руки"
	replacement_bodypart_type = /obj/item/bodypart/arm/left/robot

/datum/body_modification/bodypart_prosthesis/arm/right
	key = "right_arm_prosthesis"
	name = "Протез правой руки"
	replacement_bodypart_type = /obj/item/bodypart/arm/right/robot

/datum/body_modification/bodypart_prosthesis/leg
	abstract_type = /datum/body_modification/bodypart_prosthesis/leg

/datum/body_modification/bodypart_prosthesis/leg/left
	key = "left_leg_prosthesis"
	name = "Протез левой ноги"
	replacement_bodypart_type = /obj/item/bodypart/leg/left/robot

/datum/body_modification/bodypart_prosthesis/leg/right
	key = "right_leg_prosthesis"
	name = "Протез правой ноги"
	replacement_bodypart_type = /obj/item/bodypart/leg/right/robot
