/datum/mafia_role/mafia
	name = "Генокрад"
	desc = "Вы - член улья генокрадов. Вы можете разговаривать с своими товарищами-генокрадами ночью."
	team = MAFIA_TEAM_MAFIA
	role_type = MAFIA_REGULAR
	role_flags = ROLE_CAN_KILL
	hud_icon = "hudchangeling"
	revealed_icon = "changeling"
	winner_award = /datum/award/achievement/mafia/changeling

	revealed_outfit = /datum/outfit/mafia/changeling
	special_ui_theme = "syndicate"
	win_condition = "становятся главным в городе, и никакой одиночка не сможет его остановить."

	role_unique_actions = list(/datum/mafia_ability/changeling_kill)

/datum/mafia_role/mafia/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game, COMSIG_MAFIA_SUNDOWN, PROC_REF(mafia_text))

/datum/mafia_role/mafia/proc/mafia_text(datum/mafia_controller/source)
	SIGNAL_HANDLER

	to_chat(body, "<b>Проголосуйте за того, кто будет убит сегодня ночью. Убийца будет выбран случайным образом из числа проголосовавших.</b>")

/datum/mafia_role/mafia/thoughtfeeder
	name = "Кормилец мыслей"
	desc = "Вы - разновидность генокрадов, питающаяся воспоминаниями других людей. Используйте приставку ':j', чтобы разговаривать со своими собратьями и посещайте людей по ночам, чтобы узнать их роль."
	role_type = MAFIA_SPECIAL
	hud_icon = "hudthoughtfeeder"
	revealed_icon = "thoughtfeeder"
	winner_award = /datum/award/achievement/mafia/thoughtfeeder

	role_unique_actions = list(/datum/mafia_ability/changeling_kill, /datum/mafia_ability/thoughtfeeder)
