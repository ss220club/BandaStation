/datum/outfit/get_json_data()
	. = ..()
	.["organs"] = organs

/datum/outfit/copy_from(datum/outfit/target)
	. = ..()
	organs = target.organs

/datum/outfit/load_from(list/outfit_data)
	. = ..()
	if(!.)
		return
	organs = text2path(outfit_data["organs"])
	return TRUE
