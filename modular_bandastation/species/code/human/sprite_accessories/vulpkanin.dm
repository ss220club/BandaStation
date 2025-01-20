// BODY

/datum/bodypart_overlay/simple/body_marking/vulpkanin
	dna_feature_key = "vulpkanin_body_markings"
	applies_to = list(/obj/item/bodypart/chest/vulpkanin, /obj/item/bodypart/arm/left/vulpkanin, /obj/item/bodypart/arm/right/vulpkanin, /obj/item/bodypart/leg/left/vulpkanin, /obj/item/bodypart/leg/right/vulpkanin)
	var/aux_color_paw = null

/datum/bodypart_overlay/simple/body_marking/vulpkanin/get_accessory(name)
	return SSaccessories.vulpkanin_body_markings_list[name]

/datum/bodypart_overlay/simple/body_marking/vulpkanin/modify_bodypart_appearance(datum/appearance)
	var/image/a = appearance
	if(a.appearance_flags == 0 && aux_color_paw && (a.icon_state == "vulpkanin_l_hand" || a.icon_state == "vulpkanin_r_hand"))
		a.color = aux_color_paw
	return

/datum/bodypart_overlay/simple/body_marking/vulpkanin/set_appearance(name, set_color, bodypart)
	var/datum/sprite_accessory/vulpkanin_body_markings/accessory = get_accessory(name)
	if(isnull(accessory))
		return

	icon = accessory.icon
	icon_state = accessory.icon_state
	use_gender = accessory.gender_specific
	draw_color = accessory.color_src ? set_color : null

	if(istype(accessory, /datum/sprite_accessory/vulpkanin_body_markings) && accessory.colored_paws && (istype(bodypart, /obj/item/bodypart/arm/left/vulpkanin) || istype(bodypart, /obj/item/bodypart/arm/right/vulpkanin)))
		aux_color_paw = accessory.color_src ? set_color : null

	cache_key = jointext(generate_icon_cache(), "_")

/datum/bodypart_overlay/simple/body_marking/vulpkanin/generate_icon_cache()
	. = ..()
	. += use_gender
	. += draw_color

/datum/bodypart_overlay/simple/body_marking/vulpkanin/can_draw_on_bodypart(mob/living/carbon/human/human)
	return icon_state != SPRITE_ACCESSORY_NONE

/datum/sprite_accessory/vulpkanin_body_markings
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body_markings.dmi'
	name = "None"
	icon_state = "none"
	color_src = "vulpkanin_body_markings_color"
	em_block = TRUE
	var/colored_paws = FALSE

/datum/sprite_accessory/vulpkanin_body_markings/belly_fox_vulp
	name = "Vulpkanin Belly"
	icon_state = "foxbelly"

/datum/sprite_accessory/vulpkanin_body_markings/belly_full_vulp
	name = "Vulpkanin Belly 2"
	icon_state = "fullbelly"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/belly_crest_vulp
	name = "Vulpkanin Belly Crest"
	icon_state = "bellycrest"
	gender_specific = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/points_fade_vulp
	name = "Vulpkanin Points"
	icon_state = "pointsfade"
	colored_paws = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/points_fade_belly_vulp
	name = "Vulpkanin Points and Belly"
	icon_state = "pointsfadebelly"
	colored_paws = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/points_fade_belly_alt_vulp
	name = "Vulpkanin Points and Belly Alt."
	icon_state = "altpointsfadebelly"
	gender_specific = TRUE
	colored_paws = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/points_sharp_vulp
	name = "Vulpkanin Sharp Points"
	icon_state = "sharppoints"
	colored_paws = TRUE

/datum/sprite_accessory/vulpkanin_body_markings/points_crest_vulp
	name = "Vulpkanin Points and Crest"
	icon_state = "crestpoints"
	gender_specific = TRUE
	colored_paws = TRUE

// TAIL

/datum/sprite_accessory/tails/vulpkanin
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body_accessory.dmi'
	spine_key = "vulpkanin"

/datum/sprite_accessory/tails/vulpkanin/fluffy
	name = "Default"
	icon_state = "default"

/datum/sprite_accessory/tails/vulpkanin/bushy
	name = "Bushy"
	icon_state = "bushy"

/datum/sprite_accessory/tails/vulpkanin/straight
	name = "Straight"
	icon_state = "straight"

/datum/sprite_accessory/tails/vulpkanin/straight_bushy
	name = "Straight Bushy"
	icon_state = "straightbushy"

// HEAD ACCESSORY

/datum/sprite_accessory/vulpkanin_head_accessories
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/facial_hair.dmi'
	name = "None"
	icon_state = "none"
	color_src = "vulpkanin_head_accessories_color"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_earfluff
	name = "Vulpkanin Earfluff"
	icon_state = "earfluff"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_blaze
	name = "Blaze"
	icon_state = "blaze"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_vulpine
	name = "Vulpine"
	icon_state = "vulpine"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_vulpine_fluff
	name = "Vulpine and Earfluff"
	icon_state = "vulpinefluff"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_mask
	name = "Mask"
	icon_state = "mask"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_patch
	name = "Patch"
	icon_state = "patch"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_ruff
	name = "Ruff"
	icon_state = "ruff"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_kita
	name = "Kita"
	icon_state = "kita"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_swift
	name = "Swift"
	icon_state = "swift"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_nose
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/head_markings.dmi'
	name = "Vulpkanin Nose"
	icon_state = "nose"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_nose2
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/head_markings.dmi'
	name = "Vulpkanin Nose Alt."
	icon_state = "nose_alt"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_elder
	name = "Elder"
	icon_state = "elder"

/datum/sprite_accessory/vulpkanin_head_accessories/vulp_slash
	name = "Slash"
	icon_state = "slash"

// HEAD MARKINGS

/datum/sprite_accessory/vulpkanin_head_markings
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/head_markings.dmi'
	name = "None"
	icon_state = "none"
	color_src = "vulpkanin_head_markings_color"

/datum/sprite_accessory/vulpkanin_head_markings/nose_default_vulp
	name = "Vulpkanin Nose"
	icon_state = "nose"

/datum/sprite_accessory/vulpkanin_head_markings/nose2_default_vulp
	name = "Vulpkanin Nose Alt."
	icon_state = "nose_alt"

/datum/sprite_accessory/vulpkanin_head_markings/tiger_head_vulp
	name = "Vulpkanin Tiger Head"
	icon_state = "tiger_head"

/datum/sprite_accessory/vulpkanin_head_markings/tiger_face_vulp
	name = "Vulpkanin Tiger Head and Face"
	icon_state = "tiger_face"

/datum/sprite_accessory/vulpkanin_head_markings/muzzle_vulp
	name = "Vulpkanin Muzzle"
	icon_state = "muzzle"

/datum/sprite_accessory/vulpkanin_head_markings/muzzle_ears_vulp
	name = "Vulpkanin Muzzle and Ears"
	icon_state = "muzzle_ear"

/datum/sprite_accessory/vulpkanin_head_markings/points_fade_vulp
	name = "Vulpkanin Points Head"
	icon_state = "points_fade"

/datum/sprite_accessory/vulpkanin_head_markings/points_sharp_vulp
	name = "Vulpkanin Points Head 2"
	icon_state = "points_sharp"

// FACIAL HAIR

/datum/sprite_accessory/vulpkanin_facial_hair
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/facial_hair.dmi'
	name = "None"
	icon_state = "none"
	color_src = "vulpkanin_facial_hair_color"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_earfluff
	name = "Vulpkanin Earfluff"
	icon_state = "earfluff"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_blaze
	name = "Blaze"
	icon_state = "blaze"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_vulpine
	name = "Vulpine"
	icon_state = "vulpine"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_vulpine_brows
	name = "Vulpine and Brows"
	icon_state = "brows"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_vulpine_fluff
	name = "Vulpine and Earfluff"
	icon_state = "vulpinefluff"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_mask
	name = "Mask"
	icon_state = "mask"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_patch
	name = "Patch"
	icon_state = "patch"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_ruff
	name = "Ruff"
	icon_state = "ruff"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_kita
	name = "Kita"
	icon_state = "kita"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_swift
	name = "Swift"
	icon_state = "swift"

/datum/sprite_accessory/vulpkanin_facial_hair/vulp_elder
	name = "Elder"
	icon_state = "elder"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_slash
	name = "Slash"
	icon_state = "slash"

// TAIL MARKINGS

/datum/sprite_accessory/vulpkanin_tail_markings
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/tail_markings.dmi'
	name = "None"
	icon_state = "none"
	em_block = TRUE
	color_src = "vulpkanin_tail_markings_color"
	var/tails_allowed = list()

/datum/sprite_accessory/vulpkanin_tail_markings/vulp_default_tip
	name = "Tail Tip"
	tails_allowed = list("Default", "Straight Bushy")
	icon_state = "tip"

/datum/sprite_accessory/vulpkanin_tail_markings/vulp_default_fade
	name = "Tail Fade"
	tails_allowed = list("Default", "Straight Bushy")
	icon_state = "fade"

/datum/sprite_accessory/vulpkanin_tail_markings/vulp_bushy_fluff
	name = "Tail Fluff"
	tails_allowed = list("Bushy")
	icon_state = "fluff"

/datum/sprite_accessory/vulpkanin_tail_markings/vulp_hybrid_silverf
	name = "Tail Black Fade White Tip"
	tails_allowed = list("Straight Bushy")
	icon_state = "fadetip"
