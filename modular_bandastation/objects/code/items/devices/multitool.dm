/obj/item/multitool
	var/stored_button_id = null

//MARK: Save ID buffer for button from SS220BS
/obj/item/multitool/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)

	//--------------------------------------------------
	// УСТАНОВКА ID КНОПКЕ
	//--------------------------------------------------

	if(istype(interacting_with, /obj/machinery/button))

		var/obj/machinery/button/B = interacting_with

		if(!stored_button_id)
			to_chat(user, span_warning("В мультитуле нет сохранённого ID!"))
			return ITEM_INTERACT_BLOCKING

		B.id = stored_button_id

		to_chat(user, span_notice("Вы устанавливаете ID кнопки на '[stored_button_id]'."))

		playsound(src, 'sound/machines/click.ogg', 30, TRUE)

		return ITEM_INTERACT_BLOCKING

	//--------------------------------------------------
	// УСТАНОВКА ID КОНТРОЛЛЕРУ
	//--------------------------------------------------

	if(istype(interacting_with, /obj/item/assembly/control))

		var/obj/item/assembly/control/C = interacting_with

		if(!stored_button_id)
			to_chat(user, span_warning("В мультитуле нет сохранённого ID!"))
			return ITEM_INTERACT_BLOCKING

		C.id = stored_button_id

		to_chat(user, span_notice("Вы устанавливаете ID контроллера на '[stored_button_id]'."))

		playsound(src, 'sound/machines/click.ogg', 30, TRUE)

		return ITEM_INTERACT_BLOCKING

	//--------------------------------------------------
	// СЧИТЫВАНИЕ ID С УСТРОЙСТВА
	//--------------------------------------------------

	if(isnull(interacting_with:id))
		to_chat(user, span_warning("У объекта отсутствует ID."))
		return ITEM_INTERACT_BLOCKING

	stored_button_id = interacting_with:id

	to_chat(user, span_notice("Мультитул сохраняет ID: '[stored_button_id]'."))

	playsound(src, 'sound/items/taperecorder/tape_flip.ogg', 30, TRUE)

	return ITEM_INTERACT_BLOCKING

	//--------------------------------------------------
	// ОЧИСТКА БУФЕРА ID
	//--------------------------------------------------

/obj/item/multitool/proc/unique_action(mob/living/user)

	if(!stored_button_id)
		to_chat(user, span_warning("Буфер мультитула уже пуст."))
		return

	stored_button_id = null

	to_chat(user, span_notice("Вы очищаете буфер ID мультитула."))

	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
