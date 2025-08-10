// This file contains all boxes used by the Cargo department and its purpose on the station.

/obj/item/storage/box/shipping
	name = "box of shipping supplies"
	desc = "Содержит несколько сканеров и этикетировщиков для доставки вещей. Оберточная бумага не включена."
	illustration = "shipping"

/obj/item/storage/box/shipping/PopulateContents()
	var/static/items_inside = list(
		/obj/item/dest_tagger=1,
		/obj/item/universal_scanner=1,
		/obj/item/stack/package_wrap/small=2,
		/obj/item/stack/wrapping_paper/small=1,
		)
	generate_items_inside(items_inside,src)
