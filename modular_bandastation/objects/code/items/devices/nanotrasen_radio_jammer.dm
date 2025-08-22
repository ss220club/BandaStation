/proc/is_within_nt_radio_jammer_range(atom/source)
    for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
        if(IN_GIVEN_RANGE(source, jammer, jammer.range))
            if(!istype(jammer, /obj/item/jammer/nt))
                continue
            return TRUE
    return FALSE

/obj/item/jammer/nt
	name = "Nanotrasen radio jammer"
	desc = "Корпоративный генератор помех Нанотрейзен. Компактное устройство, способное эффективно блокировать широкий спектр радиочастот. На обратной стороне выгравировано: «Собственность корпорации Нанотрейзен. Корпорация не несёт ответственности за использование устройства третьими лицами, а также за любые действия, совершённые с его применением в случае кражи»."
	icon = 'modular_bandastation/objects/icons/obj/items/nt_radio_jammer.dmi'
	icon_state = "nt_jammer_v2"
	range = 18
	var/centcom_blackout = FALSE

/obj/item/jammer/nt/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/jammer/nt/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_RMB] = "Переключить"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/jammer/nt/attack_self(mob/user, modifiers)
    return

/obj/item/jammer/nt/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
    return

/obj/item/jammer/nt/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("Ты [active ? "деактивируешь" : "активируешь"] [declent_ru(NOMINATIVE)]."))
	user.balloon_alert(user, "[declent_ru(NOMINATIVE)] [active ? "выключен" : "включен"].")
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/jammer/nt/Destroy()
	GLOB.active_jammers -= src
	return ..()
