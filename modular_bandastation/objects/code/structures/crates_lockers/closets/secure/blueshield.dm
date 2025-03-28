/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	icon_state = "blueshield"
	icon = 'modular_bandastation/objects/icons/obj/storage/closet.dmi'
	req_access = list(ACCESS_BLUESHIELD)

/obj/structure/closet/secure_closet/blueshield/PopulateContents()
	return list(
		/obj/item/storage/briefcase/secure,
		/obj/item/storage/medkit/advanced,
		/obj/item/storage/belt/security/full,
		/obj/item/storage/bag/garment/blueshield,
		/obj/item/radio/headset/blueshield,
		/obj/item/radio/headset/blueshield/alt,
		/obj/item/sensor_device,
		/obj/item/pinpointer/crew,
	)
