/obj/item/storage/box/smoke_grenade
	name = "box of smoke grenade"
	desc = "Do not shake."
	icon_state = "security"
	illustration = "grenade"

/obj/item/storage/box/smoke_grenade/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/grenade/smokebomb = 6
	))
