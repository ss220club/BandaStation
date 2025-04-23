GLOBAL_LIST_INIT(available_lobby_styles, list(
	"По-умолчанию" = 'modular_bandastation/title_screen/html/title_screen_default.css',
	"Минималистичный" = 'modular_bandastation/title_screen/html/title_screen_minimalistic.css',
))

/datum/title_screen
	/// Custom CSS. Can be changed by admins or coders. If empty, will be used from user preferences.
	var/title_css
	/// The current title screen being displayed, as `/datum/asset_cache_item`
	var/datum/asset_cache_item/screen_image

/datum/title_screen/New(styles, screen_image_file)
	if(styles)
		src.title_css = styles
	set_screen_image(screen_image_file)

/datum/title_screen/proc/set_screen_image(screen_image_file)
	if(!screen_image_file)
		return

	if(!isfile(screen_image_file))
		screen_image_file = fcopy_rsc(screen_image_file)

	screen_image = SSassets.transport.register_asset("[screen_image_file]", screen_image_file)

/datum/title_screen/proc/show_to(client/viewer)
	if(!viewer)
		return

	winset(viewer, "title_browser", "is-disabled=false;is-visible=true")
	winset(viewer, "status_bar", "is-visible=false")

	var/datum/asset/lobby_asset = get_asset_datum(/datum/asset/simple/html_title_screen)
	var/datum/asset/fontawesome = get_asset_datum(/datum/asset/simple/namespaced/fontawesome)
	lobby_asset.send(viewer)
	fontawesome.send(viewer)

	SSassets.transport.send_assets(viewer, screen_image.name)
	if(!title_css)
		viewer << browse(get_title_html(viewer, viewer.mob, GLOB.available_lobby_styles[viewer.prefs.read_preference(/datum/preference/choiced/lobby_style)]), "window=title_browser")
	else
		viewer << browse(get_title_html(viewer, viewer.mob, title_css), "window=title_browser")


/datum/title_screen/proc/hide_from(client/viewer)
	if(viewer?.mob)
		winset(viewer, "title_browser", "is-disabled=true;is-visible=false")
		winset(viewer, "status_bar", "is-visible=true;focus=true")

/datum/title_screen/proc/create_main_button(user, href, text, advanced_classes)
	return {"
		<a class="lobby_element lobby-[href] [advanced_classes]" href='byond://?src=[REF(user)];[href]=1'>
			<span class="lobby-text">[text]</span>
			<img class="pixelated default" src="[SSassets.transport.get_asset_url(asset_name = "lobby_[href].png")]">
		</a>
	"}

/datum/title_screen/proc/create_icon_button(user, href, tooltip, tooltip_position = "bottom", enabled = TRUE)
	return {"
		<a class="lobby_button lobby_element lobby-[href] [!enabled ? "disabled" : ""]" href='byond://?src=[REF(user)];[enabled ? href : ""]=1'>
			<div class="toggle">
				<img class="pixelated default indicator [!enabled ? "disabled" : ""]" src="[SSassets.transport.get_asset_url(asset_name = "lobby_[enabled ? "highlight" : "disabled"].png")]">
			</div>
			<img class="pixelated default" src="[SSassets.transport.get_asset_url(asset_name = "lobby_[href].png")]">
			[tooltip ? {"
			<div class="lobby-tooltip" data-position="[tooltip_position]">
				<span class="lobby-tooltip-content">[tooltip]</span>
			</div> "} : ""]
		</a>
	"}

