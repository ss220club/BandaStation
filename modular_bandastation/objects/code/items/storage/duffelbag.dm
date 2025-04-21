/obj/item/storage/backpack/duffelbag/syndie/centcom
	name = "modified duffel bag"
	desc = "A large duffel bag for holding extra tactical supplies. It contains an oiled plastitanium zipper for maximum speed tactical zipping, and is better balanced on your back than an average duffelbag. Can hold three bulky items!"
	icon_state = "duffel-syndie"
	inhand_icon_state = "duffel-syndieammo"
	storage_type = /datum/storage/duffel/syndie/centcom
	resistance_flags = FIRE_PROOF
	// No slowdown while unzipped.
	zip_slowdown = 0
	// Faster unzipping. Utilizes the same noise as zipping up to fit the unzip duration.
	unzip_duration = 0.5 SECONDS

/datum/storage/duffel/syndicate/centcom
	silent = TRUE
	exception_max = 3
