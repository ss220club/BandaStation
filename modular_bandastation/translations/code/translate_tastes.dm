/proc/ru_taste(taste, list/override)
	var/list/list_to_use = override || GLOB.ru_tastes
	return list_to_use[taste] || taste
