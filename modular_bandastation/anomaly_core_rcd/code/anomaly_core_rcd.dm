/datum/design/rcd_loaded
	name = "Rapid Construction Device (RCD)"
	build_path = /obj/item/construction/rcd/no_core

/obj/item/construction/rcd
	var/core_inserted = TRUE

/obj/item/construction/rcd/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!check_anomaly_core(user))
		return
	. = ..()

/obj/item/construction/rcd/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/assembly/signaler/anomaly/bluespace))
		return
	if(!check_anomaly_core(user))
		return
	. = ..()

/obj/item/construction/rcd/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/assembly/signaler/anomaly/bluespace))
		if(core_inserted)
			to_chat(user, span_warning("В [declent_ru(ACCUSATIVE)] уже вставлено ядро!"))
			balloon_alert(user, "уже есть ядро")
			return

		to_chat(user, span_notice("Вы вставляете [attacking_item.declent_ru(NOMINATIVE)] в [declent_ru(ACCUSATIVE)] и инструмент оживает."))
		balloon_alert(user, "ядро вставлено")
		core_inserted = TRUE
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		qdel(attacking_item)
		return

	. = ..()

/obj/item/construction/rcd/no_core
	core_inserted = FALSE

/obj/item/construction/rcd/proc/check_anomaly_core(mob/user)
	if(!core_inserted)
		balloon_alert(user, "нет ядра аномалии!")
		return FALSE

	return TRUE

/obj/item/construction/rcd/examine(mob/user)
	. = ..()
	if(!core_inserted)
		. += "Это просто пустая оболочка без ядра аномалии"
