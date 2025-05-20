/obj/item/stealth
	name = "stealth device"
	icon = 'modular_bandastation/objects/icons/obj/items/spy_spider.dmi'
	icon_state = "spy_spider"
	var/aim_dir = NORTH
	var/install_delay = 3 SECONDS
	var/is_silent_install = TRUE
	var/is_visible_after_install = FALSE
	var/atom/target
	var/list/spotted_by = list()

/obj/item/stealth/Initialize(mapload)
	. = ..()

/obj/item/stealth/proc/register_signals()
	RegisterSignal(target, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY, PROC_REF(on_target_attackby_secondary))

/obj/item/stealth/proc/unregister_signals()
	if(target)
		UnregisterSignal(target, list(COMSIG_DETECTIVE_SCANNED, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY))
		target = null

/obj/item/stealth/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(isdead(interacting_with))
		return NONE
	aim_dir = get_dir(user, interacting_with)
	return plant_stealth_device(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/item/stealth/proc/plant_stealth_device(atom/installation_target, mob/living/user)
	to_chat(user, span_notice("You start planting [src]..."))
	if(!do_after(user, install_delay, target = installation_target, hidden = is_silent_install))
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	target = installation_target
	target.contents += src
	register_signals()
	on_plant(target, user)
	if(is_visible_after_install)
		mutate_overlay(target, user)

/obj/item/stealth/Destroy()
	unregister_signals()
	return ..()

/obj/item/stealth/proc/on_plant(atom/installation_target, mob/living/user)
	return

/obj/item/stealth/proc/mutate_overlay(atom/installation_target, mob/living/user)
	return

/obj/item/stealth/proc/on_scan(datum/source, mob/user, list/extra_data)
	SIGNAL_HANDLER
	LAZYOR(spotted_by, user)
	LAZYADD(extra_data[DETSCAN_CATEGORY_ILLEGAL], "Обнаружен скрытый объект: [src].")
	to_chat(user, span_alert("Обнаружен скрытый объект: [src]"))

/obj/item/stealth/proc/on_target_attackby_secondary(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(istype(tool, /obj/item/detective_scanner) && LAZYFIND(spotted_by, user))
		INVOKE_ASYNC(src, PROC_REF(remove_stealth_device), user)
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/obj/item/stealth/proc/remove_stealth_device(mob/user)
	to_chat(user, span_warning("Вы начинаете извлечение скрытого объекта: из [target]..."))
	if(do_after(user, 5 SECONDS, target))
		if(user.put_in_hands(src))
			to_chat(user, span_warning("Скрытный объект был извлечён: [src]"))
			unregister_signals()
		else
			to_chat(user, span_warning("Не удалось извлечь скрытый объект: [src]"))

