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

/datum/bodypart_overlay/mutant/quills/vox/icon_render_key(obj/item/bodypart/limb)
	. = ..()
	if(LAZYLEN(limb?.owner?.hair_masks))
		. += jointext(limb.owner.hair_masks, ",")

/datum/bodypart_overlay/mutant/quills/vox/get_image(obj/item/bodypart/limb, layer_index, layer_real)
	if(!LAZYLEN(limb?.owner?.hair_masks))
		return ..()

	var/list/hair_masks_to_use = limb.owner.hair_masks
	var/icon_state_to_use = build_icon_state(layer_index, limb)
	var/quill_cache_key = "[sprite_datum.type]-[icon_state_to_use]-[jointext(hair_masks_to_use, ",")]"
	var/static/list/cached_quill_icons
	var/icon/cached_icon = LAZYACCESS(cached_quill_icons, quill_cache_key)
	if(isnull(cached_icon))
		cached_icon = icon(sprite_datum.icon, icon_state_to_use)
		for(var/datum/hair_mask/mask as anything in hair_masks_to_use)
			cached_icon.Blend(icon(mask::icon, mask::icon_state), ICON_ADD)
		LAZYSET(cached_quill_icons, quill_cache_key, cached_icon)

	var/mutable_appearance/uncached_appearance = mutable_appearance(cached_icon, layer = layer_real)
	if(sprite_datum.center)
		center_image(uncached_appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)
	return uncached_appearance

// MARK: Vox facial quills
/obj/item/organ/facial_quills/vox
	name = "vox facial quills"
	bodypart_overlay = /datum/bodypart_overlay/mutant/facial_quills/vox
	dna_block = /datum/dna_block/feature/accessory/vox_facial_quills

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
