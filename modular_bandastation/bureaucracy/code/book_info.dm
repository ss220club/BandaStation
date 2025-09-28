#define MULTIBOOK_MAX_PAGES 20

/datum/book_info
	var/list/pages
	var/current_page_index = 1
	var/max_pages = MULTIBOOK_MAX_PAGES

/datum/book_info/New()
	. = ..()
	LAZYINITLIST(pages)

/datum/book_info/proc/ensure_pages()
	LAZYINITLIST(pages)

/datum/book_info/proc/init_pages()
	ensure_pages()

/datum/book_info/proc/normalize_left()
	ensure_pages()
	var/total = length(pages)
	if(total <= 0)
		current_page_index = 0
		return
	current_page_index = clamp(current_page_index, 1, total)
	if(!(current_page_index % 2))
		current_page_index = max(1, current_page_index - 1)

/datum/book_info/proc/next_spread()
	ensure_pages()
	if(!length(pages)) return
	normalize_left()
	var/total = length(pages)
	var/last_left = (total % 2 == 0) ? (total - 1) : total
	current_page_index = min(current_page_index + 2, last_left)
	rebuild_content_from_pages()

/datum/book_info/proc/prev_spread()
	ensure_pages()
	if(!length(pages)) return
	normalize_left()
	current_page_index = max(1, current_page_index - 2)
	rebuild_content_from_pages()

/datum/book_info/proc/rebuild_content_from_pages()
	if(!length(pages))
		content = ""
		return
	var/i = clamp(current_page_index, 1, length(pages))
	content = trim(pages[i])

/datum/book_info/proc/get_page_text(index, decode = TRUE)
	ensure_pages()
	if(index >= 1 && index <= length(pages))
		var/t = trim(pages[index])
		return t
	return ""

/datum/book_info/proc/get_page_count()
	ensure_pages()
	return length(pages)

/datum/book_info/proc/remove_page(index)
	ensure_pages()
	if(index in 1 to length(pages))
		pages.Cut(index, index + 1)
		if(length(pages) == 0)
			current_page_index = 0
			content = ""
			return TRUE
		current_page_index = clamp(current_page_index, 1, length(pages))
		normalize_left()
		rebuild_content_from_pages()
		return TRUE
	return FALSE

/datum/book_info/get_content(default="N/A")
	ensure_pages()
	rebuild_content_from_pages()
	return content || "N/A"

/datum/book_info/proc/get_full_content()
	ensure_pages()
	content = jointext(pages, "\n\n")
	return content

/datum/book_info/set_content(new_content, trusted = FALSE)
	ensure_pages()
	var/txt = "[new_content]"
	if(length(pages))
		var/index = clamp(current_page_index, 1, length(pages))
		pages[index] = txt
	else
		pages += txt
	rebuild_content_from_pages()

/datum/book_info/set_content_using_paper(obj/item/paper/incoming_paper)
	if(!incoming_paper) return
	ensure_pages()
	var/datum/paper_page/F = incoming_paper.page_for(0)
	var/datum/paper_page/B = incoming_paper.page_for(1)
	var/ftxt = F ? trim(F.get_raw_text()) : ""
	var/btxt = B ? trim(B.get_raw_text()) : ""
	if(length(ftxt))
		if(length(pages) < max_pages) pages += ftxt
	if(length(btxt))
		if(length(pages) < max_pages) pages += btxt
	rebuild_content_from_pages()

/datum/book_info/proc/tear_page(index)
	return remove_page(index)
