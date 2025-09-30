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
