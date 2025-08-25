#define MULTIBOOK_MAX_PAGES 20

/datum/book_info
	var/list/pages
	var/current_page_index = 1
	var/page_regex = "\\(page\\)\\d+\\(/page\\)"
	var/max_pages = MULTIBOOK_MAX_PAGES
	var/regex/page_splitter
	var/regex/rx_trailing_brs
	var/regex/rx_br
	var/regex/rx_p_close
	var/regex/rx_div_close

/datum/book_info/New()
	. = ..()
	page_splitter = new(page_regex)
	rx_trailing_brs = new("(\\s*<br\\s*/?>)+\\s*$", "i")
	rx_br = new("<br\\s*/?>", "i")
	rx_p_close = new("</p>", "i")
	rx_div_close = new("</div>", "i")

/// Guarantee that pages are initialized
/datum/book_info/proc/ensure_pages()
	if(!length(pages))
		init_pages()

/// Page system initialization for book (page)(/page) [var/const/page_regex]
/datum/book_info/proc/init_pages()
	if(pages)
		return

	if(!length(content))
		return

	pages = list()
	var/start_index = 1
	var/match_count = 0
	var/pageText = ""
	var/text = content // копия для работы с текстом, чтобы не трогать оригинал

	while (page_splitter.Find(text))
		var/position = page_splitter.index
		var/checkText = copytext(text, start_index, position)
		match_count++

		if(match_count <= 2)
			pageText += checkText + page_splitter.match
		else
			pageText = checkText

		if(match_count >= 2)
			pageText = remove_page_tags(pageText)
			pages += pageText
			pageText = ""

		text = copytext(text, position + length(page_splitter.match))

	text = copytext(text, start_index)
	if(length(trim(text)))
		text = pageText + text
		pages += remove_page_tags(text)

	current_page_index = clamp(current_page_index, 1, length(pages))

/// Normalize current left page index
/datum/book_info/proc/normalize_left()
	ensure_pages()
	if(!length(pages))
		current_page_index = 0
		return

	if(current_page_index < 1)
		current_page_index = 1

	if(current_page_index % 2 == 0)
		current_page_index = max(1, current_page_index - 1)

/// turn forward one spread (skip by 2 pages)
/datum/book_info/proc/next_spread()
	ensure_pages()
	if(!length(pages))
		return

	normalize_left()
	var/total = length(pages)
	var/last_left = (total % 2 == 0) ? (total - 1) : total
	current_page_index = min(current_page_index + 2, last_left)
	rebuild_content_from_pages()

/// turn backward one spread (skip by 2 pages)
/datum/book_info/proc/prev_spread()
	ensure_pages()
	if(!length(pages))
		return

	normalize_left()
	current_page_index = max(1, current_page_index - 2)
	rebuild_content_from_pages()

/// Rebuild content to match current page (для get_content)
/datum/book_info/proc/rebuild_content_from_pages()
	if(!length(pages))
		content = ""
		return

	var/i = clamp(current_page_index, 1, length(pages))
	content = trim(pages[i])

/// Clear pages from separator tags
/datum/book_info/proc/remove_page_tags(text)
	while (page_splitter.Find(text))
		text = page_splitter.Replace(text, "")

	return text

/// Get selected page text
/datum/book_info/proc/get_page_text(index, decode = TRUE)
	ensure_pages()
	if(index >= 1 && index <= length(pages))
		var/t = trim(pages[index])
		return decode ? html_decode(t) : t

	return ""

/// Get count of all pages
/datum/book_info/proc/get_page_count()
	ensure_pages()
	return length(pages)

/// Delete page from book_info
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

/// Get content of current page
/datum/book_info/get_content(default="N/A")
	ensure_pages()
	rebuild_content_from_pages()
	return html_decode(content) || "N/A"

/// Get content of all book
/datum/book_info/proc/get_full_content()
	ensure_pages()

	var/list/new_content = list()
	var/page_num = 1

	for(var/page in pages)
		new_content += "(page)[page_num](/page)\n[trim(page)]"
		page_num++

	content = jointext(new_content, "\n\n")
	return html_decode(content)

/// Set content of current page or book itself (for first initialization or spawn)
/datum/book_info/set_content(new_content, trusted = FALSE)
	if(!trusted)
		new_content = trim(html_encode(new_content), MAX_PAPER_LENGTH)

	if(pages)
		var/index = clamp(current_page_index, 1, length(pages))
		pages[index] = new_content
		rebuild_content_from_pages()
	else
		content = new_content
		init_pages()
		rebuild_content_from_pages()

/datum/book_info/proc/html_to_text(txt)
	if(!istext(txt))
		return ""

	txt = rx_br.Replace(txt, "\n")
	rx_p_close.Replace(txt, "\n\n")
	rx_div_close.Replace(txt, "\n")
	rx_trailing_brs.Replace(txt, "")

	return txt

/datum/book_info/set_content_using_paper(obj/item/paper/incoming_paper)
	var/txt = incoming_paper?.get_raw_text()
	if(!istext(txt) || !length(txt))
		return

	var/html_content = html_to_text(txt)
	set_content(html_content, FALSE)
	init_pages()
	rebuild_content_from_pages()

/datum/book_info/proc/tear_page(index)
    ensure_pages()
    if(index in 1 to length(pages))
        pages[index] = "" // пустая строка = разрыв
        // индекс и общее кол-во страниц не меняем
        rebuild_content_from_pages()
        return TRUE

    return FALSE
