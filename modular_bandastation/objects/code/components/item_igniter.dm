/datum/component/item_igniter

/datum/component/item_igniter/Initialize()
	. = ..()

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/item_igniter/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/component/item_igniter/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)

/datum/component/item_igniter/proc/on_attackby(
	atom/source,
	obj/item/attacking_item,
	mob/user,
	params,
)
	SIGNAL_HANDLER

	if(!source.can_ignite_items())
		return

	if(attacking_item.is_open_container())
		return

	INVOKE_ASYNC(
		src,
		PROC_REF(try_fire_act_item),
		source,
		attacking_item,
		user,
	)

	return COMPONENT_NO_AFTERATTACK

/datum/component/item_igniter/proc/try_fire_act_item(
	atom/source,
	obj/item/attacking_item,
	mob/user,
)
	if(
		QDELETED(source)
		|| QDELETED(attacking_item)
		|| QDELETED(user)
	)
		return

	if(!source.can_ignite_items())
		return

	user.visible_message(
		span_warning("[user] подносит [attacking_item.declent_ru(ACCUSATIVE)] к [source.declent_ru(DATIVE)]."),
		span_warning("Вы подносите [attacking_item.declent_ru(ACCUSATIVE)] к [source.declent_ru(DATIVE)]."),
	)

	var/fire_act_delay = choose_delay(attacking_item)

	if(
		!do_after(
			user,
			fire_act_delay,
			target = attacking_item,
		)
	)
		return

	if(
		QDELETED(source)
		|| QDELETED(attacking_item)
		|| !source.can_ignite_items()
	)
		return

	attacking_item.fire_act(
		source.get_igniter_temperature(),
		100,
	)

/datum/component/item_igniter/proc/choose_delay(
	obj/item/attacking_item,
)
	var/static/list/delay_by_w_class = list(
		WEIGHT_CLASS_TINY = 0.5 SECONDS,
		WEIGHT_CLASS_SMALL = 1 SECONDS,
		WEIGHT_CLASS_NORMAL = 1.5 SECONDS,
		WEIGHT_CLASS_BULKY = 2 SECONDS,
		WEIGHT_CLASS_HUGE = 2.5 SECONDS,
		WEIGHT_CLASS_GIGANTIC = 3 SECONDS,
	)

	return delay_by_w_class[attacking_item.w_class] || 2.5 SECONDS
