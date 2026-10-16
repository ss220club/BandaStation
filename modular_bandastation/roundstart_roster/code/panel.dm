// Status values shared with the RoundstartRoster TGUI interface.
#define ROSTER_PLAYER_OFFLINE "offline"
#define ROSTER_PLAYER_NOT_READY "not_ready"
#define ROSTER_PLAYER_READY "ready"

ADMIN_VERB(roundstart_roster, R_ADMIN, "Admin Roundstart Job Assignment", "Назначить игрокам должности на старт раунда.", ADMIN_CATEGORY_GAME)
	if(SSticker.HasRoundStarted())
		to_chat(user, span_warning("Панель назначения должностей доступна только до старта раунда."))
		return
	GLOB.roundstart_roster.ui_interact(user.mob)

/datum/modpack/roundstart_roster/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/modpack/roundstart_roster/ui_status(mob/user, datum/ui_state/state)
	if(SSticker.HasRoundStarted())
		return UI_CLOSE
	return ..()

/datum/modpack/roundstart_roster/ui_interact(mob/user, datum/tgui/ui)
	if(SSticker.HasRoundStarted())
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoundstartRoster", "Ивентовые стартовые должности")
		ui.open()

/datum/modpack/roundstart_roster/ui_data(mob/user)
	if(SSticker.HasRoundStarted())
		return list()
	var/list/rows = list()
	for(var/player_ckey in assignments)
		var/client/player_client = GLOB.directory[player_ckey]
		var/mob/dead/new_player/player = player_client?.mob
		var/status = ROSTER_PLAYER_NOT_READY
		if(!player_client)
			status = ROSTER_PLAYER_OFFLINE
		else if(istype(player) && player.ready == PLAYER_READY_TO_PLAY)
			status = ROSTER_PLAYER_READY
		var/datum/job/job = SSjob.get_job_type(assignments[player_ckey])
		rows += list(list("ckey" = player_ckey, "job" = job?.title, "status" = status))
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(!(job.job_flags & JOB_LATEJOIN_ONLY))
			jobs += job.title
	return list("rows" = rows, "jobs" = jobs, "editable" = SSticker.current_state < GAME_STATE_SETTING_UP)

/datum/modpack/roundstart_roster/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/admin = ui.user
	if(SSticker.current_state >= GAME_STATE_SETTING_UP)
		return FALSE
	var/player_ckey = ckey(params["ckey"])
	if(action == "remove")
		if(!(player_ckey in assignments))
			return FALSE
		assignments -= player_ckey
		log_admin("[key_name(admin)] removed the roundstart job assignment for [player_ckey].")
		update_open_panels()
		return TRUE
	if(action == "add")
		var/list/players = list()
		for(var/mob/dead/new_player/candidate as anything in GLOB.new_player_list)
			if(candidate.client && candidate.mind && is_unassigned_job(candidate.mind.assigned_role) && !(candidate.ckey in assignments))
				players += candidate.ckey
		player_ckey = tgui_input_list(admin, "Выберите игрока", "Назначение должностей", sort_list(players))
		// Recheck admin rights and round state after the player selection dialog returns.
		if(!check_rights_for(admin?.client, R_ADMIN) || SSticker.current_state >= GAME_STATE_SETTING_UP)
			return FALSE
		var/client/player_client = GLOB.directory[player_ckey]
		var/mob/dead/new_player/player = player_client?.mob
		if(!player_ckey || player_ckey in assignments || !istype(player) || !player.mind || !is_unassigned_job(player.mind.assigned_role))
			return FALSE
		assignments[player_ckey] = null
		log_admin("[key_name(admin)] added [player_ckey] to the roundstart job panel.")
		return TRUE
	if(action != "set_job" || !(player_ckey in assignments))
		return FALSE
	var/datum/job/job = SSjob.get_job(params["job"])
	if(!(job in SSjob.joinable_occupations) || (job.job_flags & JOB_LATEJOIN_ONLY))
		return FALSE
	if(assignments[player_ckey] == job.type)
		return TRUE
	var/reserved = count_reserved_slots(job, player_ckey)
	if(job.spawn_positions >= 0 && job.current_positions + reserved >= job.spawn_positions)
		to_chat(admin, span_warning("Все места на эту должность уже заняты или зарезервированы."))
		return FALSE
	assignments[player_ckey] = job.type
	log_admin("[key_name(admin)] assigned [job.title] to [player_ckey] for roundstart.")
	notify_assignment(player_ckey, admin, job)
	update_open_panels()
	return TRUE

/// Ask the player to ready up for their roster job, using PM styling, the AHelp sound and a window flash.
/// The notification does not create a support ticket.
/datum/modpack/roundstart_roster/proc/notify_assignment(player_ckey, mob/admin, datum/job/job)
	var/client/player_client = GLOB.directory[player_ckey]
	if(!player_client)
		to_chat(admin, span_warning("[player_ckey] отключился. Назначение сохранено, но уведомление не доставлено."))
		return
	var/admin_name = html_encode(key_name(admin, FALSE, FALSE))
	var/job_name = html_encode(job_title_ru(job.title))
	to_chat(player_client,
		type = MESSAGE_TYPE_ADMINPM,
		html = fieldset_block(
			span_adminhelp("Назначение на ивентовую роль"),
			span_adminsay("Администратор <b>[admin_name]</b> выбрал вас на должность <b>[job_name]</b> для ивента.<br><br><b>Подтвердите готовность: обязательно нажмите «Готов» в лобби до старта раунда.</b> Без готовности назначение не будет выдано."),
			"boxed_message red_box"),
		confidential = TRUE)
	SEND_SOUND(player_client, sound('sound/effects/adminhelp.ogg'))
	window_flash(player_client, ignorepref = TRUE)

/// Refresh open roster and player preference panels after roster changes.
/datum/modpack/roundstart_roster/proc/update_open_panels()
	SStgui.update_uis(src)
	for(var/client/player_client as anything in GLOB.clients)
		SStgui.update_uis(player_client.prefs)

#undef ROSTER_PLAYER_OFFLINE
#undef ROSTER_PLAYER_NOT_READY
#undef ROSTER_PLAYER_READY
