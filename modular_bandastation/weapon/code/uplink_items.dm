// Syndie Deagle
/datum/uplink_item/weapon_kits/medium_cost/desert_eagle
	name = "Syndicate Desert Eagle Case (Moderate)"
	desc = "An old time classic handcannon of Brutality and Power. Fires 7 brutal rounds of .50 AE. \
		A non-classic operative weapon, improved for the modern era. Comes with 3 additional magazines of .50 AE."
	item = /obj/item/storage/toolbox/guncase/desert_eagle
	relevant_child_items = list(
		/datum/uplink_item/ammo/desert_eagle,
		/datum/uplink_item/ammo_nuclear/basic/desert_eagle,
	)

/datum/uplink_item/dangerous/desert_eagle
	name = "Syndicate Desert Eagle"
	desc = "An old time classic brutal handcannon that fires .50 AE rounds and has 7 rounds in magazine."
	item = /obj/item/gun/ballistic/automatic/pistol/deagle
	cost = 14
	surplus = 50
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS
	relevant_child_items = list(
		/datum/uplink_item/ammo/desert_eagle,
		/datum/uplink_item/ammo_nuclear/basic/desert_eagle,
	)

/datum/uplink_item/ammo/desert_eagle
	name = ".50 AE magazine"
	desc = "A magazine that contains seven additional .50 AE rounds; usable with the Desert Eagle pistol. \
			For when you really need a lot of things dead."
	item = /obj/item/ammo_box/magazine/m50
	cost = 4
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/ammo_nuclear/basic/desert_eagle
	name = ".50 AE magazine (Desert Eagle)"
	desc = "A magazine that contains seven additional .50 AE rounds; usable with the Desert Eagle pistol. \
		For when you really need a lot of things dead. Unlike field agents, operatives get a premium price for their magazines!"
	item = /obj/item/ammo_box/magazine/m50
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

//MARK: China Lake 40mm
/datum/uplink_item/weapon_kits/medium_cost/china_lake
	name = "China Lake 40mm Grenade Launcher (Hard)"
	desc = "An old but trusty 40mm pump grenade launcher preloaded with a HE grenades. \
		Guaranteed to take your target out with a bang, or your money back! Comes with a box of additional grenades!"
	item = /obj/item/storage/toolbox/guncase/china_lake
	relevant_child_items = list(
		/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm,
		/datum/uplink_item/ammo_nuclear/special/carbine/a40mm/stun,
		/datum/uplink_item/ammo_nuclear/incendiary/carbine/a40mm/incendiary,
		/datum/uplink_item/ammo_nuclear/hp/carbine/a40mm/frag,
		/datum/uplink_item/ammo_nuclear/ap/carbine/a40mm/hedp,
		/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/smoke,
	)

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm
	name = "40mm HE Grenade Box"
	desc = "A box of 40mm HE grenades for use with the China Lake and M-90gl's under-barrel grenade launchers. \
		Your teammates will ask you to not shoot these down small hallways. \
		You'll do it anyway."
	item = /obj/item/storage/fancy/a40mm_box

/datum/uplink_item/ammo_nuclear/special/carbine/a40mm/stun
	name = "40mm Stun Grenade Box"
	desc = "A box of 40mm Stun grenades for use with the China Lake and M-90gl's under-barrel grenade launchers. \
		Stun grenades are basically like a better flashbangs! Bang-bang!"
	item = /obj/item/storage/fancy/a40mm_box/stun

/datum/uplink_item/ammo_nuclear/incendiary/carbine/a40mm/incendiary
	name = "40mm Incendiary Grenade Box"
	desc = "A box of 40mm Incendiary grenades for use with the China Lake and M-90gl's under-barrel grenade launchers. \
		Incendiary grenades explode with a lot of fire! Roasted crew members are guaranteed."
	item = /obj/item/storage/fancy/a40mm_box/incendiary

/datum/uplink_item/ammo_nuclear/hp/carbine/a40mm/frag
	name = "40mm Frag Grenade Box"
	desc = "A box of 40mm Frag grenades for use with the China Lake and M-90gl's under-barrel grenade launchers. \
		Fragmentation grenades explode with lots of dangerous shrapnel! It's best to lie down on the ground."
	item = /obj/item/storage/fancy/a40mm_box/frag

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/smoke
	name = "40mm Smoke Grenade Box"
	desc = "A box of 40mm HE grenades for use with the China Lake and M-90gl's under-barrel grenade launchers. \
		Smoke grenades form a cloud of smoke when they explode that can reduce danger from lasers and cover your friend!"
	item = /obj/item/storage/fancy/a40mm_box/smoke

/datum/uplink_item/ammo_nuclear/ap/carbine/a40mm/hedp
	name = "40mm HEDP Grenade Box"
	desc = "A box of 40mm HE grenades for use with the China Lake and M-90gl's under-barrel grenade launchers. \
		HEDP grenades can destroy almost any silicon or mechas... and people too. Walls and doors are also included."
	item = /obj/item/storage/fancy/a40mm_box/hedp

// MARK: Sledgehammer
/datum/uplink_item/weapon_kits/low_cost/syndiesledge
	name = "Syndicate Breaching Sledgehammer (Hard)"
	desc = "Contains a plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders. Comes with a welding helmet for your safety on the workplace!"
	item = /obj/item/storage/toolbox/guncase/syndiesledge
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	surplus = 0

/datum/uplink_item/role_restricted/syndiesledge
	name = "Syndicate Breaching Sledgehammer"
	desc = "Plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders."
	item = /obj/item/sledgehammer/syndie
	cost = 10
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)
