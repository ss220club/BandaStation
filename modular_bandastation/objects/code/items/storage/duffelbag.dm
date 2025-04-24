/obj/item/storage/backpack/duffelbag/syndie/centcom
	name = "modified duffel bag"
	desc = "A large duffel bag for holding extra tactical supplies. It contains an oiled plastitanium zipper for maximum speed tactical zipping, and is better balanced on your back than an average duffelbag. Can hold three bulky items!"
	icon_state = "duffel-srt"
	icon = 'modular_bandastation/objects/icons/obj/storage/dufel-fufel/dufel_fufel.dmi'
	worn_icon = 'modular_bandastation/objects/icons/obj/clothing/back/dufel_fufel.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/obj/storage/dufel-fufel/dufel_fufel_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/obj/storage/dufel-fufel/dufel_fufel_righthand.dmi'
	worn_icon_state = "duffel-srt-back"
	inhand_icon_state = "duffel-srt"
	storage_type = /datum/storage/duffel/syndicate/centcom
	resistance_flags = FIRE_PROOF
	// No slowdown while unzipped.
	zip_slowdown = 0
	// Faster unzipping. Utilizes the same noise as zipping up to fit the unzip duration.
	unzip_duration = 0.5 SECONDS

/obj/item/storage/backpack/duffelbag/syndie/centcom/ammo
	inhand_icon_state = "duffel-srtammo"
	icon_state = "duffel-srtammo"
	worn_icon_state = "duffel-srtammo-back"

/obj/item/storage/backpack/duffelbag/syndie/centcom/med
	inhand_icon_state = "duffel-srtmed"
	icon_state = "duffel-srtmed"
	worn_icon_state = "duffel-srtmed-back"

/datum/storage/duffel/syndicate/centcom
	silent = TRUE
	exception_max = 3
