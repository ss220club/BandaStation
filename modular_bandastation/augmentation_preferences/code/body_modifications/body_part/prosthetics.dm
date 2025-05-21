/datum/body_modification/bodypart_prosthesis
	name = "Body Part Prosthesis"
	abstract_type = /datum/body_modification/bodypart_prosthesis
	var/replacement_bodypart_type = null

/datum/body_modification/bodypart_prosthesis/apply_to_human(mob/living/carbon/target)
	. = ..()
	if(!.)
		return

	var/obj/item/bodypart/replacement_bodypart = new replacement_bodypart_type()
	var/obj/item/bodypart/limb_to_remove = target.get_bodypart(replacement_bodypart.body_zone)
	replacement_bodypart.replace_limb(target, TRUE)

	qdel(limb_to_remove)
	return TRUE

/datum/body_modification/bodypart_prosthesis/arm
	abstract_type = /datum/body_modification/bodypart_prosthesis/arm

/datum/body_modification/bodypart_prosthesis/arm/left
	key = "left_arm_prosthetic"
	name = "Протез левой руки"
	replacement_bodypart_type = /obj/item/bodypart/arm/left/robot
	incompatible_body_modifications = list("left_arm_amputation")
	category = "Левая рука"

/datum/body_modification/bodypart_prosthesis/arm/right
	key = "right_arm_prosthesis"
	name = "Протез правой руки"
	replacement_bodypart_type = /obj/item/bodypart/arm/right/robot
	incompatible_body_modifications = list("right_arm_amputation")
	category = "Правая рука"

/datum/body_modification/bodypart_prosthesis/leg
	abstract_type = /datum/body_modification/bodypart_prosthesis/leg

/datum/body_modification/bodypart_prosthesis/leg/left
	key = "left_leg_prosthesis"
	name = "Протез левой ноги"
	replacement_bodypart_type = /obj/item/bodypart/leg/left/robot
	incompatible_body_modifications = list("left_leg_amputation")
	category = "Левая нога"

/datum/body_modification/bodypart_prosthesis/leg/right
	key = "right_leg_prosthesis"
	name = "Протез правой ноги"
	replacement_bodypart_type = /obj/item/bodypart/leg/right/robot
	incompatible_body_modifications = list("right_leg_amputation")
	category = "Правая нога"
