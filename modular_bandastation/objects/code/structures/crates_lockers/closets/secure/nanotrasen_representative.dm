/obj/structure/closet/secure_closet/nanotrasen_representative
	name = "nanotrasen representative's locker"
	icon_state = "nanotrasen_representative"
	icon = 'modular_bandastation/objects/icons/obj/storage/closet.dmi'
	req_access = list(ACCESS_NANOTRASEN_REPRESENTATIVE)

/obj/structure/closet/secure_closet/nanotrasen_representative/PopulateContents()
	return list(
		/obj/item/storage/briefcase/secure,
		/obj/item/radio/headset/heads/nanotrasen_representative,
		/obj/item/pai_card,
		/obj/item/assembly/flash/handheld,
		/obj/item/taperecorder,
		/obj/item/storage/box/tapes,
		/obj/item/storage/bag/garment/nanotrasen_representative,
	)

