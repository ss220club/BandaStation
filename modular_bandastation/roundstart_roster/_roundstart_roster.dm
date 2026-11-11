/**
 * Администраторы заранее назначают игрокам должности для ивента.
 * Модуль выдаёт их готовым игрокам до обычного распределения и уведомляет игроков.
 *
 * Интеграция с core — добавление сигналов и их вызовов в наиболее общих/вероятных местах
 *
 * После успешного старта COMSIG_TICKER_ROUND_STARTING закрывает панель, очищает
 * словарь и отключает подписки.
 * После старта раунда слоты не блокируется
 */
GLOBAL_DATUM(roundstart_roster, /datum/modpack/roundstart_roster)

/datum/modpack/roundstart_roster
	name = "Roundstart Roster"
	desc = "Назначение ивентовых должностей администрацией перед стартовым распределением."
	author = "Dr_smail"
	/// Player ckey -> /datum/job typepath | Null means no job has been selected yet.
	var/alist/assignments = alist()
	/// Separate read-only UI source for the public reservation list.
	var/datum/roundstart_roster_lobby/lobby_ui

/datum/modpack/roundstart_roster/initialize()
	GLOB.roundstart_roster = src
	RegisterSignal(SSjob, COMSIG_COLLECT_ROUNDSTART_ASSIGNMENT_CALLBACKS, PROC_REF(collect_assignment_callbacks))
	RegisterSignal(SSjob, COMSIG_CHECK_JOB_ASSIGNMENT, PROC_REF(validate_assignment))
	RegisterSignal(SSjob, COMSIG_BYPASS_JOB_PREFERENCES, PROC_REF(allow_empty_job_preferences))
	RegisterSignal(SSjob, COMSIG_CHECK_ROUNDSTART_ANTAG_CANDIDATE, PROC_REF(validate_antag_candidate))
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

/datum/modpack/roundstart_roster/Destroy()
	QDEL_NULL(lobby_ui)
	GLOB.roundstart_roster = null
	return ..()

/datum/modpack/roundstart_roster/proc/unregister_signals()
	UnregisterSignal(SSjob, list(
		COMSIG_COLLECT_ROUNDSTART_ASSIGNMENT_CALLBACKS,
		COMSIG_CHECK_JOB_ASSIGNMENT,
		COMSIG_BYPASS_JOB_PREFERENCES,
		COMSIG_CHECK_ROUNDSTART_ANTAG_CANDIDATE,
	))
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/// After successful character creation and key transfer, clear the roster, close its panel and stop listening for signals.
/datum/modpack/roundstart_roster/proc/on_round_start(datum/source)
	SIGNAL_HANDLER
	unregister_signals()
	assignments.Cut()
	SStgui.close_uis(src)
	QDEL_NULL(lobby_ui)
	update_open_panels()
