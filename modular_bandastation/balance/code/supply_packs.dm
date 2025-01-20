/datum/supply_pack
	special_pod = /obj/structure/closet/supplypod/teleporter

// Disabled. Waiting for rebalancing.
/datum/supply_pack/imports/materials_market
	special = TRUE

/obj/machinery/materials_market/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_QDEL
