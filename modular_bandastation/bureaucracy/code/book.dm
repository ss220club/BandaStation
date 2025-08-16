/// UI actions for book
/obj/item/book/ui_act(action, params)
	var/datum/tgui/ui = SStgui.get_open_ui(usr, src)
	switch(action)
		if("next_spread")
			book_data.next_spread()
			if(ui) ui.send_update(usr)
			return TRUE

		if("prev_spread")
			book_data.prev_spread()
			if(ui) ui.send_update(usr)
			return TRUE

		if("tear_page")
			var/side = istext(params?["side"]) ? lowertext(params["side"]) : "left"
			tear_out_page_side(usr, side)
			SStgui.try_update_ui(usr, src)
			return TRUE

	return ..()

/// Tears out a page from the book
/obj/item/book/proc/tear_out_page_side(mob/living/user, side)
	if(!book_data) return FALSE

	book_data.ensure_pages()
	book_data.normalize_left()

	var/left = book_data.current_page_index
	var/right = left + 1
	var/count = book_data.get_page_count()

	var/target_index = left
	if(side == "right")
		if(right > count)
			to_chat(user, span_warning("Правой страницы нет."))
			return FALSE
		target_index = right

	var/text = book_data.get_page_text(target_index)
	if(!istext(text) || !length(text))
		to_chat(user, span_warning("Эту страницу нельзя вырвать."))
		return FALSE

	var/obj/item/paper/page = new /obj/item/paper(get_turf(user))
	page.raw_text_inputs = list(new /datum/paper_input(text))
	page.update_icon_state()

	book_data.tear_page(target_index)
	to_chat(user, span_notice("Ты вырываешь страницу из [src]."))
	return TRUE
