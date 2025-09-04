/datum/design/rcd_loaded
	build_path = /obj/item/construction/rcd/no_core

/obj/item/construction/rcd
	var/core_inserted = TRUE


/obj/item/construction/rcd/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/assembly/signaler/anomaly/bluespace) && !core_inserted)
		to_chat(user, span_notice("Вы вставляете [attacking_item.declent_ru(NOMINATIVE)] в [declent_ru(ACCUSATIVE)] и инструмент оживает."))
		core_inserted = TRUE
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		qdel(attacking_item)

/obj/item/construction/rcd/no_core
	core_inserted = FALSE

/obj/item/construction/rcd/proc/check_anomaly_core(mob/user)
	if(!core_inserted)
		to_chat(user, span_warning("Нет ядра аномалии!"))
		balloon_alert(user, "нет ядра аномалии!")
		return FALSE

	return TRUE

/obj/item/construction/rcd/examine(mob/user)
	. = ..()
	if(!core_inserted)
		. += "Это просто пустая оболочка без ядра аномалии"
