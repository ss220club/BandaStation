/datum/crafting_recipe/food/slavic/syrnik_raw
	name = "Сырой сырник"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/egg = 1,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sugar = 5,
	)
	result = /obj/item/food/slavic/syrnik/raw
	added_foodtypes = SUGAR|RAW
	removed_foodtypes = MEAT|EGG
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/syrnik_honey
	name = "Сырники с медом"
	reqs = list(
		/obj/item/food/slavic/syrnik/cooked = 3,
		/datum/reagent/consumable/honey = 5,
	)
	result = /obj/item/food/slavic/syrnik/serving/honey
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/syrnik_berries
	name = "Сырники с ягодами"
	reqs = list(
		/obj/item/food/slavic/syrnik/cooked = 3,
		/datum/reagent/consumable/berryjuice = 5,
	)
	result = /obj/item/food/slavic/syrnik/serving/berries
	added_foodtypes = FRUIT
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/syrnik_chocolate
	name = "Сырники с шоколадом"
	reqs = list(
		/obj/item/food/slavic/syrnik/cooked = 3,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/syrnik/serving/chocolate
	removed_foodtypes = JUNKFOOD
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/syrnik_condensed_milk
	name = "Сырники со сгущенкой"
	reqs = list(
		/obj/item/food/slavic/syrnik/cooked = 3,
		/obj/item/food/slavic/condensed_milk = 1,
	)
	result = /obj/item/food/slavic/syrnik/serving/condensed_milk
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/syrnik_smetana
	name = "Сырники со сметаной"
	reqs = list(
		/obj/item/food/slavic/syrnik/cooked = 3,
		/obj/item/food/slavic/smetana = 1,
	)
	result = /obj/item/food/slavic/syrnik/serving/smetana
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/syrnik_peanut
	name = "Сырники с арахисовой пастой"
	reqs = list(
		/obj/item/food/slavic/syrnik/cooked = 3,
		/datum/reagent/consumable/peanut_butter = 5,
	)
	result = /obj/item/food/slavic/syrnik/serving/peanut
	added_foodtypes = NUTS
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/grill/slavic_syrnik
	name = "Сырник"
	reqs = list(/obj/item/food/slavic/syrnik/raw = 1)
	result = /obj/item/food/slavic/syrnik/cooked
	dish_category = DISH_PASTRY
	meal_category = MEAL_BREAKFAST
