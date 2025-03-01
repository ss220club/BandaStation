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
	var/list/org = outfit_data["organs"]
	organs = list()
	for(var/O in org)
		var/orgtype = text2path(O)
		if(orgtype)
			organs += orgtype
	return TRUE
