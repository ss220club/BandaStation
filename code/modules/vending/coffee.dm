/obj/machinery/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Выпейте!;Выпьем!;На здоровье!;Не хотите горячего супчику?;Я бы убил за чашечку кофе!;Лучшие зёрна в галактике.;Для вас — только лучшие напитки.;М-м-м-м… Ничто не сравнится с кофе.;Я люблю кофе, а вы?;Кофе помогает работать!;Возьмите немного чайку.;Надеемся, вы предпочитаете лучшее!;Отведайте наш новый шоколад!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	panel_type = "panel9"
	products = list(
		/obj/item/reagent_containers/cup/glass/coffee = 6,
		/obj/item/reagent_containers/cup/glass/mug/tea = 6,
		/obj/item/reagent_containers/cup/glass/mug/coco = 3,
	)
	contraband = list(
		/obj/item/reagent_containers/cup/glass/ice = 12,
	)
	refill_canister = /obj/item/vending_refill/coffee
	default_price = PAYCHECK_LOWER
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SRV
	light_mask = "coffee-light-mask"
	light_color = COLOR_DARK_MODERATE_ORANGE

/obj/machinery/vending/coffee/Initialize(mapload)
	. = ..()
	if(!mapload || !is_station_level(z) || !HAS_TRAIT(SSstation, STATION_TRAIT_VENDING_SHORTAGE))
		return

	for(var/datum/data/vending_product/product_record as anything in product_records + coin_records + hidden_records)
		product_record.amount = 0
		credits_contained += rand(1, 5)

/obj/item/vending_refill/coffee
	machine_name = "Solar's Best Hot Drinks"
	icon_state = "refill_joe"
