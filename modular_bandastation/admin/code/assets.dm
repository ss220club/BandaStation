/datum/asset/json/gamepanel
	name = "gamepanel"

/datum/asset/json/gamepanel/generate()
	var/list/data = list()
	var/list/panels = list("Object", "Turf", "Mob")
	for(var/panel in panels)
		data[panel] = list()
		data[panel]["subWindowTitle"] = panel
		switch(panel)
			if("Object")
				data[panel]["objList"] = typesof(/obj)
			if("Turf")
				data[panel]["objList"] = typesof(/turf)
			if("Mob")
				data[panel]["objList"] = typesof(/mob)

	return data
