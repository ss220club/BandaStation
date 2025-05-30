/obj/item/bodypart/head/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_HAIR

/obj/item/bodypart/chest/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	is_dimorphic = TRUE

/obj/item/bodypart/chest/vulpkanin/get_butt_sprite()
	return BUTT_SPRITE_VULPKANIN

/obj/item/bodypart/arm/left/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN

/obj/item/bodypart/leg/right/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
