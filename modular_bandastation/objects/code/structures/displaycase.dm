/obj/structure/displaycase/captain
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/displaycase/hos
	desc = "Гарантия того, что работа будет непременно выполнена."
	req_access = list(ACCESS_HOS)

/obj/structure/displaycase/hos/Initialize(mapload)
	start_showpiece_type = pick(/obj/item/toy/gun/legacy/mateba, /obj/item/toy/gun/legacy/anaconda, /obj/item/toy/gun/legacy/rsh12)
	return ..()
