/datum/crewmonitor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps),
	)

/datum/crewmonitor/ui_static_data(mob/user)
	var/list/data = list()
	data["mapData"] = SSmapping.get_map_ui_data()
	return data
