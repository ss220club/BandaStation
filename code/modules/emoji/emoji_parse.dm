/proc/emoji_parse(text) //turns :ai: into an emoji in text.
	if(!text)
		return text
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				emoji = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
				var/tag = sheet.icon_tag("emoji-[emoji]")
				if(tag)
					parsed += tag
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

/proc/emoji_strip(text) // removes valid :emoji: codes while keeping invalid text intact
	if(!text)
		return text
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				emoji = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				if(emoji in emojis)
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

/proc/emoji_protect(text, list/protected_emojis) // swaps valid emoji codes for stable placeholders while speech effects mutate text
	if(!text || !CONFIG_GET(flag/emojis))
		return text
	protected_emojis ||= list()
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				var/emoji = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				if(emoji in emojis)
					var/placeholder = "[ascii2text(2)][length(protected_emojis) + 1][ascii2text(3)]"
					protected_emojis[placeholder] = ":[emoji]:"
					parsed += placeholder
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

/proc/emoji_restore(text, list/protected_emojis) // restores placeholders inserted by emoji_protect
	if(!text || !length(protected_emojis))
		return text
	for(var/placeholder in protected_emojis)
		text = replacetext(text, placeholder, protected_emojis[placeholder])
	return text

/proc/emoji_parse_runechat(text) // turns :ai: into a maptext-safe icon for runechat
	if(!text)
		return text
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/static/list/emoji_icons = list()
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				emoji = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				if(emoji in emojis)
					var/icon/emoji_icon = emoji_icons[emoji]
					if(isnull(emoji_icon))
						emoji_icon = icon(EMOJI_SET, emoji)
						emoji_icon.Scale(12, 12)
						emoji_icons[emoji] = emoji_icon
					parsed += "\icon[emoji_icon]"
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

/proc/emoji_append_random(text)
	if(!text)
		return text
	if(!CONFIG_GET(flag/emojis))
		return text
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	if(!length(emojis))
		return text
	return "[text] :[pick(emojis)]:"

/proc/emoji_sanitize(text) //cuts any text that would not be parsed as an emoji
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/final = "" //only tags are added to this
	var/pos = 1
	var/search = 0
	while(1)
		search = findtext(text, ":", pos)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				var/word = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				if(word in emojis)
					final += LOWER_TEXT(copytext(text, pos, search + length(text[search])))
				pos = search + length(text[search])
				continue
		break
	return final
