/datum/config_entry/string/discordurl
	default = "https://discord.gg/SS220"

//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/discord()
	set name = "discord"
	set desc = "Visit the discord."
	set hidden = TRUE
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(tgui_alert(src, "Это откроет ссылку в вашем браузере. Вы уверены?", "Переход в наш Discord", list("Да", "Нет")) != "Да")
			return
		src << link(discordurl)
	else
		to_chat(src, span_danger("The discord URL is not set in the server configuration."))
	return

/datum/config_entry/string/round_end_webhook_url
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
	default = "https://discord.com/api/webhooks/1421277891647377418/Exe2MMIv47hXpBGdCG1wqnutdU8XM45YLD9UQ2Mcr5MlIojc7XsV6TvjTRmN7T2xmjgR"

/datum/config_entry/string/round_end_webhook_name
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/round_end_webhook_avatar_url
	protection = CONFIG_ENTRY_LOCKED

/proc/send_round_end_webhook()
	var/webhook = CONFIG_GET(string/round_end_webhook_url)
	if(!webhook)
		return

	var/message_content = GLOB.survivor_report

	message_content = rustutils_regex_replace(message_content, "<br>", "i", "\n")
	message_content = rustutils_regex_replace(message_content, "&nbsp;&nbsp;&nbsp;&nbsp;", "i", "")
	message_content = STRIP_HTML_FULL(message_content, 4096)

	var/list/lines = splittext(message_content, "\n")
	for(var/i in 1 to length(lines))
		var/line = lines[i]
		var/list/line_parts = splittext(line, ": ")
		for(var/j in 1 to length(line_parts))
			if(j % 2 == 0)
				line_parts[j] = "**[line_parts[j]]**"
		lines[i] = line_parts.Join(": ")

	message_content = lines.Join("\n")


	var/list/embed = list(
		"title" = "Раунд #[GLOB.round_id] закончился",
		"description" = message_content,
		"color" = 5814783, // light blue
		"timestamp" = rustg_formatted_timestamp_tz("%Y-%m-%d %H:%M:%S%.3f", "-3"),
		"footer" = list(
			"text" = "Round End Report"
		)
	)

	var/list/webhook_info = list(
		"embeds" = list(embed)
	)

	if(CONFIG_GET(string/round_end_webhook_name))
		webhook_info["username"] = CONFIG_GET(string/round_end_webhook_name)
	if(CONFIG_GET(string/round_end_webhook_avatar_url))
		webhook_info["avatar_url"] = CONFIG_GET(string/round_end_webhook_avatar_url)

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers, "tmp/response.json")
	request.begin_async()
