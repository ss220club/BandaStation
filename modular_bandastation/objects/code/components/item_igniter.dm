/datum/component/item_igniter
	/// Whether this component can ignite items
	var/can_ignite_items = TRUE

/datum/component/item_igniter/Initialize()
	. = ..()

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/item_igniter/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ITEM_IGNITION_STATE_CHANGED, PROC_REF(on_ignition_state_changed))

/datum/component/item_igniter/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ITEM_IGNITION_STATE_CHANGED)

/// Signal handler to change ignition ability state
/datum/component/item_igniter/proc/on_ignition_state_changed(atom/source, state)
	SIGNAL_HANDLER
	can_ignite_items = state

/datum/component/item_igniter/proc/on_attackby(atom/source, obj/item/attacking_item, mob/user,params)
	SIGNAL_HANDLER

	if(!can_ignite_items)
		return

	if(attacking_item.is_open_container())
		return

	INVOKE_ASYNC(src, PROC_REF(try_fire_act_item), source, attacking_item, user)

	return COMPONENT_NO_AFTERATTACK

/datum/component/item_igniter/proc/try_fire_act_item(atom/source, obj/item/attacking_item, mob/user)
	if(QDELETED(source) || QDELETED(attacking_item) || QDELETED(user))
		return

	if(!can_ignite_items)
		return

	user.visible_message(
		span_warning("[user] подносит [attacking_item.declent_ru(ACCUSATIVE)] к [source.declent_ru(DATIVE)]."),
		span_warning("Вы подносите [attacking_item.declent_ru(ACCUSATIVE)] к [source.declent_ru(DATIVE)]."),
	)

	var/fire_act_delay = choose_delay(attacking_item)

	if(!do_after(user, fire_act_delay, target = attacking_item))
		return

	if(QDELETED(source) || QDELETED(attacking_item) || !can_ignite_items)
		return

	attacking_item.fire_act()

	// Signal that ignition was successful
	SEND_SIGNAL(parent, COMSIG_ITEM_IGNITION_SUCCESS, attacking_item, user)

/datum/component/item_igniter/proc/choose_delay(obj/item/attacking_item)
	var/static/list/delay_by_w_class = list(
		WEIGHT_CLASS_TINY = 0.5 SECONDS,
		WEIGHT_CLASS_SMALL = 1 SECONDS,
		WEIGHT_CLASS_NORMAL = 1.5 SECONDS,
		WEIGHT_CLASS_BULKY = 2 SECONDS,
		WEIGHT_CLASS_HUGE = 2.5 SECONDS,
		WEIGHT_CLASS_GIGANTIC = 3 SECONDS,
	)

	return delay_by_w_class[attacking_item.w_class] || 1.5 SECONDS
