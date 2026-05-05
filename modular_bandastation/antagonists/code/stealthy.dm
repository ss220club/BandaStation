/datum/uplink_item/stealthy_weapons/ruger22lr
	name = "Ruger .22 LR Tranquility Pistol"
	desc = "A compact suppressed tranquilizer pistol designed for covert nonlethal operations. \
		Comes with no extra magazines, but is compatible with .22 LR tranquilizer magazines."
	item = /obj/item/gun/ballistic/automatic/pistol/ruger22lr
	cost = 10
	purchasable_from = UPLINK_TRAITORS
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND
	relevant_child_items = list(
		/datum/uplink_item/ammo/tranq22lr,
	)
