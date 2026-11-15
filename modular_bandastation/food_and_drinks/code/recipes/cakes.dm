/datum/crafting_recipe/food/station_food/smetannik_choco_raw
	name = "Сметанник шоколадный сырой"
	reqs = list(
		/obj/item/food/station_food/smetana = 1,
		/obj/item/food/egg = 2,
		/datum/reagent/consumable/sugar = 10,
		/obj/item/food/station_food/choco_shortbread_dough_flat = 1,
	)
	result = /obj/item/food/station_food/smetannik_choco_raw
	removed_foodtypes = MEAT|EGG
	dish_category = DISH_CAKE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/station_food/smetannik_raw
	name = "Сметанник сырой"
	reqs = list(
		/obj/item/food/station_food/smetana = 1,
		/obj/item/food/egg = 2,
		/datum/reagent/consumable/sugar = 10,
		/obj/item/food/station_food/shortbread_dough_flat = 1,
	)
	result = /obj/item/food/station_food/smetannik_raw
	removed_foodtypes = MEAT|EGG
	dish_category = DISH_CAKE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/station_food/blini_cake
	name = "Блинный торт"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/station_food/smetana = 1,
		/datum/reagent/consumable/sugar = 15,
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/grown/berries = 1,
	)
	result = /obj/item/food/station_food/blini_cake
	removed_foodtypes = BREAKFAST|JUNKFOOD
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/meat_blini_pie
	name = "Мясно-блинный пирог"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 5,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/onion_slice = 6,
		/obj/item/food/meat/steak/plain = 1,
		/datum/reagent/consumable/ketchup = 10,
	)
	result = /obj/item/food/station_food/meat_blini_pie
	added_foodtypes = SUGAR
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/tvorozhnik_berries
	name = "Творожник с ягодами"
	reqs = list(
		/obj/item/food/cake/slavic/tvorozhnik = 1,
		/obj/item/food/grown/berries = 1,
	)
	result = /obj/item/food/cake/slavic/tvorozhnik_berries
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorozhnik_condensed_milk
	name = "Творожник со сгущенкой"
	reqs = list(
		/obj/item/food/cake/slavic/tvorozhnik = 1,
		/obj/item/food/station_food/condensed_milk = 1,
	)
	result = /obj/item/food/cake/slavic/tvorozhnik_condensed_milk
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorozhnik_berry_smetana
	name = "Творожник с ягодами и сметаной"
	reqs = list(
		/obj/item/food/cake/slavic/tvorozhnik = 1,
		/obj/item/food/station_food/smetana = 1,
		/obj/item/food/grown/berries = 1,
	)
	result = /obj/item/food/cake/slavic/tvorozhnik_berry_smetana
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/tvorozhnik_raw
	name = "Сырой творожник"
	reqs = list(
		/obj/item/food/station_food/tvorog = 2,
		/obj/item/food/station_food/smetana = 2,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/egg = 1,
		/datum/reagent/consumable/flour = 5,
	)
	result = /obj/item/food/station_food/tvorozhnik_raw
	added_foodtypes = SUGAR|GRAIN
	removed_foodtypes = MEAT|EGG
	dish_category = DISH_CAKE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/oven/station_food_smetannik_choco
	name = "Сметанник шоколадный"
	reqs = list(/obj/item/food/station_food/smetannik_choco_raw = 1)
	result = /obj/item/food/cake/slavic/smetannik_choco
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/station_food_smetannik_choco_slice
	name = "Кусок шоколадного сметанника"
	reqs = list(/obj/item/food/cake/slavic/smetannik_choco = 1)
	result = /obj/item/food/cakeslice/slavic/smetannik_choco
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/oven/station_food_smetannik
	name = "Сметанник"
	reqs = list(/obj/item/food/station_food/smetannik_raw = 1)
	result = /obj/item/food/cake/slavic/smetannik
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/station_food_smetannik_slice
	name = "Кусок сметанника"
	reqs = list(/obj/item/food/cake/slavic/smetannik = 1)
	result = /obj/item/food/cakeslice/slavic/smetannik
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/station_food_tvorozhnik_slice
	name = "Кусок творожника"
	reqs = list(/obj/item/food/cake/slavic/tvorozhnik = 1)
	result = /obj/item/food/cakeslice/slavic/tvorozhnik
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/station_food_tvorozhnik_berries_slice
	name = "Кусок творожника с ягодами"
	reqs = list(/obj/item/food/cake/slavic/tvorozhnik_berries = 1)
	result = /obj/item/food/cakeslice/slavic/tvorozhnik_berries
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/station_food_tvorozhnik_condensed_milk_slice
	name = "Кусок творожника со сгущенкой"
	reqs = list(/obj/item/food/cake/slavic/tvorozhnik_condensed_milk = 1)
	result = /obj/item/food/cakeslice/slavic/tvorozhnik_condensed_milk
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/station_food_tvorozhnik_berry_smetana_slice
	name = "Кусок творожника с ягодами и сметаной"
	reqs = list(/obj/item/food/cake/slavic/tvorozhnik_berry_smetana = 1)
	result = /obj/item/food/cakeslice/slavic/tvorozhnik_berry_smetana
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/oven/station_food_tvorozhnik
	name = "Творожник"
	reqs = list(/obj/item/food/station_food/tvorozhnik_raw = 1)
	result = /obj/item/food/cake/slavic/tvorozhnik
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT
