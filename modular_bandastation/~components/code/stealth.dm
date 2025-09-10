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
		UnregisterSignal(target, list(COMSIG_DETECTIVE_SCANNED, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY))

/datum/component/stealth_device/proc/on_interact_with_atom(obj/item/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER
	if(isdead(interacting_with))
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
	RegisterSignal(installation_target, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY, PROC_REF(on_target_attackby_secondary))
	RegisterSignal(installation_target, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))
	return TRUE

/datum/component/stealth_device/proc/on_scan(datum/source, mob/user, list/extra_data)
	SIGNAL_HANDLER
	spotted_by[user] = TRUE
	LAZYADD(extra_data[DETSCAN_CATEGORY_ILLEGAL], "Обнаружен скрытый объект: [parent].")
	to_chat(user, span_alert("Обнаружен скрытый объект: [parent]"))

/datum/component/stealth_device/proc/on_target_attackby_secondary(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(istype(tool, /obj/item/detective_scanner) && spotted_by[user])
		INVOKE_ASYNC(src, PROC_REF(remove_stealth_device), user)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/stealth_device/proc/remove_stealth_device(mob/user)
	var/atom/target = target_ref?.resolve()
	if(!target)
		return
	to_chat(user, span_warning("Вы начинаете извлечение скрытого объекта из [target]..."))
	if(do_after(user, removal_delay, target))
		if(user.put_in_hands(parent))
			user.balloon_alert(user, "Извлечено: [parent]")
			unregister_target_signals()
		else
			user.balloon_alert(user, "Не удалось извлечь: [parent]")
