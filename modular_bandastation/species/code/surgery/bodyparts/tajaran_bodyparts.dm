/obj/item/bodypart/head/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = SPECIES_TAJARAN
	is_dimorphic = TRUE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_HAIR|HEAD_TAJARAN
	species_bodytype = SPECIES_TAJARAN

/obj/item/bodypart/chest/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = SPECIES_TAJARAN
	is_dimorphic = TRUE
	wing_types = list(/obj/item/organ/wings/functional/dragon)
	species_bodytype = SPECIES_TAJARAN

/obj/item/bodypart/chest/tajaran/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_CAT)

/obj/item/bodypart/arm/left/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = SPECIES_TAJARAN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/left/tajaran/get_limb_icon(dropped)
	. = ..()
	var/image/limb = image(layer = -23, dir = NONE)

	limb.icon = icon_greyscale
	if(!should_draw_greyscale || !icon_greyscale)
		limb.icon = icon_static

	if(is_dimorphic) //Does this type of limb have sexual dimorphism?
		limb.icon_state = "[limb_id]_[body_zone]_[limb_gender]"
	else
		limb.icon_state = "[limb_id]_[body_zone]"

	var/image/aux
	if(aux_zone)
		aux = image(limb.icon, "pointsfade_hand_l_arm", -23, NONE)
		. += aux

	return .

/obj/item/bodypart/arm/right/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = SPECIES_TAJARAN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = SPECIES_TAJARAN

/obj/item/bodypart/leg/right/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = SPECIES_TAJARAN

/obj/item/bodypart/leg/left/digitigrade/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/left/digitigrade/tajaran/update_limb(dropping_limb = FALSE, is_creating = TRUE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_TAJARAN : BODYPART_ID_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade/tajaran
	icon_greyscale = 'modular_bandastation/species/icons/mob/species/tajaran/sprite_accessories/body.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/digitigrade/tajaran/update_limb(dropping_limb = FALSE, is_creating = TRUE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_TAJARAN : BODYPART_ID_DIGITIGRADE
