/// Datum to handle interactions between a MODsuit and its parts.
/datum/mod_part
	/// The actual item we handle.
	var/obj/item/part_item = null
	/// Are we sealed?
	var/sealed = FALSE
	/// Message to user when unsealed.
	var/unsealed_message
	/// Message to user when sealed.
	var/sealed_message
	/// The layer the item will render on when unsealed.
	var/unsealed_layer
	/// The layer the item will render on when sealed.
	var/sealed_layer
	/// What are we overslotting over?
	var/obj/item/overslotting = null

/datum/mod_part/Destroy()
	// To avoid qdel loops in MOD control units, since they're also a part
	if (!QDELING(part_item))
		qdel(part_item)
	part_item = null
	overslotting = null
	return ..()

/datum/mod_part/proc/set_item(obj/item/new_part)
	part_item = new_part
	RegisterSignal(part_item, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, PROC_REF(get_separate_worn_overlays))

// If we're overslotting an item, add its visual as an underlay
/datum/mod_part/proc/get_separate_worn_overlays(obj/item/source, list/overlays, mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file, bodyshape = NONE)
	SIGNAL_HANDLER

	if (!overslotting || sealed)
		return

	var/checked_slot = source.slot_flags
	if (ismob(source.loc))
		var/mob/as_mob = source.loc
		checked_slot = as_mob.get_slot_by_item(source)
	// BANDASTATION EDIT START - Species clothing icons
	var/mob/living/carbon/human/wearer = source.loc
	var/species_id
	if(istype(wearer))
		switch(checked_slot)
			if(ITEM_SLOT_HEAD, ITEM_SLOT_EYES, ITEM_SLOT_EARS, ITEM_SLOT_MASK)
				species_id = wearer.get_bodypart(BODY_ZONE_HEAD)?.limb_id
			if(ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING, ITEM_SLOT_NECK)
				species_id = wearer.get_bodypart(BODY_ZONE_CHEST)?.limb_id
			else
				species_id = wearer.dna?.species?.id
	var/species_icon = overslotting.get_species_worn_icon(species_id)
	var/mutable_appearance/worn_overlay = overslotting.build_worn_icon(default_layer = -draw_target.layer + 0.1, default_icon_file = get_default_icon_by_slot(checked_slot), override_file = species_icon, bodyshape = bodyshape)
	// BANDASTATION EDIT END - Species clothing icons
	for (var/mutable_appearance/overlay in worn_overlay.overlays)
		overlay.layer = draw_target.layer + 0.1
	overlays += worn_overlay
