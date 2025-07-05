/datum/supply_pack/organic/canned_food
    name = "Surplus canned food"
    desc = "У вас настолько ужасен повар что он не может обеспечить вас едой? Окей, мы можем отдать свои консервы, которые залежались на складе.\
            Внимание! Некоторые консервы могут быть предназначены только для слаймоменов. Также возможно нахождение просроченных консерв в ящике."
    cost = CARGO_CRATE_VALUE * 10
    contains = list(
		/obj/item/food/cannedfood/Expiredcannedfood = 1,
		/obj/item/food/cannedfood/cannedbeef = 1,
		/obj/item/food/cannedfood/cannedmushrooms = 1,
		/obj/item/food/cannedfood/condensedmilk = 1,
		/obj/item/food/cannedfood/cannedpizza = 1,
		/obj/item/food/cannedfood/cannedtuna = 1
	)
    crate_name = "Surplus canned food crate"

/datum/supply_pack/organic/canned_food/fill(obj/structure/closet/crate/our_crate)
	for(var/items in 1 to 10)
		var/item = pick(contains)
		new item(our_crate)
