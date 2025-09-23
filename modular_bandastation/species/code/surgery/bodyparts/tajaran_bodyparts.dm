/obj/item/bodypart/head/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = SPECIES_TAJARAN
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_HAIR

/obj/item/bodypart/chest/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = SPECIES_TAJARAN
	is_dimorphic = TRUE

/obj/item/bodypart/chest/tajaran/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_TAJARAN)

/obj/item/bodypart/arm/left/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = SPECIES_TAJARAN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = SPECIES_TAJARAN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = SPECIES_TAJARAN

/obj/item/bodypart/leg/right/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = SPECIES_TAJARAN

/obj/item/bodypart/leg/left/digitigrade/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/left/digitigrade/tajaran/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_TAJARAN : BODYPART_ID_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade/tajaran
	icon_greyscale = 'icons/bandastation/mob/species/tajaran/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/digitigrade/tajaran/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_TAJARAN : BODYPART_ID_DIGITIGRADE
