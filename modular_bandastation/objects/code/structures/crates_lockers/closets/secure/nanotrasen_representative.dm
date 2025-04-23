/obj/structure/closet/secure_closet/nanotrasen_representative
	name = "nanotrasen representative's locker"
	icon_state = "nanotrasen_representative"
	icon = 'modular_bandastation/objects/icons/obj/storage/closet.dmi'
	req_access = list(ACCESS_NANOTRASEN_REPRESENTATIVE)

/obj/structure/closet/secure_closet/nanotrasen_representative/PopulateContents()
	new /obj/item/storage/briefcase/secure(src)
	new /obj/item/radio/headset/heads/nanotrasen_representative(src)
	new /obj/item/pai_card(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/taperecorder(src)
	new /obj/item/storage/box/tapes(src)
	new /obj/item/storage/bag/garment/nanotrasen_representative(src)
