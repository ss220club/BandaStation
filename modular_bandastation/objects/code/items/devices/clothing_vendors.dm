/obj/machinery/vending/autodrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/ratge = 1,
		)
	. = ..()

/obj/machinery/vending/wardrobe/chef_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/rank/civilian/chef/red = 2,
		/obj/item/clothing/suit/chef/red = 2,
		/obj/item/clothing/head/chefhat/red = 2,
		/obj/item/clothing/suit/apron/chef/red = 1,
		)
	. = ..()

/obj/machinery/vending/wardrobe/sec_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/cowboy/security = 3,
		/obj/item/clothing/head/soft/sec/corporate = 3,
		/obj/item/clothing/head/sec_beanie = 3,
		/obj/item/clothing/neck/cloak/sec_poncho = 3,
		/obj/item/clothing/under/rank/security/officer/corporate = 3,
		/obj/item/clothing/under/rank/security/officer/skirt/corporate = 3,
		/obj/item/clothing/suit/armor/vest/bomber = 3,
		/obj/item/clothing/suit/armor/vest/coat = 3,
		/obj/item/clothing/suit/armor/vest/caftan = 3,
		)
	. = ..()

/obj/machinery/vending/wardrobe/science_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/cowboy/science = 3,
		/obj/item/clothing/suit/jacket/bomber/science = 3,
		/obj/item/clothing/neck/cloak/sci_mantle = 3,
		)
	. = ..()
