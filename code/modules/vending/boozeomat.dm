/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"
	panel_type = "panel22"

	product_categories = list(
		list(
			"name" = "Alcoholic",
			"icon" = "wine-bottle",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/bottle/curacao = 5,
				/obj/item/reagent_containers/cup/glass/bottle/applejack = 5,
				/obj/item/reagent_containers/cup/glass/bottle/wine_voltaic = 5,
				/obj/item/reagent_containers/cup/glass/bottle/tequila = 5,
				/obj/item/reagent_containers/cup/glass/bottle/rum = 5,
				/obj/item/reagent_containers/cup/glass/bottle/cognac = 5,
				/obj/item/reagent_containers/cup/glass/bottle/wine = 5,
				/obj/item/reagent_containers/cup/glass/bottle/absinthe = 5,
				/obj/item/reagent_containers/cup/glass/bottle/vermouth = 5,
				/obj/item/reagent_containers/cup/glass/bottle/gin = 5,
				/obj/item/reagent_containers/cup/glass/bottle/grenadine = 4,
				/obj/item/reagent_containers/cup/glass/bottle/hcider = 5,
				/obj/item/reagent_containers/cup/glass/bottle/amaretto = 5,
				/obj/item/reagent_containers/cup/glass/bottle/ale = 6,
				/obj/item/reagent_containers/cup/glass/bottle/grappa = 5,
				/obj/item/reagent_containers/cup/glass/bottle/navy_rum = 5,
				/obj/item/reagent_containers/cup/glass/bottle/maltliquor = 6,
				/obj/item/reagent_containers/cup/glass/bottle/kahlua = 5,
				/obj/item/reagent_containers/cup/glass/bottle/sake = 5,
				/obj/item/reagent_containers/cup/glass/bottle/beer = 6,
				/obj/item/reagent_containers/cup/glass/bottle/vodka = 5,
				/obj/item/reagent_containers/cup/glass/bottle/whiskey = 5,
				/obj/item/reagent_containers/cup/glass/bottle/coconut_rum = 5,
				/obj/item/reagent_containers/cup/glass/bottle/yuyake = 5,
				/obj/item/reagent_containers/cup/glass/bottle/shochu = 5,
				/obj/item/reagent_containers/cup/soda_cans/beer = 10,
				/obj/item/reagent_containers/cup/soda_cans/beer/rice = 10,
			),
		),

		list(
			"name" = "Non-Alcoholic",
			"icon" = "bottle-water",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/ice = 10,
				/obj/item/reagent_containers/cup/glass/bottle/juice/limejuice = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/menthol = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/cream = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice = 4,
				/obj/item/reagent_containers/cup/soda_cans/sodawater = 15,
				/obj/item/reagent_containers/cup/soda_cans/sol_dry = 8,
				/obj/item/reagent_containers/cup/soda_cans/cola = 8,
				/obj/item/reagent_containers/cup/soda_cans/tonic = 8,
				/obj/item/reagent_containers/cup/glass/bottle/hakka_mate = 5,
				/obj/item/reagent_containers/cup/soda_cans/melon_soda = 5,
			),
		),

		list(
			"name" = "Glassware",
			"icon" = "wine-glass",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/drinkingglass = 30,
				/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass = 12,
				/obj/item/reagent_containers/cup/glass/flask = 3,
				/obj/item/reagent_containers/cup/glass/bottle = 15,
				/obj/item/reagent_containers/cup/glass/bottle/small = 15,
			),
		),
	)

	contraband = list(
		/obj/item/reagent_containers/cup/glass/mug/tea = 12,
		/obj/item/reagent_containers/cup/glass/bottle/fernet = 5,
	)
	premium = list(
		/obj/item/reagent_containers/cup/bottle/ethanol = 4,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 5,
		/obj/item/reagent_containers/cup/glass/bottle/trappist = 5,
		/obj/item/reagent_containers/cup/glass/bottle/bitters = 5,
	)

	product_slogans = "Надеюсь, никто не попросит меня о чёртовой кружке чая...;Алкоголь - друг человека. Вы же не бросите друга?;Очень рад вас обслужить!;Никто на этой станции не хочет выпить?"
	product_ads = "Выпьем!;Бухло пойдёт вам на пользу!;Алкоголь - друг человека.;Очень рад вас обслужить!;Хотите отличного холодного пива?;Ничто так не лечит, как бухло!;Пригубите!;Выпейте!;Возьмите пивка!;Пиво пойдёт вам на пользу!;Только лучший алкоголь!;Бухло лучшего качества с 2053 года!;Вино со множеством наград!;Максимум алкоголя!;Твоё любимое пиво.;Тост: «За прогресс!»"
	refill_canister = /obj/item/vending_refill/boozeomat
	default_price = PAYCHECK_CREW * 0.9
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SRV
	light_mask = "boozeomat-light-mask"

/obj/machinery/vending/boozeomat/syndicate
	age_restrictions = FALSE
	initial_language_holder = /datum/language_holder/syndicate

/obj/item/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
