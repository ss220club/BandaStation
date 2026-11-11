/// Public reservation counts only; player identities stay in the admin panel.
/datum/modpack/roundstart_roster/proc/get_lobby_data()
	var/list/data = list("jobs" = list(), "total" = 0)
	if(!SSticker || SSticker.HasRoundStarted())
		return data

	var/list/job_counts = list()
	for(var/player_ckey in assignments)
		var/datum/job/job = SSjob.get_job_type(assignments[player_ckey])
		if(!job)
			continue
		job_counts[job.title] += 1
		data["total"] += 1

	var/list/jobs = data["jobs"]
	for(var/job_title in sort_list(job_counts))
		jobs += list(list("title" = job_title_ru(job_title), "count" = job_counts[job_title]))
	return data

/// Send a personalized header after the browser loads or the roster changes.
/datum/modpack/roundstart_roster/proc/update_lobby_player(client/viewer, list/lobby_data)
	if(!viewer || !isnewplayer(viewer.mob))
		return
	if(isnull(lobby_data))
		lobby_data = get_lobby_data()
	var/datum/job/assigned_job = SSjob.get_job_type(assignments[viewer.ckey])
	var/list/header_data = list(
		"total" = lobby_data["total"],
		"assigned_job" = lobby_data["total"] && assigned_job ? job_title_ru(assigned_job.title) : null,
	)
	SStitle.title_output(viewer, json_encode(header_data), "updateRoster")

/// Aggregate once per roster change, without polling or reloading the lobby.
/datum/modpack/roundstart_roster/proc/update_lobby()
	var/list/lobby_data = get_lobby_data()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		update_lobby_player(player.client, lobby_data)
	if(lobby_ui)
		SStgui.update_uis(lobby_ui)

/datum/modpack/roundstart_roster/proc/open_lobby_list(mob/user)
	if(!user?.client || !isnewplayer(user) || SSticker.HasRoundStarted())
		return
	if(!lobby_ui)
		lobby_ui = new
	lobby_ui.ui_interact(user)

/datum/roundstart_roster_lobby/Destroy()
	SStgui.close_uis(src)
	return ..()

/datum/roundstart_roster_lobby/ui_state(mob/user)
	return GLOB.new_player_state

/datum/roundstart_roster_lobby/ui_status(mob/user, datum/ui_state/state)
	if(SSticker.HasRoundStarted())
		return UI_CLOSE
	return ..()

/datum/roundstart_roster_lobby/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoundstartRosterManifest", "Ивентовые назначения")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/roundstart_roster_lobby/ui_data(mob/user)
	return GLOB.roundstart_roster.get_lobby_data()
