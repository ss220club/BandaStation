/datum/sprite_accessory/vulpkanin_limb_markings
	icon = 'icons/bandastation/mob/species/vulpkanin/sprite_accessories/limb_markings.dmi'
	color_src = TRUE
	em_block = TRUE

/datum/sprite_accessory/vulpkanin_limb_markings/points_fade
	name = "Pointsfade"
	icon_state = "pointsfade"

/datum/sprite_accessory/vulpkanin_limb_markings/points_sharp
	name = "Sharp points"
	icon_state = "sharppoints"

/datum/sprite_accessory/vulpkanin_limb_markings/points_crest
	name = "Points and crest"
	icon_state = "crestpoints"

/datum/bodypart_overlay/simple/body_marking/vulpkanin_limb
	dna_feature_key = "vulpkanin_limb_markings"
	dna_color_feature_key = "vulpkanin_body_markings_color"
	applies_to = list(
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/leg/right,
		/obj/item/bodypart/leg/left,
	)

/datum/bodypart_overlay/simple/body_marking/vulpkanin_limb/get_accessory(name)
	return SSaccessories.vulpkanin_limb_markings_list[name]
