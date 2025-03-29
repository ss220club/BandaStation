/obj/item/storage/box/tapes
	name = "tape box"
	desc = "Коробка запасных плёнок для диктофона."

/obj/item/storage/box/tapes/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/tape/random = 6
	))
