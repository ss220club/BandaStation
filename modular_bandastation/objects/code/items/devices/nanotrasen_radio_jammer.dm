/obj/item/nt_jammer
	name = "Nanotrasen radio jammer"
	desc = "Корпоративный генератор помех Нанотрейзен. Компактное устройство, способное эффективно блокировать широкий спектр радиочастот. На обратной стороне выгравировано: «Собственность корпорации Нанотрейзен. Корпорация не несёт ответственности за использование устройства третьими лицами, а также за любые действия, совершённые с его применением в случае кражи»."
	icon = 'modular_bandastation/objects/icons/obj/items/nt_radio_jammer.dmi'
	icon_state = "nt_jammer"
	var/active = FALSE

	/// The range of devices to disable while active
	var/range = 18


/obj/item/nt_jammer/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/nt_jammer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_RMB] = "Toggle"
	return CONTEXTUAL_SCREENTIP_SET


/obj/item/nt_jammer/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("Ты [active ? "деактивируешь" : "активируешь"] [src]."))
	user.balloon_alert(user, "[active ? "выключил" : "включил"] генератор помех")
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/nt_jammer/Destroy()
	GLOB.active_jammers -= src
	return ..()




