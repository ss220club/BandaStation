/datum/preference/choiced/language/init_possible_values()
	var/list/values = ..()
	//добавление нового языка в варианты выбора для черты двуязычности, если он не является основным для раундстартовой расы.
	values |= /datum/language/spinwarder::name

	return values
