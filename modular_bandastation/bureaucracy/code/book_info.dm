/datum/book_info
	var/list/pages
	var/current_page_index
	var/page_regex = "\\(page\\)\\d+\\(/page\\)"
	var/max_pages = 20

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
	var/regex/page_splitter = new(page_regex)
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

/// Rebuild content to match current page (для get_content)
/datum/book_info/proc/rebuild_content_from_pages()
	if(!length(pages))
		content = ""
		return

	var/i = clamp(current_page_index, 1, length(pages))
	content = trim(pages[i])

/// Clear pages from separator tags
/datum/book_info/proc/remove_page_tags(text)
	var/regex/page_splitter = new(page_regex)
	while (page_splitter.Find(text))
		text = page_splitter.Replace(text, "")
	return text

/// Get count of all pages
/datum/book_info/proc/get_page_count()
	ensure_pages()
	return length(pages)

/// Delete page from book_info
/datum/book_info/proc/remove_page(index)
	ensure_pages()
	if(index in 1 to length(pages))
		pages.Cut(index, index + 1)
		current_page_index = clamp(current_page_index, 1, length(pages))
		rebuild_content_from_pages()
		return TRUE
	return FALSE

/// Switch page to next one until it's last
/datum/book_info/proc/next_page()
	ensure_pages()
	current_page_index = clamp(current_page_index + 1, 1, length(pages))
	rebuild_content_from_pages()

/// Switch page to previous one until it's first
/datum/book_info/proc/prev_page()
	ensure_pages()
	current_page_index = clamp(current_page_index - 1, 1, length(pages))
	rebuild_content_from_pages()

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

/// Set content of book when using bookbinder
/datum/book_info/set_content_using_paper(obj/item/paper/P)
	. = ..()
	init_pages()

/// Recreate content to contain full book data
/datum/book_info/proc/regenerate_content()
	ensure_pages()

	var/list/new_content = list()
	var/page_num = 1

	for(var/page in pages)
		new_content += "(page)[page_num](/page)\n[trim(page)]"
		page_num++

	content = jointext(new_content, "\n\n")
