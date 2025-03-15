/datum/mafia_role/lawyer
	name = "Адвокат"
	desc = "Вы можете выбрать человека, которому будете предоставлять обширные юридические консультации, предотвращая ночные действия."
	revealed_outfit = /datum/outfit/mafia/lawyer
	role_type = TOWN_SUPPORT
	hud_icon = "hudlawyer"
	revealed_icon = "lawyer"
	winner_award = /datum/award/achievement/mafia/lawyer

	role_unique_actions = list(/datum/mafia_ability/roleblock)

/datum/mafia_role/hop
	name = "Глава персонала"
	desc = "Вы можете раскрыть себя один раз за игру, утроив силу голоса, но лишившись возможности быть защищенным!"
	role_type = TOWN_SUPPORT
	role_flags = ROLE_UNIQUE
	role_flags = ROLE_CAN_KILL
	hud_icon = "hudheadofpersonnel"
	revealed_icon = "headofpersonnel"
	revealed_outfit = /datum/outfit/mafia/hop
	winner_award = /datum/award/achievement/mafia/hop

	role_unique_actions = list(/datum/mafia_ability/self_reveal)
