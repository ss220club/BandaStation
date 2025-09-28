/// =========================================================================
///  /datum/paper_page — единичная страница бумаги
/// =========================================================================

/datum/paper_page
	var/list/datum/paper_input/text_inputs
	var/list/datum/paper_stamp/stamps

/datum/paper_page/New()
	. = ..()
	LAZYINITLIST(text_inputs)
	LAZYINITLIST(stamps)

/datum/paper_page/proc/has_content()
	return (LAZYLEN(text_inputs) || LAZYLEN(stamps))

/datum/paper_page/proc/clear()
	LAZYNULL(text_inputs)
	LAZYNULL(stamps)

/datum/paper_page/proc/make_copy() as /datum/paper_page
	var/datum/paper_page/P = new
	if(LAZYLEN(text_inputs))
		for(var/datum/paper_input/I as anything in text_inputs)
			LAZYADD(P.text_inputs, I.make_copy())
	if(LAZYLEN(stamps))
		for(var/datum/paper_stamp/S as anything in stamps)
			LAZYADD(P.stamps, S.make_copy())
	return P

/datum/paper_page/proc/get_total_length()
	var/total = 0
	for(var/datum/paper_input/I as anything in text_inputs)
		total += I.get_raw_text_length()
	return total

/datum/paper_page/proc/get_raw_text()
	if(!LAZYLEN(text_inputs))
		return ""
	var/out = ""
	for(var/datum/paper_input/I as anything in text_inputs)
		out += "[I.get_raw_text()]/"
	return out

/datum/paper_page/proc/to_html()
	if(!LAZYLEN(text_inputs))
		return ""
	var/list/parts = list()
	for(var/datum/paper_input/I as anything in text_inputs)
		LAZYADD(parts, I.to_raw_html())
	return jointext(parts, "<br>")
