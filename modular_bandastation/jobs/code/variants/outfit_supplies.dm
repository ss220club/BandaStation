/datum/outfit/job
	/// Preserve a role's starting supplies when its selected backpack cannot hold them.
	var/preserve_backpack_supplies = FALSE

/// Keep starting supplies with their recipient before falling back to the floor.
/datum/outfit/job/equip_backpack_item(mob/living/carbon/human/user, item_path)
	. = ..()
	if(. || !preserve_backpack_supplies)
		return
	. = TRUE
	var/obj/item/supply = SSwardrobe.provide_type(item_path, user)
	if(QDELETED(supply))
		return
	if(user.equip_to_storage(supply, ITEM_SLOT_BACK, indirect_action = TRUE) || QDELETED(supply))
		return
	to_chat(user, span_notice("[capitalize(supply.declent_ru(NOMINATIVE))] не помещается в сумку и оставлен рядом с вами."))
	supply.forceMove(user.drop_location())
