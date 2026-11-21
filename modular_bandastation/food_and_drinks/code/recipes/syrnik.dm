/datum/crafting_recipe/food/station_food/syrnik_raw
	name = "Сырой сырник"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/egg = 1,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sugar = 5,
	)
	result = /obj/item/food/station_food/syrnik/raw
	added_foodtypes = SUGAR|RAW
	removed_foodtypes = MEAT|EGG
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/syrnik_honey
	name = "Сырники с медом"
	reqs = list(
		/obj/item/food/station_food/syrnik/cooked = 3,
		/datum/reagent/consumable/honey = 5,
	)
	result = /obj/item/food/station_food/syrnik/serving/honey
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/syrnik_berries
	name = "Сырники с ягодами"
	reqs = list(
		/obj/item/food/station_food/syrnik/cooked = 3,
		/datum/reagent/consumable/berryjuice = 5,
	)
	result = /obj/item/food/station_food/syrnik/serving/berries
	added_foodtypes = FRUIT
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/syrnik_chocolate
	name = "Сырники с шоколадом"
	reqs = list(
		/obj/item/food/station_food/syrnik/cooked = 3,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/station_food/syrnik/serving/chocolate
	removed_foodtypes = JUNKFOOD
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/syrnik_condensed_milk
	name = "Сырники со сгущенкой"
	reqs = list(
		/obj/item/food/station_food/syrnik/cooked = 3,
		/obj/item/food/station_food/condensed_milk = 1,
	)
	result = /obj/item/food/station_food/syrnik/serving/condensed_milk
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/syrnik_smetana
	name = "Сырники со сметаной"
	reqs = list(
		/obj/item/food/station_food/syrnik/cooked = 3,
		/obj/item/food/station_food/smetana = 1,
	)
	result = /obj/item/food/station_food/syrnik/serving/smetana
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/syrnik_peanut
	name = "Сырники с арахисовой пастой"
	reqs = list(
		/obj/item/food/station_food/syrnik/cooked = 3,
		/datum/reagent/consumable/peanut_butter = 5,
	)
	result = /obj/item/food/station_food/syrnik/serving/peanut
	added_foodtypes = NUTS
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/grill/station_food_syrnik
	name = "Сырник"
	reqs = list(/obj/item/food/station_food/syrnik/raw = 1)
	result = /obj/item/food/station_food/syrnik/cooked
	dish_category = DISH_PASTRY
	meal_category = MEAL_BREAKFAST
