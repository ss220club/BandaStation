/obj/item/storage/box/id_stickers
	name = "ID stickers box"
	desc = "Коробка с кучкой наклеек на ID карту."
	icon = 'modular_bandastation/objects/icons/obj/storage/box.dmi'
	icon_state = "id_stickers_box"
	illustration = "id_stickers_box_label"

/obj/item/storage/box/id_stickers/PopulateContents()
	for(var/i in 1 to 3)
		var/skin = pick(subtypesof(/obj/item/id_sticker))
		new skin(src)
