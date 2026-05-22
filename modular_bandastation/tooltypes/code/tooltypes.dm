//MARK: Присвоение add_context() различным объектам при наведении на них курсором.

/// Кнопки - при взаимодействии с мультитулом.

/obj/machinery/button/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)

	. = ..()

	if(istype(held_item, /obj/item/multitool))

		var/obj/item/multitool/M = held_item

		if(M.stored_id)
			context[SCREENTIP_CONTEXT_RMB] = "Установить ID"
		else
			context[SCREENTIP_CONTEXT_RMB] = "Считать ID"

		return CONTEXTUAL_SCREENTIP_SET

/// Платы, контроллеры - при взаимодействии с мультитулом.

/obj/item/assembly/control/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)

	. = ..()

	if(istype(held_item, /obj/item/multitool))

		var/obj/item/multitool/M = held_item

		if(M.stored_id)
			context[SCREENTIP_CONTEXT_RMB] = "Установить ID"
		else
			context[SCREENTIP_CONTEXT_RMB] = "Считать ID"

		return CONTEXTUAL_SCREENTIP_SET
