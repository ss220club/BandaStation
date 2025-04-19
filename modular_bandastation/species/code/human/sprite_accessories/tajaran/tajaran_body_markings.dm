/datum/sprite_accessory/tajaran_body_markings
	icon = 'icons/bandastation/mob/species/tajaran/sprite_accessories/body_markings.dmi'
	color_src = "tajaran_body_markings_color"

/datum/sprite_accessory/tajaran_body_markings/belly_tajaran
	name = "Belly"
	icon_state = "belly"

/datum/sprite_accessory/tajaran_body_markings/belly_full_tajaran
	name = "Full Belly"
	icon_state = "fullbelly"

/datum/sprite_accessory/tajaran_body_markings/belly_crest_tajaran
	name = "Belly Crest"
	icon_state = "crest"

/datum/sprite_accessory/tajaran_body_markings/points_tajaran
	name = "Points"
	icon_state = "points"

/datum/sprite_accessory/tajaran_body_markings/patch_tajaran
	name = "Patch"
	icon_state = "patch"

/datum/sprite_accessory/tajaran_body_markings/tiger_tajaran
	name = "Tiger"
	icon_state = "tiger"

/datum/sprite_accessory/tajaran_body_markings/cheetah_tajaran
	name = "Cheetah"
	icon_state = "cheetah"

// MARK: bodypart_overlay
/datum/bodypart_overlay/simple/body_marking/tajaran_body
	dna_feature_key = "tajaran_body_markings"
	dna_color_feature_key = "tajaran_body_markings_color"
	applies_to = list(
		/obj/item/bodypart/chest,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left/digitigrade,
		/obj/item/bodypart/leg/right/digitigrade
	)

/datum/bodypart_overlay/simple/body_marking/tajaran_body/get_accessory(name)
	return SSaccessories.tajaran_body_markings_list[name]
