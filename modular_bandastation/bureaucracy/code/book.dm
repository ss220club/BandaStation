/// UI actions for book — как было
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

/// Вырвать страницу (теперь спавним двусторонний лист и чистим обе стороны)
/obj/item/book/proc/tear_out_page_side(mob/living/user, side)
	if(!book_data)
		return FALSE

	book_data.ensure_pages()
	book_data.normalize_left()

	var/left = book_data.current_page_index
	var/right = left + 1
	var/count = book_data.get_page_count()

	var/target = left
	if(side == "right")
		if(right > count)
			to_chat(user, span_warning("Правой страницы нет."))
			return FALSE
		target = right

	// Определяем пару front/back и порядок удаления
	var/front_idx
	var/back_idx
	var/list/remove_order = list()

	if(target % 2) // нечётная — левый лист
		front_idx = target
		back_idx = (target + 1) <= count ? (target + 1) : null
		// сначала удаляем back (если есть), потом front
		if(back_idx) remove_order += back_idx
		remove_order += front_idx
	else // чётная — правый лист
		front_idx = (target - 1) >= 1 ? (target - 1) : null
		back_idx = target
		// сначала удаляем back (сама целевая), потом front (если есть)
		remove_order += back_idx
		if(front_idx) remove_order += front_idx

	// Собираем тексты
	var/front_text = front_idx ? book_data.get_page_text(front_idx) : ""
	var/back_text  = back_idx  ? book_data.get_page_text(back_idx)  : ""

	if(!length(front_text) && !length(back_text))
		to_chat(user, span_warning("Эту страницу нельзя вырвать."))
		return FALSE

	// Спавним реальный лист
	var/turf/T = get_turf(user) || get_turf(src)
	var/obj/item/paper/P = new /obj/item/paper(T)
	// заполняем front/back напрямую в страницы
	if(front_idx && length(front_text))
		P.page_for(0).text_inputs = list(new /datum/paper_input(front_text))
	if(back_idx && length(back_text))
		// создадим back-страницу по требованию
		if(!P.back_page) P.back_page = new
		P.page_for(1).text_inputs = list(new /datum/paper_input(back_text))

	P.update_icon_state()

	// Удаляем страницы из книги в безопасном порядке
	for(var/i in remove_order)
		book_data.remove_page(i)

	to_chat(user, span_notice("Ты вырываешь лист из [src]."))
	return TRUE
