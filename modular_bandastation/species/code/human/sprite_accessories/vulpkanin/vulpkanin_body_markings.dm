/datum/sprite_accessory/vulpkanin_body_markings
	icon = 'icons/bandastation/mob/species/vulpkanin/sprite_accessories/body_markings.dmi'
	color_src = TRUE
	em_block = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/belly_fox
	name = "Vulpkanin Belly"
	icon_state = "foxbelly"

/datum/sprite_accessory/vulpkanin_body_markings/belly_full
	name = "Vulpkanin Belly 2"
	icon_state = "fullbelly"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/belly_crest
	name = "Vulpkanin Belly Crest"
	icon_state = "bellycrest"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/points_fade
	name = "Vulpkanin Points"
	icon_state = "pointsfade"

/datum/sprite_accessory/vulpkanin_body_markings/points_fade_belly
	name = "Vulpkanin Points and Belly"
	icon_state = "pointsfadebelly"

/datum/sprite_accessory/vulpkanin_body_markings/points_fade_belly_alt
	name = "Vulpkanin Points and Belly Alt."
	icon_state = "altpointsfadebelly"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/points_sharp
	name = "Vulpkanin Sharp Points"
	icon_state = "sharppoints"

/datum/sprite_accessory/vulpkanin_body_markings/points_crest
	name = "Vulpkanin Points and Crest"
	icon_state = "crestpoints"
	gender_specific = TRUE

/datum/bodypart_overlay/simple/body_marking/vulpkanin_body
	dna_feature_key = "vulpkanin_body_markings"
	dna_color_feature_key = "vulpkanin_body_markings_color"
	applies_to = list(
		/obj/item/bodypart/chest,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right
	)

/datum/bodypart_overlay/simple/body_marking/vulpkanin_body/get_accessory(name)
	return SSaccessories.vulpkanin_body_markings_list[name]
