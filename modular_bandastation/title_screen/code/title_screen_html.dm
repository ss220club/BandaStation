/**
 * Get the HTML of title screen.
 */
/datum/title_screen/proc/get_title_html(client/viewer, mob/user, styles)
	var/screen_image_url = SSassets.transport.get_asset_url(asset_cache_item = screen_image)
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
	var/mob/dead/new_player/player = user
	var/list/html = list()
	html += {"
		<!DOCTYPE html>
		<html>
		<head>
			<title>Title Screen</title>
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url(asset_name = "font-awesome.css")]'>
			<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url(asset_name = "brands.min.css")]'>
			[sheet.css_tag()]
			<style type='text/css'>
				[file2text('modular_bandastation/title_screen/html/title_screen_default.css')]
				[styles ? file2text(styles) : ""]
			</style>
		</head>
		<body>
	"}

	if(screen_image_url)
		html += {"
			<img id="screen_blur" class="bg bg-blur" src="[screen_image_url]" alt="Загрузка..." onerror="fix_image()">
			<img id="screen_image" class="bg" src="[screen_image_url]" alt="Загрузка..." onerror="fix_image()">
		"}

	html += {"<input type="checkbox" id="hide_menu">"}
	html += {"<div id="container_notice" class="[SStitle.notice ? "" : "hidden"]">[SStitle.notice]</div>"}

	html += {"<div class="lobby_wrapper">"}
	html += {"<div class="lobby_container">"}

	html += {"
		<div class="lobby_element lobby-name">
			<label class="lobby_element lobby-collapse" for="hide_menu"></label>
			<span id="character_name">[player.client.prefs.read_preference(/datum/preference/name/real_name)]</span>
			<div class="logo">
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
			[create_button(player, "discord", tooltip = "Открыть наш дискорд", tooltip_position = "top")]
			[create_button(player, "changelog", tooltip = "Открыть чейнджлог", tooltip_position = "top-end")]
		</div>
	"}

	html += {"</div>"}
	html += {"<label class="lobby_element lobby-collapse outside" for="hide_menu"></label>"}
	html += {"<div id="lobby_info"></div>"}
	html += {"</body>"}

	html += {"
		<script language="JavaScript">
			function call_byond(href, value) {
				window.location = `byond://?src=[REF(player)];${href}=${value}`
			}

			let ready_int = 0;
			const readyID = document.querySelector(".lobby-toggle_ready");
			const ready_class = \[ "bad", "good" \];
			function toggle_ready(setReady) {
				if(setReady) {
					ready_int = setReady;
					readyID.classList.add(ready_class\[ready_int\]);
					readyID.classList.remove(ready_class\[1 - ready_int\]);
				} else {
					ready_int++;
					if(ready_int === ready_class.length)
						ready_int = 0;
					readyID.classList.add("good");
					readyID.classList.remove("bad");
				}
			}

			function job_sign(assign, id) {
				let traitID;
				let trait_link;

				if(!id) {
					return
				}

				if (id === "1") {
					traitID = "lobby-trait-1";
				} else if (id === "2") {
					traitID = "lobby-trait-2";
				} else if (id === "3"){
					traitID = "lobby-trait-3";
				} else {
					return
				}

				trait_link = document.getElementById(traitID);
				if(assign === "true") {
					trait_link.classList.add("good");
					trait_link.classList.remove("bad");
				} else {
					trait_link.classList.remove("good");
					trait_link.classList.add("bad");
				}
			}

			const admin_buttons = document.getElementById("lobby_admin")
			function admin_buttons_visibility(visible) {
				if(visible === "true") {
					admin_buttons.classList.remove("hidden")
				} else {
					admin_buttons.classList.add("hidden")
				}
			}

			const notice_container = document.getElementById("container_notice");
			function update_notice(notice) {
				if(notice === undefined) {
					notice_container.classList.add("hidden");
					notice_container.innerHTML = "";
				} else {
					notice_container.classList.remove("hidden");
					notice_container.innerHTML = notice;
				}
			}

			const character_name_slot = document.getElementById("character_name");
			function update_character_name(name) {
				character_name_slot.textContent = name;
			}

			let image_src;
			const image_container = document.getElementById("screen_image");
			const image_blur_container = document.getElementById("screen_blur");
			function update_image(image) {
				image_src = image;
				image_container.src = image_src;
				image_blur_container.src = image_src;
			}

			let attempts = 0;
			const maxAttempts = 10;
			function fix_image() {
				const img = new Image();
				img.src = image_src;
				if(img.naturalWidth === 0 || img.naturalHeight === 0) {
					if(attempts === maxAttempts) {
						attempts = 0;
						return;
					}

					attempts++;
					setTimeout(function() {
						fix_image();
					}, 1000);
				} else {
					attempts = 0;
					image_container.src = image_src;
					return;
				}
			}

			const info_placement = document.getElementById("lobby_info");
			function update_info(info) {
				info_placement.innerHTML = info;
			}

			/* Return focus to Byond after click */
			function reFocus() {
				call_byond("focus", true);
			}

			document.addEventListener('keyup', reFocus);
			document.addEventListener('mouseup', reFocus);

			/* Tell Byond that the title screen is ready */
			call_byond("title_ready", true);
		</script>
	"}

	html += "</html>"

	return html.Join()
