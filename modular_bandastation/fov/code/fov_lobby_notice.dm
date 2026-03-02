/proc/fov_show_lobby_notice(client/player_client)
	if(!player_client?.mob)
		return
	var/message = "На сервере тестируется переработка FOV системы. Не финальный вид изменений. \
		Затемнение мобов за пределами обзора и его поворот в боевом режиме могут вести себя нестабильно. \
		Настройки визуала и бинд для свободного обзора (по умолачнию ПКМ) находятся в настройках игры. \
		 "
	var/c = tgui_alert(
		player_client.mob,
		message,
		"FOV",
		list("Хорошо", "Настройки"),
		timeout = 30 SECONDS
	)
	if(c == "Настройки" && player_client?.mob)
		var/datum/preferences/prefs = player_client.prefs
		if(prefs)
			prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
			prefs.update_static_data(player_client.mob)
			prefs.ui_interact(player_client.mob)
