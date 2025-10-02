/datum/personality/brave
	savefile_key = "brave"
	name = "Храбрый"
	desc = "Нужно нечто большее, чем немного крови, чтобы напугать меня."
	pos_gameplay_desc = "Страх накапливается медленнее, а эффекты настроения, связанные со страхом, слабее"
	groups = list(PERSONALITY_GROUP_GENERAL_FEAR, PERSONALITY_GROUP_PEOPLE_FEAR)

/datum/personality/cowardly
	savefile_key = "cowardly"
	name = "Трусливый"
	desc = "Здесь всё представляет опасность! Даже воздух!"
	neg_gameplay_desc = "Страх накапливается быстрее, а эффекты настроения, связанные со страхом, сильнее"
	groups = list(PERSONALITY_GROUP_GENERAL_FEAR)
