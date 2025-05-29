
/obj/item/organ/cyberimp/arm/toolkit/centcom
	name = "centcom combat implant"
	desc = "A powerful, military-grade cybernetic implant, designed to provide the user with combat useful devices from its arm."
	items_to_create = list(
		/obj/item/melee/energy/blade/hardlight,
		/obj/item/gun/medbeam,
		/obj/item/borg/stun,
		/obj/item/gun/energy/pulse/pistol/m1911
	)

/obj/item/organ/cyberimp/arm/toolkit/centcom/Extend(obj/item/augment)
	. = ..()
	UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF_SECONDARY)

/obj/item/organ/cyberimp/arm/toolkit/custom
	name = "custom arm implant"
	desc = "A custom arm implant, designed to be filled with whatever the user wants."
	aug_overlay = "toolkit"
	items_to_create = list()
	var/max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/organ/cyberimp/arm/toolkit/custom/attackby(obj/item/I, mob/user, params)
	if(LAZYLEN(items_list) == 1)
		var/datum/weakref/ref = items_list[1]
		active_item = ref.resolve()
	if(active_item)
		if(I.tool_behaviour != TOOL_SCREWDRIVER)
			to_chat(user, span_warning("There's already an item stored in [src]!"))
			return
		items_list -= WEAKREF(active_item)
		user.put_in_hands(active_item)
		REMOVE_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
		to_chat(user, span_notice("You carefully remove [active_item] from [src] with [I]."))
		playsound(get_turf(src), 'sound/items/tools/screwdriver.ogg', 50, TRUE)
		active_item = null
		return

	if(I.w_class > max_w_class)
		to_chat(user, span_warning("[I] is too big to fit in [src]!"))
		return

	if(!user.transferItemToLoc(I, src))
		return

	items_list += WEAKREF(I)
	active_item = I
	to_chat(user, span_notice("You insert [I] into [src]."))
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)

/obj/item/organ/cyberimp/arm/toolkit/custom/on_mob_remove(mob/living/carbon/arm_owner)
	if(active_item)
		Retract()
	return ..()

/obj/item/organ/cyberimp/arm/toolkit/custom/Destroy()
	if(active_item)
		QDEL_NULL(active_item)
	return ..()
