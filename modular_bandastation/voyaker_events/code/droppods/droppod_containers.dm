/obj/structure/closet/crate/loot/common

/obj/structure/closet/crate/loot/common/Initialize(mapload)
	. = ..()

	var/list/loot = list(
		/obj/item/stack/sheet/iron,
		/obj/item/storage/toolbox,
		/obj/item/flashlight,
		/obj/item/crowbar
	)
	for(var/i in 1 to rand(3,6))
		var/path = pick(loot)
		new path(src)
