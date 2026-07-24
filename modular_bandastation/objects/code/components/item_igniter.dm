/datum/component/item_igniter
	/// Whether this component can ignite items
	var/can_ignite_items = FALSE

/datum/component/item_igniter/Initialize()
	. = ..()

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/item_igniter/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby))
	RegisterSignal(parent, CHANGE_IGNITION_STATE, PROC_REF(change_ignition_state))

/datum/component/item_igniter/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, CHANGE_IGNITION_STATE)

/// Signal handler to change ignition ability state
/datum/component/item_igniter/proc/change_ignition_state(atom/source, state)
	SIGNAL_HANDLER
	can_ignite_items = state

/datum/component/item_igniter/proc/check_oxygen()
	var/obj/parent_obj = parent
	if(iscarbon(parent_obj.loc))
		parent_obj = parent_obj.loc
	if(isopenturf(parent_obj.loc))
		var/turf/open/parent_turf = parent_obj.loc
		if(parent_turf.air?.moles[/datum/gas/oxygen] >= 5)
			return TRUE
	return FALSE

/datum/component/item_igniter/proc/attackby(atom/source, obj/item/attacking_item, mob/user,params)
	SIGNAL_HANDLER

	if(!can_ignite_items)
		return COMPONENT_NO_AFTERATTACK

	INVOKE_ASYNC(src, PROC_REF(try_fire_act_item), source, attacking_item, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/item_igniter/proc/try_fire_act_item(atom/source, obj/item/attacking_item, mob/user)
	if(QDELETED(source) || QDELETED(attacking_item) || QDELETED(user))
		return

	if(!can_ignite_items || !check_oxygen())
		return

	if(!(attacking_item.resistance_flags & FLAMMABLE) || (attacking_item.resistance_flags & FIRE_PROOF))
		return

	user.visible_message(
		span_warning("[user] подносит [attacking_item.declent_ru(ACCUSATIVE)] к [source.declent_ru(DATIVE)]."),
		span_warning("Вы подносите [attacking_item.declent_ru(ACCUSATIVE)] к [source.declent_ru(DATIVE)]."),
	)

	var/fire_act_delay = choose_delay(attacking_item)

	if(!do_after(user, fire_act_delay, target = attacking_item))
		return

	if(QDELETED(source) || !can_ignite_items)
		return

	attacking_item.fire_act()

/datum/component/item_igniter/proc/choose_delay(obj/item/attacking_item)
	switch(attacking_item.w_class)
		if(WEIGHT_CLASS_TINY)
			return 0.5 SECONDS
		if(WEIGHT_CLASS_SMALL)
			return 1 SECONDS
		if(WEIGHT_CLASS_NORMAL)
			return 1.5 SECONDS
		if(WEIGHT_CLASS_BULKY)
			return 2 SECONDS
		if(WEIGHT_CLASS_HUGE)
			return 2.5 SECONDS
		if(WEIGHT_CLASS_GIGANTIC)
			return 3 SECONDS

	return 1.5 SECONDS
