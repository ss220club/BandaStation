/obj/item/storage/box/deathimp
	name = "death alarm implant kit"
	desc = "Коробка с имплантами оповещения о смерти."
	illustration = "implant"

/obj/item/storage/box/deathimp/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/implanter/death_alarm = 1,
		/obj/item/implantcase/death_alarm = 6
	))
