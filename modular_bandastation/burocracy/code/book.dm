/obj/item/book/ui_act(action, params)
	var/datum/tgui/ui = SStgui.get_open_ui(usr, src)
	switch(action)
		if("next_page")
			book_data.next_page()
			if(ui)
				ui.update_static_data(usr)
			return TRUE

		if("prev_page")
			book_data.prev_page()
			if(ui)
				ui.send_update(usr)
			return TRUE

		if("tear_page")
			tear_out_page(usr)
			SStgui.try_update_ui(usr, src)
			return TRUE

	return ..()

/obj/item/book/proc/tear_out_page(mob/living/user)
	if (!book_data)
		return FALSE

	book_data.ensure_pages()

	var/page_index = book_data.current_page_index
	var/text = book_data.content
	if (!istext(text))
		to_chat(user, span_warning("This page can't be ripped out."))
		return FALSE

	var/obj/item/paper/page = new /obj/item/paper(get_turf(user))
	page.raw_text_inputs = list(new /datum/paper_input(text))
	page.update_icon_state()

	book_data.remove_page(page_index)

	to_chat(user, span_notice("You tear out a page from [src]."))
	return TRUE




