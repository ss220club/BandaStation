// MARK: Vox snout
/obj/item/organ/snout/vox
	name = "vox snout"
	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/vox
	dna_block = /datum/dna_block/feature/accessory/vox_snout
	icon_state = "snout"

/datum/bodypart_overlay/mutant/snout/vox
	feature_key = FEATURE_VOX_SNOUT
	color_source = ORGAN_COLOR_FEATURE
	dna_color_feature_key = FEATURE_VOX_SNOUT_COLOR

// MARK: Vox tail
/obj/item/organ/tail/vox
	name = "vox tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/vox
	dna_block = null

/datum/bodypart_overlay/mutant/tail/vox
	feature_key = FEATURE_VOX_TAIL

// MARK: Vox Quills
/obj/item/organ/quills/vox
	name = "vox quills"
	bodypart_overlay = /datum/bodypart_overlay/mutant/quills/vox
	dna_block = /datum/dna_block/feature/accessory/vox_quills
	icon_state = "quills"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_VOX_QUILLS

	use_mob_sprite_as_obj_sprite = TRUE

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/quills/vox
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_VOX_QUILLS
	color_source = ORGAN_COLOR_FEATURE
	dna_color_feature_key = FEATURE_VOX_QUILLS_COLOR
	offset_location = UPPER_BODY

/datum/bodypart_overlay/mutant/quills/vox/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEHAIR)

// MARK: Vox facial quills
/obj/item/organ/facial_quills/vox
	name = "vox facial quills"
	bodypart_overlay = /datum/bodypart_overlay/mutant/facial_quills/vox
	dna_block = /datum/dna_block/feature/accessory/vox_facial_quills
	icon_state = "facial_quills"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_VOX_FACIAL_QUILLS

	use_mob_sprite_as_obj_sprite = TRUE

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/facial_quills/vox
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_VOX_FACIAL_QUILLS
	color_source = ORGAN_COLOR_FEATURE
	dna_color_feature_key = FEATURE_VOX_FACIAL_QUILLS_COLOR
	offset_location = UPPER_BODY

/datum/bodypart_overlay/mutant/facial_quills/vox/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEFACIALHAIR)
