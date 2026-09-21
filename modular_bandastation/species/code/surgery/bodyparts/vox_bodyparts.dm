/obj/item/bodypart/head/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = TRUE
	head_flags = HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN

/obj/item/bodypart/chest/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = TRUE

/obj/item/bodypart/chest/vox/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_VOX)

/obj/item/bodypart/arm/left/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX

/obj/item/bodypart/leg/right/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX

/obj/item/bodypart/leg/left/digitigrade/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	species_id = SPECIES_VOX
	bodyshape = BODYSHAPE_HUMANOID
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/left/digitigrade/vox/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/digitigrade_limb, SPECIES_VOX, initial(limb_id))

/obj/item/bodypart/leg/right/digitigrade/vox
	icon_greyscale = 'icons/bandastation/mob/species/vox/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	species_id = SPECIES_VOX
	bodyshape = BODYSHAPE_HUMANOID
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/digitigrade/vox/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/digitigrade_limb, SPECIES_VOX, initial(limb_id))
