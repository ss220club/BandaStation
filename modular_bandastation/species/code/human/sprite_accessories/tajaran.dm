// MARK: Tajaran body
/datum/bodypart_overlay/simple/body_marking/tajaran
	dna_feature_key = "tajaran_body_markings"
	applies_to = list(/obj/item/bodypart/chest/tajaran, /obj/item/bodypart/arm/left/tajaran, /obj/item/bodypart/arm/right/tajaran, /obj/item/bodypart/leg/left/digitigrade/tajaran, /obj/item/bodypart/leg/right/digitigrade/tajaran)
	var/aux_color_paw = null

/datum/bodypart_overlay/simple/body_marking/tajaran/get_accessory(name)
	return SSaccessories.tajaran_body_markings_list[name]

/datum/bodypart_overlay/simple/body_marking/tajaran/modify_bodypart_appearance(datum/appearance)
	var/image/a = appearance
	if(a.appearance_flags == 0 && aux_color_paw && (a.icon_state == "tajaran_l_hand" || a.icon_state == "tajaran_r_hand"))
		a.color = aux_color_paw
	return

/datum/bodypart_overlay/simple/body_marking/tajaran/bitflag_to_layer(layer)
	switch(layer)
		if(EXTERNAL_BEHIND)
			return -BODY_BEHIND_LAYER
		if(EXTERNAL_ADJACENT)
			return -BODYPARTS_LAYER
		if(EXTERNAL_FRONT)
			return -BODY_FRONT_LAYER
		if(1 << 3)
			return -BODYPARTS_HIGH_LAYER

/datum/sprite_accessory/tajaran_body_markings
	icon = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body_markings.dmi'
	name = "None"
	icon_state = "none"
	color_src = "tajaran_body_markings_color"
	em_block = TRUE
	var/colored_paws = FALSE

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
	colored_paws = TRUE

/datum/sprite_accessory/tajaran_body_markings/patch_tajaran
	name = "Patch"
	icon_state = "patch"
	colored_paws = TRUE

/datum/sprite_accessory/tajaran_body_markings/tiger_tajaran
	name = "Tiger"
	icon_state = "tiger"

/datum/sprite_accessory/tajaran_body_markings/cheetah_tajaran
	name = "Cheetah"
	icon_state = "cheetah"

// MARK: Tajaran tail
/datum/sprite_accessory/tails/tajaran
	icon = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body_accessory.dmi'
	spine_key = "tajaran"

/datum/sprite_accessory/tails/tajaran/tiny
	name = "Tiny tail"
	icon_state = "tiny"

/datum/sprite_accessory/tails/tajaran/short
	name = "Short tail"
	icon_state = "short"

/datum/sprite_accessory/tails/tajaran/wingertail
	name = "Long tail"
	icon_state = "wingertail"

/datum/sprite_accessory/tails/tajaran/huge
	name = "Huge tail"
	icon_state = "huge"

// MARK: Tajaran head markings
/datum/sprite_accessory/tajaran_head_markings
	icon = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/head_markings.dmi'
	name = "None"
	icon_state = "none"
	color_src = "tajaran_head_markings_color"

/datum/sprite_accessory/tajaran_head_markings/taj_tigerhead
	name = "Tiger head"
	icon_state = "tiger_head"

/datum/sprite_accessory/tajaran_head_markings/taj_tigerface
	name = "Tiger face"
	icon_state = "tiger_face"

/datum/sprite_accessory/tajaran_head_markings/taj_outears
	name = "Outer ears"
	icon_state = "outears"

/datum/sprite_accessory/tajaran_head_markings/taj_inears
	name = "Inner ears"
	icon_state = "inears"

/datum/sprite_accessory/tajaran_head_markings/taj_muzzle
	name = "Muzzle"
	icon_state = "muzzle"

/datum/sprite_accessory/tajaran_head_markings/taj_muzinears
	name = "Muzzle and Inner ears"
	icon_state = "muzinears"

/datum/sprite_accessory/tajaran_head_markings/taj_nose
	name = "Nose"
	icon_state = "nose"

/datum/sprite_accessory/tajaran_head_markings/taj_muzzle2
	name = "Muzzle Alt."
	icon_state = "muzzle2"

/datum/sprite_accessory/tajaran_head_markings/taj_points
	name = "Points"
	icon_state = "points"

/datum/sprite_accessory/tajaran_head_markings/taj_patch
	name = "Patch"
	icon_state = "patch"

/datum/sprite_accessory/tajaran_head_markings/taj_cheetah
	name = "Cheetah"
	icon_state = "cheetah"

// MARK: Tajaran facial hair
/datum/sprite_accessory/tajaran_facial_hair
	icon = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/facial_hair.dmi'
	name = "None"
	icon_state = "none"
	color_src = "tajaran_facial_hair_color"

/datum/sprite_accessory/tajaran_facial_hair/taj_goatee
	name = "Goatee"
	icon_state = "goatee"

/datum/sprite_accessory/tajaran_facial_hair/taj_goatee_faded
	name = "Faded goatee"
	icon_state = "goatee_faded"

/datum/sprite_accessory/tajaran_facial_hair/taj_moustache
	name = "Moustache"
	icon_state = "moustache"

/datum/sprite_accessory/tajaran_facial_hair/taj_faccial_mutton
	name = "Faccial_mutton"
	icon_state = "faccial_mutton"

/datum/sprite_accessory/tajaran_facial_hair/taj_pencilstache
	name = "Pencilstache"
	icon_state = "pencilstache"

/datum/sprite_accessory/tajaran_facial_hair/taj_sideburns
	name = "Sideburns"
	icon_state = "sideburns"

/datum/sprite_accessory/tajaran_facial_hair/taj_smallstache
	name = "Smallstache"
	icon_state = "smallstache"

// MARK: Tajaran tail markings
/datum/sprite_accessory/tajaran_tail_markings
	icon = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/tail_markings.dmi'
	name = "None"
	icon_state = "none"
	em_block = TRUE
	color_src = "tajaran_tail_markings_color"
	var/tails_allowed = list()

/datum/sprite_accessory/tajaran_tail_markings/taj_wingertail_stripes
	name = "Long tail - Stripes"
	tails_allowed = list("Long tail")
	icon_state = "stripesw"

/datum/sprite_accessory/tajaran_tail_markings/taj_huge_stripes
	name = "Huge tail - Stripes"
	tails_allowed = list("Huge tail")
	icon_state = "stripesh"

/datum/sprite_accessory/tajaran_tail_markings/taj_huge_dots
	name = "Huge tail - Dots"
	tails_allowed = list("Huge tail")
	icon_state = "dots"
