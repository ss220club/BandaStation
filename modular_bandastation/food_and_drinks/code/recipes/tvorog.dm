/datum/crafting_recipe/food/station_food/smetana
	name = "Сметана"
	reqs = list(
		/datum/reagent/consumable/cream = 10,
		/obj/item/plate = 1,
		/datum/reagent/consumable/yoghurt = 5,
	)
	result = /obj/item/food/station_food/smetana
	added_foodtypes = DAIRY
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/station_food/sochnik_raw
	name = "Сочник сырой"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/station_food/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/station_food/sochnik_raw
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/station_food/tvorog_porridge
	name = "Творог каша"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_porridge
	added_foodtypes = SUGAR
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/tvorog_pumpkin
	name = "Творог с тыквой"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/pumpkin = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_pumpkin
	added_foodtypes = SUGAR
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/tvorog_chocolate
	name = "Творог с шоколадом"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/chocolatebar = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_chocolate
	removed_foodtypes = JUNKFOOD
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorog_orange
	name = "Творог с апельсином"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/citrus/orange = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_orange
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorog_cherry
	name = "Творог с вишней"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/cherries = 1,
		/obj/item/food/chocolatebar = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_cherry
	removed_foodtypes = JUNKFOOD
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/condensed_milk
	name = "Сгущенка"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 15,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/condensed_milk
	added_foodtypes = DAIRY|SUGAR
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/station_food/tvorog_fruit
	name = "Творог с фруктами"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/citrus/lemon = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/food/grown/citrus/orange = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_fruit
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorog_banana
	name = "Творог с бананом"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/banana = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_banana
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorog_berries
	name = "Творог с ягодами"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/berries = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_berries
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorog_nuts_honey
	name = "Творог с орехами и медом"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/korta_nut = 1,
		/obj/item/food/station_food/cookie/cooked = 1,
		/datum/reagent/consumable/honey = 5,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_nuts_honey
	unit_test_spawn_extras = list(
		/obj/item/food/station_food/cookie/cooked/plain/round = 1,
	)
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorog_apple_berries
	name = "Творог с яблоком и ягодами"
	reqs = list(
		/obj/item/food/station_food/tvorog = 1,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/apple = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/food/grown/korta_nut = 1,
		/obj/item/plate = 1,
	)
	result = /obj/item/food/station_food/tvorog_apple_berries
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorog
	name = "Творог"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/obj/item/rag = 1,
		/datum/reagent/toxin/bad_food = 2,
	)
	result = /obj/item/food/station_food/tvorog
	added_foodtypes = DAIRY
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/oven/station_food_sochnik
	name = "Сочник"
	reqs = list(/obj/item/food/station_food/sochnik_raw = 1)
	result = /obj/item/food/station_food/sochnik
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT
