/obj/item/food/station_food/smetana
	name = "sour cream"
	desc = "Густая сметана с мягким сливочным вкусом и лёгкой кислинкой."
	icon_state = "smetana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = DAIRY
	crafting_complexity = FOOD_COMPLEXITY_2
	tastes = list("сливочная кислинка" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_porridge
	name = "cottage cheese porridge"
	desc = "Мягкий творог, смешанный со сметаной и сахаром до нежной консистенции."
	icon_state = "tvorog_porridge"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("творог" = 2, "сметана и сахар" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_pumpkin
	name = "cottage cheese with pumpkin"
	desc = "Творог с тыквой. Мягкая овощная добавка придаёт блюду сладковатый вкус."
	icon_state = "tvorog_pumpkin"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("творог" = 2, "тыква" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_chocolate
	name = "cottage cheese with chocolate"
	desc = "Творожный десерт с шоколадом. Сочетание лёгкой кислинки и насыщенной шоколадной сладости."
	icon_state = "tvorog_chocolate"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/sugar = 7,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("творог" = 2, "шоколад" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_orange
	name = "cottage cheese with orange"
	desc = "Творог с сочным апельсином. Цитрус добавляет свежий аромат и кисло-сладкий вкус."
	icon_state = "tvorog_orange"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|FRUIT|ORANGES
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("творог" = 2, "апельсин" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_cherry
	name = "cottage cheese with cherry"
	desc = "Творог с вишней. Сочные ягоды придают десерту выраженную кислинку."
	icon_state = "tvorog_cherry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/consumable/sugar = 7,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("творог" = 2, "вишня" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/condensed_milk
	name = "condensed milk"
	desc = "Густое сладкое сгущённое молоко со сливочным вкусом. Подходит к блинам, сырникам и выпечке."
	icon_state = "condensed_milk"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сладкое молоко" = 2, "сливки" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_fruit
	name = "cottage cheese with fruit"
	desc = "Творожный десерт с цитрусовыми и ягодами. Сочная фруктовая добавка дополняет мягкую основу."
	icon_state = "tvorog_fruit"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/consumable/sugar = 7,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|FRUIT|ORANGES
	crafting_complexity = FOOD_COMPLEXITY_4
	tastes = list("творог" = 2, "цитрусовые и ягоды" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_banana
	name = "cottage cheese with banana"
	desc = "Творог с бананом. Мягкая фруктовая мякоть придаёт десерту сладость и густую текстуру."
	icon_state = "tvorog_banana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("творог" = 2, "банан" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_berries
	name = "cottage cheese with berries"
	desc = "Творог с ягодами. Лёгкая молочная кислинка сочетается с ягодной сладостью."
	icon_state = "tvorog_berries"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("творог" = 2, "ягоды" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_nuts_honey
	name = "cottage cheese with nuts and honey"
	desc = "Творожный десерт с орехами, мёдом и печеньем. Мягкая основа дополнена хрустящими кусочками."
	icon_state = "tvorog_nuts_honey"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/sugar = 7,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/honey = 5,
	)
	foodtypes = DAIRY|SUGAR|NUTS|GRAIN
	crafting_complexity = FOOD_COMPLEXITY_4
	tastes = list("творог" = 2, "орехи и мёд" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog_apple_berries
	name = "cottage cheese with apple and berries"
	desc = "Творог с яблоком и ягодами. Сочная начинка добавляет свежий кисло-сладкий вкус."
	icon_state = "tvorog_apple_berries"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|FRUIT|NUTS
	crafting_complexity = FOOD_COMPLEXITY_4
	tastes = list("творог" = 2, "яблоко и ягоды" = 1)
	trash_type = /obj/item/plate

/obj/item/food/station_food/tvorog
	name = "cottage cheese"
	desc = "Мягкий зернистый творог с характерным кисломолочным вкусом. Основа для десертов и выпечки."
	icon_state = "tvorog"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY
	crafting_complexity = FOOD_COMPLEXITY_2
	tastes = list("свежий творог" = 2, "молочная кислинка" = 1)

/obj/item/food/station_food/tvorog/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	. = ..()
	if(!istype(current_recipe, /datum/crafting_recipe/food/station_food/tvorog))
		return
	reagents.remove_reagent(/datum/reagent/consumable/cream, 5)
	reagents.remove_reagent(/datum/reagent/toxin/bad_food, 2)
	reagents.add_reagent_list(food_reagents)

/obj/item/food/station_food/sochnik
	food_flags = FOOD_FINGER_FOOD
	name = "cottage cheese pastry"
	desc = "Сочник из рассыпчатого теста с мягкой творожной начинкой, сложенный в форме полумесяца."
	icon_state = "sochnik"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = DAIRY|SUGAR|GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2
	tastes = list("песочное тесто" = 2, "сладкая творожная начинка" = 1)

/obj/item/food/station_food/sochnik_raw
	name = "raw cottage cheese pastry"
	desc = "Сложенная пополам заготовка из песочного теста с творожной начинкой. Готова к выпечке."
	icon_state = "sochnik_raw"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = DAIRY|SUGAR|GRAIN|RAW
	crafting_complexity = FOOD_COMPLEXITY_2
	tastes = list("сырое творожное тесто" = 1)
	foodtypes_removed_when_cooked = RAW

/obj/item/food/station_food/sochnik_raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/station_food/sochnik, rand(30 SECONDS, 40 SECONDS), TRUE, TRUE)
