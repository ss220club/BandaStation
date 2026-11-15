/obj/item/food/station_food/syrnik
	abstract_type = /obj/item/food/station_food/syrnik
	foodtypes = DAIRY|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/station_food/syrnik/cooked
	food_flags = FOOD_FINGER_FOOD
	name = "syrnik"
	desc = "Обжаренный сырник с золотистой корочкой и мягкой творожной серединой."
	icon_state = "syrnik"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("обжаренный творог" = 2)

/obj/item/food/station_food/syrnik/raw
	name = "raw syrnik"
	desc = "Небольшая заготовка из сладкой творожной массы. Перед подачей её нужно обжарить."
	icon_state = "syrnik_raw"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = DAIRY|SUGAR|RAW
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сырой творог" = 2, "тесто" = 1)
	foodtypes_removed_when_cooked = RAW

/obj/item/food/station_food/syrnik/serving
	abstract_type = /obj/item/food/station_food/syrnik/serving
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/station_food/syrnik/serving/honey
	name = "syrniki with honey"
	desc = "Порция румяных сырников с густым мёдом и нежной творожной серединой."
	icon_state = "syrnik_honey"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/honey = 5,
	)
	tastes = list("обжаренный творог" = 2, "мёд" = 1)

/obj/item/food/station_food/syrnik/serving/berries
	name = "syrniki with berries"
	desc = "Сырники с ягодами. Кисло-сладкий сок дополняет мягкий творожный вкус."
	icon_state = "syrnik_berries"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/sugar = 9,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/berryjuice = 5,
	)
	foodtypes = DAIRY|SUGAR|FRUIT
	tastes = list("обжаренный творог" = 2, "ягоды" = 1)

/obj/item/food/station_food/syrnik/serving/chocolate
	name = "syrniki with chocolate"
	desc = "Румяные сырники с шоколадом. Сладкое покрытие сочетается с нежной творожной основой."
	icon_state = "syrnik_chocolate"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/sugar = 12,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("обжаренный творог" = 2, "шоколад" = 1)

/obj/item/food/station_food/syrnik/serving/condensed_milk
	name = "syrniki with condensed milk"
	desc = "Сырники со сгущённым молоком. Густая сладкая подливка покрывает золотистую корочку."
	icon_state = "syrnik_condmilk"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/sugar = 12,
		/datum/reagent/consumable/nutriment/protein = 8,
	)
	tastes = list("обжаренный творог" = 2, "сгущённое молоко" = 1)

/obj/item/food/station_food/syrnik/serving/smetana
	name = "syrniki with sour cream"
	desc = "Сырники с густой сметаной. Её лёгкая кислинка уравновешивает сладость творожного теста."
	icon_state = "syrnik_smetana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/sugar = 9,
		/datum/reagent/consumable/nutriment/protein = 10,
	)
	tastes = list("обжаренный творог" = 2, "сметана" = 1)

/obj/item/food/station_food/syrnik/serving/peanut
	name = "syrniki with peanut butter"
	desc = "Сырники с арахисовой пастой. Плотное ореховое дополнение к мягкой творожной основе."
	icon_state = "syrnik_peanut"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/sugar = 9,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/peanut_butter = 5,
	)
	foodtypes = DAIRY|SUGAR|NUTS
	tastes = list("обжаренный творог" = 2, "арахисовая паста" = 1)

/obj/item/food/station_food/syrnik/raw/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/station_food/syrnik/cooked, rand(30 SECONDS, 40 SECONDS), TRUE, TRUE)
