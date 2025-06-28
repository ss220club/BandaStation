/datum/mafia_role/detective
	name = "Детектив"
	desc = "Вы можете исследовать одного человека в каждую ночь, чтобы узнать его команду.."
	revealed_outfit = /datum/outfit/mafia/detective
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/detective

	hud_icon = "huddetective"
	revealed_icon = "detective"

	role_unique_actions = list(/datum/mafia_ability/investigate)

/datum/mafia_role/psychologist
	name = "Психолог"
	desc = "Вы можете посетить кого-то ОДИН раз за игру, чтобы раскрыть его истинную роль утром!"
	revealed_outfit = /datum/outfit/mafia/psychologist
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/psychologist

	hud_icon = "hudpsychologist"
	revealed_icon = "psychologist"

	role_unique_actions = list(/datum/mafia_ability/reveal_role)

/datum/mafia_role/chaplain
	name = "Священник"
	desc = "Каждую ночь вы можете общаться с духами мертвых, чтобы узнать роли погибших членов экипажа.."
	revealed_outfit = /datum/outfit/mafia/chaplain
	role_type = TOWN_INVEST
	hud_icon = "hudchaplain"
	revealed_icon = "chaplain"
	winner_award = /datum/award/achievement/mafia/chaplain

	role_unique_actions = list(/datum/mafia_ability/seance)
