/**
 * Администраторы заранее назначают игрокам должности для ивента.
 * Модуль выдаёт их готовым игрокам до обычного распределения, уведомляет игроков
 * и показывает заблокированные должности в настройках.
 *
 * Интеграция с core — добавление сигналов и их вызовов в наиболее общих/вероятных местах
 * Чуть чуть UI для отоброжения занятых для ивента должностей..
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
	/// ckey -> job typepath map. A null value means the row has no assigned job yet.
	var/alist/assignments = alist()

/datum/modpack/roundstart_roster/initialize()
	GLOB.roundstart_roster = src
	RegisterSignal(SSjob, COMSIG_ROUNDSTART_ROSTER_APPLY, PROC_REF(queue_assignments))
	RegisterSignal(SSjob, COMSIG_ROUNDSTART_ROSTER_VALIDATE_ASSIGNMENT, PROC_REF(validate_assignment))
	RegisterSignal(SSjob, COMSIG_ROUNDSTART_ROSTER_BYPASS_PREFS, PROC_REF(bypass_preferences))
	RegisterSignal(SSjob, COMSIG_ROUNDSTART_ROSTER_VALIDATE_ANTAG, PROC_REF(validate_antag_candidate))
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(finish_roundstart))

/datum/modpack/roundstart_roster/Destroy()
	unregister_signals()
	if(GLOB.roundstart_roster == src)
		GLOB.roundstart_roster = null
	return ..()

/datum/modpack/roundstart_roster/proc/unregister_signals()
	UnregisterSignal(SSjob, list(COMSIG_ROUNDSTART_ROSTER_APPLY, COMSIG_ROUNDSTART_ROSTER_VALIDATE_ASSIGNMENT, COMSIG_ROUNDSTART_ROSTER_BYPASS_PREFS, COMSIG_ROUNDSTART_ROSTER_VALIDATE_ANTAG))
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/// After successful character creation and key transfer, clear the roster, close its panel and stop listening for signals.
/datum/modpack/roundstart_roster/proc/finish_roundstart(datum/source)
	SIGNAL_HANDLER
	unregister_signals()
	assignments.Cut()
	SStgui.close_uis(src)
	update_open_panels()
