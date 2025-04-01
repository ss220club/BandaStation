/datum/asset/json/gamepanel
	name = "gamepanel"

/datum/asset/json/gamepanel/generate()
	var/list/data = list()
	var/list/panels = list("Object", "Turf", "Mob")
	for(var/panel in panels)
		switch(panel)
			if("Object")
				data[panel] = typesof(/obj)
			if("Turf")
				data[panel] = typesof(/turf)
			if("Mob")
				data[panel] = typesof(/mob)

	return data
