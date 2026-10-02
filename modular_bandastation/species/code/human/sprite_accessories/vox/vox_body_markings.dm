/datum/sprite_accessory/vox_body_markings
	icon = 'icons/bandastation/mob/species/vox/sprite_accessories/vox_bodymarkings.dmi'
	color_src = TRUE
	em_block = TRUE

/datum/sprite_accessory/vox_body_markings/leader
	name = "Leader"
	icon_state = "leader"

/datum/sprite_accessory/vox_body_markings/drone
	name = "Drone"
	icon_state = "drone"

/datum/sprite_accessory/vox_body_markings/reaver
	name = "Reaver"
	icon_state = "reaver"

/datum/sprite_accessory/vox_body_markings/raider
	name = "Raider"
	icon_state = "raider"

/datum/sprite_accessory/vox_body_markings/larva
	name = "Larva"
	icon_state = "larva"

/datum/sprite_accessory/vox_body_markings/scavenger
	name = "Scavenger"
	icon_state = "scavenger"

/datum/sprite_accessory/vox_body_markings/servirtor
	name = "Servirtor"
	icon_state = "servirtor"

/datum/bodypart_overlay/simple/body_marking/vox_body
	dna_feature_key = FEATURE_VOX_BODY_MARKINGS
	dna_color_feature_key = FEATURE_VOX_BODY_MARKINGS_COLOR
	applies_to = list(/obj/item/bodypart/chest)
