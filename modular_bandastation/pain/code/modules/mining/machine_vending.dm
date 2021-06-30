// -- Additional stuff for the mining point vendor. --
/obj/machinery/mineral/equipment_vendor/Initialize()
	prize_list += new /datum/data/mining_equipment("Painkiller Medipen", /obj/item/reagent_containers/hypospray/medipen/survival/painkiller, 500)
	. = ..()
