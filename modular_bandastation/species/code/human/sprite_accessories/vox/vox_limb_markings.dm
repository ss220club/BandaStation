/datum/sprite_accessory/vox_limb_markings/default
	name = "Default"
	icon = 'icons/bandastation/mob/species/vox/sprite_accessories/limb_markings.dmi'
	icon_state = "default"
	color_src = TRUE
	em_block = TRUE

/datum/bodypart_overlay/simple/body_marking/vox_limb
	dna_feature_key = FEATURE_VOX_LIMB_MARKINGS
	dna_color_feature_key = FEATURE_VOX_LIMB_MARKINGS_COLOR
	applies_to = list(
		/obj/item/bodypart/head,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/right/digitigrade,
		/obj/item/bodypart/leg/left/digitigrade,
	)
