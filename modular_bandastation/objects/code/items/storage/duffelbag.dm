/obj/item/storage/backpack/duffelbag/centcom
	name = "modified duffel bag"
	desc = "A large duffel bag for holding extra tactical supplies. It contains an oiled plastitanium zipper for maximum speed tactical zipping, and is better balanced on your back than an average duffelbag. Can hold three bulky items!"
	icon_state = "duffel-syndiemed"
	inhand_icon_state = "duffel-syndiemed"
	storage_type = /datum/storage/duffel/centcom
	resistance_flags = FIRE_PROOF
	// Less slowdown while unzipped. Still bulky, but it won't halve your movement speed in an active combat situation.
	zip_slowdown = 0
	// Faster unzipping. Utilizes the same noise as zipping up to fit the unzip duration.
	unzip_duration = 0.5 SECONDS
	unzip_sfx = 'sound/items/zip/zip_up.ogg'

/datum/storage/duffel/centcom
	silent = TRUE
	exception_max = 3

/datum/storage/duffel/centcom/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	var/static/list/exception_type_list = list(
		// Gun and gun-related accessories
		/obj/item/gun,
		/obj/item/pneumatic_cannon,
		// Melee
		/obj/item/kinetic_crusher, //mostly
		/obj/item/dualsaber,
		/obj/item/staff/bostaff,
		/obj/item/fireaxe,
		/obj/item/crowbar/mechremoval,
		/obj/item/spear,
		/obj/item/nullrod,
		/obj/item/melee/cleric_mace,
		/obj/item/melee/ghost_sword,
		/obj/item/melee/cleaving_saw,
		// Deployables
		/obj/item/transfer_valve,
		/obj/item/powersink,
		/obj/item/deployable_turret_folded,
		/obj/item/cardboard_cutout,
		/obj/item/gibtonite,
		// Sustenance
		/obj/item/food/cheese/royal,
		/obj/item/food/powercrepe,
		// Back Items
		/obj/item/tank/jetpack,
		/obj/item/watertank,
		// Skub
		/obj/item/skub,
		// Bulky Supplies
		/obj/item/mecha_ammo,
		/obj/item/golem_shell,
		// Clothing
		/obj/item/clothing/shoes/winterboots/ice_boots/eva,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor/heavy,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/utility,
		// Storage
		/obj/item/storage/bag/money,
		// Heads!
		/obj/item/bodypart/head,
		// Fish
		/obj/item/fish,
		/obj/item/fish_tank,
	)

	set_holdable(exception_hold_list = exception_type_list)

	//...So we can run this without it generating a line for every subtype.
	var/list/desc = list()
	for(var/obj/item/valid_item as anything in exception_type_list)
		desc += "\a [initial(valid_item.name)]"
	can_hold_description = "\n\t[span_notice("[desc.Join("\n\t")]")]"
