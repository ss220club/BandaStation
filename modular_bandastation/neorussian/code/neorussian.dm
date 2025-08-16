/datum/preference/choiced/language/init_possible_values()
	var/list/values = ..()
	//добавление нео-русского в варианты выбора для черты двуязычности
	if (!(/datum/language/spinwarder::name in values))
		values += /datum/language/spinwarder::name
	return values
