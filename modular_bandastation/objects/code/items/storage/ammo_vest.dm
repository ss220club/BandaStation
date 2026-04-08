// MARK: Ammo Webbing
/datum/storage/pockets/ammo_v
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/pockets/ammo_v/New()
	. = ..()
	set_holdable(list(
		/obj/item/ammo_box/magazine
	))
