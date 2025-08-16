/datum/preference/choiced/language/init_possible_values()
	var/list/values = list()

	if(!GLOB.uncommon_roundstart_languages.len)
		generate_selectable_species_and_languages()

	values += "Random"
	//we add uncommon as it's foreigner-only.
	values += /datum/language/uncommon::name
	//добавление нео-русского в варианты выбора для черты двуязычности
	values += /datum/language/spinwarder::name

	for(var/datum/language/language_type as anything in GLOB.uncommon_roundstart_languages)
		if(initial(language_type.name) in values)
			continue
		values += initial(language_type.name)

	return values
