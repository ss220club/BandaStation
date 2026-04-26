#define AHELP_KEYWORDS_FILE "config/bandastation/ahelp_keywords.json"

/proc/get_ahelp_keywords()
	var/static/initialized
	var/static/list/keywords

	if(initialized)
		return keywords

	initialized = TRUE
	keywords = null

	if(!fexists(AHELP_KEYWORDS_FILE))
		return null

	var/raw_json = file2text(AHELP_KEYWORDS_FILE)
	if(!length(raw_json))
		return null

	var/list/parsed = safe_json_decode(raw_json)
	if(isnull(parsed) || !islist(parsed))
		log_config("JSON parsing failure for [AHELP_KEYWORDS_FILE]")
		return null

	var/list/keyword_strings = parsed["ahelp_keywords"]
	if(!islist(keyword_strings) || !length(keyword_strings))
		return null

	var/list/unique = list()
	unique |= keyword_strings
	var/list/cleaned = list()
	for(var/entry in unique)
		if(!istext(entry) || !length(trim(entry)))
			continue
		cleaned += trim(entry)

	if(!length(cleaned))
		return null

	return keywords = cleaned

// true if the message contains a keyword
/proc/ahelp_message_matches_keyword(message)
	var/list/keywords = get_ahelp_keywords()
	if(!length(keywords))
		return FALSE

	var/ticket_text = LOWER_TEXT("[message]")
	for(var/keyword in keywords)
		if(findtext(ticket_text, LOWER_TEXT(keyword)))
			return TRUE

	return FALSE

#undef AHELP_KEYWORDS_FILE
