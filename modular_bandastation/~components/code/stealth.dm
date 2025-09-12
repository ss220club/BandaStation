/datum/component/stealth_device
	var/install_delay = 3 SECONDS
	var/is_silent_install = TRUE
	var/removal_delay = 5 SECONDS
	var/list/spotted_by = list()
	var/datum/weakref/target_ref

/datum/component/stealth_device/Initialize(install_delay = 3 SECONDS, is_silent_install = TRUE, removal_delay = 5 SECONDS)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.install_delay = install_delay
	src.is_silent_install = is_silent_install
	src.removal_delay = removal_delay

/datum/component/stealth_device/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_interact_with_atom))

/datum/component/stealth_device/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM)
	unregister_target_signals()

/datum/component/stealth_device/proc/unregister_target_signals()
	var/atom/target = target_ref?.resolve()
	if(target)
		UnregisterSignal(target, list(COMSIG_DETECTIVE_SCANNED, COMSIG_ATOM_ATTACK_HAND_SECONDARY))

/datum/component/stealth_device/proc/on_interact_with_atom(obj/item/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER
	if(isdead(interacting_with) || istype(interacting_with, /turf))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(plant_stealth_device), interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/datum/component/stealth_device/proc/plant_stealth_device(atom/installation_target, mob/living/user)
	var/obj/item/device = parent
	to_chat(user, span_notice("Вы начинаете устанавливать [parent]..."))
	if(!do_after(user, install_delay, target = installation_target, hidden = is_silent_install))
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(parent))
		return FALSE
	target_ref = WEAKREF(installation_target)
	device.forceMove(installation_target)
	RegisterSignal(installation_target, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_secondary_attack_hand))
	RegisterSignal(installation_target, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))
	installation_target.AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = "Извлечь скрытый объект", check_showing_context = CALLBACK(src, PROC_REF(check_showing_context)))
	spotted_by[user.mind] = TRUE
	return TRUE

/datum/component/stealth_device/proc/on_scan(datum/source, mob/user, list/extra_data)
	SIGNAL_HANDLER
	spotted_by[user.mind] = TRUE
	LAZYADD(extra_data[DETSCAN_CATEGORY_ILLEGAL], "Обнаружен скрытый объект: [parent.declent_ru(NOMINATIVE)].")
	to_chat(user, span_alert("Обнаружен скрытый объект: [parent.declent_ru(NOMINATIVE)]"))

/datum/component/stealth_device/proc/on_secondary_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	if(spotted_by[user.mind])
		INVOKE_ASYNC(src, PROC_REF(remove_stealth_device), user)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/stealth_device/proc/remove_stealth_device(mob/user)
	var/atom/target = target_ref?.resolve()
	if(!target)
		return
	to_chat(user, span_warning("Вы начинаете извлечение скрытого объекта из [target.declent_ru(GENITIVE)]..."))
	if(do_after(user, removal_delay, target))
		if(user.put_in_hands(parent))
			user.balloon_alert(user, "Извлечено: [parent.declent_ru(NOMINATIVE)]")
			unregister_target_signals()
			RemoveElement(/datum/element/contextual_screentip_bare_hands)
			spotted_by.Cut()
		else
			user.balloon_alert(user, "Не удалось извлечь: [parent.declent_ru(NOMINATIVE)]")

/datum/component/stealth_device/proc/check_showing_context(datum/source, list/context, obj/item/held_item, mob/user)
	return src.spotted_by[user.mind]

/datum/element/contextual_screentip_bare_hands
	var/datum/callback/check_showing_context

/datum/element/contextual_screentip_bare_hands/Attach(
	datum/target, use_named_parameters,
	lmb_text,
	rmb_text,
	lmb_text_combat_mode,
	rmb_text_combat_mode,
	datum/callback/check_showing_context)
	. = ..()
	src.check_showing_context = check_showing_context

/datum/element/contextual_screentip_bare_hands/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	if(check_showing_context && !check_showing_context.Invoke(source, context, held_item, user))
		return NONE
	. = ..()

