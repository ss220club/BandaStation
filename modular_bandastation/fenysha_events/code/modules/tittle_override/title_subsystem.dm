// Hybrid SStitle: overrides the old (commented) base title subsystem so it behaves like
// modular_skyrat's new browser-based title, but uses DEFAULT_TITLE_HTML from title_defines.dm
// (trainstation CSS from ~custom_tittle.dm) instead of bubbers_title.txt / skyrat defaults.

SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY

	var/file_path
	var/icon/startup_splash

	/// The current title screen being displayed, as a file path text.
	var/current_title_screen
	/// The current notice text, or null.
	var/current_notice
	/// The preamble html that includes all styling and layout.
	var/title_html
	/// The list of possible title screens to rotate through, as file path texts.
	var/title_screens = list()

	/// average realtime seconds it takes to load the map we're currently running
	var/average_completion_time = DEFAULT_TITLE_MAP_LOADTIME
	/// a given startup message => average timestamp in realtime seconds
	var/list/startup_message_timings = list()
	/// Raw data to update later
	var/list/progress_json = list()
	/// The reference realtime that we're treating as 0 for this run
	var/progress_reference_time = 0
	/// A list of station traits that have lobby buttons
	var/list/available_lobby_station_traits = list()

/datum/controller/subsystem/title/Initialize()
	// Use hybrid default HTML (trainstation CSS from title_defines.dm); optional file override
	if(fexists("[global.config.directory]/bubbers/bubbers_title.txt"))
		title_html = file2text("[global.config.directory]/bubbers/bubbers_title.txt")
	else
		title_html = DEFAULT_TITLE_HTML

	var/list/provisional_title_screens = flist("[global.config.directory]/title_screens/images/")
	var/list/local_title_screens = list()
	var/list/current_map_file = splittext(SSmapping.current_map.map_file, ".")

	for(var/screen in provisional_title_screens)
		var/list/formatted_list = splittext(screen, "+")
		if((LOWER_TEXT(formatted_list[1]) == LOWER_TEXT(current_map_file[1])))
			local_title_screens += screen
			continue

		if(LAZYLEN(formatted_list) > 1 && LOWER_TEXT(formatted_list[1]) == "startup_splash")
			var/file_path = "[global.config.directory]/title_screens/images/[screen]"
			ASSERT(fexists(file_path))
			startup_splash = new(fcopy_rsc(file_path))

	if(local_title_screens.len == 0)
		for(var/screen in provisional_title_screens)
			var/list/formatted_list = splittext(screen, "+")
			if((LAZYLEN(formatted_list) == 1 && (formatted_list[1] != "exclude" && formatted_list[1] != "blank.png" && formatted_list[1] != "startup_splash")))
				local_title_screens += screen

	// Progress stuff
	check_progress_reference_time()
	load_progress_json()

	if(startup_splash)
		change_title_screen(startup_splash)
	else
		change_title_screen(DEFAULT_TITLE_LOADING_SCREEN)

	if(length(local_title_screens))
		for(var/i in local_title_screens)
			var/file_path = "[global.config.directory]/title_screens/images/[i]"
			ASSERT(fexists(file_path))
			var/icon/title2use = new(fcopy_rsc(file_path))
			title_screens += title2use

	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(on_enter_pregame))

	return SS_INIT_SUCCESS

/**
 * Called when ticker enters pregame; switch title screen to lobby image and refresh again after 1s.
 * Replaces direct calls from SSticker so ticker stays agnostic of title implementation.
 */
/datum/controller/subsystem/title/proc/on_enter_pregame()
	SIGNAL_HANDLER
	change_title_screen()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/controller/subsystem/title, change_title_screen)), 1 SECONDS)

/**
 * Make sure reference time is set up. If not, this is now time 0.
 */
/datum/controller/subsystem/title/proc/check_progress_reference_time()
	if(!progress_reference_time)
		progress_reference_time = world.timeofday

/**
 * Handle and clean up leaving startup
 */
/datum/controller/subsystem/title/proc/check_finish_progress()
	//It's the first time we're firing out of startup -> pregame
	if(progress_json && SSticker.current_state == GAME_STATE_PREGAME)
		save_progress_json()

/**
 * Load the progress info json and setup that part of the SS.
*/
/datum/controller/subsystem/title/proc/load_progress_json()
	var/json_file = file(TITLE_PROGRESS_CACHE_FILE)
	if(!fexists(json_file))
		return

	// Load map progress cache info
	progress_json = json_decode(file2text(json_file))

	// Different format. Purge everything.
	if(progress_json["_version"] != TITLE_PROGRESS_CACHE_VERSION)
		progress_json.Cut()
		return

	// If there's no info about the current map, use the defaults.
	var/list/map_info = progress_json[SSmapping.current_map.map_name]
	if(!islist(map_info))
		return

	// Get expected total time and subpart time
	average_completion_time = map_info["total"] || DEFAULT_TITLE_MAP_LOADTIME
	startup_message_timings = map_info["messages"] || list()

/datum/controller/subsystem/title/proc/save_progress_json()
	var/json_file = file(TITLE_PROGRESS_CACHE_FILE)
	var/list/map_info = list()

	progress_json["_version"] = TITLE_PROGRESS_CACHE_VERSION

	if(progress_json[SSmapping.current_map.map_name])
		// Save total time and updated message timings. Latest time is worth 1/4 the "average"
		map_info["total"] = 0.75 * average_completion_time + 0.25 * (world.timeofday - progress_reference_time)
	else
		// New. Just save the time it took.
		map_info["total"] = world.timeofday - progress_reference_time
	map_info["messages"] = startup_message_timings
	progress_json[SSmapping.current_map.map_name] = map_info

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(progress_json))

	// We're done, don't touch it again this round.
	progress_json = null

/datum/controller/subsystem/title/Recover()
	startup_splash = SStitle.startup_splash
	file_path = SStitle.file_path

	current_title_screen = SStitle.current_title_screen
	current_notice = SStitle.current_notice
	title_html = SStitle.title_html
	title_screens = SStitle.title_screens

	average_completion_time = SStitle.average_completion_time
	startup_message_timings = SStitle.startup_message_timings
	progress_json = SStitle.progress_json
	progress_reference_time = SStitle.progress_reference_time

/**
 * Show the title screen to all new players.
 */
/datum/controller/subsystem/title/proc/show_title_screen()
	for(var/mob/dead/new_player/new_player in GLOB.new_player_list)
		INVOKE_ASYNC(new_player, TYPE_PROC_REF(/mob/dead/new_player, show_title_screen))

/**
 * Adds a notice to the main title screen in the form of big red text!
 */
/datum/controller/subsystem/title/proc/set_notice(new_title)
	current_notice = new_title ? sanitize_text(new_title) : null
	show_title_screen()

/**
 * Changes the title screen to a new image.
 */
/datum/controller/subsystem/title/proc/change_title_screen(new_screen)
	if(new_screen)
		current_title_screen = new_screen
	else
		if(LAZYLEN(title_screens))
			current_title_screen = pick(title_screens)
		else
			current_title_screen = DEFAULT_TITLE_SCREEN_IMAGE

	check_finish_progress()
	show_title_screen()

/**
 * Update a user's character setup name.
 * Arguments:
 * * user - The user being updated
 * * name - the real name of the current slot.
 */
/datum/controller/subsystem/title/proc/update_character_name(mob/dead/new_player/user, name)
	if(!(istype(user) && user.title_screen_is_ready))
		return

	user.client << output(name, "title_browser:update_current_character")

/**
 * Adds a startup message to the splashscreen.
 *
 * Arguments:
 * * msg - the message to show users.
 * * warning - optional: TRUE to indicate this is an error/warning
 */
/proc/add_startup_message(msg, warning)
	// Remove the # second(s) / #s part of the message.
	var/static/regex/msg_key_regex = new(@"[0-9.]+( second)?s?!", "ig")

	// HTML displayed to user
	var/msg_html = {"<p class="terminal_text">[warning ? "☒ " : ""][msg]</p>"}
	// Key used to cache the timing info
	var/msg_key = msg_key_regex.Replace(msg, "#")

	GLOB.startup_messages += msg_html

	// If we ran before SStitle initialized, set the ref time now.
	SStitle.check_progress_reference_time()

	// Add or update message history info.
	var/old_timing = SStitle.startup_message_timings[msg_key]
	var/new_timing
	if(!old_timing)
		// new message
		new_timing = world.timeofday - SStitle.progress_reference_time
	else
		// old message. Latest time is worth 1/4 the "average"
		new_timing = 0.75 * old_timing + 0.25 * (world.timeofday - SStitle.progress_reference_time)
	SStitle.startup_message_timings[msg_key] = new_timing

	for(var/mob/dead/new_player/new_player in GLOB.new_player_list)
		if(!new_player.title_screen_is_ready)
			continue

		new_player.client << output(msg_html, "title_browser:append_terminal_text")
		new_player.client << output(list2params(list(new_timing, SStitle.average_completion_time)), "title_browser:update_loading_progress")





/// BYOND timestamp corresponding to deadline (Jun. 16, 2025)
#define DEADLINE_TIMESTAMP 8033472000

/mob/dead/new_player
	/// Title screen is ready to receive signals
	var/title_screen_is_ready = FALSE
	/// Whether the player (if unvetted) has acknowledged the deadline warning
	var/unvetted_notified = FALSE

/**
 * Check player vetting status and if necessary warn about upcoming deadline
 *
 * Returns FALSE if unvetted and deadline has passed, TRUE otherwise
 */
/mob/dead/new_player/proc/trigger_unvetted_warning()
	if(!CONFIG_GET(flag/check_vetted))
		unvetted_notified = TRUE
		return TRUE
	if(!SSplayer_ranks.initialized)
		return TRUE
	if(SSplayer_ranks.is_vetted(client, admin_bypass = FALSE))
		unvetted_notified = TRUE
		return TRUE

	// Time's up
	if(DEADLINE_TIMESTAMP - world.realtime <= 0)
		tgui_alert(
			src,
			"Unvetted players are no longer allowed to join or observe rounds, please visit #get-vetted in the Discord to submit a vetting application",
			"You are unvetted!",
			timeout = 10 SECONDS,
		)
		return FALSE

	var/remaining_time = round((DEADLINE_TIMESTAMP - world.realtime) / (1 DAYS), 1)
	tgui_deadline_alert(
		src,
		"Unvetted players will lose the ability to join or observe rounds in [remaining_time] day\s!",
		"Get vetted by [time2text(DEADLINE_TIMESTAMP, "Month DD YYYY")]!",
		days_remaining = remaining_time,
		timeout = 10 SECONDS,
	)
	unvetted_notified = TRUE
	return TRUE

/mob/dead/new_player/Topic(href, href_list)
	if(src != usr)
		return

	if(!client)
		return

	if(client.interviewee)
		return FALSE

	if(href_list["observe"])
		play_lobby_button_sound()
		if(!unvetted_notified && !trigger_unvetted_warning())
			return FALSE
		make_me_an_observer()
		return

	if(href_list["job_traits"])
		play_lobby_button_sound()
		if(!unvetted_notified && !trigger_unvetted_warning())
			return FALSE
		show_job_traits()
		return

	if(href_list["server_swap"])
		play_lobby_button_sound()
		server_swap()
		return

	if(href_list["view_manifest"])
		play_lobby_button_sound()
		ViewManifest()
		return

	if(href_list["character_directory"])
		play_lobby_button_sound()
		client.show_character_directory()
		return

	if(href_list["toggle_antag"])
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/be_antag], !preferences.read_preference(/datum/preference/toggle/be_antag))
		client << output(preferences.read_preference(/datum/preference/toggle/be_antag), "title_browser:toggle_antag")
		return

	if(href_list["character_setup"])
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
		preferences.update_static_data(src)
		preferences.ui_interact(src)
		return

	if(href_list["game_options"])
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)
		return

	if(href_list["toggle_ready"])
		play_lobby_button_sound()
		// Prevent readying up after the round has begun setting up or is already playing
		if(SSticker.current_state >= GAME_STATE_SETTING_UP)
			to_chat(src, span_notice("The round is starting. You cannot ready up at this time."))
			return FALSE
		if(CONFIG_GET(flag/min_flavor_text))
			var/datum/preferences/preferences = client.prefs
			var/uses_silicon_flavortext = (is_silicon_job(preferences?.get_highest_priority_job()) && length_char(client?.prefs?.read_preference(/datum/preference/text/silicon_flavor_text)) < CONFIG_GET(number/silicon_flavor_text_character_requirement))
			var/uses_normal_flavortext = (!is_silicon_job(preferences?.get_highest_priority_job()) && length_char(client?.prefs?.read_preference(/datum/preference/text/flavor_text)) < CONFIG_GET(number/flavor_text_character_requirement))
			if(uses_silicon_flavortext)
				to_chat(src, span_notice("You need at least [CONFIG_GET(number/silicon_flavor_text_character_requirement)] characters of Silicon Flavor Text to ready up for the round. You have [length_char(client.prefs.read_preference(/datum/preference/text/silicon_flavor_text))] characters."))
				return
			if(uses_normal_flavortext)
				to_chat(src, span_notice("You need at least [CONFIG_GET(number/flavor_text_character_requirement)] characters of Flavor Text to ready up for the round. You have [length_char(client.prefs.read_preference(/datum/preference/text/flavor_text))] characters."))
				return

		if(!unvetted_notified && !trigger_unvetted_warning())
			return FALSE
		ready = is_ready_to_play() ? PLAYER_NOT_READY : PLAYER_READY_TO_PLAY
		client << output(ready, "title_browser:toggle_ready")
		return

	if(href_list["late_join"])
		play_lobby_button_sound()
		if(!unvetted_notified && !trigger_unvetted_warning())
			return FALSE
		GLOB.latejoin_menu.ui_interact(usr)
		return

	if(href_list["title_is_ready"])
		title_screen_is_ready = TRUE
		return

	if(href_list["polls_menu"])
		play_lobby_button_sound()
		handle_player_polling()
		return

	. = ..()

/mob/dead/new_player/Login()
	. = ..()
	show_title_screen()

/**
 * Shows the titlescreen to a new player.
 */
/mob/dead/new_player/proc/show_title_screen()
	if (client?.interviewee)
		return

	winset(src, "title_browser", "is-disabled=false;is-visible=true")
	winset(src, "status_bar", "is-visible=false")

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/lobby) //Sending pictures to the client
	assets.send(src)

	update_title_screen()

/**
 * Hard updates the title screen HTML, it causes visual glitches if used.
 */
/mob/dead/new_player/proc/update_title_screen()
	var/dat = get_title_html()

	src << browse(SStitle.current_title_screen, "file=loading_screen.gif;display=0")
	src << browse(dat, "window=title_browser")

/datum/asset/simple/lobby
	assets = list(
		"FixedsysExcelsior3.01Regular.ttf" = 'html/browser/FixedsysExcelsior3.01Regular.ttf',
	)

/**
 * Removes the titlescreen entirely from a mob.
 */
/mob/dead/new_player/proc/hide_title_screen()
	if(client?.mob)
		winset(client, "title_browser", "is-disabled=true;is-visible=false")
		winset(client, "status_bar", "is-visible=true")

/mob/dead/new_player/proc/play_lobby_button_sound()
	SEND_SOUND(src, sound('modular_skyrat/master_files/sound/effects/save.ogg'))

/**
 * Allows the player to select a server to join from any loaded servers.
 */
/mob/dead/new_player/proc/server_swap()
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	if(LAZYLEN(servers) == 1)
		var/server_name = servers[1]
		var/server_ip = servers[server_name]
		var/confirm = tgui_alert(src, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Connect me!", "Stay here"))
		if(confirm == "Connect me!")
			to_chat_immediate(src, "So long, spaceman.")
			client << link(server_ip)
		return
	var/server_name = tgui_input_list(src, "Please select the server you wish to swap to:", "Swap servers!", servers)
	if(!server_name)
		return
	var/server_ip = servers[server_name]
	var/confirm = tgui_alert(src, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Connect me!", "Stay here!"))
	if(confirm == "Connect me!")
		to_chat_immediate(src, "So long, spaceman.")
		src.client << link(server_ip)

/**
 * Shows currently available job traits
 */
/mob/dead/new_player/proc/show_job_traits()
	if (!client || client.interviewee)
		return
	if(!length(GLOB.lobby_station_traits))
		to_chat(src, span_warning("There are currently no job traits available!"))
		return
	var/list/available_lobby_station_traits = list()
	for (var/datum/station_trait/trait as anything in GLOB.lobby_station_traits)
		if (!trait.can_display_lobby_button(client))
			continue
		available_lobby_station_traits += trait

	if(!LAZYLEN(available_lobby_station_traits))
		to_chat(src, span_warning("There are currently no job traits available!"))
		return

	var/datum/station_trait/clicked_trait = tgui_input_list(src, "Select a job trait to sign up for:", "Job Traits", available_lobby_station_traits)

	if(!clicked_trait)
		return

	clicked_trait.on_lobby_button_click(src)

/**
 * Shows the player a list of current polls, if any.
 */
/mob/dead/new_player/proc/playerpolls()
	if(!usr || !client)
		return

	var/output
	if (!SSdbcore.Connect())
		return
	var/isadmin = FALSE
	if(client?.holder)
		isadmin = TRUE
	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = ckey))

	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		return
	if(query_get_new_polls.NextRow())
		output +={"<a class="menu_button menu_newpoll" href='byond://?src=[text_ref(src)];polls_menu=1'>POLLS (NEW)</a>"}
	else
		output +={"<a class="menu_button" href='byond://?src=[text_ref(src)];polls_menu=1'>POLLS</a>"}
	qdel(query_get_new_polls)
	if(QDELETED(src))
		return
	return output

#undef DEADLINE_TIMESTAMP
