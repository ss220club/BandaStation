/datum/emote_panel
	var/list/blacklisted_emotes = list("me", "help")

// BANDASTATION EDIT START - Select an eligible species variant for each emote key.
/datum/emote_panel/ui_static_data(mob/user)
	var/list/data = list()

	var/list/emotes = list()

	for(var/key in GLOB.emote_list)
		var/list/variants = GLOB.emote_list[key]
		var/datum/emote/first_variant = variants[1]
		if(first_variant.key != key || (key in blacklisted_emotes))
			continue
		var/datum/emote/emote = get_available_emote(user, key)
		if(!emote)
			continue
		emotes += list(list(
			"key" = emote.key,
			"name" = emote.name,
			"hands" = emote.hands_use_check,
			"visible" = emote.emote_type & EMOTE_VISIBLE,
			"audible" = emote.emote_type & EMOTE_AUDIBLE,
			"sound" = !isnull(emote.get_sound(user)),
			"use_params" = emote.message_param,
		))

	data["emotes"] = emotes

	return data
// BANDASTATION EDIT END

// BANDASTATION EDIT START - Validate panel requests and recheck delayed input.
/datum/emote_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(QDELETED(ui.user) || !ui.user.client)
		return
	switch(action)
		if("play_emote")
			var/emote_key = params["emote_key"]
			var/mob/user = ui.user
			var/client/user_client = user.client
			var/datum/emote/emote = get_available_emote(user, emote_key, status_check = TRUE)
			if(!emote || (emote.key in blacklisted_emotes))
				return
			var/use_params = params["use_params"]
			var/emote_param
			if(emote.message_param && use_params)
				emote_param = tgui_input_text(user, "Add params to the emote...", emote.message_param, max_length = MAX_MESSAGE_LEN)
			if(QDELETED(user) || QDELETED(ui) || ui.closing || ui.status != UI_INTERACTIVE || ui.user != user || user.client != user_client || user_client?.mob != user)
				return
			if(get_available_emote(user, emote_key, status_check = TRUE) != emote)
				return
			user.emote(emote_key, message = emote_param, intentional = TRUE)
		if("preview_sound")
			var/emote_key = params["emote_key"]
			var/datum/emote/emote = get_available_emote(ui.user, emote_key, status_check = TRUE)
			if(!emote || (emote.key in blacklisted_emotes) || !emote.should_play_sound(ui.user, intentional = TRUE))
				return
			var/emote_sound = get_sfx(emote.get_sound(ui.user))
			if(!emote_sound)
				to_chat(ui.user, span_warning("Couldn't get a preview sound for [emote.name]."), type = MESSAGE_TYPE_INFO)
				return
			SEND_SOUND(ui.user, sound(emote_sound, volume = 75))
			to_chat(ui.user, span_warning("Previewed sound for [emote.name]."), type = MESSAGE_TYPE_INFO)
// BANDASTATION EDIT END

/datum/emote_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmotePanel")
		ui.set_autoupdate(FALSE)
		ui.open()
	// BANDASTATION ADDITION START - The user may have changed species since opening.
	else
		update_static_data(user, ui)
	// BANDASTATION ADDITION END

/datum/emote_panel/ui_state(mob/user)
	return GLOB.always_state

// BANDASTATION ADDITION START - Shared panel eligibility and event-driven refresh.
/// Resolve aliases and select the first emote variant the current mob can perform.
/proc/get_available_emote(mob/user, emote_key, status_check = FALSE)
	if(QDELETED(user) || !istext(emote_key))
		return
	for(var/datum/emote/emote in GLOB.emote_list[emote_key])
		// Some specialized checks assume their allowed mob type before calling parent.
		if(!is_type_in_typecache(user, emote.mob_type_allowed_typecache) || is_type_in_typecache(user, emote.mob_type_blacklist_typecache))
			continue
		if(emote.can_run_emote(user, status_check = status_check, intentional = TRUE))
			return emote

/// Refresh only this client's sidebar and already-open full emote panel.
/mob/proc/update_emote_panels()
	if(!client)
		return
	client.tgui_panel?.emotes_send_list()
	GLOB.emote_panel?.update_static_data(src, always_instant = TRUE)
// BANDASTATION ADDITION END
