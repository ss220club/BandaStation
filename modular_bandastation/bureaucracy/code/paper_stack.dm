#define PAPER_STACK_MAX_LEAVES 20
#define PAPER_STACK_SPILL_CHANCE 20

/obj/item/paper_stack
	name = "paper stack"
	desc = "A loosely bundled stack of paper sheets."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "paper_stack"
	inhand_icon_state = "paper"
	worn_icon_state = "paper"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE

	/// Листы в стопке (каждый = 2 страницы: front/back)
	var/list/obj/item/paper/papers

	/// Текущая страница 1..N (строчный индекс, а не по листам)
	var/current_page_index = 1

/obj/item/paper_stack/Initialize(mapload)
	. = ..()
	LAZYINITLIST(papers)
	update_appearance()

/obj/item/paper_stack/Destroy()
	LAZYNULL(papers)
	return ..()

/obj/item/paper_stack/examine(mob/user)
	. = ..()
	var/total_pages = stack_total_pages()
	. += span_notice("Sheets: [LAZYLEN(papers)] (pages: [total_pages]).")
	. += span_notice("Spill chance on bump/pick/drop: [PAPER_STACK_SPILL_CHANCE]%.")
	return .

/obj/item/paper_stack/update_icon_state()
	var/count = LAZYLEN(papers)
	if(count >= 8)
		icon_state = "paper_stack"
	else if(count >= 3)
		icon_state = "paper_stack_mid"
	else if(count >= 1)
		icon_state = "paper_stack_low"
	else
		icon_state = "paper_stack_empty"
	return ..()

/obj/item/paper_stack/proc/stack_total_pages()
	return max(0, LAZYLEN(papers) * 2)

/obj/item/paper_stack/proc/_clamp_index(idx)
	var/total = stack_total_pages()
	if(total <= 0)
		return 1
	return clamp(idx, 1, total)

/obj/item/paper_stack/proc/_paper_index_for_page(page_idx)
	page_idx = _clamp_index(page_idx)
	return ceil(page_idx / 2.0)

/obj/item/paper_stack/proc/_index_to_paper_and_side(idx)
	idx = _clamp_index(idx)
	var/paper_index = ceil(idx / 2.0)
	var/side_num = (idx % 2 == 0) ? 1 : 0
	return list(paper_index, side_num)

/obj/item/paper_stack/proc/get_active_paper()
	if(!LAZYLEN(papers))
		return null
	var/list/map = _index_to_paper_and_side(current_page_index)
	var/paper_index = map[1]
	if(paper_index < 1 || paper_index > LAZYLEN(papers))
		return null
	return papers[paper_index]

/obj/item/paper_stack/proc/_bind_paper_for_page(obj/item/paper/P, page_index)
	if(!P) return
	var/list/map = _index_to_paper_and_side(page_index)
	var/side_num = map[2]
	var/datum/paper_page/PP = P.page_for(side_num)
	P.raw_text_inputs = PP ? PP.text_inputs : null
	P.raw_stamp_data  = PP ? PP.stamps      : null

/obj/item/paper_stack/proc/_collapse_if_needed(mob/living/user)
	var/count = LAZYLEN(papers)
	if(count <= 0)
		qdel(src)
		return TRUE

	if(count == 1)
		var/obj/item/paper/only = papers[1]

		only.current_side = 0
		only.rebind_legacy_lists()
		only.update_icon_state()
		only.update_appearance()

		if(user && user.get_active_held_item() == src)
			user.temporarilyRemoveItemFromInventory(src)
			only.forceMove(user)
			user.put_in_hands(only)
		else
			only.forceMove(loc)
		qdel(src)
		return TRUE

	return FALSE

/obj/item/paper_stack/proc/absorb_paper(obj/item/paper/P, mob/living/user)
	if(!istype(P, /obj/item/paper))
		return FALSE

	if(istype(P, /obj/item/paper_stack))
		var/obj/item/paper_stack/S = P
		for(var/i in 1 to LAZYLEN(S.papers))
			if(LAZYLEN(papers) >= PAPER_STACK_MAX_LEAVES) break
			var/obj/item/paper/PP = S.papers[i]
			LAZYADD(papers, PP)
			PP.forceMove(src)
		qdel(S)
	else
		if(LAZYLEN(papers) >= PAPER_STACK_MAX_LEAVES)
			if(user) to_chat(user, span_warning("The stack is already full."))
			return FALSE
		LAZYADD(papers, P)
		P.forceMove(src)

	current_page_index = stack_total_pages()
	update_appearance()
	update_static_data_for_all_viewers()
	return TRUE

/obj/item/paper_stack/proc/next_page()
	if(!LAZYLEN(papers)) return
	current_page_index++
	current_page_index = _clamp_index(current_page_index)
	update_static_data_for_all_viewers()

/obj/item/paper_stack/proc/prev_page()
	if(!LAZYLEN(papers)) return
	current_page_index--
	current_page_index = _clamp_index(current_page_index)
	update_static_data_for_all_viewers()

/obj/item/paper_stack/proc/append_photo_paper(obj/item/photo/PH, mob/living/user)
	if(!PH || !istype(PH, /obj/item/photo))
		return FALSE

	var/html = icon2html(PH)

	var/obj/item/paper/P = new /obj/item/paper(null)
	if(!P.front_page)
		P.front_page = new

	var/datum/paper_input/I = new /datum/paper_input(
		html,
		null,
		null,
		FALSE,
		TRUE,
		null
	)
	LAZYADD(P.front_page.text_inputs, I)
	P.back_page = null
	P.current_side = 0
	P.has_advanced_html = TRUE
	P.rebind_legacy_lists()
	P.update_icon_state()
	P.update_appearance()

	if(!absorb_paper(P, user))
		qdel(P)
		return FALSE

	return TRUE

/obj/item/paper_stack/attackby(obj/item/attacking_item, mob/living/user, list/mods, list/amods)
	. = ..()

	if(istype(attacking_item, /obj/item/photo))
		var/obj/item/photo/PH = attacking_item
		if(append_photo_paper(PH, user))
			qdel(PH)
			if(user) to_chat(user, span_notice("Ты добавляешь фотографию как отдельную страницу в пачку."))
			return CLICK_ACTION_SUCCESS

	_try_spill(user)
	return .

/obj/item/paper_stack/proc/_try_spill(mob/living/user)
	if(!LAZYLEN(papers))
		return
	if(!prob(PAPER_STACK_SPILL_CHANCE))
		return
	var/obj/item/paper/P = remove_paper_by_page(user, 1)
	if(P && user)
		user.visible_message(
			span_warning("[user] fumbles the stack and a sheet slips out!"),
			span_warning("A sheet slips out of the stack!")
		)

/obj/item/paper_stack/click_alt(mob/living/user)
	remove_paper_by_page(user, 1)
	return CLICK_ACTION_SUCCESS

/obj/item/paper_stack/pickup(mob/living/user)
	. = ..()
	_try_spill(user)
	return .

/obj/item/paper_stack/dropped(mob/living/user)
	. = ..()
	_try_spill(user)
	return .

/obj/item/paper_stack/ui_interact(mob/user, datum/tgui/ui)
	if(resistance_flags & ON_FIRE)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaperSheet", name)
		ui.open()

/obj/item/paper_stack/ui_static_data(mob/user)
	var/list/data = list()
	var/obj/item/paper/P = get_active_paper()
	if(P)
		_bind_paper_for_page(P, current_page_index)
		data = P.ui_static_data(user)
	else
		data["user_name"] = user?.real_name
		data[LIST_PAPER_RAW_TEXT_INPUT] = list()
		data[LIST_PAPER_RAW_STAMP_INPUT] = list()
		data[LIST_PAPER_COLOR] = COLOR_WHITE
		data[LIST_PAPER_NAME] = name
		data["max_length"] = MAX_PAPER_LENGTH
		data["default_pen_font"] = PEN_FONT
		data["default_pen_color"] = COLOR_BLACK
		data["signature_font"] = FOUNTAIN_PEN_FONT

	data["is_stack"] = TRUE
	data["stack_page_index"] = current_page_index
	data["stack_page_count"] = stack_total_pages()
	return data

/obj/item/paper_stack/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/paper/P = get_active_paper()
	if(P)
		_bind_paper_for_page(P, current_page_index)
		data = P.ui_data(user)

	data["can_prev"] = (current_page_index > 1)
	data["can_next"] = (current_page_index < stack_total_pages())
	return data

/obj/item/paper_stack/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("stack_next")
			next_page()
			SStgui.try_update_ui(ui.user, src)
			return TRUE

		if("stack_prev")
			prev_page()
			SStgui.try_update_ui(ui.user, src)
			return TRUE

		if("remove_paper_current")
			if(remove_paper_current(ui.user))
				SStgui.try_update_ui(ui.user, src)
			return TRUE

		if("remove_paper_first")
			if(remove_paper_first(ui.user))
				SStgui.try_update_ui(ui.user, src)
			return TRUE

		if("remove_paper_last")
			if(remove_paper_last(ui.user))
				SStgui.try_update_ui(ui.user, src)
			return TRUE

	var/obj/item/paper/P = get_active_paper()
	if(P)
		_bind_paper_for_page(P, current_page_index)
		return P.ui_act(action, params, ui)

	return FALSE

/obj/item/paper_stack/proc/get_raw_text()
	var/obj/item/paper/P = get_active_paper()
	if(P)
		_bind_paper_for_page(P, current_page_index)
		return P.get_raw_text()
	return ""

/obj/item/paper_stack/proc/get_total_length()
	var/obj/item/paper/P = get_active_paper()
	if(P)
		_bind_paper_for_page(P, current_page_index)
		return P.get_total_length()
	return 0

/obj/item/paper_stack/proc/remove_paper_by_page(mob/living/user, page_idx)
	if(!LAZYLEN(papers))
		return null

	if(!isnum(page_idx) || page_idx <= 0)
		page_idx = current_page_index

	var/paper_index = _paper_index_for_page(page_idx)
	if(paper_index < 1 || paper_index > LAZYLEN(papers))
		return null

	var/obj/item/paper/P = papers[paper_index]
	papers.Cut(paper_index, paper_index + 1)

	P.current_side = 0
	P.rebind_legacy_lists()
	P.update_icon_state()
	P.update_appearance()

	var/turf/T = get_turf(src) || loc
	P.forceMove(T)

	var/after = stack_total_pages()
	if(after <= 0)
		current_page_index = 1
	else
		current_page_index = clamp(min(current_page_index, after), 1, after)

	update_appearance()
	update_static_data_for_all_viewers()
	_collapse_if_needed(user)

	if(user) to_chat(user, span_notice("Ты вынимаешь лист из стопки."))
	return P

/obj/item/paper_stack/proc/remove_paper_current(mob/living/user)
	return remove_paper_by_page(user, current_page_index)

/obj/item/paper_stack/proc/remove_paper_first(mob/living/user)
	return remove_paper_by_page(user, 1)

/obj/item/paper_stack/proc/remove_paper_last(mob/living/user)
	return remove_paper_by_page(user, stack_total_pages())


#undef PAPER_STACK_MAX_LEAVES
#undef PAPER_STACK_SPILL_CHANCE
