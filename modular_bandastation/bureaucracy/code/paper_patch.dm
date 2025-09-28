#define PAPER_SIDE_FRONT 0
#define PAPER_SIDE_BACK  1

/obj/item/paper
	var/current_side = PAPER_SIDE_FRONT
	var/datum/paper_page/front_page
	var/datum/paper_page/back_page
	var/has_advanced_html = FALSE

/obj/item/paper/proc/active_page() as /datum/paper_page
	if(current_side == PAPER_SIDE_BACK)
		return back_page
	return front_page

/obj/item/paper/proc/rebind_legacy_lists()
	var/datum/paper_page/P = active_page()
	if(P)
		raw_text_inputs = P.text_inputs
		raw_stamp_data  = P.stamps
	else
		LAZYNULL(raw_text_inputs)
		LAZYNULL(raw_stamp_data)

/obj/item/paper/Initialize(mapload)
	. = ..()
	if(!front_page)
		front_page = new
	rebind_legacy_lists()

/obj/item/paper/proc/flip_side()
	current_side = (current_side == PAPER_SIDE_FRONT) ? PAPER_SIDE_BACK : PAPER_SIDE_FRONT
	if(current_side == PAPER_SIDE_BACK && !back_page)
		back_page = new
	rebind_legacy_lists()
	update_appearance()
	update_static_data_for_all_viewers()

/obj/item/paper/ui_static_data(mob/user)
	var/list/data = ..()
	if(!islist(data))
		data = list()
	data["current_side"] = (current_side == PAPER_SIDE_BACK) ? "back" : "front"
	data["sanitize_text"] = has_advanced_html ? FALSE : TRUE
	return data

/obj/item/paper/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(action == "flip_side")
		flip_side()
		return TRUE
	return FALSE

/obj/item/paper/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/paper) && attacking_item != src)
		var/turf/T = get_turf(src)
		var/obj/item/paper_stack/S = new /obj/item/paper_stack(T)
		S.absorb_paper(src, user)
		S.absorb_paper(attacking_item, user)
		if(user && user.Adjacent(S))
			user.put_in_hands(S)
		return CLICK_ACTION_SUCCESS

	if(istype(attacking_item, /obj/item/paper_stack))
		var/obj/item/paper_stack/S = attacking_item
		S.absorb_paper(src, user)
		return CLICK_ACTION_SUCCESS

	return ..()

/obj/item/paper/proc/page_for(side_num) as /datum/paper_page
	if(side_num)
		return back_page
	return front_page

/obj/item/paper/proc/side_has_content(side_num)
	var/datum/paper_page/P = page_for(side_num)
	return !!(P && P.has_content())

#undef PAPER_SIDE_FRONT
#undef PAPER_SIDE_BACK
