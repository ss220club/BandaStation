/obj/machinery/computer/security
	var/datum/nanomap/nanomap

/obj/machinery/computer/security/Initialize(mapload)
	. = ..()
	nanomap = new /datum/nanomap

/obj/machinery/computer/security/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps),
	)

/obj/machinery/computer/security/ui_static_data()
	var/list/data = ..()
	data["mapData"] = nanomap.get_tgui_data()
	return data
