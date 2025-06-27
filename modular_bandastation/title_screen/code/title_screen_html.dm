/**
 * Get the HTML of title screen.
 */
/datum/title_screen/proc/get_title_html(client/viewer, mob/user, styles)
	var/screen_image_url = SSassets.transport.get_asset_url(asset_cache_item = screen_image)
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
	var/mob/dead/new_player/player = user
	var/loading_percentage = CLAMP01(SStitle.subsystems_loaded / SStitle.subsystems_total) * 100
	var/list/html = list()
	html += {"
		<!DOCTYPE html>
		<html [!MC_RUNNING() ? "class='loading' style='--loading-percentage: [loading_percentage]%;'" : ""]>
		<head>
			<meta charset="UTF-8">
			<title>Title Screen</title>
			<script defer src='[SSassets.transport.get_asset_url("title_screen.js")]' ></script>
			<link rel='stylesheet' href='[SSassets.transport.get_asset_url("font-awesome.css")]'>
			<link rel='stylesheet' href='[SSassets.transport.get_asset_url("brands.min.css")]'>
			[sheet.css_tag() /* Emoji support */]
			<style>
				[file2text('modular_bandastation/title_screen/html/title_screen_default.css')]
				[styles ? file2text(styles) : ""]
			</style>
		</head>
		<body>
	"}

	if(screen_image_url)
		html += {"
			<img id="screen_blur" class="bg bg-blur" src="[screen_image_url]" alt="Загрузка..." onerror="fixImage()">
			<img id="screen_image" class="bg" src="[screen_image_url]" alt="Загрузка..." onerror="fixImage()">
		"}

	html += {"<input type="checkbox" id="hide_menu">"}
	html += {"<div id="container_notice" class="[SStitle.notice ? "" : "hidden"]">[SStitle.notice]</div>"}

	html += {"<div class="lobby_wrapper">"}
	html += {"<div class="lobby_container">"}

	html += {"
		<div class="lobby_element lobby-name">
			<label class="lobby_element lobby-collapse" for="hide_menu"></label>
			<span id="character_name" data-loading="[SStitle.subsystem_loading]" data-name="[player.client.prefs.read_preference(/datum/preference/name/real_name)]"></span>
			<div id="logo" data-loaded="[round(loading_percentage)]%">
				<img src="[SSassets.transport.get_asset_url(asset_name = "ss220_logo.png")]">
			</div>
		</div>"}

	html += {"<div class="lobby_buttons">"}

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		html += create_button(player, "toggle_ready", "Готов", advanced_classes = "[player.ready == PLAYER_READY_TO_PLAY ? "good" : "bad"] checkbox")
	else
		html += create_button(player, "late_join", "Присоединиться")

	html += {"
		[create_button(player, "observe", "Наблюдать")]
		[create_button(player, "manifest", "Манифест персонала")]
		<hr>
		[create_button(player, "character_setup", "Настройка персонажа")]
		[create_button(player, "settings", "Настройки игры")]
	"}

	if(length(GLOB.lobby_station_traits))
		var/number = 0
		for(var/datum/station_trait/job/trait as anything in GLOB.lobby_station_traits)
			if(!istype(trait))
				continue // Skip trait if it is not a job

			if(!trait.can_display_lobby_button(player.client))
				continue

			number++
			if(number == 1)
				html += {"<hr>"}

			var/assigned = LAZYFIND(trait.lobby_candidates, player)
			html += {"
				<a id="lobby-trait-[number]" class="lobby_element checkbox [assigned ? "good" : "bad"]" href='byond://?src=[REF(player)];trait_signup=[trait.name];id=[number]'>
					<span class="lobby-text">[trait.name]</span>
					<div class="lobby-tooltip" data-position="right">
						<span class="lobby-tooltip-content">[trait.button_desc]</span>
					</div>
				</a>
			"}

	html += {"
		<div id="lobby_admin" class="[check_rights_for(viewer, R_ADMIN|R_DEBUG) ? "" : "hidden"]">
			<hr>
			[create_button(player, "start_now", "Запустить раунд", enabled = SSticker && SSticker.current_state <= GAME_STATE_PREGAME)]
			[create_button(player, "delay", "Отложить начало раунда", enabled = SSticker && SSticker.current_state <= GAME_STATE_PREGAME)]
			[create_button(player, "notice", "Оставить уведомление")]
			[create_button(player, "picture", "Сменить изображение")]
		</div>
	"}

	html += {"</div></div>"}

	html += {"
		<div class="lobby_buttons-end">
			[create_button(player, "wiki", tooltip = "Перейти на вики", tooltip_position = "top-start")]
			[create_button(player, "discord", tooltip = "Открыть наш дискорд", tooltip_position = "top-start")]
			[create_button(player, "github", tooltip = "Перейти в наш репозиторий", tooltip_position = "top")]
			[create_button(player, "bug", tooltip = "Сообщить о баге", tooltip_position = "top")]
			[create_button(player, "changelog", tooltip = "Открыть чейнджлог", tooltip_position = "top-end")]
		</div>
	"}

	html += {"</div>"}
	html += {"<label class="lobby_element lobby-collapse outside" for="hide_menu"></label>"}
	html += {"<div id="lobby_info"><div id="round_info"></div>"}
	html += {"</div>"}

	html += {"</body>"}
	html += "</html>"

	return html.Join()
