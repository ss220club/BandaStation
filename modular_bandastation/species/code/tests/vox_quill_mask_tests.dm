/// Hair masks must trim external quills without changing the underlying accessory or its naked appearance.
/datum/unit_test/vox_quill_hair_masks/Run()
	var/mob/living/carbon/human/consistent/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	var/obj/item/bodypart/head/head = vox.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/quills/vox/organ = vox.get_organ_by_type(/obj/item/organ/quills/vox)
	var/datum/bodypart_overlay/mutant/quills/vox/quills = organ.bodypart_overlay
	quills.set_appearance(/datum/sprite_accessory/vox_quills/kingly)
	var/image/naked = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	var/naked_key = jointext(quills.icon_render_key(head), ",")
	var/naked_pixels = count_visible_pixels(naked)
	TEST_ASSERT(naked_pixels > 0, "Vox quill mask fixture has no visible naked pixels.")

	for(var/mask_type in list(/datum/hair_mask/winterhood, /datum/hair_mask/hoodie, /datum/hair_mask/standard_hat_low))
		vox.hair_masks = list(mask_type)
		var/image/masked = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
		TEST_ASSERT(count_visible_pixels(masked) < naked_pixels, "[mask_type] did not trim Vox quills.")
		TEST_ASSERT(count_changed_pixels(naked, masked) > 0, "[mask_type] left every Vox quill pixel unchanged.")
		TEST_ASSERT_NOTEQUAL(jointext(quills.icon_render_key(head), ","), naked_key, "[mask_type] was missing from the Vox quill bodypart cache key.")
		var/image/cached = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
		TEST_ASSERT_EQUAL(masked.icon, cached.icon, "Identical Vox quill masks did not reuse their cached icon.")

	vox.hair_masks = null
	var/image/restored = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	TEST_ASSERT_EQUAL(count_changed_pixels(naked, restored), 0, "Removing a hair mask changed the naked Vox quill sprite.")
	TEST_ASSERT_EQUAL(jointext(quills.icon_render_key(head), ","), naked_key, "Removing a hair mask did not restore the naked Vox quill cache key.")

	vox.hair_masks = list(/datum/hair_mask/winterhood)
	var/image/kingly_masked = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	quills.set_appearance(/datum/sprite_accessory/vox_quills/shortquills)
	var/image/short_masked = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	TEST_ASSERT_NOTEQUAL(kingly_masked.icon, short_masked.icon, "Different Vox quill styles shared a masked icon cache entry.")
	quills.set_appearance(/datum/sprite_accessory/vox_quills/kingly)
	var/image/kingly_again = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	TEST_ASSERT_EQUAL(kingly_again.icon, kingly_masked.icon, "Changing Vox quill styles corrupted the previous masked cache entry.")
	vox.hair_masks = null

/// Real equipment updates must add/remove masking even when a hood does not set HIDEHAIR.
/datum/unit_test/vox_quill_hair_masks/live_equipment/Run()
	var/mob/living/carbon/human/consistent/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	var/obj/item/bodypart/head/head = vox.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/quills/vox/organ = vox.get_organ_by_type(/obj/item/organ/quills/vox)
	var/datum/bodypart_overlay/mutant/quills/vox/quills = organ.bodypart_overlay
	quills.set_appearance(/datum/sprite_accessory/vox_quills/kingly)
	vox.update_body()
	var/image/naked = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	var/naked_key = jointext(quills.icon_render_key(head), ",")
	var/obj/item/clothing/head/hooded/winterhood/hood = allocate(/obj/item/clothing/head/hooded/winterhood)
	TEST_ASSERT(!(hood.flags_inv & HIDEHAIR), "Winter hood fixture unexpectedly hides all hair.")
	TEST_ASSERT(vox.equip_to_slot_if_possible(hood, ITEM_SLOT_HEAD, disable_warning = TRUE), "Could not equip the Vox winter hood fixture.")
	TEST_ASSERT(hood.hair_mask in vox.hair_masks, "Equipping a hood did not register the live Vox hair mask.")
	TEST_ASSERT(quills.can_draw_on_bodypart(head, vox), "Hair masking hid the whole Vox quill organ instead of trimming it.")
	var/image/masked = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	TEST_ASSERT(count_visible_pixels(masked) < count_visible_pixels(naked), "The equipped hood left Vox quills protruding unchanged.")
	TEST_ASSERT_NOTEQUAL(jointext(quills.icon_render_key(head), ","), naked_key, "Equipping a hood retained the naked Vox quill render cache key.")
	TEST_ASSERT(vox.temporarilyRemoveItemFromInventory(hood, force = TRUE), "Could not remove the Vox winter hood fixture.")
	TEST_ASSERT(!LAZYLEN(vox.hair_masks), "Removing a hood retained the live Vox hair mask.")
	var/image/restored = quills.get_image(head, EXTERNAL_ADJACENT, -BODY_ADJ_LAYER)
	TEST_ASSERT_EQUAL(count_changed_pixels(naked, restored), 0, "Removing the equipped hood did not restore all four directions of Vox quills.")
	TEST_ASSERT_EQUAL(jointext(quills.icon_render_key(head), ","), naked_key, "Removing the equipped hood retained the masked Vox quill render cache key.")

/datum/unit_test/vox_quill_hair_masks/proc/count_visible_pixels(image/appearance)
	var/pixels = 0
	for(var/direction in GLOB.cardinals)
		var/icon/sprite = icon(appearance.icon, appearance.icon_state, direction)
		for(var/x in 1 to sprite.Width())
			for(var/y in 1 to sprite.Height())
				if(sprite.GetPixel(x, y))
					pixels++
	return pixels

/datum/unit_test/vox_quill_hair_masks/proc/count_changed_pixels(image/first, image/second)
	var/pixels = 0
	for(var/direction in GLOB.cardinals)
		var/icon/first_sprite = icon(first.icon, first.icon_state, direction)
		var/icon/second_sprite = icon(second.icon, second.icon_state, direction)
		for(var/x in 1 to first_sprite.Width())
			for(var/y in 1 to first_sprite.Height())
				if(first_sprite.GetPixel(x, y) != second_sprite.GetPixel(x, y))
					pixels++
	return pixels
