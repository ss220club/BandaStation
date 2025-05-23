/datum/asset/json/gamepanel
	name = "gamepanel"

/datum/asset/json/gamepanel/proc/check_mapping(atom/some_atom)
	var/atom_text = "[some_atom]"
	var/is_mapping = findtext(atom_text, "helper") || findtext(atom_text, "spawner") || findtext(atom_text, "random")
	return is_mapping ? TRUE : FALSE

/datum/asset/json/gamepanel/generate()
	var/list/data = list()
	var/list/objects = typesof(/obj)
	var/list/turfs = typesof(/turf)
	var/list/mobs = typesof(/mob)

	data["Objects"] = list()
	data["Turfs"] = list()
	data["Mobs"] = list()

	for(var/item in objects)
		var/obj/temp = item;
		data["Objects"][item] = list(
			"icon" = temp?.icon || "none",
			"icon_state" = temp?.icon_state || "none",
			"name" = temp.name,
			"mapping" = check_mapping(item)
		)

	for(var/item in turfs)
		var/turf/temp = item;
		data["Turfs"][item] = list(
			"icon" = temp?.icon || "noneturf",
			"icon_state" = temp?.icon_state || "noneturf",
			"name" = temp.name,
			"mapping" = check_mapping(item)
		)

	for(var/item in mobs)
		var/mob/temp = item;
		data["Mobs"][item] = list(
			"icon" = temp?.icon || "nonemob",
			"icon_state" = temp?.icon_state || "nonemob",
			"name" = temp.name,
			"mapping" = check_mapping(item)
		)

	return data
