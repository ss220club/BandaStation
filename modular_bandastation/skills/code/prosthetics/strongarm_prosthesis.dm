// Datum для модификации тела - протез Strongarm
// Добавляет протез руки "Strongarm" в систему модификаций тела

/datum/body_modification/bodypart_prosthesis/arm/strongarm
	abstract_type = /datum/body_modification/bodypart_prosthesis/arm/strongarm
	manufacturers = list(
		"Project Apex"
	)

/datum/body_modification/bodypart_prosthesis/arm/strongarm/left
	key = "strongarm_left_prosthesis"
	name = "Боевой протез 'Strongarm' (левая)"
	replacement_bodypart_type = /obj/item/bodypart/arm/left/strongarm
	incompatible_body_modifications = list("left_arm_amputation", "left_arm_prosthesis")
	category = "Левая рука"

/datum/body_modification/bodypart_prosthesis/arm/strongarm/right
	key = "strongarm_right_prosthesis"
	name = "Боевой протез 'Strongarm' (правая)"
	replacement_bodypart_type = /obj/item/bodypart/arm/right/strongarm
	incompatible_body_modifications = list("right_arm_amputation", "right_arm_prosthesis")
	category = "Правая рука"
