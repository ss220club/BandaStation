/// Returns a list of slots that are *visibly* covered by clothing and thus cannot be seen by others
/mob/living/carbon/proc/check_obscured_slots()
	var/hidden_slots = NONE

	for(var/obj/item/equipped_item in get_equipped_items())
		hidden_slots |= equipped_item.flags_inv

	return hidden_slots_to_inventory_slots(hidden_slots)

/// Returns a list of slots that are protected by other clothing, but could possibly be seen by others, via transparent visors and similar stuff
/mob/living/carbon/proc/check_covered_slots()
	var/hidden_slots = NONE

	for(var/obj/item/equipped_item in get_equipped_items())
		hidden_slots |= equipped_item.flags_inv | equipped_item.transparent_protection

	return hidden_slots_to_inventory_slots(hidden_slots)

/// Convers HIDEX to ITEM_SLOT_X, should be phased out in favor of using latter everywhere later
/proc/hidden_slots_to_inventory_slots(hidden_slots)
	var/obscured = NONE
	if(hidden_slots & HIDENECK)
		obscured |= ITEM_SLOT_NECK
	if(hidden_slots & HIDEMASK)
		obscured |= ITEM_SLOT_MASK
	if(hidden_slots & HIDEBELT)
		obscured |= ITEM_SLOT_BELT
	if(hidden_slots & HIDEEYES)
		obscured |= ITEM_SLOT_EYES
	if(hidden_slots & HIDEEARS)
		obscured |= ITEM_SLOT_EARS
	if(hidden_slots & HIDEGLOVES)
		obscured |= ITEM_SLOT_GLOVES
	if(hidden_slots & HIDEJUMPSUIT)
		obscured |= ITEM_SLOT_ICLOTHING
	if(hidden_slots & HIDESHOES)
		obscured |= ITEM_SLOT_FEET
	if(hidden_slots & HIDESUITSTORAGE)
		obscured |= ITEM_SLOT_SUITSTORE
	if(hidden_slots & HIDEHEADGEAR)
		obscured |= ITEM_SLOT_HEAD
	return obscured

/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_NECK)
			return wear_neck
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed

	return ..()

/mob/living/carbon/get_slot_by_item(obj/item/looking_for)
	if(looking_for == back)
		return ITEM_SLOT_BACK

	if(looking_for == wear_mask)
		return ITEM_SLOT_MASK

	if(looking_for == wear_neck)
		return ITEM_SLOT_NECK

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == handcuffed)
		return ITEM_SLOT_HANDCUFFED

	if(looking_for == legcuffed)
		return ITEM_SLOT_LEGCUFFED

	return ..()

/// Returns items which are currently visible on the mob
/mob/living/carbon/proc/get_visible_items()
	var/static/list/visible_slots = list(
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_ICLOTHING,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_EYES,
		ITEM_SLOT_EARS,
		ITEM_SLOT_MASK,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_FEET,
		ITEM_SLOT_ID,
		ITEM_SLOT_BELT,
		ITEM_SLOT_BACK,
		ITEM_SLOT_NECK,
		ITEM_SLOT_HANDS,
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_HANDCUFFED,
		ITEM_SLOT_LEGCUFFED,
	)
	var/list/obscured = check_obscured_slots()
	var/list/visible_items = list()
	for (var/slot in visible_slots)
		if (obscured & slot)
			continue
		var/obj/item/equipped = get_item_by_slot(slot)
		if (equipped)
			visible_items += equipped
	for (var/obj/item/held in held_items)
		visible_items += held
	return visible_items

/mob/living/carbon/proc/equip_in_one_of_slots(obj/item/equipping, list/slots, qdel_on_fail = TRUE, indirect_action = FALSE)
	var/static/list/equip_slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_HANDS = ITEM_SLOT_HANDS,
		LOCATION_GLOVES = ITEM_SLOT_GLOVES,
		LOCATION_EYES = ITEM_SLOT_EYES,
		LOCATION_MASK = ITEM_SLOT_MASK,
		LOCATION_HEAD = ITEM_SLOT_HEAD,
		LOCATION_NECK = ITEM_SLOT_NECK,
		LOCATION_ID = ITEM_SLOT_ID,
	)
	var/static/list/storage_slots = list(
		LOCATION_BACKPACK = ITEM_SLOT_BACK,
	)

	for(var/slot in slots)
		if(equip_slots[slot])
			if(equip_to_slot_if_possible(equipping, equip_slots[slot], disable_warning = TRUE, indirect_action = indirect_action))
				return slot
		else if (storage_slots[slot])
			if(equip_to_storage(equipping, storage_slots[slot], indirect_action = indirect_action))
				return slot
	if(qdel_on_fail)
		qdel(equipping)
	return null

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
	if(!slot)
		return

	if(!istype(equipping))
		return

	var/index = get_held_index_of_item(equipping)
	if(index)
		held_items[index] = null

	if(equipping.pulledby)
		equipping.pulledby.stop_pulling()

	equipping.screen_loc = null
	if(client)
		client.screen -= equipping

	if(observers?.len)
		for(var/mob/dead/observe as anything in observers)
			if(observe.client)
				observe.client.screen -= equipping

	equipping.forceMove(src)
	SET_PLANE_EXPLICIT(equipping, ABOVE_HUD_PLANE, src)
	equipping.appearance_flags |= NO_CLIENT_COLOR
	var/not_handled = FALSE

	switch(slot)
		if(ITEM_SLOT_BACK)
			if(back)
				return
			back = equipping
			update_worn_back()
		if(ITEM_SLOT_MASK)
			if(wear_mask)
				return
			wear_mask = equipping
			update_worn_mask()
		if(ITEM_SLOT_HEAD)
			if(head)
				return
			head = equipping
			update_worn_head()
		if(ITEM_SLOT_NECK)
			if(wear_neck)
				return
			wear_neck = equipping
			update_worn_neck(equipping)
		if(ITEM_SLOT_HANDCUFFED)
			set_handcuffed(equipping)
			update_handcuffed()
		if(ITEM_SLOT_LEGCUFFED)
			legcuffed = equipping
			update_worn_legcuffs()
		if(ITEM_SLOT_HANDS)
			put_in_hands(equipping)
			update_held_items()
		else
			not_handled = TRUE

	//Item has been handled at this point and equipped callback can be safely called
	//We cannot call it for items that have not been handled as they are not yet correctly
	//in a slot (handled further down inheritance chain, probably living/carbon/human/equip_to_slot
	if(!not_handled)
		has_equipped(equipping, slot, initial)

	return not_handled

/mob/living/carbon/has_equipped(obj/item/item, slot, initial)
	. = ..()
	hud_used?.update_locked_slots()

/mob/living/carbon/get_equipped_speed_mod_items()
	return ..() + get_equipped_items()

/mob/living/carbon/doUnEquip(obj/item/item_dropping, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !item_dropping) //We don't want to set anything to null if the parent returned 0.
		return

	var/not_handled = FALSE //if we actually unequipped an item, this is because we dont want to run this proc twice, once for carbons and once for humans
	if(item_dropping == head)
		head = null
		if(!QDELETED(src))
			update_worn_head()
	else if(item_dropping == back)
		back = null
		if(!QDELETED(src))
			update_worn_back()
	else if(item_dropping == wear_mask)
		wear_mask = null
		if(!QDELETED(src))
			update_worn_mask()
	else if(item_dropping == wear_neck)
		wear_neck = null
		if(!QDELETED(src))
			update_worn_neck(item_dropping)
	else if(item_dropping == handcuffed)
		set_handcuffed(null)
		if(buckled?.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		if(!QDELETED(src))
			update_handcuffed()
	else if(item_dropping == legcuffed)
		legcuffed = null
		if(!QDELETED(src))
			update_worn_legcuffs()
	else
		not_handled = TRUE

	// Not an else-if because we're probably equipped in another slot
	if(item_dropping == internal && (QDELETED(src) || QDELETED(item_dropping) || item_dropping.loc != src))
		cutoff_internals()
		if(!QDELETED(src))
			update_mob_action_buttons(UPDATE_BUTTON_STATUS)

	if(not_handled)
		return

	update_equipment_speed_mods()
	update_obscured_slots(item_dropping.flags_inv)
	hud_used?.update_locked_slots()

/// Returns the helmet if an air tank compatible helmet is equipped.
/mob/living/carbon/proc/can_breathe_helmet()
	if (isclothing(head) && (head.clothing_flags & HEADINTERNALS))
		return head

/// Returns the mask if an air tank compatible mask is equipped.
/mob/living/carbon/proc/can_breathe_mask()
	if (isclothing(wear_mask) && (wear_mask.clothing_flags & MASKINTERNALS))
		return wear_mask

/// Returns the tube if a breathing tube is equipped.
/mob/living/carbon/proc/can_breathe_tube()
	return get_organ_slot(ORGAN_SLOT_BREATHING_TUBE)

/// Returns the object that allows us to breathe internals - tube implant, mask or helmet
/mob/living/carbon/proc/can_breathe_internals()
	return can_breathe_tube() || can_breathe_mask() || can_breathe_helmet()

/// Returns truthy if air tank is open and mob lacks apparatus, or if the tank moved away from the mob.
/mob/living/carbon/proc/invalid_internals()
	return (internal || external) && (!can_breathe_internals() || (internal && internal.loc != src))

/**
 * Open the internal air tank without checking for any breathing apparatus.
 * Returns TRUE if the air tank was opened successfully.
 * Closes any existing tanks before opening another one.
 *
 * Arguments:
 * * tank - The given tank to open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!target_tank)
		return
	close_all_airtanks()
	if (is_external)
		external = target_tank
	else
		internal = target_tank
	target_tank.after_internals_opened(src)
	update_mob_action_buttons()
	return TRUE

/**
 * Opens the given internal air tank if a breathing apparatus is found. Returns TRUE if successful, FALSE otherwise.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank we will attempt to toggle open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/try_open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!can_breathe_internals())
		return
	return open_internals(target_tank, is_external)

/**
 * Actually closes the active internal or external air tank.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/close_internals(is_external = FALSE)
	var/obj/item/tank/target_tank = is_external ? external : internal
	if (!target_tank)
		return
	if (is_external)
		external = null
	else
		internal = null
	target_tank.after_internals_closed(src)
	update_mob_action_buttons()
	//To make sure it stops at a timely manner when you turn off internals
	breathing_loop.stop()
	return TRUE

/// Close the the currently open external (that's EX-ternal) air tank. Returns TRUE if successful.
/mob/living/carbon/proc/close_externals()
	return close_internals(TRUE)

/// Quickly/lazily close all airtanks without any returns or notifications.
/mob/living/carbon/proc/close_all_airtanks()
	if (external)
		close_externals()
	if (internal)
		close_internals()

/**
 * Prepares to open the internal air tank and notifies the mob in chat.
 * Handles displaying messages to the user before doing the actual opening.
 * Returns TRUE if the tank was opened/closed successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/toggle_open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!target_tank)
		return
	if(internal || (is_external && external))
		to_chat(src, span_notice("Вы начинаете дышать из [target_tank.declent_ru(GENITIVE)]."))
	else
		to_chat(src, span_notice("Вы открываете клапан на [target_tank.declent_ru(PREPOSITIONAL)]."))
	return open_internals(target_tank, is_external)

/**
 * Prepares to close the currently open internal air tank and notifies in chat.
 * Handles displaying messages to the user before doing the actual closing.
 * Returns TRUE if
 *
 * Arguments:
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/toggle_close_internals(is_external = FALSE)
	if (!internal && !external)
		return
	to_chat(src, span_notice("Вы перекрываете клапан на [is_external ? external.declent_ru(PREPOSITIONAL) : internal.declent_ru(PREPOSITIONAL)]."))
	return close_internals(is_external)

/// Prepares emergency disconnect from open air tanks and notifies in chat. Usually called after mob suddenly unequips breathing apparatus.
/mob/living/carbon/proc/cutoff_internals()
	if (!external && !internal)
		return
	to_chat(src, span_notice("Вы перестаете дышать из [external?.declent_ru(GENITIVE) || internal?.declent_ru(GENITIVE)], и клапан перекрывается."))
	close_all_airtanks()

/**
 * Toggles the given internal air tank open, or close the currently open one, if a compatible breathing apparatus is found.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from internally.
 */
/mob/living/carbon/proc/toggle_internals(obj/item/tank)
	// Carbons can't open their own internals tanks.
	return FALSE

/**
 * Toggles the given external (that's EX-ternal) air tank open, or close the currently open one, if a compatible breathing apparatus is found.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from externally.
 */
/mob/living/carbon/proc/toggle_externals(obj/item/tank)
	// Carbons can't open their own externals tanks.
	return FALSE

/mob/living/carbon/proc/get_holding_bodypart_of_item(obj/item/I)
	var/index = get_held_index_of_item(I)
	return index && hand_bodyparts[index]

///Returns a list of all body_zones covered by clothing
/mob/living/carbon/proc/get_covered_body_zones()
	RETURN_TYPE(/list)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/covered_flags = NONE
	var/list/all_worn_items = get_equipped_items()
	for(var/obj/item/worn_item in all_worn_items)
		covered_flags |= worn_item.body_parts_covered

	return cover_flags2body_zones(covered_flags)

///Returns a bitfield of all zones covered by clothing
/mob/living/carbon/proc/get_all_covered_flags()
	SHOULD_NOT_OVERRIDE(TRUE)

	var/covered_flags = NONE
	var/list/all_worn_items = get_equipped_items()
	for(var/obj/item/worn_item in all_worn_items)
		covered_flags |= worn_item.body_parts_covered

	return covered_flags

/// Attempts to equip the given item in a conspicious place.
/// This is used when, for instance, a character spawning with an item
/// in their hands would be a dead giveaway that they are an antagonist.
/// Returns the human readable name of where it placed the item, or null otherwise.
/mob/living/carbon/proc/equip_conspicuous_item(obj/item/item, delete_item_if_failed = TRUE)
	var/static/list/pockets = list(
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)

	var/placed_in = equip_in_one_of_slots(item, pockets, qdel_on_fail = FALSE, indirect_action = TRUE)

	if (!placed_in)
		placed_in = equip_to_storage(item, ITEM_SLOT_BACK, indirect_action = TRUE)

	if (isnull(placed_in) && delete_item_if_failed)
		qdel(item)

	return placed_in
