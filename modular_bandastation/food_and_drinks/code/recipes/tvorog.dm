/datum/crafting_recipe/food/slavic/smetana
	name = "Сметана"
	reqs = list(
		/datum/reagent/consumable/cream = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/datum/reagent/consumable/yoghurt = 5,
	)
	result = /obj/item/food/slavic/smetana
	added_foodtypes = DAIRY
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/sochnik_raw
	name = "Сочник сырой"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/sochnik_raw
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/tvorog_porridge
	name = "Творог каша"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
	)
	result = /obj/item/food/slavic/tvorog_porridge
	added_foodtypes = SUGAR
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/tvorog_pumpkin
	name = "Творог с тыквой"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/pumpkin = 1,
	)
	result = /obj/item/food/slavic/tvorog_pumpkin
	added_foodtypes = SUGAR
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/slavic/tvorog_chocolate
	name = "Творог с шоколадом"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/tvorog_chocolate
	removed_foodtypes = JUNKFOOD
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/tvorog_orange
	name = "Творог с апельсином"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/citrus/orange = 1,
	)
	result = /obj/item/food/slavic/tvorog_orange
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/tvorog_cherry
	name = "Творог с вишней"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/cherries = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/tvorog_cherry
	removed_foodtypes = JUNKFOOD
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/condensed_milk
	name = "Сгущенка"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 15,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/slavic/condensed_milk
	added_foodtypes = DAIRY|SUGAR
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/tvorog_fruit
	name = "Творог с фруктами"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/citrus/lemon = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/food/grown/citrus/orange = 1,
	)
	result = /obj/item/food/slavic/tvorog_fruit
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/tvorog_banana
	name = "Творог с бананом"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/banana = 1,
	)
	result = /obj/item/food/slavic/tvorog_banana
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/tvorog_berries
	name = "Творог с ягодами"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/berries = 1,
	)
	result = /obj/item/food/slavic/tvorog_berries
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/tvorog_nuts_honey
	name = "Творог с орехами и медом"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/korta_nut = 1,
		/obj/item/food/slavic/cookie/cooked = 1,
		/datum/reagent/consumable/honey = 5,
	)
	result = /obj/item/food/slavic/tvorog_nuts_honey
	unit_test_spawn_extras = list(
		/obj/item/food/slavic/cookie/cooked/plain/round = 1,
	)
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/tvorog_apple_berries
	name = "Творог с яблоком и ягодами"
	reqs = list(
		/obj/item/food/slavic/tvorog = 1,
		/obj/item/food/slavic/smetana = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/grown/apple = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/food/grown/korta_nut = 1,
	)
	result = /obj/item/food/slavic/tvorog_apple_berries
	added_foodtypes = SUGAR
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slavic/tvorog
	name = "Творог"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/toxin/bad_food = 2,
	)
	result = /obj/item/food/slavic/tvorog
	tool_paths = list(/obj/item/stack/sheet/cloth)
	added_foodtypes = DAIRY
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/oven/slavic_sochnik
	name = "Сочник"
	reqs = list(/obj/item/food/slavic/sochnik_raw = 1)
	result = /obj/item/food/slavic/sochnik
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT
