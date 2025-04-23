/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	icon_state = "blueshield"
	icon = 'modular_bandastation/objects/icons/obj/storage/closet.dmi'
	req_access = list(ACCESS_BLUESHIELD)

/obj/structure/closet/secure_closet/blueshield/PopulateContents()
	new /obj/item/storage/briefcase/secure(src)
	new /obj/item/storage/medkit/advanced(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/storage/bag/garment/blueshield(src)
	new /obj/item/radio/headset/blueshield(src)
	new /obj/item/radio/headset/blueshield/alt(src)
	new /obj/item/sensor_device(src)
	new /obj/item/pinpointer/crew(src)
